import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/data/auth_repository.dart';
import 'package:laforika/features/auth/data/custom_api_auth_gateway.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/memory_secure_store.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = AppConfig(
    environment: AppEnvironment.dev,
    apiBaseUrl: 'http://10.0.2.2:3000/v1',
    logLevel: AppLogLevel.debug,
    featureFlags: <String, bool>{},
  );

  const principal = AuthPrincipal(accountId: 'acc-refresh');

  test(
    '401 refresh retries through attached Dio without provider self-dependency',
    () async {
      final store = MemorySecureStore();
      final repository = FakeAuthRepository()
        ..refreshResult = const Success(
          TokenPairDto(
            accessToken: 'fresh-access',
            refreshToken: 'fresh-refresh',
            accountId: 'acc-refresh',
          ),
        );

      late final CustomApiAuthGateway gateway;
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          authSessionGatewayProvider.overrideWith((ref) {
            gateway = CustomApiAuthGateway(
              repository: repository,
              secureStore: store,
            );
            return gateway;
          }),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .onCredentialsAccepted(
            accessToken: 'stale-access',
            refreshToken: 'refresh-secret',
            principal: principal,
          );
      gateway.expireAccessTokenInMemory();

      final dio = container.read(dioProvider);
      var meCalls = 0;
      dio.httpClientAdapter = _Adapter((options) async {
        expect(
          options.path.contains('/auth/refresh'),
          isFalse,
          reason: 'refresh must use the session gateway, not Dio recursion',
        );
        expect(options.path.contains('/account/me'), isTrue);
        meCalls += 1;
        final auth = options.headers['Authorization']?.toString() ?? '';
        if (auth.contains('expired.integration.test.token')) {
          return ResponseBody.fromString(
            '{"code":"AUTH_SESSION_REVOKED"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        expect(auth, 'Bearer fresh-access');
        return ResponseBody.fromString(
          '{"accountId":"acc-refresh"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final liveRepository = AuthRepository(dio);
      final result = await liveRepository.me();

      expect(result.isSuccess, isTrue);
      expect(meCalls, 2);
      expect(gateway.accessToken, 'fresh-access');
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
    },
  );
}
