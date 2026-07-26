/// Local Home discovery search helpers (no network / persistence).
library;

String normalizeHomeSearchQuery(String raw) {
  return raw.trim().toLowerCase();
}

/// Whether [haystack] contains [query] after normalization.
///
/// Empty [query] matches everything.
bool homeSearchMatches({
  required String query,
  required Iterable<String> haystackParts,
}) {
  final normalized = normalizeHomeSearchQuery(query);
  if (normalized.isEmpty) {
    return true;
  }
  final haystack = haystackParts
      .map(normalizeHomeSearchQuery)
      .where((part) => part.isNotEmpty)
      .join(' ');
  return haystack.contains(normalized);
}
