import 'package:flutter/material.dart';

import 'package:laforika/core/theme/app_tokens.dart';

/// Builds the M0 placeholder Material 3 theme with Vazirmatn typography.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(AppTokens.seedColorValue),
    brightness: Brightness.light,
    surface: const Color(AppTokens.surfaceColorValue),
  );

  final textTheme = Typography.material2021().black.apply(
    fontFamily: AppTokens.fontFamily,
    bodyColor: const Color(AppTokens.onSurfaceColorValue),
    displayColor: const Color(AppTokens.onSurfaceColorValue),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: AppTokens.fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(AppTokens.surfaceColorValue),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
