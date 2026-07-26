import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';
import 'package:laforika/features/profile/presentation/profile_controller.dart';

import '../../support/fake_profile_repository.dart';

class _Gateway implements AuthSessionGateway {
  _Gateway(this._hydrate);

  AuthState _hydrate;
  String? _accessToken;

  void setHydrate(AuthState next) => _hydrate = next;

  @override
  String? get accessToken => _accessToken;

  @override
  Future<AuthPrincipal> acceptCredentials({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  }) async {
    _accessToken = accessToken;
    return principal;
  }

  @override
  Future<void> clearLocalSession() async {
    _accessToken = null;
  }

  @override
  Future<AuthState> hydrate() async => _hydrate;

  @override
  Future<Result<void>> logoutAll() async => const Success(null);

  @override
  Future<Result<void>> logoutCurrent() async {
    _accessToken = null;
    return const Success(null);
  }

  @override
  Future<Result<String>> refreshAccessToken() async =>
      const FailureResult(AuthFailure(code: 'AUTH_NO_REFRESH'));
}

const _profile = ProfileDto(
  accountId: 'acc-1',
  phone: '+989121234567',
  phoneVerified: true,
  firstName: 'علی',
  lastName: null,
  email: null,
  emailVerified: false,
);

void main() {
  test('loads profile when authenticated and clears on logout', () async {
    final repo = FakeProfileRepository()..getResult = const Success(_profile);
    final gateway = _Gateway(
      const AuthAuthenticated(AuthPrincipal(accountId: 'acc-1')),
    );
    final container = ProviderContainer(
      overrides: [
        authSessionGatewayProvider.overrideWithValue(gateway),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.notifier).hydrate();
    final loaded = await container.read(profileControllerProvider.future);
    expect(loaded?.firstName, 'علی');
    expect(repo.getCalls, 1);

    await container.read(authControllerProvider.notifier).logout();
    final guest = await container.read(profileControllerProvider.future);
    expect(guest, isNull);
  });

  test('save updates state on success and retains failure', () async {
    final repo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchResult = const Success(
        ProfileDto(
          accountId: 'acc-1',
          phone: '+989121234567',
          phoneVerified: true,
          firstName: 'رضا',
          lastName: null,
          email: null,
          emailVerified: false,
        ),
      );
    final gateway = _Gateway(
      const AuthAuthenticated(AuthPrincipal(accountId: 'acc-1')),
    );
    final container = ProviderContainer(
      overrides: [
        authSessionGatewayProvider.overrideWithValue(gateway),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.notifier).hydrate();
    await container.read(profileControllerProvider.future);

    final result = await container
        .read(profileControllerProvider.notifier)
        .save(
          const PatchProfileRequest(firstName: 'رضا', includeFirstName: true),
        );
    expect(result.isSuccess, isTrue);
    expect(
      container.read(profileControllerProvider).asData?.value?.firstName,
      'رضا',
    );

    repo.patchResult = const FailureResult(
      ServerFailure(code: 'PROFILE_EMAIL_IN_USE'),
    );
    final conflict = await container
        .read(profileControllerProvider.notifier)
        .save(const PatchProfileRequest(email: 'x@y.z', includeEmail: true));
    expect(conflict.failureOrNull?.code, 'PROFILE_EMAIL_IN_USE');
    expect(
      container.read(profileControllerProvider).asData?.value?.firstName,
      'رضا',
    );
  });

  test('ignores delayed save after logout without throwing', () async {
    final repo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchDelay = const Duration(milliseconds: 80)
      ..patchResult = const Success(
        ProfileDto(
          accountId: 'acc-1',
          phone: '+989121234567',
          phoneVerified: true,
          firstName: 'رضا',
          lastName: null,
          email: null,
          emailVerified: false,
        ),
      );
    final gateway = _Gateway(
      const AuthAuthenticated(AuthPrincipal(accountId: 'acc-1')),
    );
    final container = ProviderContainer(
      overrides: [
        authSessionGatewayProvider.overrideWithValue(gateway),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final keepAlive = container.listen(profileControllerProvider, (_, _) {});
    addTearDown(keepAlive.close);

    await container.read(authControllerProvider.notifier).hydrate();
    await container.read(profileControllerProvider.future);

    final saveFuture = container
        .read(profileControllerProvider.notifier)
        .save(
          const PatchProfileRequest(firstName: 'رضا', includeFirstName: true),
        );
    await container.read(authControllerProvider.notifier).logout();
    final result = await saveFuture;

    expect(result.isSuccess, isTrue);
    expect(await container.read(profileControllerProvider.future), isNull);
    expect(container.read(profileControllerProvider).asData?.value, isNull);
  });

  test('ignores account A save after transition to account B', () async {
    final repo = FakeProfileRepository()
      ..getResult = const Success(_profile)
      ..patchDelay = const Duration(milliseconds: 80)
      ..patchResult = const Success(
        ProfileDto(
          accountId: 'acc-1',
          phone: '+989121234567',
          phoneVerified: true,
          firstName: 'از-الف',
          lastName: null,
          email: null,
          emailVerified: false,
        ),
      );
    final gateway = _Gateway(
      const AuthAuthenticated(AuthPrincipal(accountId: 'acc-1')),
    );
    final container = ProviderContainer(
      overrides: [
        authSessionGatewayProvider.overrideWithValue(gateway),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final keepAlive = container.listen(profileControllerProvider, (_, _) {});
    addTearDown(keepAlive.close);

    await container.read(authControllerProvider.notifier).hydrate();
    await container.read(profileControllerProvider.future);

    final saveFuture = container
        .read(profileControllerProvider.notifier)
        .save(
          const PatchProfileRequest(
            firstName: 'از-الف',
            includeFirstName: true,
          ),
        );

    repo.getResult = const Success(
      ProfileDto(
        accountId: 'acc-2',
        phone: '+989121234568',
        phoneVerified: true,
        firstName: 'مریم',
        lastName: null,
        email: null,
        emailVerified: false,
      ),
    );
    await container
        .read(authControllerProvider.notifier)
        .onCredentialsAccepted(
          accessToken: 'access-2',
          refreshToken: 'refresh-2',
          principal: const AuthPrincipal(accountId: 'acc-2'),
        );

    final next = await container.read(profileControllerProvider.future);
    expect(next?.accountId, 'acc-2');
    expect(next?.firstName, 'مریم');

    final stale = await saveFuture;
    expect(stale.isSuccess, isTrue);
    expect(
      container.read(profileControllerProvider).asData?.value?.accountId,
      'acc-2',
    );
    expect(
      container.read(profileControllerProvider).asData?.value?.firstName,
      'مریم',
    );
  });

  test('account change triggers fresh account-scoped load', () async {
    final repo = FakeProfileRepository()..getResult = const Success(_profile);
    final gateway = _Gateway(
      const AuthAuthenticated(AuthPrincipal(accountId: 'acc-1')),
    );
    final container = ProviderContainer(
      overrides: [
        authSessionGatewayProvider.overrideWithValue(gateway),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.notifier).hydrate();
    await container.read(profileControllerProvider.future);

    repo.getResult = const Success(
      ProfileDto(
        accountId: 'acc-2',
        phone: '+989121234568',
        phoneVerified: true,
        firstName: 'مریم',
        lastName: null,
        email: null,
        emailVerified: false,
      ),
    );
    await container
        .read(authControllerProvider.notifier)
        .onCredentialsAccepted(
          accessToken: 'access-2',
          refreshToken: 'refresh-2',
          principal: const AuthPrincipal(accountId: 'acc-2'),
        );

    final next = await container.read(profileControllerProvider.future);
    expect(next?.accountId, 'acc-2');
    expect(next?.firstName, 'مریم');
    expect(repo.getCalls, 2);
  });
}
