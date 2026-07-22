/// Converts Persian/Arabic-Indic digits to Latin digits for transport.
String toLatinDigits(String input) {
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final persianIndex = persian.indexOf(char);
    if (persianIndex >= 0) {
      buffer.write(persianIndex);
      continue;
    }
    final arabicIndex = arabic.indexOf(char);
    if (arabicIndex >= 0) {
      buffer.write(arabicIndex);
      continue;
    }
    buffer.write(char);
  }
  return buffer.toString();
}

/// Validates a preserved return destination against known internal routes.
bool isValidReturnDestination(
  String? destination, {
  required Set<String> registeredPaths,
  required Set<String> authOnlyPaths,
  required String startupPath,
}) {
  if (destination == null || destination.isEmpty) {
    return false;
  }
  final uri = Uri.tryParse(destination);
  if (uri == null) {
    return false;
  }
  if (uri.hasScheme || uri.hasAuthority) {
    return false;
  }
  final path = uri.path.isEmpty ? '/' : uri.path;
  if (path == startupPath) {
    return false;
  }
  if (authOnlyPaths.contains(path)) {
    return false;
  }
  return registeredPaths.contains(path);
}
