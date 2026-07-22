import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/presentation/phone_auth_screen.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../support/fake_auth_repository.dart';

class _Gateway implements AuthSessionGateway {
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
  Future<AuthState> hydrate() async => const AuthUnauthenticated();

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'phone resend re-enables after cooldown without other interaction',
    (tester) async {
      var now = DateTime.utc(2026, 7, 22, 12, 0, 0);
      final fake = FakeAuthRepository();
      fake.phoneChallengeFactory = () => ChallengeCreatedDto(
        challengeId: 'challenge-${fake.phoneChallengeCalls}',
        maskedDestination: '09****67',
        resendAvailableAt: now
            .add(const Duration(seconds: 2))
            .toIso8601String(),
        expiresAt: now.add(const Duration(minutes: 5)).toIso8601String(),
      );

      final l10n = await AppLocalizations.delegate.load(
        const Locale('fa', 'IR'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(_config),
            authSessionGatewayProvider.overrideWithValue(_Gateway()),
            authRepositoryProvider.overrideWithValue(fake),
          ],
          child: MaterialApp(
            locale: const Locale('fa', 'IR'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PhoneAuthScreen(clock: () => now),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('auth_phone_field')),
        '09121234567',
      );
      await tester.tap(find.byKey(const Key('auth_phone_send')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('auth_phone_resend')), findsOneWidget);
      var resend = tester.widget<TextButton>(
        find.byKey(const Key('auth_phone_resend')),
      );
      expect(resend.onPressed, isNull);
      expect(find.text(l10n.authResendCode), findsNothing);

      // Advance fake clock past cooldown; pump so the 1s timer rebuilds.
      now = now.add(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));

      resend = tester.widget<TextButton>(
        find.byKey(const Key('auth_phone_resend')),
      );
      expect(resend.onPressed, isNotNull);
      expect(find.text(l10n.authResendCode), findsOneWidget);

      await tester.tap(find.byKey(const Key('auth_phone_resend')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fake.phoneChallengeCalls, 2);
      resend = tester.widget<TextButton>(
        find.byKey(const Key('auth_phone_resend')),
      );
      expect(resend.onPressed, isNull);
    },
  );

  testWidgets('phone resend is enabled when resendAvailableAt is in the past', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 7, 22, 12, 0, 0);
    final fake = FakeAuthRepository();
    fake.phoneChallengeResult = Success(
      ChallengeCreatedDto(
        challengeId: 'challenge-past',
        maskedDestination: '09****67',
        resendAvailableAt: now
            .subtract(const Duration(seconds: 1))
            .toIso8601String(),
        expiresAt: now.add(const Duration(minutes: 5)).toIso8601String(),
      ),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(_Gateway()),
          authRepositoryProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          locale: const Locale('fa', 'IR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PhoneAuthScreen(clock: () => now),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('auth_phone_field')),
      '09121234567',
    );
    await tester.tap(find.byKey(const Key('auth_phone_send')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final resend = tester.widget<TextButton>(
      find.byKey(const Key('auth_phone_resend')),
    );
    expect(resend.onPressed, isNotNull);
    expect(find.text(l10n.authResendCode), findsOneWidget);
  });
}
