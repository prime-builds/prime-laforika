/// Opaque authenticated principal — stable account scoping only.
class AuthPrincipal {
  const AuthPrincipal({
    required this.accountId,
    this.hasPhone = false,
    this.hasEmail = false,
    this.maskedPhone,
    this.maskedEmail,
  });

  final String accountId;
  final bool hasPhone;
  final bool hasEmail;
  final String? maskedPhone;
  final String? maskedEmail;

  AuthPrincipal copyWith({
    String? accountId,
    bool? hasPhone,
    bool? hasEmail,
    String? maskedPhone,
    String? maskedEmail,
  }) {
    return AuthPrincipal(
      accountId: accountId ?? this.accountId,
      hasPhone: hasPhone ?? this.hasPhone,
      hasEmail: hasEmail ?? this.hasEmail,
      maskedPhone: maskedPhone ?? this.maskedPhone,
      maskedEmail: maskedEmail ?? this.maskedEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AuthPrincipal &&
        other.accountId == accountId &&
        other.hasPhone == hasPhone &&
        other.hasEmail == hasEmail &&
        other.maskedPhone == maskedPhone &&
        other.maskedEmail == maskedEmail;
  }

  @override
  int get hashCode =>
      Object.hash(accountId, hasPhone, hasEmail, maskedPhone, maskedEmail);
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
