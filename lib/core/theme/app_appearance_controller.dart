import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/storage/prefs_facade.dart';
import 'package:laforika/core/storage/prefs_facade_provider.dart';
import 'package:laforika/core/theme/app_appearance.dart';

/// Owns installation-level appearance state for the application lifetime.
///
/// Kept alive because theme mode must remain stable across the process and is
/// restored once from non-sensitive preferences before first paint.
class AppAppearanceController extends Notifier<AppAppearance> {
  @override
  AppAppearance build() {
    ref.keepAlive();
    return _readStoredAppearance();
  }

  PrefsFacade get _prefs => ref.read(prefsFacadeProvider);

  AppAppearance _readStoredAppearance() {
    try {
      return AppAppearanceCodec.decode(
        _prefs.getString(AppAppearancePrefsKeys.appearanceMode),
      );
    } on Object {
      _reportSanitizedDiagnostic(
        'Appearance preference read failed; using System default.',
      );
      return AppAppearance.system;
    }
  }

  Future<void> setAppearance(AppAppearance appearance) async {
    state = appearance;
    try {
      await _prefs.setString(
        AppAppearancePrefsKeys.appearanceMode,
        AppAppearanceCodec.encode(appearance),
      );
    } on Object {
      _reportSanitizedDiagnostic(
        'Appearance preference write failed; in-memory mode retained.',
      );
    }
  }

  void _reportSanitizedDiagnostic(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'laforika.appearance');
    }
  }
}

final appAppearanceControllerProvider =
    NotifierProvider<AppAppearanceController, AppAppearance>(
      AppAppearanceController.new,
    );
