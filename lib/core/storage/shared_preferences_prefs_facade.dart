import 'package:shared_preferences/shared_preferences.dart';

import 'package:laforika/core/storage/prefs_facade.dart';

/// Concrete [PrefsFacade] backed by [SharedPreferences].
final class SharedPreferencesPrefsFacade implements PrefsFacade {
  SharedPreferencesPrefsFacade(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesPrefsFacade> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesPrefsFacade(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}
