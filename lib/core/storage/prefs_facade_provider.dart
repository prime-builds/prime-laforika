import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/storage/prefs_facade.dart';

/// Overridden in bootstrap with a loaded [PrefsFacade] instance.
///
/// Kept alive for the application lifetime so appearance restoration stays
/// deterministic after the one-time SharedPreferences load.
final prefsFacadeProvider = Provider<PrefsFacade>((ref) {
  throw UnimplementedError(
    'prefsFacadeProvider must be overridden in bootstrap',
  );
});
