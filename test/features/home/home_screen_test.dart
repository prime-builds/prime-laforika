import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_prefs.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class _RecordingGateway implements AuthSessionGateway {
  _RecordingGateway(this._hydrate, {this.logoutDelay = Duration.zero});

  final AuthState _hydrate;
  final Duration logoutDelay;
  int logoutCurrentCalls = 0;
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
    logoutCurrentCalls += 1;
    if (logoutDelay > Duration.zero) {
      await Future<void>.delayed(logoutDelay);
    }
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

const _fullPrincipal = AuthPrincipal(
  accountId: 'acc-home-secret',
  hasPhone: true,
  hasEmail: true,
  maskedPhone: '+989****67',
  maskedEmail: 'us***@example.com',
);

Future<AppLocalizations> _l10n() =>
    AppLocalizations.delegate.load(const Locale('fa', 'IR'));

Future<ProviderContainer> _pumpAuthenticatedHome(
  WidgetTester tester, {
  required AuthPrincipal principal,
  AuthSessionGateway? gateway,
  Size? physicalSize,
  double textScale = 1.0,
}) async {
  final boundGateway =
      gateway ?? _RecordingGateway(AuthAuthenticated(principal));

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
        authSessionGatewayProvider.overrideWithValue(boundGateway),
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
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('authenticated home shows phone and email ready states', (
    tester,
  ) async {
    await _pumpAuthenticatedHome(tester, principal: _fullPrincipal);
    final l10n = await _l10n();

    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(find.byKey(const Key('home_discovery_shell')), findsOneWidget);
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
    expect(find.text(l10n.homeWelcomeSubtitle), findsOneWidget);
    expect(find.text(l10n.homeAccountStatusTitle), findsOneWidget);
    expect(find.text(l10n.homePhoneReady), findsOneWidget);
    expect(find.text(l10n.homeEmailReady), findsOneWidget);
    expect(find.text('+989****67'), findsOneWidget);
    expect(find.text('us***@example.com'), findsOneWidget);
    expect(find.textContaining('acc-home-secret'), findsNothing);
    expect(find.byKey(const Key('home_account_security')), findsOneWidget);
    expect(find.byKey(const Key('home_logout')), findsOneWidget);
    expect(find.text(l10n.homeAccountSecurityTitle), findsOneWidget);
  });

  testWidgets('phone-only principal shows email missing', (tester) async {
    await _pumpAuthenticatedHome(
      tester,
      principal: const AuthPrincipal(
        accountId: 'acc-phone',
        hasPhone: true,
        maskedPhone: '+989****11',
      ),
    );
    final l10n = await _l10n();

    expect(find.text(l10n.homePhoneReady), findsOneWidget);
    expect(find.text(l10n.homeEmailMissing), findsOneWidget);
    expect(find.text('+989****11'), findsOneWidget);
    expect(find.textContaining('acc-phone'), findsNothing);
  });

  testWidgets('email-only principal shows phone missing', (tester) async {
    await _pumpAuthenticatedHome(
      tester,
      principal: const AuthPrincipal(
        accountId: 'acc-email',
        hasEmail: true,
        maskedEmail: 'ab***@example.com',
      ),
    );
    final l10n = await _l10n();

    expect(find.text(l10n.homeEmailReady), findsOneWidget);
    expect(find.text(l10n.homePhoneMissing), findsOneWidget);
    expect(find.text('ab***@example.com'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets('missing masks do not render null or empty punctuation', (
    tester,
  ) async {
    await _pumpAuthenticatedHome(
      tester,
      principal: const AuthPrincipal(
        accountId: 'acc-bare',
        hasPhone: true,
        hasEmail: true,
      ),
    );
    final l10n = await _l10n();

    expect(find.text(l10n.homePhoneReady), findsOneWidget);
    expect(find.text(l10n.homeEmailReady), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('acc-bare'), findsNothing);
  });

  testWidgets('account security destination navigates via public path', (
    tester,
  ) async {
    await _pumpAuthenticatedHome(tester, principal: _fullPrincipal);
    final l10n = await _l10n();

    await tester.tap(find.byKey(const Key('home_account_security')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountSecurityTitle), findsOneWidget);
  });

  testWidgets('logout invokes gateway once and returns to auth entry', (
    tester,
  ) async {
    final gateway = _RecordingGateway(
      const AuthAuthenticated(_fullPrincipal),
      logoutDelay: const Duration(milliseconds: 200),
    );
    final container = await _pumpAuthenticatedHome(
      tester,
      principal: _fullPrincipal,
      gateway: gateway,
    );
    final l10n = await _l10n();

    await tester.tap(find.byKey(const Key('home_logout')));
    await tester.pump();

    final pendingDestination = tester.widget<Semantics>(
      find.byKey(const Key('home_account_security')),
    );
    expect(pendingDestination.properties.enabled, isFalse);

    await tester.tap(find.byKey(const Key('home_logout')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(gateway.logoutCurrentCalls, 1);
    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    expect(find.text(l10n.authMethodTitle), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('narrow short layout does not overflow', (tester) async {
    await _pumpAuthenticatedHome(
      tester,
      principal: _fullPrincipal,
      physicalSize: const Size(320, 568),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
    expect(find.byKey(const Key('home_account_security')), findsOneWidget);
    expect(find.byKey(const Key('home_logout')), findsOneWidget);
  });

  testWidgets('wide layout keeps actions reachable', (tester) async {
    await _pumpAuthenticatedHome(
      tester,
      principal: _fullPrincipal,
      physicalSize: const Size(900, 800),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home_account_status')), findsOneWidget);
    expect(find.byKey(const Key('home_account_security')), findsOneWidget);
  });

  testWidgets('text scale 2.0 remains scrollable without overflow', (
    tester,
  ) async {
    await _pumpAuthenticatedHome(
      tester,
      principal: _fullPrincipal,
      physicalSize: const Size(320, 568),
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
    expect(find.byKey(const Key('home_logout')), findsOneWidget);
  });

  testWidgets('logout and account-security expose localized semantics', (
    tester,
  ) async {
    await _pumpAuthenticatedHome(tester, principal: _fullPrincipal);
    final l10n = await _l10n();

    final destination = tester.widget<Semantics>(
      find.byKey(const Key('home_account_security')),
    );
    expect(destination.properties.label, l10n.homeOpenAccountSecurity);
    expect(destination.properties.button, isTrue);
    expect(find.byTooltip(l10n.homeLogoutTooltip), findsOneWidget);
    expect(find.text(l10n.homePhoneReady), findsOneWidget);
    expect(find.text(l10n.homeEmailReady), findsOneWidget);
  });

  test('home barrel route constants remain stable', () {
    expect(homeRouteName, 'home');
    expect(homeRoutePath, '/');
    expect(homeRegisteredPaths, <String>{homeRoutePath});
    expect(homeRoutes(), isNotEmpty);
  });
}
