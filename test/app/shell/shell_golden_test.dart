import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/shell/shell.dart';

import '../../core/theme/tolerant_golden_comparator.dart';
import '../../support/test_prefs.dart';
import 'shell_test_harness.dart';

Future<ByteData> _fontBytes(String relativePath) async {
  final file = File(relativePath);
  final bytes = await file.readAsBytes();
  return ByteData.view(bytes.buffer);
}

String _flutterSdkPath() {
  final localProperties = File('android/local.properties');
  final lines = localProperties.readAsLinesSync();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('flutter.sdk=')) {
      return trimmed.substring('flutter.sdk='.length).replaceAll(r'\\', r'\');
    }
  }
  throw StateError('flutter.sdk missing from android/local.properties');
}

Future<void> _loadFonts() async {
  final vazir = FontLoader(AppTokens.fontFamily);
  vazir.addFont(_fontBytes('assets/fonts/vazirmatn/Vazirmatn-Regular.ttf'));
  vazir.addFont(_fontBytes('assets/fonts/vazirmatn/Vazirmatn-Medium.ttf'));
  vazir.addFont(_fontBytes('assets/fonts/vazirmatn/Vazirmatn-SemiBold.ttf'));
  await vazir.load();

  final materialIcons = FontLoader('MaterialIcons');
  materialIcons.addFont(
    _fontBytes(
      '${_flutterSdkPath()}/bin/cache/artifacts/material_fonts/'
      'MaterialIcons-Regular.otf',
    ),
  );
  await materialIcons.load();
}

class _GoldenGateway implements AuthSessionGateway {
  _GoldenGateway(this._hydrate);

  final AuthState _hydrate;
  String? _accessToken;

  @override
  String? get accessToken => _accessToken;

  @override
  Future<AuthPrincipal> acceptCredentials({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  }) async {
    _accessToken = accessToken;
    return principal;
  }

  @override
  Future<void> clearLocalSession() async {
    _accessToken = null;
  }

  @override
  Future<AuthState> hydrate() async => _hydrate;

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

Future<void> _pumpProductionHome(
  WidgetTester tester, {
  required ThemeMode themeMode,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authSessionGatewayProvider.overrideWithValue(
          _GoldenGateway(const AuthUnauthenticated()),
        ),
        testPrefsOverride(),
      ],
      child: const LaforikaApp(),
    ),
  );
  // Appearance may still be System; force theme via MediaQuery/platform brightness
  // is already handled by AppAppearanceController default System + light binding.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();

  // Re-wrap is unnecessary when prefs default to System and surface is light.
  // For dark golden, toggle appearance through the app if needed; instead pump
  // a themed MaterialApp child when dark is requested via a second path below.
  if (themeMode == ThemeMode.dark) {
    // Dark production Home: override appearance by rebuilding under dark theme
    // using the same Home composition surface already settled, then capture
    // after forcing dark via platform brightness.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();
  } else {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFonts();
    goldenFileComparator = TolerantGoldenComparator(
      Uri.parse('test/app/shell/shell_golden_test.dart'),
      precisionTolerance: 0.02,
    );
  });

  testWidgets('production Home shell golden light RTL', (tester) async {
    await _pumpProductionHome(tester, themeMode: ThemeMode.light);
    expect(find.byType(FloatingBottomDock), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_shell_light_rtl.png'),
    );
  });

  testWidgets('production Home shell golden dark RTL', (tester) async {
    await _pumpProductionHome(tester, themeMode: ThemeMode.dark);
    expect(find.byType(FloatingBottomDock), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_shell_dark_rtl.png'),
    );
  });

  testWidgets('module fixture expanded golden light RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      shellHarness(theme: buildLightTheme(), child: const ShellFixtureHost()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ماژول ۱'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.apps), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/module_fixture_expanded_light_rtl.png'),
    );
  });
}
