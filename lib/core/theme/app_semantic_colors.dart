import 'package:flutter/material.dart';

/// Approved Laforika semantic palette (ADR-0009 / UI_FOUNDATION).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.appBackground,
    required this.primarySurface,
    required this.secondarySurface,
    required this.elevatedSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.border,
    required this.brandAccent,
    required this.onBrandAccent,
    required this.subtleSelection,
    required this.error,
    required this.success,
  });

  final Color appBackground;
  final Color primarySurface;
  final Color secondarySurface;
  final Color elevatedSurface;
  final Color primaryText;
  final Color secondaryText;
  final Color border;
  final Color brandAccent;
  final Color onBrandAccent;
  final Color subtleSelection;
  final Color error;
  final Color success;

  static const AppSemanticColors light = AppSemanticColors(
    appBackground: Color(0xFFF3F3F3),
    primarySurface: Color(0xFFFFFFFF),
    secondarySurface: Color(0xFFF9F9F9),
    elevatedSurface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF242424),
    secondaryText: Color(0xFF616161),
    border: Color(0xFFE5E5E5),
    brandAccent: Color(0xFF0067C0),
    onBrandAccent: Color(0xFFFFFFFF),
    subtleSelection: Color(0xFFE5F1FB),
    error: Color(0xFFC42B1C),
    success: Color(0xFF107C10),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    appBackground: Color(0xFF202020),
    primarySurface: Color(0xFF2C2C2C),
    secondarySurface: Color(0xFF252525),
    elevatedSurface: Color(0xFF323232),
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFC7C7C7),
    border: Color(0xFF454545),
    brandAccent: Color(0xFF60CDFF),
    onBrandAccent: Color(0xFF003E5A),
    subtleSelection: Color(0xFF0F3A4F),
    error: Color(0xFFFF99A4),
    success: Color(0xFF6CCB5F),
  );

  @override
  AppSemanticColors copyWith({
    Color? appBackground,
    Color? primarySurface,
    Color? secondarySurface,
    Color? elevatedSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? border,
    Color? brandAccent,
    Color? onBrandAccent,
    Color? subtleSelection,
    Color? error,
    Color? success,
  }) {
    return AppSemanticColors(
      appBackground: appBackground ?? this.appBackground,
      primarySurface: primarySurface ?? this.primarySurface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      border: border ?? this.border,
      brandAccent: brandAccent ?? this.brandAccent,
      onBrandAccent: onBrandAccent ?? this.onBrandAccent,
      subtleSelection: subtleSelection ?? this.subtleSelection,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      secondarySurface: Color.lerp(
        secondarySurface,
        other.secondarySurface,
        t,
      )!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      onBrandAccent: Color.lerp(onBrandAccent, other.onBrandAccent, t)!,
      subtleSelection: Color.lerp(subtleSelection, other.subtleSelection, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension AppSemanticColorsX on ThemeData {
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
