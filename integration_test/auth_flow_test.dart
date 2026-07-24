import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';
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
    final email = 'm2_$suffix@example.com';
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

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('home_discovery_shell')), findsOneWidget);
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
    expect(find.text(l10n.homeAccountStatusTitle), findsOneWidget);
    expect(find.text(l10n.homePhoneReady), findsOneWidget);

    final homeElement = tester.element(find.byType(HomeScreen));
    final homeContainer = ProviderScope.containerOf(homeElement);
    final authState = homeContainer.read(authControllerProvider);
    expect(authState, isA<AuthAuthenticated>());
    final accountId = (authState as AuthAuthenticated).principal.accountId;
    expect(accountId, isNotEmpty);
    expect(find.textContaining(accountId), findsNothing);

    // Ensure Account Security was not opened as a side-effect of login.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('account_attach_email')), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const Key('home_account_security')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home_account_security')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

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

    // Return to Home through normal router navigation.
    final securityContext = tester.element(
      find.byKey(const Key('account_id_label')),
    );
    GoRouter.of(securityContext).go(homeRoutePath);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);

    // Re-open account security from Home, then logout current session.
    await tester.scrollUntilVisible(
      find.byKey(const Key('home_account_security')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home_account_security')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
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
    expect(find.text(l10n.homeEmailReady), findsOneWidget);

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
      queryParameters: <String, dynamic>{
        'destination': destination,
        'purpose': purpose,
      },
      options: Options(headers: <String, dynamic>{'x-fixture-key': fixtureKey}),
    );
    final code = response.data?['code'] as String?;
    if (code != null && code.isNotEmpty) {
      return code;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  fail('Fixture code not available for $purpose / $destination');
}
