import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/storage/secure_store.dart';

/// Environment-scoped storage key for Laforika-owned secrets.
String scopedSecureStorageKey(AppEnvironment environment, String key) {
  return '${environment.wireName}:$key';
}

/// Environment-partitioned [SecureStore] backed by [FlutterSecureStorage].
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore({
    required this._environment,
    FlutterSecureStorage? storage,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(),
             iOptions: IOSOptions(
               accessibility: KeychainAccessibility.first_unlock_this_device,
             ),
           );

  final AppEnvironment _environment;
  final FlutterSecureStorage _storage;

  String _scoped(String key) => scopedSecureStorageKey(_environment, key);

  @override
  Future<String?> read(String key) => _storage.read(key: _scoped(key));

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: _scoped(key), value: value);
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: _scoped(key));

  @override
  Future<void> deleteAllForEnvironment() async {
    final all = await _storage.readAll();
    final prefix = '${_environment.wireName}:';
    for (final key in all.keys) {
      if (key.startsWith(prefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
