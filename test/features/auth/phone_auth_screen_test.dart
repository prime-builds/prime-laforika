import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/presentation/phone_auth_screen.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../support/fake_auth_repository.dart';

class _FakeGateway implements AuthSessionGateway {
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
      const FailureResult(AuthFailure(code: 'NO_REFRESH'));
}

Widget _harness({required Widget child, required AuthRepository repository}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      authSessionGatewayProvider.overrideWithValue(_FakeGateway()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      locale: const Locale('fa', 'IR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'direct phone auth at 320dp and textScale 2.0 renders phone input and send button >= 48dp without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final fakeRepo = FakeAuthRepository();
      await tester.pumpWidget(
        _harness(child: const PhoneAuthScreen(), repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_phone_send')), findsOneWidget);
      expect(tester.takeException(), isNull);

      final sendSize = tester.getSize(find.byKey(const Key('auth_phone_send')));
      expect(sendSize.width, greaterThanOrEqualTo(AppTokens.minTouchTarget));
      expect(sendSize.height, greaterThanOrEqualTo(AppTokens.minTouchTarget));
    },
  );

  testWidgets(
    'phone OTP verification at 320dp and textScale 2.0 renders code input, verify button, and cooldown without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final now = DateTime.utc(2026, 9, 17, 12, 0, 0);
      final fakeRepo = FakeAuthRepository()
        ..phoneChallengeResult = Success(
          ChallengeCreatedDto(
            challengeId: 'c1',
            maskedDestination: '+98 *** *** 1234',
            resendAvailableAt: now
                .add(const Duration(seconds: 45))
                .toIso8601String(),
            expiresAt: now.add(const Duration(minutes: 5)).toIso8601String(),
          ),
        );

      await tester.pumpWidget(
        _harness(
          child: PhoneAuthScreen(clock: () => now),
          repository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('auth_phone_field')),
        '09121234567',
      );
      await tester.tap(find.byKey(const Key('auth_phone_send')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth_otp_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_otp_verify')), findsOneWidget);
      expect(find.byKey(const Key('auth_phone_resend')), findsOneWidget);
      expect(tester.takeException(), isNull);

      final verifySize = tester.getSize(
        find.byKey(const Key('auth_otp_verify')),
      );
      expect(verifySize.width, greaterThanOrEqualTo(AppTokens.minTouchTarget));
      expect(verifySize.height, greaterThanOrEqualTo(AppTokens.minTouchTarget));
    },
  );
}
