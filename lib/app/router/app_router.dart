import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/app/router/routes.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/utils/auth_utils.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';

/// Single application [GoRouter] owned by the composition root.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);

  return GoRouter(
    initialLocation: authStartupRoutePath,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final returnTo = state.uri.queryParameters['from'];

      final registered = appRegisteredPaths;
      final public = appPublicPaths;
      final protected = appProtectedPaths;

      switch (auth) {
        case AuthUnknown():
        case AuthHydrationError():
          if (location != authStartupRoutePath) {
            return authStartupRoutePath;
          }
          return null;
        case AuthUnauthenticated():
          if (location == authStartupRoutePath) {
            return homeRoutePath;
          }
          if (authOnlyPaths.contains(location)) {
            return null;
          }
          if (public.contains(location)) {
            return null;
          }
          if (protected.contains(location)) {
            final encoded = Uri.encodeComponent(location);
            return '$authRoutePath?from=$encoded';
          }
          // Unknown non-public path: treat as protected for fail-closed UX.
          if (registered.contains(location)) {
            final encoded = Uri.encodeComponent(location);
            return '$authRoutePath?from=$encoded';
          }
          return homeRoutePath;
        case AuthAuthenticated():
          if (location == authStartupRoutePath ||
              authOnlyPaths.contains(location)) {
            if (isValidReturnDestination(
              returnTo,
              registeredPaths: registered,
              authOnlyPaths: authOnlyPaths,
              startupPath: authStartupRoutePath,
            )) {
              return returnTo;
            }
            return homeRoutePath;
          }
          return null;
      }
    },
    routes: appRoutes(),
  );
});
