/// Thin non-sensitive preferences contract for installation-level UI state.
abstract interface class PrefsFacade {
  /// Returns the stored string for [key], or `null` when absent.
  String? getString(String key);

  /// Persists [value] for [key].
  Future<void> setString(String key, String value);
}
