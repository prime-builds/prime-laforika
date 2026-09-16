import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/router/app_router.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/profile/profile.dart';

import '../../core/theme/tolerant_golden_comparator.dart';
import '../../support/fake_auth_repository.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFonts();
    goldenFileComparator = TolerantGoldenComparator(
      Uri.parse('test/app/shell/wp07_visual_hardening_golden_test.dart'),
      precisionTolerance: 0.02,
    );
  });

  testWidgets('guest Profile golden light RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(
            _GoldenGateway(const AuthUnauthenticated()),
          ),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go(profileRoutePath);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_guest_auth')), findsOneWidget);
    expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
    expect(find.byKey(const Key('shell_dock_profile')), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/profile_guest_light_rtl.png'),
    );
  });

  testWidgets('direct phone auth golden light RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(
            _GoldenGateway(const AuthUnauthenticated()),
          ),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go(authRoutePath);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth_phone_field')), findsOneWidget);
    expect(find.byKey(const Key('auth_phone_send')), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/phone_auth_light_rtl.png'),
    );
  });

  testWidgets('Account Security golden dark RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;

    final authRepo = FakeAuthRepository()
      ..meResult = const Success(AccountMeDto(accountId: 'golden-account'))
      ..sessionsResult = const Success([
        SessionDto(
          sessionId: 's-current',
          deviceLabel: 'سامسونگ گلکسی اس ۲۴',
          createdAt: '2026-09-17T00:00:00.000Z',
          lastSeenAt: '2026-09-17T01:00:00.000Z',
          isCurrent: true,
        ),
        SessionDto(
          sessionId: 's-laptop',
          deviceLabel: 'مرورگر کروم ویندوز',
          createdAt: '2026-09-16T12:00:00.000Z',
          lastSeenAt: '2026-09-16T18:00:00.000Z',
          isCurrent: false,
        ),
      ]);

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_config),
          authSessionGatewayProvider.overrideWithValue(
            _GoldenGateway(
              const AuthAuthenticated(
                AuthPrincipal(accountId: 'golden-account'),
              ),
            ),
          ),
          authRepositoryProvider.overrideWithValue(authRepo),
          testPrefsOverride(),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const LaforikaApp();
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go(accountSecurityRoutePath);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account_security_screen')), findsOneWidget);
    expect(find.byKey(const Key('account_session_s-current')), findsOneWidget);
    expect(find.byKey(const Key('account_session_s-laptop')), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/account_security_dark_rtl.png'),
    );
  });

  testWidgets('module fixture compact golden dark RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      shellHarness(theme: buildDarkTheme(), child: const ShellFixtureHost()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ماژول ۱'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('fixture_body')),
      const Offset(0, -80),
    );
    await tester.pump();
    await tester.pump(AppTokens.motionStandard);

    expect(find.text('ماژول ۱'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/module_fixture_compact_dark_rtl.png'),
    );
  });
}
