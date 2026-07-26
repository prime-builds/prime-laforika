import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/core/storage/secure_store.dart';
import 'package:laforika/features/auth/data/auth_repository.dart';
import 'package:laforika/features/auth/data/custom_api_auth_gateway.dart';
import 'package:laforika/features/auth/presentation/account_security_screen.dart';
import 'package:laforika/features/auth/presentation/phone_auth_screen.dart';
import 'package:laforika/features/auth/presentation/session_startup_screen.dart';

export 'package:laforika/features/auth/data/custom_api_auth_gateway.dart';
export 'package:laforika/features/auth/data/auth_repository.dart';
export 'package:laforika/features/auth/presentation/phone_auth_panel.dart'
    show PhoneAuthPanel;

const authStartupRouteName = 'authStartup';
const authStartupRoutePath = '/startup';

/// Canonical user-facing auth entry — direct phone OTP (not a method chooser).
const authRouteName = 'auth';
const authRoutePath = '/auth';

const accountSecurityRouteName = 'accountSecurity';
const accountSecurityRoutePath = '/account/security';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

CustomApiAuthGateway createCustomApiAuthGateway({
  required AuthRepository repository,
  required SecureStore secureStore,
}) {
  return CustomApiAuthGateway(repository: repository, secureStore: secureStore);
}

/// Auth-only paths (login UI). Guests may visit these without redirect.
Set<String> get authOnlyPaths => {authRoutePath};

/// Explicitly protected capability paths. Guests are redirected to [authRoutePath].
Set<String> get authProtectedPaths => {accountSecurityRoutePath};

Set<String> get authRegisteredPaths => {
  authStartupRoutePath,
  ...authOnlyPaths,
  ...authProtectedPaths,
};

List<RouteBase> authRoutes() => [
  GoRoute(
    path: authStartupRoutePath,
    name: authStartupRouteName,
    builder: (context, state) => const SessionStartupScreen(),
  ),
  GoRoute(
    path: authRoutePath,
    name: authRouteName,
    builder: (context, state) => const PhoneAuthScreen(),
  ),
  GoRoute(
    path: accountSecurityRoutePath,
    name: accountSecurityRouteName,
    builder: (context, state) => const AccountSecurityScreen(),
  ),
];
