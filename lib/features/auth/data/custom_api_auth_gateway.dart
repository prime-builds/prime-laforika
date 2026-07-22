import 'dart:async';

import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/storage/secure_store.dart';
import 'package:laforika/features/auth/data/auth_repository.dart';

const _refreshTokenKey = 'auth.refreshToken';

/// Custom API session adapter — Laforika-owned refresh secret in secure storage.
class CustomApiAuthGateway implements AuthSessionGateway {
  CustomApiAuthGateway({required this._repository, required this._secureStore});

  final AuthRepository _repository;
  final SecureStore _secureStore;

  String? _accessToken;
  AuthPrincipal? _principal;
  Future<Result<String>>? _refreshInFlight;

  @override
  String? get accessToken => _accessToken;

  @override
  Future<AuthState> hydrate() async {
    final refresh = await _secureStore.read(_refreshTokenKey);
    if (refresh == null || refresh.isEmpty) {
      return const AuthUnauthenticated();
    }

    final result = await _repository.refresh(refreshToken: refresh);
    switch (result) {
      case Success(:final value):
        _accessToken = value.accessToken;
        await _secureStore.write(_refreshTokenKey, value.refreshToken);
        _principal = AuthPrincipal(
          accountId: value.accountId,
          hasPhone: value.hasPhone,
          hasEmail: value.hasEmail,
          maskedPhone: value.maskedPhone,
          maskedEmail: value.maskedEmail,
        );
        return AuthAuthenticated(_principal!);
      case FailureResult(:final failure):
        if (failure is AuthFailure) {
          await clearLocalSession();
          return const AuthUnauthenticated();
        }
        if (failure is NetworkFailure || failure is TimeoutFailure) {
          return const AuthHydrationError();
        }
        await clearLocalSession();
        return const AuthUnauthenticated();
    }
  }

  @override
  Future<AuthPrincipal> acceptCredentials({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  }) async {
    _accessToken = accessToken;
    _principal = principal;
    await _secureStore.write(_refreshTokenKey, refreshToken);
    return principal;
  }

  @override
  Future<Result<String>> refreshAccessToken() {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }
    _refreshInFlight = _doRefresh();
    return _refreshInFlight!.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<Result<String>> _doRefresh() async {
    final refresh = await _secureStore.read(_refreshTokenKey);
    if (refresh == null || refresh.isEmpty) {
      return const FailureResult(AuthFailure(code: 'AUTH_NO_REFRESH'));
    }

    final result = await _repository.refresh(refreshToken: refresh);
    switch (result) {
      case Success(:final value):
        _accessToken = value.accessToken;
        await _secureStore.write(_refreshTokenKey, value.refreshToken);
        _principal = AuthPrincipal(
          accountId: value.accountId,
          hasPhone: value.hasPhone,
          hasEmail: value.hasEmail,
          maskedPhone: value.maskedPhone,
          maskedEmail: value.maskedEmail,
        );
        return Success(value.accessToken);
      case FailureResult(:final failure):
        if (failure is AuthFailure) {
          await clearLocalSession();
        }
        return FailureResult(failure);
    }
  }

  @override
  Future<Result<void>> logoutCurrent() async {
    final result = await _repository.logout();
    await clearLocalSession();
    return result;
  }

  @override
  Future<Result<void>> logoutAll() async {
    final result = await _repository.logoutAll();
    await clearLocalSession();
    return result;
  }

  @override
  Future<void> clearLocalSession() async {
    _accessToken = null;
    _principal = null;
    await _secureStore.delete(_refreshTokenKey);
  }
}
