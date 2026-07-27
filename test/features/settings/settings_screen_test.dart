import 'dart:async';

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
import 'package:laforika/core/theme/app_appearance.dart';
import 'package:laforika/core/theme/app_appearance_controller.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/settings/settings.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/test_prefs.dart';

class _Gateway implements AuthSessionGateway {
  _Gateway(this._hydrate, {this.logoutDelay});

  AuthState _hydrate;
  String? _accessToken;
  final Completer<void>? logoutDelay;

  void setHydrate(AuthState next) => _hydrate = next;

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
    final delay = logoutDelay;
    if (delay != null) {
      await delay.future;
    }
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

Future<ProviderContainer> _pumpSettings(
  WidgetTester tester, {
  required AuthState hydrate,
  FakeAuthRepository? authRepository,
  Completer<void>? logoutDelay,
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
        authSessionGatewayProvider.overrideWithValue(
          _Gateway(hydrate, logoutDelay: logoutDelay),
        ),
        testPrefsOverride(),
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
  container.read(goRouterProvider).go(settingsRoutePath);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guest Settings shows Appearance and About without account', (
    tester,
  ) async {
    await _pumpSettings(tester, hydrate: const AuthUnauthenticated());
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    expect(find.text(l10n.settingsAppearanceSection), findsOneWidget);
    expect(find.byKey(const Key('settings_about')), findsOneWidget);
    expect(find.text(l10n.appTitle), findsWidgets);
    expect(find.byKey(const Key('settings_account_section')), findsNothing);
    expect(find.byKey(const Key('settings_logout')), findsNothing);
    expect(find.byKey(const Key('shell_dock_profile')), findsOneWidget);
    expect(find.byKey(const Key('shell_dock_home')), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    expect(find.byType(AdaptiveModuleStrip), findsNothing);
    expect(find.byType(ContextualTabStrip), findsNothing);
    expect(find.byKey(const Key('home_search_field')), findsNothing);

    final back = tester.widget<IconButton>(
      find.byKey(const Key('settings_back')),
    );
    expect(back.tooltip, l10n.settingsBack);
    final backSize = tester.getSize(find.byKey(const Key('settings_back')));
    expect(backSize.width, greaterThanOrEqualTo(AppTokens.minTouchTarget));
    expect(backSize.height, greaterThanOrEqualTo(AppTokens.minTouchTarget));
  });

  testWidgets('appearance selection cycles System Light Dark and System', (
    tester,
  ) async {
    final container = await _pumpSettings(
      tester,
      hydrate: const AuthUnauthenticated(),
    );
    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.system,
    );
    _expectAppearanceSelected(tester, AppAppearance.system);

    await tester.tap(find.byKey(const Key('settings_appearance_light')));
    await tester.pumpAndSettle();
    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.light,
    );
    _expectAppearanceSelected(tester, AppAppearance.light);

    await tester.tap(find.byKey(const Key('settings_appearance_dark')));
    await tester.pumpAndSettle();
    expect(container.read(appAppearanceControllerProvider), AppAppearance.dark);
    _expectAppearanceSelected(tester, AppAppearance.dark);

    await tester.tap(find.byKey(const Key('settings_appearance_system')));
    await tester.pumpAndSettle();
    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.system,
    );
    _expectAppearanceSelected(tester, AppAppearance.system);
  });

  testWidgets('authenticated Settings shows account and logout stays on page', (
    tester,
  ) async {
    final authRepo = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'acc-s'))
      ..sessionsResult = const Success(<SessionDto>[]);
    final container = await _pumpSettings(
      tester,
      hydrate: const AuthAuthenticated(AuthPrincipal(accountId: 'acc-s')),
      authRepository: authRepo,
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.byKey(const Key('settings_account_section')), findsOneWidget);
    expect(find.byKey(const Key('settings_account_security')), findsOneWidget);
    expect(find.byKey(const Key('settings_logout')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings_account_security')));
    await tester.pumpAndSettle();
    expect(
      container.read(goRouterProvider).state.uri.path,
      accountSecurityRoutePath,
    );

    container.read(goRouterProvider).go(settingsRoutePath);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings_logout')));
    await tester.pumpAndSettle();

    expect(container.read(goRouterProvider).state.uri.path, settingsRoutePath);
    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    expect(find.byKey(const Key('settings_account_section')), findsNothing);
    expect(find.text(l10n.settingsAppearanceSection), findsOneWidget);
    expect(find.byKey(const Key('settings_about')), findsOneWidget);
  });

  testWidgets('logout pending disables account actions', (tester) async {
    final logoutGate = Completer<void>();
    final authRepo = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'acc-s'))
      ..sessionsResult = const Success(<SessionDto>[]);
    await _pumpSettings(
      tester,
      hydrate: const AuthAuthenticated(AuthPrincipal(accountId: 'acc-s')),
      authRepository: authRepo,
      logoutDelay: logoutGate,
    );

    await tester.tap(find.byKey(const Key('settings_logout')));
    await tester.pump();

    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('settings_logout')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const Key('settings_account_security')),
          )
          .onPressed,
      isNull,
    );

    logoutGate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings_account_section')), findsNothing);
  });

  testWidgets('back returns to Profile; 320dp and textScale 2.0', (
    tester,
  ) async {
    final container = await _pumpSettings(
      tester,
      hydrate: const AuthUnauthenticated(),
      physicalSize: const Size(320, 640),
      textScale: 2.0,
    );
    await tester.tap(find.byKey(const Key('settings_back')));
    await tester.pumpAndSettle();
    expect(container.read(goRouterProvider).state.uri.path, profileRoutePath);
  });
}

void _expectAppearanceSelected(WidgetTester tester, AppAppearance selected) {
  final group = tester.widget<RadioGroup<AppAppearance>>(
    find.byType(RadioGroup<AppAppearance>),
  );
  expect(group.groupValue, selected);
}
