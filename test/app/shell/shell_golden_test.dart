import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

import '../../core/theme/tolerant_golden_comparator.dart';
import 'shell_test_harness.dart';

Future<ByteData> _fontBytes(String relativePath) async {
  final file = File(relativePath);
  final bytes = await file.readAsBytes();
  return ByteData.view(bytes.buffer);
}

Future<void> _loadVazirmatn() async {
  final loader = FontLoader(AppTokens.fontFamily);
  loader.addFont(_fontBytes('assets/fonts/vazirmatn/Vazirmatn-Regular.ttf'));
  loader.addFont(_fontBytes('assets/fonts/vazirmatn/Vazirmatn-Medium.ttf'));
  loader.addFont(_fontBytes('assets/fonts/vazirmatn/Vazirmatn-SemiBold.ttf'));
  await loader.load();
}

Widget _homeShellGolden(ThemeData theme) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('fa', 'IR'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: AppShellScaffold(
        dockItems: const [
          ShellDockItem(
            id: ShellDockIds.home,
            semanticLabel: 'خانه',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
        ],
        dockSelectedId: ShellDockIds.home,
        onDockSelected: (_) {},
        search: const Padding(
          padding: EdgeInsetsDirectional.all(AppTokens.pagePadding),
          child: SizedBox(
            height: AppTokens.minTouchTarget,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(BorderSide()),
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 12),
                  child: Text('جستجو'),
                ),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          children: const [
            Text('به لفوریکا خوش آمدید'),
            SizedBox(height: 16),
            Text('امنیت حساب'),
            SizedBox(height: 400),
          ],
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadVazirmatn();
    goldenFileComparator = TolerantGoldenComparator(
      Uri.parse('test/app/shell/shell_golden_test.dart'),
      precisionTolerance: 0.02,
    );
  });

  testWidgets('production Home shell golden light RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_homeShellGolden(buildLightTheme()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_shell_light_rtl.png'),
    );
  });

  testWidgets('production Home shell golden dark RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_homeShellGolden(buildDarkTheme()));
    await tester.pumpAndSettle();
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
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/module_fixture_expanded_light_rtl.png'),
    );
  });
}
