import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/storage/flutter_secure_store.dart';
import 'package:laforika/core/storage/secure_store.dart';

final secureStoreProvider = Provider<SecureStore>((ref) {
  final config = ref.watch(appConfigProvider);
  return FlutterSecureStore(environment: config.environment);
});
