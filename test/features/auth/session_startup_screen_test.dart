import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/presentation/session_startup_screen.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

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
  required AuthState state,
  Size physicalSize = const Size(320, 568),
  double textScale = 2.0,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: Size(physicalSize.width, physicalSize.height),
      textScaler: TextScaler.linear(textScale),
    ),
    child: ProviderScope(
      overrides: [
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
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'startup loading at 320dp and textScale 2.0 renders without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _harness(
          state: const AuthUnknown(),
          child: const SessionStartupScreen(),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('startup_loading')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'startup error at 320dp and textScale 2.0 renders retry button >= 48dp without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _harness(
          state: const AuthHydrationError(),
          child: const SessionStartupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('startup_error')), findsOneWidget);
      expect(find.byKey(const Key('startup_retry')), findsOneWidget);
      expect(tester.takeException(), isNull);

      final retrySize = tester.getSize(find.byKey(const Key('startup_retry')));
      expect(retrySize.width, greaterThanOrEqualTo(AppTokens.minTouchTarget));
      expect(retrySize.height, greaterThanOrEqualTo(AppTokens.minTouchTarget));
    },
  );
}
