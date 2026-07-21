import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/config/app_config.dart';

/// Must be overridden at the application root with a validated [AppConfig].
final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError(
    'appConfigProvider must be overridden in ProviderScope at bootstrap.',
  );
});
