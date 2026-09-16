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
import 'package:laforika/features/auth/presentation/account_security_screen.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../support/fake_auth_repository.dart';

class _FakeGateway implements AuthSessionGateway {
  _FakeGateway(this.state);

  final AuthState state;

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
  Future<AuthState> hydrate() async => state;

  @override
  Future<Result<void>> logoutAll() async => const Success(null);

  @override
  Future<Result<void>> logoutCurrent() async => const Success(null);

  @override
  Future<Result<String>> refreshAccessToken() async =>
      const FailureResult(AuthFailure(code: 'NO_REFRESH'));
}

Widget _harness({
  required Widget child,
  required AuthRepository repository,
  AuthState state = const AuthAuthenticated(
    AuthPrincipal(accountId: 'test-account'),
  ),
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      authSessionGatewayProvider.overrideWithValue(_FakeGateway(state)),
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
    'account security at 320dp and textScale 2.0 renders sessions list and actions without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final fakeRepo = FakeAuthRepository()
        ..meResult = const Success(AccountMeDto(accountId: 'test-account'))
        ..sessionsResult = const Success([
          SessionDto(
            sessionId: 's-current',
            deviceLabel: 'دستگاه جاری تست سامسونگ گلکسی',
            createdAt: '2026-09-17T00:00:00.000Z',
            lastSeenAt: '2026-09-17T01:00:00.000Z',
            isCurrent: true,
          ),
          SessionDto(
            sessionId: 's-other',
            deviceLabel: 'دستگاه دوم برای لغو نشست فعال',
            createdAt: '2026-09-16T12:00:00.000Z',
            lastSeenAt: '2026-09-16T18:00:00.000Z',
            isCurrent: false,
          ),
        ]);

      await tester.pumpWidget(
        _harness(child: const AccountSecurityScreen(), repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_security_screen')), findsOneWidget);
      expect(
        find.byKey(const Key('account_session_s-current')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('account_session_s-other')), findsOneWidget);
      expect(tester.takeException(), isNull);

      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
        find.byKey(const Key('account_logout_all')),
        200,
        scrollable: scrollable,
      );

      expect(find.byKey(const Key('account_logout_current')), findsOneWidget);
      expect(find.byKey(const Key('account_logout_all')), findsOneWidget);

      final logoutCurrentSize = tester.getSize(
        find.byKey(const Key('account_logout_current')),
      );
      expect(
        logoutCurrentSize.height,
        greaterThanOrEqualTo(AppTokens.minTouchTarget),
      );

      final logoutAllSize = tester.getSize(
        find.byKey(const Key('account_logout_all')),
      );
      expect(
        logoutAllSize.height,
        greaterThanOrEqualTo(AppTokens.minTouchTarget),
      );
    },
  );
}
