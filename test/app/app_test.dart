import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/fatal_startup_app.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class _FakeGateway implements AuthSessionGateway {
  AuthState hydrateResult = const AuthUnauthenticated();

  @override
  String? get accessToken => null;

  @override
  Future<AuthPrincipal> acceptCredentials({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  }) async => principal;

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<AuthState> hydrate() async => hydrateResult;

  @override
  Future<Result<void>> logoutAll() async => const Success(null);

  @override
  Future<Result<void>> logoutCurrent() async => const Success(null);

  @override
  Future<Result<String>> refreshAccessToken() async =>
      const FailureResult(AuthFailure(code: 'AUTH_NO_REFRESH'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testConfig = AppConfig(
    environment: AppEnvironment.dev,
    apiBaseUrl: 'http://10.0.2.2:3000/v1',
    logLevel: AppLogLevel.debug,
    featureFlags: <String, bool>{},
  );

  testWidgets('LaforikaApp uses fa-IR and RTL', (tester) async {
    final gateway = _FakeGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          authSessionGatewayProvider.overrideWithValue(gateway),
        ],
        child: const LaforikaApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('fa', 'IR'));
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('FatalStartupApp shows localized failure without raw details', (
    tester,
  ) async {
    const leaked = 'SECRET_CONFIG_PATH=/tmp/secret.json';

    await tester.pumpWidget(const FatalStartupApp());
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.text(l10n.fatalStartupTitle), findsOneWidget);
    expect(find.text(l10n.fatalStartupMessage), findsOneWidget);
    expect(find.textContaining(leaked), findsNothing);
    expect(find.textContaining('FormatException'), findsNothing);
  });
}
