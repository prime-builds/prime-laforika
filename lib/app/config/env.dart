import 'dart:convert';

import 'package:laforika/core/config/app_config.dart';

/// Compile-time keys supplied via `--dart-define` / `--dart-define-from-file`.
///
/// - `APP_FLAVOR`: native flavor name (`dev` | `staging` | `prod`)
/// - `APP_ENVIRONMENT`: config environment; must match `APP_FLAVOR`
/// - `API_BASE_URL`: required API base URL; HTTPS required for non-dev
/// - `APP_LOG_LEVEL`: `debug` | `info` | `warning` | `error`
/// - `FEATURE_FLAGS_JSON`: JSON object of string → boolean flags
abstract final class Env {
  /// Loads and validates configuration from compile-time defines.
  ///
  /// Throws [FormatException] when required values are missing, unsupported,
  /// mismatched, or unsafe. Callers must not surface raw exception text in UI.
  static AppConfig load({
    String flavor = const String.fromEnvironment('APP_FLAVOR'),
    String environment = const String.fromEnvironment('APP_ENVIRONMENT'),
    String apiBaseUrl = const String.fromEnvironment('API_BASE_URL'),
    String logLevel = const String.fromEnvironment('APP_LOG_LEVEL'),
    String featureFlagsJson = const String.fromEnvironment(
      'FEATURE_FLAGS_JSON',
      defaultValue: '{}',
    ),
  }) {
    return parse(
      flavor: flavor,
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      logLevel: logLevel,
      featureFlagsJson: featureFlagsJson,
    );
  }

  /// Pure parsing entry point used by bootstrap and unit tests.
  static AppConfig parse({
    required String flavor,
    required String environment,
    required String apiBaseUrl,
    required String logLevel,
    required String featureFlagsJson,
  }) {
    if (flavor.isEmpty) {
      throw const FormatException('Missing APP_FLAVOR');
    }
    if (environment.isEmpty) {
      throw const FormatException('Missing APP_ENVIRONMENT');
    }
    if (logLevel.isEmpty) {
      throw const FormatException('Missing APP_LOG_LEVEL');
    }

    final parsedEnvironment = AppEnvironment.parse(environment);
    final parsedFlavor = AppEnvironment.parse(flavor);
    if (parsedFlavor != parsedEnvironment) {
      throw const FormatException('APP_FLAVOR does not match APP_ENVIRONMENT');
    }

    final parsedLogLevel = AppLogLevel.parse(logLevel);
    final flags = _parseFeatureFlags(featureFlagsJson);
    final normalizedUrl = _requireApiBaseUrl(
      apiBaseUrl: apiBaseUrl,
      environment: parsedEnvironment,
    );

    return AppConfig(
      environment: parsedEnvironment,
      apiBaseUrl: normalizedUrl,
      logLevel: parsedLogLevel,
      featureFlags: flags,
    );
  }

  static Map<String, bool> _parseFeatureFlags(String raw) {
    final value = raw.trim().isEmpty ? '{}' : raw;
    late final Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      throw const FormatException('Malformed FEATURE_FLAGS_JSON');
    }

    if (decoded is! Map) {
      throw const FormatException('FEATURE_FLAGS_JSON must be a JSON object');
    }

    final flags = <String, bool>{};
    decoded.forEach((key, entry) {
      if (key is! String || entry is! bool) {
        throw const FormatException(
          'FEATURE_FLAGS_JSON entries must be string to boolean',
        );
      }
      flags[key] = entry;
    });
    return Map<String, bool>.unmodifiable(flags);
  }

  static String _requireApiBaseUrl({
    required String apiBaseUrl,
    required AppEnvironment environment,
  }) {
    final trimmed = apiBaseUrl.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Missing API_BASE_URL');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('Invalid API_BASE_URL');
    }

    if (environment != AppEnvironment.dev && uri.scheme != 'https') {
      throw const FormatException(
        'Non-development API_BASE_URL must use HTTPS',
      );
    }

    return trimmed;
  }
}
