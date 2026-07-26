/// Server-aligned name normalization: trim and convert blank to null.
String? normalizeProfileName(String raw) {
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Server-aligned contact-email normalization: trim and convert blank to null.
String? normalizeProfileEmail(String raw) {
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Mirrors server length and conservative email syntax validation.
bool isValidProfileDraft({
  required String firstName,
  required String lastName,
  required String email,
}) {
  final normalizedFirst = normalizeProfileName(firstName);
  final normalizedLast = normalizeProfileName(lastName);
  final normalizedEmail = normalizeProfileEmail(email);
  if (normalizedFirst != null && normalizedFirst.runes.length > 100) {
    return false;
  }
  if (normalizedLast != null && normalizedLast.runes.length > 100) {
    return false;
  }
  if (normalizedEmail == null) {
    return true;
  }
  if (normalizedEmail.length > 254 || normalizedEmail.contains('..')) {
    return false;
  }
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail);
}
