import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';

import 'theme_specimen.dart';

Widget _harness({
  required ThemeData theme,
  double width = 390,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: theme,
    locale: const Locale('fa', 'IR'),
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: const ThemeSpecimen(),
    ),
  );
}

void main() {
  testWidgets('theme specimen fits 320dp width without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_harness(theme: buildLightTheme(), width: 320));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ThemeSpecimen), findsOneWidget);
  });

  testWidgets('theme specimen supports 2.0 text scale without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_harness(theme: buildDarkTheme(), textScale: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final button = tester.getSize(find.widgetWithText(FilledButton, 'اصلی'));
    expect(button.height, greaterThanOrEqualTo(AppTokens.minTouchTarget));
  });
}
