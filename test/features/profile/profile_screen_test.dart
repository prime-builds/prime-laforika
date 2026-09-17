import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/router/app_router.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/settings/settings.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_profile_repository.dart';
import '../../support/test_prefs.dart';

class _Gateway implements AuthSessionGateway {
  _Gateway(this._hydrate);

  final AuthState _hydrate;
  String? _accessToken;

  @override
  String? get accessToken => _accessToken;

  @override
  Future<AuthPrincipal> acceptCredentials({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  }) async {
    _accessToken = accessToken;
    return principal;
  }

  @override
  Future<void> clearLocalSession() async {
    _accessToken = null;
  }

  @override
  Future<AuthState> hydrate() async => _hydrate;

  @override
  Future<Result<void>> logoutAll() async => const Success(null);

  @override
  Future<Result<void>> logoutCurrent() async {
    _accessToken = null;
    return const Success(null);
  }

  @override
  Future<Result<String>> refreshAccessToken() async =>
      const FailureResult(AuthFailure(code: 'AUTH_NO_REFRESH'));
}

const _config = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: 'http://10.0.2.2:3000/v1',
  logLevel: AppLogLevel.debug,
  featureFlags: <String, bool>{},
);

const _principal = AuthPrincipal(accountId: 'acc-profile');

const _profile = ProfileDto(
  accountId: 'acc-profile',
  phone: '+989121234567',
  phoneVerified: true,
  firstName: 'علی',
  lastName: 'محمدی',
  email: 'Contact@Example.com',
  emailVerified: true,
);

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required AuthState hydrate,
  FakeProfileRepository? profileRepository,
  FakeAuthRepository? authRepository,
  Size? physicalSize,
  double textScale = 1.0,
}) async {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  if (physicalSize != null) {
    tester.view.physicalSize = physicalSize;
    tester.view.devicePixelRatio = 1.0;
  }
  tester.platformDispatcher.textScaleFactorTestValue = textScale;

  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authSessionGatewayProvider.overrideWithValue(_Gateway(hydrate)),
        testPrefsOverride(),
        if (profileRepository != null)
          profileRepositoryProvider.overrideWithValue(profileRepository),
        if (authRepository != null)
          authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          return const LaforikaApp();
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guest Profile shows direct phone OTP without chooser', (
    tester,
  ) async {
    final container = await _pumpApp(
      tester,
      hydrate: const AuthUnauthenticated(),
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.byKey(const Key('profile_screen')), findsOneWidget);
    expect(container.read(goRouterProvider).state.uri.path, profileRoutePath);
    expect(find.byKey(const Key('profile_guest_auth')), findsOneWidget);
    expect(find.text(l10n.profileGuestIntro), findsOneWidget);
    expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
    expect(find.byKey(const Key('profile_logout')), findsNothing);
    expect(find.byKey(const Key('profile_account_security')), findsNothing);
    expect(find.byKey(const Key('profile_header_settings')), findsOneWidget);
    expect(
      find.byKey(const Key('profile_header_notifications')),
      findsOneWidget,
    );
    expect(find.textContaining('رمز'), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_header_settings')));
    await tester.pumpAndSettle();
    expect(container.read(goRouterProvider).state.uri.path, settingsRoutePath);
  });

  testWidgets('authenticated Profile loads editor and supports save/logout', (
    tester,
  ) async {
    final profileRepo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchDelay = const Duration(milliseconds: 100)
      ..patchResult = const Success(
        ProfileDto(
          accountId: 'acc-profile',
          phone: '+989121234567',
          phoneVerified: true,
          firstName: 'رضا',
          lastName: 'محمدی',
          email: 'Contact@Example.com',
          emailVerified: true,
        ),
      );
    final authRepo = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'acc-profile'))
      ..sessionsResult = const Success(<SessionDto>[]);

    final container = await _pumpApp(
      tester,
      hydrate: const AuthAuthenticated(_principal),
      profileRepository: profileRepo,
      authRepository: authRepo,
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.byKey(const Key('profile_first_name')), findsOneWidget);
    expect(container.read(goRouterProvider).state.uri.path, profileRoutePath);
    expect(find.text('علی'), findsOneWidget);
    expect(find.byKey(const Key('profile_phone')), findsOneWidget);
    expect(find.byKey(const Key('profile_save')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('profile_first_name')), 'رضا');
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.profileSaved), findsOneWidget);
    expect(profileRepo.patchCalls, 1);

    final editorList = find.ancestor(
      of: find.byKey(const Key('profile_first_name')),
      matching: find.byType(ListView),
    );
    await tester.drag(editorList, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_logout')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_guest_auth')), findsOneWidget);
    expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
  });

  testWidgets('load failure shows retry; 320dp and textScale 2.0', (
    tester,
  ) async {
    final profileRepo = FakeProfileRepository()
      ..getResult = const FailureResult(NetworkFailure());
    final container = await _pumpApp(
      tester,
      hydrate: const AuthAuthenticated(_principal),
      profileRepository: profileRepo,
      physicalSize: const Size(320, 568),
      textScale: 2.0,
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.text(l10n.profileErrorNetwork), findsOneWidget);
    expect(find.text(l10n.profileRetry), findsOneWidget);
    expect(tester.takeException(), isNull);

    profileRepo.getResult = const Success(_profile);
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.profileRetry),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_first_name')), findsOneWidget);
  });

  testWidgets(
    'guest Profile shows direct phone OTP at 320dp and textScale 2.0 without overflow',
    (tester) async {
      final container = await _pumpApp(
        tester,
        hydrate: const AuthUnauthenticated(),
        physicalSize: const Size(320, 568),
        textScale: 2.0,
      );
      container.read(goRouterProvider).go(profileRoutePath);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_guest_auth')), findsOneWidget);
      expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_phone_send')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'authenticated Profile editor at 320dp and textScale 2.0 scrolls and saves without overflow',
    (tester) async {
      final profileRepo = FakeProfileRepository()
        ..getResult = const Success(_profile);
      final container = await _pumpApp(
        tester,
        hydrate: const AuthAuthenticated(_principal),
        profileRepository: profileRepo,
        physicalSize: const Size(320, 568),
        textScale: 2.0,
      );
      container.read(goRouterProvider).go(profileRoutePath);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_first_name')), findsOneWidget);
      final editorList = find.ancestor(
        of: find.byKey(const Key('profile_first_name')),
        matching: find.byType(ListView),
      );
      await tester.drag(editorList, const Offset(0, -500));
      await tester.pumpAndSettle();
      final saveButton = find.byKey(const Key('profile_save'));
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Account Security opens focused protected screen', (
    tester,
  ) async {
    final profileRepo = FakeProfileRepository()
      ..getResult = const Success(_profile);
    final authRepo = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'acc-profile'))
      ..sessionsResult = const Success(<SessionDto>[]);
    final container = await _pumpApp(
      tester,
      hydrate: const AuthAuthenticated(_principal),
      profileRepository: profileRepo,
      authRepository: authRepo,
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();

    final editorList = find.ancestor(
      of: find.byKey(const Key('profile_first_name')),
      matching: find.byType(ListView),
    );
    await tester.drag(editorList, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_account_security')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account_security_screen')), findsOneWidget);
    expect(
      container.read(goRouterProvider).state.uri.path,
      accountSecurityRoutePath,
    );
    expect(find.byKey(const Key('shell_dock_profile')), findsNothing);
  });

  testWidgets('validation/conflict retains profile draft', (tester) async {
    final profileRepo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchResult = const FailureResult(
        ServerFailure(code: 'PROFILE_EMAIL_IN_USE'),
      );
    final container = await _pumpApp(
      tester,
      hydrate: const AuthAuthenticated(_principal),
      profileRepository: profileRepo,
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('profile_first_name')),
      List.filled(101, 'ن').join(),
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('profile_save')))
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byKey(const Key('profile_first_name')), 'علی');
    await tester.enterText(
      find.byKey(const Key('profile_email')),
      'taken@example.test',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.text(l10n.profileErrorEmailInUse), findsOneWidget);
    expect(find.text('taken@example.test'), findsOneWidget);
    expect(profileRepo.patchCalls, 1);
  });

  testWidgets('disables logout and Account Security while save is in flight', (
    tester,
  ) async {
    final profileRepo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchDelay = const Duration(milliseconds: 300)
      ..patchResult = const Success(
        ProfileDto(
          accountId: 'acc-profile',
          phone: '+989121234567',
          phoneVerified: true,
          firstName: 'رضا',
          lastName: 'محمدی',
          email: 'Contact@Example.com',
          emailVerified: true,
        ),
      );
    final container = await _pumpApp(
      tester,
      hydrate: const AuthAuthenticated(_principal),
      profileRepository: profileRepo,
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profile_first_name')), 'رضا');
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pump();

    final editorList = find.ancestor(
      of: find.byKey(const Key('profile_save')),
      matching: find.byType(ListView),
    );
    await tester.drag(editorList, const Offset(0, -500));
    await tester.pump();

    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const Key('profile_account_security')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('profile_logout')))
          .onPressed,
      isNull,
    );
    expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
    expect(find.byKey(const Key('profile_screen')), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('profile_logout')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('navigating away during save does not throw on completion', (
    tester,
  ) async {
    final profileRepo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchDelay = const Duration(milliseconds: 200)
      ..patchResult = const Success(
        ProfileDto(
          accountId: 'acc-profile',
          phone: '+989121234567',
          phoneVerified: true,
          firstName: 'رضا',
          lastName: 'محمدی',
          email: 'Contact@Example.com',
          emailVerified: true,
        ),
      );
    final container = await _pumpApp(
      tester,
      hydrate: const AuthAuthenticated(_principal),
      profileRepository: profileRepo,
    );
    container.read(goRouterProvider).go(profileRoutePath);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profile_first_name')), 'رضا');
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pump();

    // Dock Home remains available while save is in flight.
    await tester.tap(find.byKey(const Key('shell_dock_home')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
  });

  test('profile barrel constants', () {
    expect(profileRouteName, 'profile');
    expect(profileRoutePath, '/profile');
    expect(profilePublicPaths, <String>{profileRoutePath});
    expect(profileRegisteredPaths, <String>{profileRoutePath});
  });
}
