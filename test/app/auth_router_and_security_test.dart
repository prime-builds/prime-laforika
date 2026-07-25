import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_prefs.dart';
import 'package:go_router/go_router.dart';

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

const _principal = AuthPrincipal(
  accountId: 'acc-secure',
  hasPhone: true,
  hasEmail: true,
  maskedPhone: '+989****67',
  maskedEmail: 'us***@example.com',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unknown startup shows loading without auth method flash', (
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
    expect(find.text(l10n.authMethodTitle), findsNothing);
  });

  testWidgets('unauthenticated redirects protected home to auth', (
    tester,
  ) async {
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

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.authMethodTitle), findsOneWidget);
    expect(find.text(l10n.homeWelcomeTitle), findsNothing);
  });

  testWidgets('authenticated auth-route redirects to home', (tester) async {
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
    expect(find.text(l10n.authMethodTitle), findsNothing);
  });

  testWidgets('account security shows change-password and clears on success', (
    tester,
  ) async {
    final repository = FakeAuthRepository()
      ..meResult = const Success(
        AccountMeDto(
          accountId: 'acc-secure',
          hasPhone: true,
          hasEmail: true,
          maskedPhone: '+989****67',
          maskedEmail: 'us***@example.com',
        ),
      )
      ..sessionsResult = const Success(<SessionDto>[])
      ..changePasswordResult = const Success(null);

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
    expect(find.text(l10n.accountChangePasswordTitle), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('account_current_password')),
      'correct-horse-battery',
    );
    await tester.enterText(
      find.byKey(const Key('account_new_password')),
      'correct-horse-battery-2',
    );
    await tester.tap(find.byKey(const Key('account_change_password')));
    await tester.pumpAndSettle();

    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
  });

  testWidgets('validated return destination is honored after login', (
    tester,
  ) async {
    final gateway = _ControllableGateway(const AuthUnauthenticated());
    final repository = FakeAuthRepository()
      ..meResult = const Success(
        AccountMeDto(
          accountId: 'acc-secure',
          hasPhone: true,
          hasEmail: true,
          maskedPhone: '+989****67',
          maskedEmail: 'us***@example.com',
        ),
      )
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
      '$authMethodRoutePath?from=${Uri.encodeComponent(accountSecurityRoutePath)}',
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
  });

  test('appRoutes and appRegisteredPaths aggregate auth and home', () {
    final routes = appRoutes();
    expect(routes, isNotEmpty);
    expect(appRegisteredPaths, contains(homeRoutePath));
    expect(appRegisteredPaths, contains(authMethodRoutePath));
    expect(appRegisteredPaths, contains(accountSecurityRoutePath));
    expect(appRegisteredPaths, containsAll(authRegisteredPaths));
    expect(appRegisteredPaths, containsAll(homeRegisteredPaths));

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
    expect(paths, contains(homeRoutePath));
  });

  test('appRegisteredPaths validates home and rejects auth-only/startup', () {
    expect(
      isValidReturnDestination(
        homeRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isTrue,
    );
    expect(
      isValidReturnDestination(
        accountSecurityRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isTrue,
    );
    expect(
      isValidReturnDestination(
        authMethodRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
    expect(
      isValidReturnDestination(
        authStartupRoutePath,
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
    expect(
      isValidReturnDestination(
        'https://evil.example/path',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
    expect(
      isValidReturnDestination(
        '//evil.example/path',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
    expect(
      isValidReturnDestination(
        Uri.encodeFull('https://evil.example'),
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
    expect(
      isValidReturnDestination(
        '/unknown/module',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
    expect(
      isValidReturnDestination(
        'not a path',
        registeredPaths: appRegisteredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: authStartupRoutePath,
      ),
      isFalse,
    );
  });

  testWidgets('home remains a valid authenticated return destination', (
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
    router.go(
      '$authMethodRoutePath?from=${Uri.encodeComponent(homeRoutePath)}',
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

    expect(router.state.uri.path, homeRoutePath);
    expect(find.byKey(const Key('home_discovery_shell')), findsOneWidget);
  });
}
