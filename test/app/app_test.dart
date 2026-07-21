import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/fatal_startup_app.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testConfig = AppConfig(
    environment: AppEnvironment.dev,
    apiBaseUrl: null,
    logLevel: AppLogLevel.debug,
    featureFlags: <String, bool>{},
  );

  testWidgets('LaforikaApp uses fa-IR, RTL, and localized Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(testConfig)],
        child: const LaforikaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('fa', 'IR'));
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(find.text('لفوریکا آماده است'), findsOneWidget);
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
}
