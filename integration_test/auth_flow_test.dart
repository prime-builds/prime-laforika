import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:laforika/app/router/app_router.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_appearance.dart';
import 'package:laforika/core/theme/app_appearance_controller.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/features/notifications/notifications.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/settings/settings.dart';
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
    'guest Home → Profile OTP → edit/save → security/refresh → Profile logout',
    (tester) async {
      expect(
        fixtureKey,
        isNotEmpty,
        reason: 'FIXTURE_INBOX_KEY dart-define is required for this flow',
      );

      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final phone = '0912${suffix.substring(suffix.length - 7)}';
      final normalizedPhone = '+98${phone.substring(1)}';

      // bootstrap() replaces FlutterError.onError; restore the test binding
      // handler so assertion failures surface cleanly.
      final testOnError = FlutterError.onError;
      await app.main();
      FlutterError.onError = testOnError;

      await _pumpUntilFound(
        tester,
        find.byType(HomeScreen),
        timeout: const Duration(seconds: 20),
      );

      final l10n = await AppLocalizations.delegate.load(
        const Locale('fa', 'IR'),
      );

      // Guest Home after hydration — not login.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home_discovery_shell')), findsOneWidget);
      expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
      expect(find.byKey(const Key('home_logout')), findsNothing);
      expect(find.text(l10n.authPhoneTitle), findsNothing);

      await tester.tap(find.byKey(const Key('shell_dock_profile')));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('auth_phone_field')),
        timeout: const Duration(seconds: 15),
      );

      // Direct phone OTP inside guest Profile — no method chooser.
      expect(find.byKey(const Key('profile_guest_auth')), findsOneWidget);
      expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
      expect(find.textContaining('ایمیل'), findsNothing);

      await tester.enterText(find.byKey(const Key('auth_phone_field')), phone);
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('auth_phone_send')));
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('auth_otp_field')),
        timeout: const Duration(seconds: 30),
      );

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
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_first_name')),
        timeout: const Duration(seconds: 20),
      );

      final securityElement = tester.element(
        find.byKey(const Key('profile_screen')),
      );
      final container = ProviderScope.containerOf(securityElement);
      final authState = container.read(authControllerProvider);
      expect(authState, isA<AuthAuthenticated>());
      final accountId = (authState as AuthAuthenticated).principal.accountId;
      expect(accountId, isNotEmpty);

      final loadedProfile = container
          .read(profileControllerProvider)
          .asData
          ?.value;
      expect(loadedProfile?.accountId, accountId);

      final uniqueEmail = 'integration+$suffix@example.test';
      await tester.enterText(
        find.byKey(const Key('profile_first_name')),
        'آزمون',
      );
      await tester.enterText(
        find.byKey(const Key('profile_last_name')),
        'لفوریکا',
      );
      await tester.enterText(
        find.byKey(const Key('profile_email')),
        uniqueEmail,
      );
      await tester.tap(find.byKey(const Key('profile_save')));
      FocusManager.instance.primaryFocus?.unfocus();
      await _pumpUntilFound(
        tester,
        find.text(l10n.profileSaved, skipOffstage: false),
        timeout: const Duration(seconds: 15),
      );
      expect(
        find.text(l10n.profileSaved, skipOffstage: false),
        findsOneWidget,
      );

      // Re-enter Profile and verify persisted values came from GET.
      // Prefer router go() — stacked shells can leave duplicate dock keys.
      container.read(goRouterProvider).go('/');
      await _pumpUntilFound(
        tester,
        find.byType(HomeScreen),
        timeout: const Duration(seconds: 10),
      );
      container.read(goRouterProvider).go(profileRoutePath);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_first_name')),
        timeout: const Duration(seconds: 15),
      );
      expect(find.text('آزمون'), findsOneWidget);
      expect(find.text('لفوریکا'), findsOneWidget);
      expect(find.text(uniqueEmail), findsOneWidget);

      final accountSecurity = find.byKey(const Key('profile_account_security'));
      await tester.ensureVisible(accountSecurity);
      await tester.pumpAndSettle();
      await tester.tap(accountSecurity);
      // Scaffold mounts immediately; wait for post-load sessions content.
      await _pumpUntilFound(
        tester,
        find.text(l10n.accountSessionsTitle),
        timeout: const Duration(seconds: 20),
      );
      expect(find.byKey(const Key('account_security_screen')), findsOneWidget);

      // Force access-token expiry and verify refresh on protected call.
      final gateway =
          container.read(authSessionGatewayProvider) as CustomApiAuthGateway;
      gateway.expireAccessTokenInMemory();
      final meResult = await container.read(authRepositoryProvider).me();
      expect(meResult.isSuccess, isTrue);
      expect(meResult.valueOrNull?.accountId, accountId);
      expect(
        gateway.accessToken,
        isNot(equals('expired.integration.test.token')),
      );
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
      expect(
        (container.read(authControllerProvider) as AuthAuthenticated)
            .principal
            .accountId,
        accountId,
      );

      container.read(goRouterProvider).go(profileRoutePath);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_first_name')),
        timeout: const Duration(seconds: 15),
      );
      final logout = find.byKey(const Key('profile_logout'));
      await tester.ensureVisible(logout);
      await tester.pumpAndSettle();
      await tester.tap(logout);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_guest_auth')),
        timeout: const Duration(seconds: 20),
      );
      expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );

      container.read(goRouterProvider).go('/');
      await _pumpUntilFound(
        tester,
        find.byType(HomeScreen),
        timeout: const Duration(seconds: 15),
      );
      expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
    },
  );

  testWidgets(
    'guest Settings → Notifications OTP resume → Settings logout stays public',
    (tester) async {
      expect(
        fixtureKey,
        isNotEmpty,
        reason: 'FIXTURE_INBOX_KEY dart-define is required for this flow',
      );

      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final phone = '0913${suffix.substring(suffix.length - 7)}';
      final normalizedPhone = '+98${phone.substring(1)}';

      final testOnError = FlutterError.onError;
      await app.main();
      FlutterError.onError = testOnError;

      await _pumpUntilFound(
        tester,
        find.byType(HomeScreen),
        timeout: const Duration(seconds: 20),
      );

      final l10n = await AppLocalizations.delegate.load(
        const Locale('fa', 'IR'),
      );

      await tester.tap(find.byKey(const Key('shell_dock_profile')));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_guest_auth')),
        timeout: const Duration(seconds: 15),
      );

      // Guest Settings from Profile header — no authentication required.
      await tester.tap(find.byKey(const Key('profile_header_settings')));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('settings_screen')),
        timeout: const Duration(seconds: 15),
      );
      expect(find.byKey(const Key('settings_account_section')), findsNothing);
      expect(find.byKey(const Key('settings_about')), findsOneWidget);

      final settingsElement = tester.element(
        find.byKey(const Key('settings_screen')),
      );
      final container = ProviderScope.containerOf(settingsElement);
      expect(
        container.read(appAppearanceControllerProvider),
        AppAppearance.system,
      );
      await tester.tap(find.byKey(const Key('settings_appearance_dark')));
      await tester.pumpAndSettle();
      expect(
        container.read(appAppearanceControllerProvider),
        AppAppearance.dark,
      );

      await tester.tap(find.byKey(const Key('settings_back')));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_guest_auth')),
        timeout: const Duration(seconds: 15),
      );

      // Guest Notifications → direct phone OTP with resume.
      await tester.tap(find.byKey(const Key('profile_header_notifications')));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('auth_phone_field')),
        timeout: const Duration(seconds: 15),
      );
      expect(
        container.read(goRouterProvider).state.uri.queryParameters['from'],
        notificationsRoutePath,
      );

      final phoneField = find
          .byKey(const Key('auth_phone_field'))
          .hitTestable();
      expect(phoneField, findsOneWidget);
      await tester.enterText(phoneField, phone);
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('auth_phone_send')).hitTestable());
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('auth_otp_field')).hitTestable(),
        timeout: const Duration(seconds: 30),
      );

      final phoneCode = await _readFixtureCode(
        destination: normalizedPhone,
        purpose: 'PHONE_SIGN_IN',
        fixtureKey: fixtureKey,
      );
      await tester.enterText(
        find.byKey(const Key('auth_otp_field')).hitTestable(),
        phoneCode,
      );
      await tester.tap(find.byKey(const Key('auth_otp_verify')).hitTestable());
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('notifications_empty')),
        timeout: const Duration(seconds: 20),
      );
      expect(find.byKey(const Key('notifications_screen')), findsOneWidget);
      expect(find.byKey(const Key('shell_dock_profile')), findsOneWidget);
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

      container.read(goRouterProvider).go(settingsRoutePath);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('settings_account_section')),
        timeout: const Duration(seconds: 15),
      );
      expect(find.byKey(const Key('settings_logout')), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings_account_security')));
      await _pumpUntilFound(
        tester,
        find.text(l10n.accountSessionsTitle),
        timeout: const Duration(seconds: 20),
      );
      expect(find.byKey(const Key('account_security_screen')), findsOneWidget);

      final gateway =
          container.read(authSessionGatewayProvider) as CustomApiAuthGateway;
      gateway.expireAccessTokenInMemory();
      final meResult = await container.read(authRepositoryProvider).me();
      expect(meResult.isSuccess, isTrue);
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

      container.read(goRouterProvider).go(settingsRoutePath);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('settings_logout')),
        timeout: const Duration(seconds: 15),
      );
      await tester.ensureVisible(find.byKey(const Key('settings_logout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_logout')));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('settings_about')),
        timeout: const Duration(seconds: 20),
      );
      expect(
        container.read(goRouterProvider).state.uri.path,
        settingsRoutePath,
      );
      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );
      expect(find.byKey(const Key('settings_account_section')), findsNothing);
      expect(find.text(l10n.settingsAppearanceSection), findsOneWidget);

      container.read(goRouterProvider).go(profileRoutePath);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('profile_guest_auth')),
        timeout: const Duration(seconds: 15),
      );
      container.read(goRouterProvider).go('/');
      await _pumpUntilFound(
        tester,
        find.byType(HomeScreen),
        timeout: const Duration(seconds: 15),
      );
      expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);

      // Notifications remains protected after logout.
      container.read(goRouterProvider).go(notificationsRoutePath);
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('auth_phone_field')),
        timeout: const Duration(seconds: 15),
      );
      expect(
        container.read(goRouterProvider).state.uri.queryParameters['from'],
        notificationsRoutePath,
      );
    },
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  required Duration timeout,
}) async {
  final end = DateTime.now().add(timeout);
  final capturedErrors = <String>[];
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    final pending = tester.takeException();
    if (pending != null) {
      capturedErrors.add(pending.toString());
    }
    if (finder.evaluate().isNotEmpty) {
      await tester.pump();
      return;
    }
  }
  final visibleTexts = find
      .byType(Text)
      .evaluate()
      .map((e) {
        final widget = e.widget;
        return widget is Text ? widget.data : null;
      })
      .whereType<String>()
      .take(12)
      .join(' | ');
  final hasPhoneSend = find
      .byKey(const Key('auth_phone_send'))
      .evaluate()
      .isNotEmpty;
  final hasOtp = find.byKey(const Key('auth_otp_field')).evaluate().isNotEmpty;
  final hasGuest = find
      .byKey(const Key('profile_guest_auth'))
      .evaluate()
      .isNotEmpty;
  final hasSecurity = find
      .byKey(const Key('account_security_screen'))
      .evaluate()
      .isNotEmpty;
  fail(
    'Timed out waiting for $finder. '
    'hasPhoneSend=$hasPhoneSend hasOtp=$hasOtp hasGuest=$hasGuest '
    'hasSecurity=$hasSecurity. '
    'errors=${capturedErrors.take(5).join(' || ')}. '
    'Visible text: $visibleTexts',
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
