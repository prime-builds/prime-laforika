import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/features/notifications/presentation/notifications_screen.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

export 'package:laforika/features/notifications/presentation/notifications_controller.dart';
export 'package:laforika/features/notifications/presentation/notifications_screen.dart'
    show
        NotificationsScreen,
        NotificationsDockItemsBuilder,
        NotificationsDockSelected;

/// Protected Notifications route name constant.
const String notificationsRouteName = 'notifications';

/// Protected Notifications route path constant.
const String notificationsRoutePath = '/notifications';

/// Registered internal paths owned by the Notifications feature.
Set<String> get notificationsRegisteredPaths => <String>{
  notificationsRoutePath,
};

/// Explicitly protected capability paths owned by Notifications.
Set<String> get notificationsProtectedPaths => <String>{notificationsRoutePath};

/// Notifications feature route registry for `app/router` aggregation.
List<RouteBase> notificationsRoutes({
  required List<ShellDockItem> Function(AppLocalizations l10n) dockItems,
  required void Function(BuildContext context, String dockId) onDockSelected,
}) {
  return <RouteBase>[
    GoRoute(
      name: notificationsRouteName,
      path: notificationsRoutePath,
      builder: (BuildContext context, GoRouterState state) {
        return NotificationsScreen(
          dockItems: dockItems,
          onDockSelected: onDockSelected,
        );
      },
    ),
  ];
}
