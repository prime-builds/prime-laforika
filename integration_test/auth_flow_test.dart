import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';
import 'package:laforika/main.dart' as app;

/// Real-backend Android guest-first phone OTP flow against Nest + PostgreSQL.
///
/// Requires:
/// - backend listening where `config/dev.json` points (`10.0.2.2:3000` on emulator)
/// - `--dart-define=FIXTURE_INBOX_KEY=...` matching the backend fixture key
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const fixtureKey = String.fromEnvironment('FIXTURE_INBOX_KEY');

  testWidgets(
    'guest Home → protected Account Security → phone OTP → resume → refresh → logout → guest Home',
    (tester) async {
      expect(
        fixtureKey,
        isNotEmpty,
        reason: 'FIXTURE_INBOX_KEY dart-define is required for this flow',
      );

      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final phone = '0912${suffix.substring(suffix.length - 7)}';
      final normalizedPhone = '+98${phone.substring(1)}';

      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final l10n = await AppLocalizations.delegate.load(
        const Locale('fa', 'IR'),
      );

      // Guest Home after hydration — not login.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home_discovery_shell')), findsOneWidget);
      expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
      expect(find.byKey(const Key('home_logout')), findsNothing);
      expect(find.text(l10n.authPhoneTitle), findsNothing);

      await tester.tap(find.byKey(const Key('home_account_security_action')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Direct phone OTP — no method chooser / email option.
      expect(find.text(l10n.authPhoneTitle), findsOneWidget);
      expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
      expect(find.textContaining('ایمیل'), findsNothing);

      await tester.enterText(find.byKey(const Key('auth_phone_field')), phone);
      await tester.tap(find.byKey(const Key('auth_phone_send')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final phoneCode = await _readFixtureCode(
        destination: normalizedPhone,
        purpose: 'PHONE_SIGN_IN',
        fixtureKey: fixtureKey,
      );
      await tester.enterText(
        find.byKey(const Key('auth_otp_field')),
        phoneCode,
      );
      await tester.tap(find.byKey(const Key('auth_otp_verify')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Resume protected Account Security.
      expect(find.byKey(const Key('account_security_screen')), findsOneWidget);
      expect(find.text(l10n.accountSessionsTitle), findsOneWidget);

      final securityElement = tester.element(
        find.byKey(const Key('account_security_screen')),
      );
      final container = ProviderScope.containerOf(securityElement);
      final authState = container.read(authControllerProvider);
      expect(authState, isA<AuthAuthenticated>());
      final accountId = (authState as AuthAuthenticated).principal.accountId;
      expect(accountId, isNotEmpty);

      // Force access-token expiry and verify refresh on protected call.
      final gateway =
          container.read(authSessionGatewayProvider) as CustomApiAuthGateway;
      gateway.expireAccessTokenInMemory();
      await container.read(authRepositoryProvider).me();
      expect(
        gateway.accessToken,
        isNot(equals('expired.integration.test.token')),
      );
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

      await tester.tap(find.byKey(const Key('account_logout_current')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Logout returns to guest Home, not login.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home_logout')), findsNothing);
      expect(find.text(l10n.authPhoneTitle), findsNothing);
      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );

      await tester.tap(find.byKey(const Key('home_account_security_action')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text(l10n.authPhoneTitle), findsOneWidget);
    },
  );
}

Future<String> _readFixtureCode({
  required String destination,
  required String purpose,
  required String fixtureKey,
}) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  for (var attempt = 0; attempt < 10; attempt += 1) {
    final response = await dio.get<Map<String, dynamic>>(
      '/dev/fixtures/inbox',
      queryParameters: {'destination': destination, 'purpose': purpose},
      options: Options(headers: {'X-Fixture-Key': fixtureKey}),
    );
    final code = response.data?['code']?.toString();
    if (code != null && code.isNotEmpty) {
      return code;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  fail('fixture OTP unavailable');
}
