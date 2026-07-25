import 'package:laforika/core/storage/prefs_facade.dart';

/// Process-local [PrefsFacade] for tests and non-fatal preference failures.
final class InMemoryPrefsFacade implements PrefsFacade {
  InMemoryPrefsFacade([Map<String, String>? seed])
    : _values = <String, String>{...?seed};

  final Map<String, String> _values;

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
