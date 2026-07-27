import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/features/profile/presentation/profile_screen.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

export 'package:laforika/features/profile/data/profile_dtos.dart';
export 'package:laforika/features/profile/data/profile_repository.dart';
export 'package:laforika/features/profile/presentation/profile_controller.dart';
export 'package:laforika/features/profile/presentation/profile_error_mapper.dart';
export 'package:laforika/features/profile/presentation/profile_header.dart';
export 'package:laforika/features/profile/presentation/profile_screen.dart'
    show
        ProfileScreen,
        ProfileDockItemsBuilder,
        ProfileDockSelected,
        ProfileHeaderAction;
export 'package:laforika/features/profile/presentation/profile_validation.dart';

/// Public Profile route name constant.
const String profileRouteName = 'profile';

/// Public Profile route path constant.
const String profileRoutePath = '/profile';

/// Registered internal paths owned by the Profile feature.
Set<String> get profileRegisteredPaths => <String>{profileRoutePath};

/// Guest-accessible public paths owned by the Profile feature.
Set<String> get profilePublicPaths => <String>{profileRoutePath};

/// Profile feature route registry for `app/router` aggregation.
List<RouteBase> profileRoutes({
  required List<ShellDockItem> Function(AppLocalizations l10n) dockItems,
  required void Function(BuildContext context, String dockId) onDockSelected,
  required ProfileHeaderAction onSettings,
  required ProfileHeaderAction onNotifications,
}) {
  return <RouteBase>[
    GoRoute(
      name: profileRouteName,
      path: profileRoutePath,
      builder: (BuildContext context, GoRouterState state) {
        return ProfileScreen(
          dockItems: dockItems,
          onDockSelected: onDockSelected,
          onSettings: onSettings,
          onNotifications: onNotifications,
        );
      },
    ),
  ];
}
