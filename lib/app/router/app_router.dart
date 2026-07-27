import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/app/router/routes.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/utils/auth_utils.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';

/// Cold-start / deep-link entry location for [GoRouter].
///
/// Production defaults to [authStartupRoutePath]. Tests may override to simulate
/// opening a registered destination before session hydration completes.
final routerInitialLocationProvider = Provider<String>(
  (ref) => authStartupRoutePath,
);

/// Single application [GoRouter] owned by the composition root.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);
  final initialLocation = ref.watch(routerInitialLocationProvider);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final returnTo = state.uri.queryParameters['from'];

      final registered = appRegisteredPaths;
      final public = appPublicPaths;
      final protected = appProtectedPaths;

      String? canonicalize(String? destination) {
        return canonicalizeReturnDestination(
          destination,
          registeredPaths: registered,
          authOnlyPaths: authOnlyPaths,
          startupPath: authStartupRoutePath,
        );
      }

      String authWithReturn(String destination) {
        final encoded = Uri.encodeComponent(destination);
        return '$authRoutePath?from=$encoded';
      }

      String startupWithReturn(String destination) {
        final encoded = Uri.encodeComponent(destination);
        return '$authStartupRoutePath?from=$encoded';
      }

      switch (auth) {
        case AuthUnknown():
        case AuthHydrationError():
          if (location == authStartupRoutePath) {
            // Keep any already-preserved `from=` query on startup.
            return null;
          }
          // Query/fragment-bearing deep links are unsafe and must not be preserved.
          final pending = (state.uri.hasQuery || state.uri.fragment.isNotEmpty)
              ? null
              : canonicalize(location);
          if (pending != null) {
            return startupWithReturn(pending);
          }
          return authStartupRoutePath;
        case AuthUnauthenticated():
          if (location == authStartupRoutePath) {
            final pending = canonicalize(returnTo);
            if (pending != null) {
              if (public.contains(pending)) {
                return pending;
              }
              // Protected and other registered non-public paths fail closed to OTP.
              return authWithReturn(pending);
            }
            return homeRoutePath;
          }
          if (authOnlyPaths.contains(location)) {
            return null;
          }
          if (public.contains(location)) {
            return null;
          }
          if (protected.contains(location)) {
            return authWithReturn(location);
          }
          // Unknown non-public registered path: treat as protected for fail-closed UX.
          if (registered.contains(location)) {
            return authWithReturn(location);
          }
          return homeRoutePath;
        case AuthAuthenticated():
          if (location == authStartupRoutePath ||
              authOnlyPaths.contains(location)) {
            final canonical = canonicalize(returnTo);
            if (canonical != null) {
              return canonical;
            }
            return homeRoutePath;
          }
          return null;
      }
    },
    routes: appRoutes(),
  );
});
