import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:laforika/core/storage/in_memory_prefs_facade.dart';
import 'package:laforika/core/storage/prefs_facade.dart';
import 'package:laforika/core/storage/prefs_facade_provider.dart';
import 'package:laforika/core/theme/app_appearance.dart';

/// Default in-memory prefs override for widget tests using [LaforikaApp].
Override testPrefsOverride([PrefsFacade? prefs]) {
  return prefsFacadeProvider.overrideWithValue(prefs ?? InMemoryPrefsFacade());
}

/// Prefs seeded with a stored appearance mode.
Override testPrefsOverrideWithAppearance(AppAppearance appearance) {
  return prefsFacadeProvider.overrideWithValue(
    InMemoryPrefsFacade({
      AppAppearancePrefsKeys.appearanceMode: AppAppearanceCodec.encode(
        appearance,
      ),
    }),
  );
}
