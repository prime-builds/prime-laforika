import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/core/storage/secure_store.dart';
import 'package:laforika/features/auth/data/auth_repository.dart';
import 'package:laforika/features/auth/data/custom_api_auth_gateway.dart';
import 'package:laforika/features/auth/presentation/account_security_screen.dart';
import 'package:laforika/features/auth/presentation/auth_method_screen.dart';
import 'package:laforika/features/auth/presentation/email_auth_screen.dart';
import 'package:laforika/features/auth/presentation/password_reset_screen.dart';
import 'package:laforika/features/auth/presentation/phone_auth_screen.dart';
import 'package:laforika/features/auth/presentation/session_startup_screen.dart';

export 'package:laforika/features/auth/data/custom_api_auth_gateway.dart';
export 'package:laforika/features/auth/data/auth_repository.dart';

const authStartupRouteName = 'authStartup';
const authStartupRoutePath = '/startup';

const authMethodRouteName = 'authMethod';
const authMethodRoutePath = '/auth';

const authPhoneRouteName = 'authPhone';
const authPhoneRoutePath = '/auth/phone';

const authEmailRouteName = 'authEmail';
const authEmailRoutePath = '/auth/email';

const authPasswordResetRouteName = 'authPasswordReset';
const authPasswordResetRoutePath = '/auth/password-reset';

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

Set<String> get authOnlyPaths => {
  authMethodRoutePath,
  authPhoneRoutePath,
  authEmailRoutePath,
  authPasswordResetRoutePath,
};

Set<String> get authRegisteredPaths => {
  authStartupRoutePath,
  ...authOnlyPaths,
  accountSecurityRoutePath,
};

List<RouteBase> authRoutes() => [
  GoRoute(
    path: authStartupRoutePath,
    name: authStartupRouteName,
    builder: (context, state) => const SessionStartupScreen(),
  ),
  GoRoute(
    path: authMethodRoutePath,
    name: authMethodRouteName,
    builder: (context, state) => const AuthMethodScreen(),
  ),
  GoRoute(
    path: authPhoneRoutePath,
    name: authPhoneRouteName,
    builder: (context, state) => const PhoneAuthScreen(),
  ),
  GoRoute(
    path: authEmailRoutePath,
    name: authEmailRouteName,
    builder: (context, state) => const EmailAuthScreen(),
  ),
  GoRoute(
    path: authPasswordResetRoutePath,
    name: authPasswordResetRouteName,
    builder: (context, state) => const PasswordResetScreen(),
  ),
  GoRoute(
    path: accountSecurityRoutePath,
    name: accountSecurityRouteName,
    builder: (context, state) => const AccountSecurityScreen(),
  ),
];
