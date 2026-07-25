import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';

import 'theme_specimen.dart';

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

Widget _goldenHarness(ThemeData theme) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('fa', 'IR'),
    home: const ThemeSpecimen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadVazirmatn();
  });

  testWidgets('light RTL theme specimen golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_goldenHarness(buildLightTheme()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/theme_specimen_light_rtl.png'),
    );
  });

  testWidgets('dark RTL theme specimen golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_goldenHarness(buildDarkTheme()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/theme_specimen_dark_rtl.png'),
    );
  });
}
