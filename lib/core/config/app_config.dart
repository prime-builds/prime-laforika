/// Compile-time environment identity for Laforika.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment parse(String value) {
    return switch (value) {
      'dev' => AppEnvironment.dev,
      'staging' => AppEnvironment.staging,
      'prod' => AppEnvironment.prod,
      _ => throw const FormatException('Unsupported APP_ENVIRONMENT'),
    };
  }

  String get wireName => name;
}

/// Local diagnostic verbosity.
enum AppLogLevel {
  debug,
  info,
  warning,
  error;

  static AppLogLevel parse(String value) {
    return switch (value) {
      'debug' => AppLogLevel.debug,
      'info' => AppLogLevel.info,
      'warning' => AppLogLevel.warning,
      'error' => AppLogLevel.error,
      _ => throw const FormatException('Unsupported APP_LOG_LEVEL'),
    };
  }
}

/// Immutable application configuration contract owned by `core/config`.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.logLevel,
    required this.featureFlags,
  });

  final AppEnvironment environment;

  /// Required API base URL including the `/v1` prefix (e.g. `http://10.0.2.2:3000/v1`).
  final String apiBaseUrl;
  final AppLogLevel logLevel;
  final Map<String, bool> featureFlags;
}
