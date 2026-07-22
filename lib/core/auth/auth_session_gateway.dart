import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';

/// Provider-neutral session gateway owned by `core/auth`.
abstract interface class AuthSessionGateway {
  /// Current in-memory access token, if any.
  String? get accessToken;

  /// Restores session from secure storage via a real refresh when possible.
  Future<AuthState> hydrate();

  /// Accepts tokens after a successful login/signup/verify.
  Future<AuthPrincipal> acceptCredentials({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  });

  /// Single-flight refresh. Returns failure without clearing secrets on
  /// temporary network errors.
  Future<Result<String>> refreshAccessToken();

  Future<Result<void>> logoutCurrent();

  Future<Result<void>> logoutAll();

  Future<void> clearLocalSession();
}
