import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/presentation/home_screen.dart';
import 'package:laforika/main.dart' as app;

/// Real-backend Android auth vertical slice against Nest + PostgreSQL.
///
/// Requires:
/// - backend listening where `config/dev.json` points (`10.0.2.2:3000` on emulator)
/// - `--dart-define=FIXTURE_INBOX_KEY=...` matching the backend fixture key
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const fixtureKey = String.fromEnvironment('FIXTURE_INBOX_KEY');

  testWidgets('phone signup → attach email → email login → refresh → logout', (
    tester,
  ) async {
    expect(
      fixtureKey,
      isNotEmpty,
      reason: 'FIXTURE_INBOX_KEY dart-define is required for this flow',
    );

    final suffix = DateTime.now().millisecondsSinceEpoch.toString();
    final phone = '0912${suffix.substring(suffix.length - 7)}';
    final normalizedPhone = '+98${phone.substring(1)}';
    final email = 'm1_$suffix@example.com';
    const password = 'correct-horse-battery-1';

    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Startup → unauthenticated auth entry.
    expect(find.byKey(const Key('auth_continue_phone')), findsOneWidget);

    await tester.tap(find.byKey(const Key('auth_continue_phone')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('auth_phone_field')), phone);
    await tester.tap(find.byKey(const Key('auth_phone_send')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final phoneCode = await _readFixtureCode(
      destination: normalizedPhone,
      purpose: 'PHONE_SIGN_IN',
      fixtureKey: fixtureKey,
    );
    await tester.enterText(find.byKey(const Key('auth_otp_field')), phoneCode);
    await tester.tap(find.byKey(const Key('auth_otp_verify')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('home_account_id')), findsOneWidget);
    final homeAccountText = tester
        .widget<Text>(find.byKey(const Key('home_account_id')))
        .data!;
    final accountId = homeAccountText.split(':').last.trim();
    expect(accountId, isNotEmpty);

    await tester.tap(find.byKey(const Key('home_account_security')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(
      find.byKey(const Key('account_attach_email')),
      email,
    );
    await tester.enterText(
      find.byKey(const Key('account_attach_password')),
      password,
    );
    await tester.tap(find.byKey(const Key('account_attach_email_send')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final emailCode = await _readFixtureCode(
      destination: email,
      purpose: 'EMAIL_ATTACH',
      fixtureKey: fixtureKey,
    );
    await tester.enterText(
      find.byKey(const Key('account_attach_email_code')),
      emailCode,
    );
    await tester.tap(find.byKey(const Key('account_attach_email_verify')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byKey(const Key('account_id_label')), findsOneWidget);
    final securityAccountText = tester
        .widget<Text>(find.byKey(const Key('account_id_label')))
        .data!;
    expect(securityAccountText, contains(accountId));

    await tester.tap(find.byKey(const Key('account_logout')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('auth_continue_email')), findsOneWidget);

    await tester.tap(find.byKey(const Key('auth_continue_email')));
    await tester.pumpAndSettle();

    // Switch to sign-in mode (second segment).
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth_email_field')), email);
    await tester.enterText(
      find.byKey(const Key('auth_password_field')),
      password,
    );
    await tester.tap(find.byKey(const Key('auth_email_submit')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(HomeScreen), findsOneWidget);

    // Forced access-token expiry → single-flight refresh without logout.
    final element = tester.element(find.byType(HomeScreen));
    final container = ProviderScope.containerOf(element);
    final gateway =
        container.read(authSessionGatewayProvider) as CustomApiAuthGateway;
    gateway.expireAccessTokenInMemory();
    final me = await container.read(authRepositoryProvider).me();
    expect(me.isSuccess, isTrue);
    expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

    await tester.tap(find.byKey(const Key('home_logout')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('auth_continue_phone')), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}

Future<String> _readFixtureCode({
  required String destination,
  required String purpose,
  required String fixtureKey,
}) async {
  // Hits the real Nest fixture inbox (in-memory in remediations; path unchanged).
  // No fake auth injection — codes come from GET /v1/dev/fixtures/inbox.
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  for (var attempt = 0; attempt < 20; attempt++) {
    final response = await dio.get<Map<String, dynamic>>(
      '/dev/fixtures/inbox',
      queryParameters: {'destination': destination, 'purpose': purpose},
      options: Options(headers: {'X-Fixture-Key': fixtureKey}),
    );
    final code = response.data?['code'] as String?;
    if (code != null && code.isNotEmpty) {
      return code;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  fail('Fixture code not available for $purpose / $destination');
}
