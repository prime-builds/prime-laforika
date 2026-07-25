import 'package:go_router/go_router.dart';

import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';

/// Aggregates feature public route registries into one list.
List<RouteBase> appRoutes() => <RouteBase>[...authRoutes(), ...homeRoutes()];

/// Aggregated registered internal paths for return-destination validation.
Set<String> get appRegisteredPaths => <String>{
  ...authRegisteredPaths,
  ...homeRegisteredPaths,
};

/// Guest-accessible public paths after session restoration.
Set<String> get appPublicPaths => <String>{...homePublicPaths};

/// Explicitly protected capability paths.
Set<String> get appProtectedPaths => <String>{...authProtectedPaths};
