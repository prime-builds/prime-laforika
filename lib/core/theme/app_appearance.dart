import 'package:flutter/material.dart';

/// Installation-level appearance modes approved by ADR-0009.
enum AppAppearance {
  system,
  light,
  dark;

  ThemeMode get themeMode => switch (this) {
    AppAppearance.system => ThemeMode.system,
    AppAppearance.light => ThemeMode.light,
    AppAppearance.dark => ThemeMode.dark,
  };
}

/// Centralized preference key for appearance persistence.
abstract final class AppAppearancePrefsKeys {
  static const String appearanceMode = 'laforika.appearance.mode';
}

/// Stable serialization for [AppAppearance].
abstract final class AppAppearanceCodec {
  static const String system = 'system';
  static const String light = 'light';
  static const String dark = 'dark';

  static String encode(AppAppearance appearance) => switch (appearance) {
    AppAppearance.system => system,
    AppAppearance.light => light,
    AppAppearance.dark => dark,
  };

  /// Missing or unknown values fall back to [AppAppearance.system].
  static AppAppearance decode(String? raw) {
    return switch (raw) {
      system => AppAppearance.system,
      light => AppAppearance.light,
      dark => AppAppearance.dark,
      _ => AppAppearance.system,
    };
  }
}
