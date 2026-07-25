/// Opaque authenticated principal — stable account scoping only.
class AuthPrincipal {
  const AuthPrincipal({required this.accountId});

  final String accountId;

  AuthPrincipal copyWith({String? accountId}) {
    return AuthPrincipal(accountId: accountId ?? this.accountId);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthPrincipal && other.accountId == accountId;
  }

  @override
  int get hashCode => accountId.hashCode;
}

/// Application session state.
sealed class AuthState {
  const AuthState();
}

final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.principal);

  final AuthPrincipal principal;
}

final class AuthHydrationError extends AuthState {
  const AuthHydrationError({this.canRetry = true});

  /// Temporary transport failure during startup hydration.
  final bool canRetry;
}
