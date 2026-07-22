import 'package:laforika/core/storage/secure_store.dart';

/// In-memory [SecureStore] for unit tests.
class MemorySecureStore implements SecureStore {
  final Map<String, String> _values = <String, String>{};

  Map<String, String> get values => Map.unmodifiable(_values);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAllForEnvironment() async {
    _values.clear();
  }
}
