import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:laforika/features/notifications/notifications.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../support/test_prefs.dart';

class _Gateway implements AuthSessionGateway {
  _Gateway(this._hydrate);

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
  Future<Result<void>> logoutCurrent() async {
    _accessToken = null;
    return const Success(null);
  }

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

Future<ProviderContainer> _pumpNotifications(
  WidgetTester tester, {
  List<dynamic> extraOverrides = const <dynamic>[],
  Size? physicalSize,
  double textScale = 1.0,
}) async {
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  if (physicalSize != null) {
    tester.view.physicalSize = physicalSize;
    tester.view.devicePixelRatio = 1.0;
  }
  tester.platformDispatcher.textScaleFactorTestValue = textScale;

  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authSessionGatewayProvider.overrideWithValue(
          _Gateway(const AuthAuthenticated(AuthPrincipal(accountId: 'acc-n'))),
        ),
        testPrefsOverride(),
        ...extraOverrides,
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
  container.read(goRouterProvider).go(notificationsRoutePath);
  await tester.pump();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('production empty state with Profile dock selected', (
    tester,
  ) async {
    await _pumpNotifications(tester);
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));

    expect(find.byKey(const Key('notifications_screen')), findsOneWidget);
    expect(find.byKey(const Key('notifications_empty')), findsOneWidget);
    expect(find.text(l10n.notificationsEmptyTitle), findsOneWidget);
    expect(find.byKey(const Key('notifications_list')), findsNothing);
    expect(find.byKey(const Key('shell_dock_profile')), findsOneWidget);
    expect(find.byKey(const Key('shell_dock_home')), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    expect(find.byType(AdaptiveModuleStrip), findsNothing);
    expect(find.byKey(const Key('notifications_back')), findsOneWidget);
  });

  testWidgets('loading state shows progress', (tester) async {
    await _pumpNotifications(
      tester,
      extraOverrides: [
        notificationsControllerProvider.overrideWith(_HangingInbox.new),
      ],
    );
    await tester.pump();
    expect(find.byKey(const Key('notifications_loading')), findsOneWidget);
  });

  testWidgets('error state retries once', (tester) async {
    await _pumpNotifications(
      tester,
      extraOverrides: [
        notificationsControllerProvider.overrideWith(_ErrorThenEmpty.new),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notifications_error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('notifications_retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notifications_empty')), findsOneWidget);
  });

  testWidgets('test-only data state lists items', (tester) async {
    await _pumpNotifications(
      tester,
      extraOverrides: [
        notificationsControllerProvider.overrideWith(_DataInbox.new),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notifications_list')), findsOneWidget);
    expect(find.byKey(const Key('notifications_item_n1')), findsOneWidget);
    expect(
      find.text('عنوان طولانی اعلان برای پیچیدن متن فارسی'),
      findsOneWidget,
    );
  });

  testWidgets('320dp and textScale 2.0 empty state', (tester) async {
    await _pumpNotifications(
      tester,
      physicalSize: const Size(320, 640),
      textScale: 2.0,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notifications_empty')), findsOneWidget);
    expect(find.byKey(const Key('notifications_back')), findsOneWidget);
  });
}

class _HangingInbox extends NotificationsController {
  @override
  Future<List<NotificationListItem>> build() =>
      Completer<List<NotificationListItem>>().future;
}

class _ErrorThenEmpty extends NotificationsController {
  var _attempt = 0;

  @override
  Future<List<NotificationListItem>> build() async {
    _attempt += 1;
    if (_attempt == 1) {
      throw StateError('fixture');
    }
    return const <NotificationListItem>[];
  }
}

class _DataInbox extends NotificationsController {
  @override
  Future<List<NotificationListItem>> build() async {
    return const [
      NotificationListItem(
        id: 'n1',
        title: 'عنوان طولانی اعلان برای پیچیدن متن فارسی',
        body: 'متن بدنه اعلان نمونه برای آزمون نمایش و پیمایش.',
        unread: true,
      ),
      NotificationListItem(id: 'n2', title: 'خوانده‌شده', body: 'بدنه کوتاه'),
    ];
  }
}
