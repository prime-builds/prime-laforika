import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/config/env.dart';
import 'package:laforika/core/config/app_config.dart';

void main() {
  group('Env.parse', () {
    test('accepts a valid matching configuration', () {
      final config = Env.parse(
        flavor: 'dev',
        environment: 'dev',
        apiBaseUrl: '',
        logLevel: 'debug',
        featureFlagsJson: '{"homeEnabled":true}',
      );

      expect(config.environment, AppEnvironment.dev);
      expect(config.apiBaseUrl, isNull);
      expect(config.logLevel, AppLogLevel.debug);
      expect(config.featureFlags, <String, bool>{'homeEnabled': true});
    });

    final failureCases =
        <
          ({
            String name,
            String flavor,
            String environment,
            String apiBaseUrl,
            String logLevel,
            String featureFlagsJson,
          })
        >[
          (
            name: 'flavor/environment mismatch',
            flavor: 'dev',
            environment: 'prod',
            apiBaseUrl: '',
            logLevel: 'debug',
            featureFlagsJson: '{}',
          ),
          (
            name: 'missing environment',
            flavor: 'dev',
            environment: '',
            apiBaseUrl: '',
            logLevel: 'debug',
            featureFlagsJson: '{}',
          ),
          (
            name: 'unsupported environment',
            flavor: 'qa',
            environment: 'qa',
            apiBaseUrl: '',
            logLevel: 'debug',
            featureFlagsJson: '{}',
          ),
          (
            name: 'invalid log level',
            flavor: 'dev',
            environment: 'dev',
            apiBaseUrl: '',
            logLevel: 'verbose',
            featureFlagsJson: '{}',
          ),
          (
            name: 'malformed feature flags',
            flavor: 'dev',
            environment: 'dev',
            apiBaseUrl: '',
            logLevel: 'debug',
            featureFlagsJson: '{bad',
          ),
          (
            name: 'non-boolean feature flag entry',
            flavor: 'dev',
            environment: 'dev',
            apiBaseUrl: '',
            logLevel: 'debug',
            featureFlagsJson: '{"x":1}',
          ),
          (
            name: 'non-development non-HTTPS API URL',
            flavor: 'staging',
            environment: 'staging',
            apiBaseUrl: 'http://example.com',
            logLevel: 'info',
            featureFlagsJson: '{}',
          ),
        ];

    for (final failureCase in failureCases) {
      test('rejects ${failureCase.name}', () {
        expect(
          () => Env.parse(
            flavor: failureCase.flavor,
            environment: failureCase.environment,
            apiBaseUrl: failureCase.apiBaseUrl,
            logLevel: failureCase.logLevel,
            featureFlagsJson: failureCase.featureFlagsJson,
          ),
          throwsA(isA<FormatException>()),
        );
      });
    }
  });
}
