/// Centralized non-color design tokens for Laforika UI foundation.
abstract final class AppTokens {
  static const String fontFamily = 'Vazirmatn';

  // Spacing (8dp foundation).
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  /// Normal page padding starts at 16dp.
  static const double pagePadding = spaceMd;

  static const double minTouchTarget = 48;

  // Component radii (12–16dp range).
  static const double radiusSm = 12;
  static const double radiusMd = 16;

  /// Reserved for the future floating dock (M03_WP04); no dock widget here.
  static const double radiusDock = 28;

  static const double borderWidth = 1;

  // Subtle elevation.
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 2;

  // Motion (~180–250ms).
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionStandard = Duration(milliseconds: 200);
  static const Duration motionEmphasized = Duration(milliseconds: 250);
}
