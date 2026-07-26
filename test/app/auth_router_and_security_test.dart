import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/test_prefs.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/router/app_router.dart';
import 'package:laforika/app/router/routes.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/utils/auth_utils.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/presentation/account_security_screen.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../support/fake_auth_repository.dart';

class _ControllableGateway implements AuthSessionGateway {
  _ControllableGateway(this._hydrate);

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
  Future<Result<void>> logoutCurrent() async => const Success(null);

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

const _principal = AuthPrincipal(accountId: 'acc-secure');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unknown startup shows loading without auth flash', (
    tester,
  ) async {
    final gateway = _ControllableGateway(const AuthUnknown());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: const LaforikaApp(),
      ),
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.authStartupLoading), findsOneWidget);
    expect(find.text(l10n.authPhoneTitle), findsNothing);
    expect(find.text(l10n.homeWelcomeTitle), findsNothing);
  });

  testWidgets('unauthenticated hydration lands on guest Home', (tester) async {
    final gateway = _ControllableGateway(const AuthUnauthenticated());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: const LaforikaApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
    expect(find.text(l10n.authPhoneTitle), findsNothing);
    expect(find.byKey(const Key('home_logout')), findsNothing);
  });

  testWidgets('authenticated hydration lands on Home', (tester) async {
    final gateway = _ControllableGateway(const AuthAuthenticated(_principal));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: const LaforikaApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
    expect(find.byKey(const Key('home_logout')), findsNothing);
    expect(find.text(l10n.authPhoneTitle), findsNothing);
  });

  testWidgets('guest protected Account Security redirects to phone auth', (
    tester,
  ) async {
    final gateway = _ControllableGateway(const AuthUnauthenticated());
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go(accountSecurityRoutePath);
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(router.state.uri.path, authRoutePath);
    expect(router.state.uri.queryParameters['from'], accountSecurityRoutePath);
    expect(find.text(l10n.authPhoneTitle), findsOneWidget);
  });

  testWidgets('canonical /auth shows phone OTP directly', (tester) async {
    final gateway = _ControllableGateway(const AuthUnauthenticated());
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go(authRoutePath);
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.authPhoneTitle), findsOneWidget);
    expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
  });

  testWidgets('OTP acceptance resumes protected Account Security', (
    tester,
  ) async {
    final gateway = _ControllableGateway(const AuthUnauthenticated());
    final repository = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'acc-secure'))
      ..sessionsResult = const Success(<SessionDto>[]);
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go(
      '$authRoutePath?from=${Uri.encodeComponent(accountSecurityRoutePath)}',
    );
    await tester.pumpAndSettle();

    await container
        .read(authControllerProvider.notifier)
        .onCredentialsAccepted(
          accessToken: 'a',
          refreshToken: 'r',
          principal: _principal,
        );
    await tester.pumpAndSettle();

    expect(router.state.uri.path, accountSecurityRoutePath);
    expect(find.byKey(const Key('account_security_screen')), findsOneWidget);
  });

  testWidgets('authenticated /auth with invalid from falls back to Home', (
    tester,
  ) async {
    final gateway = _ControllableGateway(const AuthAuthenticated(_principal));
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go('$authRoutePath?from=${Uri.encodeComponent('/unknown')}');
    await tester.pumpAndSettle();

    expect(router.state.uri.path, homeRoutePath);
  });

  testWidgets('account security lists sessions without credential controls', (
    tester,
  ) async {
    final repository = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'acc-secure'))
      ..sessionsResult = const Success(<SessionDto>[
        SessionDto(
          sessionId: 's1',
          createdAt: '2026-01-01T00:00:00.000Z',
          lastSeenAt: '2026-01-01T00:00:00.000Z',
          isCurrent: true,
          deviceLabel: 'test',
        ),
      ]);

    final gateway = _ControllableGateway(const AuthAuthenticated(_principal));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          locale: Locale('fa', 'IR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AccountSecurityScreen(),
        ),
      ),
    );

    final element = tester.element(find.byType(AccountSecurityScreen));
    final container = ProviderScope.containerOf(element);
    await container
        .read(authControllerProvider.notifier)
        .onCredentialsAccepted(
          accessToken: 'a',
          refreshToken: 'r',
          principal: _principal,
        );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.accountSessionsTitle), findsOneWidget);
    expect(find.byKey(const Key('account_logout_current')), findsOneWidget);
    expect(find.byKey(const Key('account_logout_all')), findsOneWidget);
    expect(find.textContaining('رمز'), findsNothing);
    expect(find.textContaining('ایمیل'), findsNothing);
  });

  test('appRoutes and path registries aggregate auth, home, and profile', () {
    final routes = appRoutes();
    expect(routes, isNotEmpty);
    expect(appRegisteredPaths, contains(homeRoutePath));
    expect(appRegisteredPaths, contains(profileRoutePath));
    expect(appRegisteredPaths, contains(authRoutePath));
    expect(appRegisteredPaths, contains(accountSecurityRoutePath));
    expect(appPublicPaths, contains(homeRoutePath));
    expect(appPublicPaths, contains(profileRoutePath));
    expect(appProtectedPaths, contains(accountSecurityRoutePath));
    expect(appPublicPaths, isNot(contains(accountSecurityRoutePath)));
    expect(authOnlyPaths, equals(<String>{authRoutePath}));
    expect(appProtectedPaths, isNot(contains(profileRoutePath)));
    expect(authOnlyPaths, isNot(contains(profileRoutePath)));

    final names = <String>[];
    final paths = <String>[];
    void walk(List<RouteBase> bases) {
      for (final route in bases) {
        if (route is GoRoute) {
          if (route.name != null) {
            names.add(route.name!);
          }
          paths.add(route.path);
          walk(route.routes);
        } else if (route is ShellRoute) {
          walk(route.routes);
        }
      }
    }

    walk(routes);
    expect(names.toSet().length, names.length);
    expect(paths.toSet().length, paths.length);
    expect(names, contains(homeRouteName));
    expect(names, contains(profileRouteName));
    expect(paths, contains(homeRoutePath));
    expect(paths, contains(profileRoutePath));
    expect(paths, isNot(contains('/auth/phone')));
    expect(paths, isNot(contains('/auth/email')));
    expect(paths, isNot(contains('/auth/password-reset')));
  });

  test('return destinations accept public/protected and reject unsafe', () {
    expect(
      canonicalizeReturnDestination(
        homeRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      homeRoutePath,
    );
    expect(
      canonicalizeReturnDestination(
        profileRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      profileRoutePath,
    );
    expect(
      canonicalizeReturnDestination(
        accountSecurityRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      accountSecurityRoutePath,
    );
    expect(
      canonicalizeReturnDestination(
        authRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
    expect(
      canonicalizeReturnDestination(
        authStartupRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
    expect(
      canonicalizeReturnDestination(
        'https://evil.example/path',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
    expect(
      canonicalizeReturnDestination(
        '//evil.example/path',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
    expect(
      canonicalizeReturnDestination(
        '/unknown/module',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
    expect(
      canonicalizeReturnDestination(
        '$accountSecurityRoutePath?x=1',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
    expect(
      canonicalizeReturnDestination(
        '$accountSecurityRoutePath#frag',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isNull,
    );
  });

  testWidgets('authenticated /auth with query/fragment from falls back to Home', (
    tester,
  ) async {
    final gateway = _ControllableGateway(const AuthAuthenticated(_principal));
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go(
      '$authRoutePath?from=${Uri.encodeComponent('$accountSecurityRoutePath?x=1')}',
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, homeRoutePath);

    router.go(
      '$authRoutePath?from=${Uri.encodeComponent(accountSecurityRoutePath)}',
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, accountSecurityRoutePath);
  });
}
