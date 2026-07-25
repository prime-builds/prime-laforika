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

/// Path-only policy for preserved return destinations.
///
/// Current app routes carry no reconstructable query state that must survive
/// login. Query parameters and URI fragments are therefore **rejected** (not
/// stripped) so ephemeral or attacker-controlled state cannot ride through
/// `/auth?from=…`. Successful validation returns the canonical registered path
/// only (no query, no fragment).
String? canonicalizeReturnDestination(
  String? destination, {
  required Set<String> registeredPaths,
  required Set<String> authOnlyPaths,
  required String startupPath,
}) {
  if (destination == null || destination.isEmpty) {
    return null;
  }
  // Reject absolute / protocol-relative forms before URI parsing quirks.
  if (destination.contains('://') || destination.startsWith('//')) {
    return null;
  }
  // Path-only: reject query and fragment markers rather than silently discarding.
  if (destination.contains('?') || destination.contains('#')) {
    return null;
  }
  final uri = Uri.tryParse(destination);
  if (uri == null) {
    return null;
  }
  if (uri.hasScheme || uri.hasAuthority) {
    return null;
  }
  if (uri.hasQuery || uri.fragment.isNotEmpty) {
    return null;
  }
  final path = uri.path.isEmpty ? '/' : uri.path;
  if (path == startupPath) {
    return null;
  }
  if (authOnlyPaths.contains(path)) {
    return null;
  }
  if (!registeredPaths.contains(path)) {
    return null;
  }
  return path;
}

/// Whether [destination] is a valid path-only internal return destination.
bool isValidReturnDestination(
  String? destination, {
  required Set<String> registeredPaths,
  required Set<String> authOnlyPaths,
  required String startupPath,
}) {
  return canonicalizeReturnDestination(
        destination,
        registeredPaths: registeredPaths,
        authOnlyPaths: authOnlyPaths,
        startupPath: startupPath,
      ) !=
      null;
}
