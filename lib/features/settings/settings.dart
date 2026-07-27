import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/features/settings/presentation/settings_screen.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

export 'package:laforika/features/settings/presentation/settings_screen.dart'
    show SettingsScreen, SettingsDockItemsBuilder, SettingsDockSelected;

/// Public Settings route name constant.
const String settingsRouteName = 'settings';

/// Public Settings route path constant.
const String settingsRoutePath = '/settings';

/// Registered internal paths owned by the Settings feature.
Set<String> get settingsRegisteredPaths => <String>{settingsRoutePath};

/// Guest-accessible public paths owned by the Settings feature.
Set<String> get settingsPublicPaths => <String>{settingsRoutePath};

/// Settings feature route registry for `app/router` aggregation.
List<RouteBase> settingsRoutes({
  required List<ShellDockItem> Function(AppLocalizations l10n) dockItems,
  required void Function(BuildContext context, String dockId) onDockSelected,
}) {
  return <RouteBase>[
    GoRoute(
      name: settingsRouteName,
      path: settingsRoutePath,
      builder: (BuildContext context, GoRouterState state) {
        return SettingsScreen(
          dockItems: dockItems,
          onDockSelected: onDockSelected,
        );
      },
    ),
  ];
}
