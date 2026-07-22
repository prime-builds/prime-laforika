/// Redacts sensitive keys from HTTP log payloads.
abstract final class HttpRedactor {
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'password',
    'newPassword',
    'currentPassword',
    'refreshToken',
    'accessToken',
    'token',
    'code',
    'otp',
    'email',
    'phone',
    'phoneNumber',
    'x-fixture-key',
  };

  static Object? redact(Object? value) {
    if (value is Map) {
      return value.map((key, entry) {
        final keyText = key.toString();
        if (_isSensitive(keyText)) {
          return MapEntry(key, '***');
        }
        return MapEntry(key, redact(entry));
      });
    }
    if (value is List) {
      return value.map(redact).toList(growable: false);
    }
    return value;
  }

  static Map<String, dynamic> redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (_isSensitive(key)) {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }

  static bool _isSensitive(String key) {
    final normalized = key.toLowerCase().replaceAll('_', '');
    return _sensitiveKeys.any(
      (candidate) =>
          normalized == candidate.toLowerCase().replaceAll('_', '') ||
          normalized.contains(candidate.toLowerCase().replaceAll('_', '')),
    );
  }
}
