import 'package:flutter/widgets.dart';

/// Controlled dock destination for [FloatingBottomDock].
@immutable
class ShellDockItem {
  const ShellDockItem({
    required this.id,
    required this.semanticLabel,
    required this.icon,
    this.selectedIcon,
  });

  final String id;
  final String semanticLabel;
  final IconData icon;
  final IconData? selectedIcon;
}

/// Controlled module strip entry for [AdaptiveModuleStrip].
@immutable
class ShellModuleItem {
  const ShellModuleItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

/// Controlled contextual tab for [ContextualTabStrip].
@immutable
class ShellTabItem {
  const ShellTabItem({required this.id, required this.label});

  final String id;
  final String label;
}

/// Canonical dock destination ids used by adjacency helpers and fixtures.
abstract final class ShellDockIds {
  static const home = 'home';
  static const chat = 'chat';
  static const profile = 'profile';
}
