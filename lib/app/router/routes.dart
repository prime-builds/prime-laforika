import 'package:go_router/go_router.dart';

import 'package:laforika/app/navigation/production_dock.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/home.dart';
import 'package:laforika/features/notifications/notifications.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/settings/settings.dart';

/// Aggregates feature public route registries into one list.
List<RouteBase> appRoutes() => <RouteBase>[
  ...authRoutes(),
  ...homeRoutes(
    dockItems: ProductionDock.items,
    onDockSelected: ProductionDock.onSelected,
  ),
  ...profileRoutes(
    dockItems: ProductionDock.items,
    onDockSelected: ProductionDock.onSelected,
    onSettings: (context) => context.go(settingsRoutePath),
    onNotifications: (context) => context.go(notificationsRoutePath),
  ),
  ...settingsRoutes(
    dockItems: ProductionDock.items,
    onDockSelected: ProductionDock.onSelected,
  ),
  ...notificationsRoutes(
    dockItems: ProductionDock.items,
    onDockSelected: ProductionDock.onSelected,
  ),
];

/// Aggregated registered internal paths for return-destination validation.
Set<String> get appRegisteredPaths => <String>{
  ...authRegisteredPaths,
  ...homeRegisteredPaths,
  ...profileRegisteredPaths,
  ...settingsRegisteredPaths,
  ...notificationsRegisteredPaths,
};

/// Guest-accessible public paths after session restoration.
Set<String> get appPublicPaths => <String>{
  ...homePublicPaths,
  ...profilePublicPaths,
  ...settingsPublicPaths,
};

/// Explicitly protected capability paths.
Set<String> get appProtectedPaths => <String>{
  ...authProtectedPaths,
  ...notificationsProtectedPaths,
};
