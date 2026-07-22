import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_session_gateway.dart';
import 'package:laforika/core/auth/auth_state.dart';

/// Sole owner of application session state.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthUnknown();

  AuthSessionGateway get _gateway => ref.read(authSessionGatewayProvider);

  Future<void> hydrate() async {
    state = const AuthUnknown();
    final next = await _gateway.hydrate();
    state = next;
  }

  Future<void> retryHydration() => hydrate();

  Future<void> onCredentialsAccepted({
    required String accessToken,
    required String refreshToken,
    required AuthPrincipal principal,
  }) async {
    final accepted = await _gateway.acceptCredentials(
      accessToken: accessToken,
      refreshToken: refreshToken,
      principal: principal,
    );
    state = AuthAuthenticated(accepted);
  }

  void updatePrincipal(AuthPrincipal principal) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(principal);
    }
  }

  Future<void> logout() async {
    await _gateway.logoutCurrent();
    state = const AuthUnauthenticated();
  }

  Future<void> logoutAll() async {
    await _gateway.logoutAll();
    state = const AuthUnauthenticated();
  }

  Future<void> forceUnauthenticated() async {
    await _gateway.clearLocalSession();
    state = const AuthUnauthenticated();
  }
}

/// Overridden by app composition with the custom API gateway.
final authSessionGatewayProvider = Provider<AuthSessionGateway>((ref) {
  throw UnimplementedError(
    'authSessionGatewayProvider must be overridden in bootstrap',
  );
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Stable [Listenable] bridge for go_router refresh without reconstructing the router.
class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(this._ref) {
    _subscription = _ref.listen<AuthState>(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final listenable = AuthRouterRefresh(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});
