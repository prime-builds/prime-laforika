import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/fatal_startup_app.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/theme/app_appearance.dart';
import 'package:laforika/core/theme/app_appearance_controller.dart';
import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../support/test_prefs.dart';

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

  Future<void> pumpApp(WidgetTester tester, {Override? prefsOverride}) async {
    final gateway = _FakeGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          authSessionGatewayProvider.overrideWithValue(gateway),
          prefsOverride ?? testPrefsOverride(),
        ],
        child: const LaforikaApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('LaforikaApp uses fa-IR and RTL', (tester) async {
    await pumpApp(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('fa', 'IR'));
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('default appearance is ThemeMode.system', (tester) async {
    await pumpApp(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.brightness, Brightness.light);
    expect(app.darkTheme?.brightness, Brightness.dark);
  });

  testWidgets('stored light appearance produces light root theme', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefsOverride: testPrefsOverrideWithAppearance(AppAppearance.light),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(
      app.theme?.scaffoldBackgroundColor,
      AppSemanticColors.light.appBackground,
    );
  });

  testWidgets('stored dark appearance produces dark root theme', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefsOverride: testPrefsOverrideWithAppearance(AppAppearance.dark),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      app.darkTheme?.scaffoldBackgroundColor,
      AppSemanticColors.dark.appBackground,
    );
  });

  testWidgets('changing controller mode updates rendered root theme', (
    tester,
  ) async {
    final gateway = _FakeGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          authSessionGatewayProvider.overrideWithValue(gateway),
          testPrefsOverride(),
        ],
        child: const LaforikaApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final element = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(element);
    await container
        .read(appAppearanceControllerProvider.notifier)
        .setAppearance(AppAppearance.dark);
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
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

  testWidgets('FatalStartupApp follows light system brightness', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(() {
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    await tester.pumpWidget(const FatalStartupApp());
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(
      scaffold.backgroundColor ??
          Theme.of(
            tester.element(find.byType(Scaffold)),
          ).scaffoldBackgroundColor,
      AppSemanticColors.light.appBackground,
    );
  });

  testWidgets('FatalStartupApp follows dark system brightness', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(() {
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    await tester.pumpWidget(const FatalStartupApp());
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });
}
