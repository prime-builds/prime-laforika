import 'package:dio/dio.dart';

import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/data/auth_repository.dart';

/// Controllable [AuthRepository] double for unit/widget tests.
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(Dio());

  Result<TokenPairDto> refreshResult = const FailureResult(
    AuthFailure(code: 'AUTH_INVALID_CREDENTIALS'),
  );
  Result<AccountMeDto> meResult = const FailureResult(
    AuthFailure(code: 'AUTH_SESSION_REVOKED'),
  );
  Result<List<SessionDto>> sessionsResult = const Success(<SessionDto>[]);
  Result<void> changePasswordResult = const Success(null);
  Result<void> logoutResult = const Success(null);
  Result<void> logoutAllResult = const Success(null);
  Result<ChallengeCreatedDto> phoneChallengeResult = const FailureResult(
    AuthFailure(code: 'AUTH_RATE_LIMITED'),
  );
  Result<TokenPairDto> phoneVerifyResult = const FailureResult(
    AuthFailure(code: 'AUTH_CHALLENGE_INVALID'),
  );

  int refreshCalls = 0;
  int phoneChallengeCalls = 0;
  Duration? refreshDelay;

  /// Optional factory so each challenge request can return a fresh cooldown.
  ChallengeCreatedDto Function()? phoneChallengeFactory;

  @override
  Future<Result<TokenPairDto>> refresh({required String refreshToken}) async {
    refreshCalls += 1;
    final delay = refreshDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    return refreshResult;
  }

  @override
  Future<Result<ChallengeCreatedDto>> requestPhoneChallenge({
    required String phone,
  }) async {
    phoneChallengeCalls += 1;
    final factory = phoneChallengeFactory;
    if (factory != null) {
      return Success(factory());
    }
    return phoneChallengeResult;
  }

  @override
  Future<Result<TokenPairDto>> verifyPhoneChallenge({
    required String challengeId,
    required String code,
  }) async => phoneVerifyResult;

  @override
  Future<Result<AccountMeDto>> me() async => meResult;

  @override
  Future<Result<List<SessionDto>>> listSessions() async => sessionsResult;

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => changePasswordResult;

  @override
  Future<Result<void>> logout() async => logoutResult;

  @override
  Future<Result<void>> logoutAll() async => logoutAllResult;

  @override
  Future<Result<void>> removePhone() async => const Success(null);

  @override
  Future<Result<void>> removeEmail() async => const Success(null);

  @override
  Future<Result<void>> revokeSession(String sessionId) async =>
      const Success(null);
}
