import 'package:dio/dio.dart';

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
    'destination',
    'purpose',
    'challengeId',
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

  /// Path only — never includes query or fragment.
  static String redactUri(Uri uri) {
    final path = uri.path;
    return path.isEmpty ? '/' : path;
  }

  /// Safe log target: method callers should pair with [RequestOptions.method].
  static String safeRequestPath(RequestOptions options) {
    return redactUri(options.uri);
  }

  /// Redacts sensitive query parameter values; non-sensitive values are kept.
  static Map<String, String> redactQueryParameters(Map<String, dynamic> query) {
    return query.map((key, value) {
      final keyText = key.toString();
      if (_isSensitive(keyText)) {
        return MapEntry(keyText, '***');
      }
      return MapEntry(keyText, value?.toString() ?? '');
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
