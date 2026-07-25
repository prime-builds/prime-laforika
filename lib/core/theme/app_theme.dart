import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/core/theme/app_tokens.dart';

/// Builds the approved Material 3 light theme.
ThemeData buildLightTheme() => _buildTheme(AppSemanticColors.light);

/// Builds the approved Material 3 dark theme.
ThemeData buildDarkTheme() => _buildTheme(AppSemanticColors.dark);

ThemeData _buildTheme(AppSemanticColors colors) {
  final brightness = identical(colors, AppSemanticColors.dark)
      ? Brightness.dark
      : Brightness.light;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: colors.brandAccent,
    onPrimary: colors.onBrandAccent,
    secondary: colors.subtleSelection,
    onSecondary: colors.primaryText,
    error: colors.error,
    onError: brightness == Brightness.dark
        ? colors.appBackground
        : const Color(0xFFFFFFFF),

    surface: colors.primarySurface,
    onSurface: colors.primaryText,
    surfaceContainerHighest: colors.secondarySurface,
    surfaceContainerHigh: colors.elevatedSurface,
    outline: colors.border,
    outlineVariant: colors.border,
    shadow: Colors.black.withValues(alpha: 0.18),
    scrim: Colors.black.withValues(alpha: 0.4),
    inverseSurface: colors.primaryText,
    onInverseSurface: colors.primarySurface,
    inversePrimary: colors.brandAccent,
  );

  final baseTextTheme = brightness == Brightness.dark
      ? Typography.material2021().white
      : Typography.material2021().black;

  final textTheme = baseTextTheme.apply(
    fontFamily: AppTokens.fontFamily,
    bodyColor: colors.primaryText,
    displayColor: colors.primaryText,
  );

  final secondaryLabelStyle = textTheme.bodyMedium?.copyWith(
    color: colors.secondaryText,
    fontWeight: FontWeight.w400,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    fontFamily: AppTokens.fontFamily,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: colors.appBackground,
    canvasColor: colors.appBackground,
    dividerColor: colors.border,
    extensions: <ThemeExtension<dynamic>>[colors],
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primarySurface,
      foregroundColor: colors.primaryText,
      elevation: AppTokens.elevationNone,
      scrolledUnderElevation: AppTokens.elevationLow,
      centerTitle: true,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: colors.elevatedSurface,
      elevation: AppTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: BorderSide(color: colors.border, width: AppTokens.borderWidth),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.border,
      thickness: AppTokens.borderWidth,
      space: AppTokens.spaceMd,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.secondarySurface,
      hintStyle: secondaryLabelStyle,
      labelStyle: secondaryLabelStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: BorderSide(
          color: colors.border,
          width: AppTokens.borderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: BorderSide(
          color: colors.border,
          width: AppTokens.borderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: BorderSide(
          color: colors.brandAccent,
          width: AppTokens.borderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: BorderSide(
          color: colors.error,
          width: AppTokens.borderWidth,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.brandAccent,
        foregroundColor: colors.onBrandAccent,
        disabledBackgroundColor: colors.border,
        disabledForegroundColor: colors.secondaryText,
        minimumSize: const Size(
          AppTokens.minTouchTarget,
          AppTokens.minTouchTarget,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.elevatedSurface,
        foregroundColor: colors.primaryText,
        disabledBackgroundColor: colors.secondarySurface,
        disabledForegroundColor: colors.secondaryText,
        elevation: AppTokens.elevationLow,
        minimumSize: const Size(
          AppTokens.minTouchTarget,
          AppTokens.minTouchTarget,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          side: BorderSide(color: colors.border, width: AppTokens.borderWidth),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.brandAccent,
        disabledForegroundColor: colors.secondaryText,
        minimumSize: const Size(
          AppTokens.minTouchTarget,
          AppTokens.minTouchTarget,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primaryText,
        disabledForegroundColor: colors.secondaryText,
        side: BorderSide(color: colors.border, width: AppTokens.borderWidth),
        minimumSize: const Size(
          AppTokens.minTouchTarget,
          AppTokens.minTouchTarget,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.brandAccent,
      circularTrackColor: colors.subtleSelection,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.elevatedSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colors.primaryText,
      ),
      actionTextColor: colors.brandAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.elevatedSurface,
      elevation: AppTokens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.elevatedSurface,
      elevation: AppTokens.elevationMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusMd),
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.brandAccent,
      selectionColor: colors.subtleSelection,
      selectionHandleColor: colors.brandAccent,
    ),
  );
}
