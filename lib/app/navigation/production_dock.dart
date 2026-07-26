import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/features/home/home.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// App-owned production dock destinations (Profile + Home; no Chat).
///
/// Visual LTR order is Profile then Home so RTL reads Profile left, Home right.
abstract final class ProductionDock {
  static List<ShellDockItem> items(AppLocalizations l10n) {
    return <ShellDockItem>[
      ShellDockItem(
        id: ShellDockIds.profile,
        semanticLabel: l10n.shellProfileLabel,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
      ShellDockItem(
        id: ShellDockIds.home,
        semanticLabel: l10n.shellHomeLabel,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
    ];
  }

  static void onSelected(BuildContext context, String id) {
    switch (id) {
      case ShellDockIds.home:
        context.go(homeRoutePath);
      case ShellDockIds.profile:
        context.go(profileRoutePath);
    }
  }
}
