import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/data/custom_api_auth_gateway.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/memory_secure_store.dart';

void main() {
  const principal = AuthPrincipal(
    accountId: 'acc-1',
    hasPhone: true,
    hasEmail: false,
    maskedPhone: '+989****67',
  );

  group('AuthController', () {
    late FakeAuthRepository repository;
    late MemorySecureStore store;
    late CustomApiAuthGateway gateway;
    late ProviderContainer container;

    setUp(() {
      repository = FakeAuthRepository();
      store = MemorySecureStore();
      gateway = CustomApiAuthGateway(
        repository: repository,
        secureStore: store,
      );
      container = ProviderContainer(
        overrides: [authSessionGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);
    });

    test(
      'starts unknown then hydrates to unauthenticated without secret',
      () async {
        expect(container.read(authControllerProvider), isA<AuthUnknown>());
        await container.read(authControllerProvider.notifier).hydrate();
        expect(
          container.read(authControllerProvider),
          isA<AuthUnauthenticated>(),
        );
      },
    );

    test('accepts credentials then logout clears session', () async {
      await container
          .read(authControllerProvider.notifier)
          .onCredentialsAccepted(
            accessToken: 'access',
            refreshToken: 'refresh',
            principal: principal,
          );
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
      expect(store.values['auth.refreshToken'], 'refresh');

      await container.read(authControllerProvider.notifier).logout();
      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );
      expect(store.values.containsKey('auth.refreshToken'), isFalse);
    });

    test('hydration keeps credentials on temporary network failure', () async {
      await store.write('auth.refreshToken', 'refresh');
      repository.refreshResult = const FailureResult(NetworkFailure());

      await container.read(authControllerProvider.notifier).hydrate();
      expect(container.read(authControllerProvider), isA<AuthHydrationError>());
      expect(store.values['auth.refreshToken'], 'refresh');
    });

    test('hydration clears credentials on definitive auth failure', () async {
      await store.write('auth.refreshToken', 'refresh');
      repository.refreshResult = const FailureResult(
        AuthFailure(code: 'AUTH_SESSION_REVOKED'),
      );

      await container.read(authControllerProvider.notifier).hydrate();
      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );
      expect(store.values.containsKey('auth.refreshToken'), isFalse);
    });
  });

  group('CustomApiAuthGateway', () {
    test('single-flight refresh shares one repository call', () async {
      final repository = FakeAuthRepository()
        ..refreshDelay = const Duration(milliseconds: 40)
        ..refreshResult = const Success(
          TokenPairDto(
            accessToken: 'a2',
            refreshToken: 'r2',
            accountId: 'acc-1',
            hasPhone: true,
          ),
        );
      final store = MemorySecureStore();
      await store.write('auth.refreshToken', 'r1');
      final gateway = CustomApiAuthGateway(
        repository: repository,
        secureStore: store,
      );

      final results = await Future.wait([
        gateway.refreshAccessToken(),
        gateway.refreshAccessToken(),
        gateway.refreshAccessToken(),
      ]);

      expect(repository.refreshCalls, 1);
      for (final result in results) {
        expect(result, isA<Success<String>>());
        expect(result.valueOrNull, 'a2');
      }
      expect(store.values['auth.refreshToken'], 'r2');
      expect(gateway.accessToken, 'a2');
    });
  });
}
