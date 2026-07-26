import 'package:flutter/material.dart';

import 'package:laforika/features/shell/adaptive_module_strip.dart';
import 'package:laforika/features/shell/contextual_tab_strip.dart';
import 'package:laforika/features/shell/floating_bottom_dock.dart';
import 'package:laforika/features/shell/shell_models.dart';
import 'package:laforika/core/theme/app_tokens.dart';

/// Home/module discovery shell geometry: strip → search → tabs → body → dock.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.body,
    required this.dockItems,
    required this.dockSelectedId,
    required this.onDockSelected,
    this.modules = const [],
    this.selectedModuleId,
    this.onModuleSelected,
    this.moduleStripCompact = false,
    this.moduleStripScrollController,
    this.tabs = const [],
    this.selectedTabId,
    this.onTabSelected,
    this.search,
    this.scaffoldKey,
  });

  /// Vertical body scroll offset (logical px) at which the module strip compacts.
  static const double moduleStripCompactThreshold = 24;

  final Widget body;
  final List<ShellDockItem> dockItems;
  final String? dockSelectedId;
  final ValueChanged<String> onDockSelected;

  final List<ShellModuleItem> modules;
  final String? selectedModuleId;
  final ValueChanged<String>? onModuleSelected;
  final bool moduleStripCompact;
  final ScrollController? moduleStripScrollController;

  final List<ShellTabItem> tabs;
  final String? selectedTabId;
  final ValueChanged<String>? onTabSelected;

  /// Optional search field widget placed below the module strip.
  final Widget? search;

  final Key? scaffoldKey;

  /// Reserved bottom padding so body content clears the floating dock.
  static const double dockBottomInset =
      AppTokens.spaceLg + AppTokens.minTouchTarget + AppTokens.spaceMd;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final showStrip = modules.isNotEmpty;
    final showTabs = tabs.isNotEmpty && selectedModuleId != null;

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showStrip)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: AppTokens.spaceSm,
                      bottom: AppTokens.spaceSm,
                    ),
                    child: AdaptiveModuleStrip(
                      modules: modules,
                      selectedId: selectedModuleId,
                      compact: moduleStripCompact,
                      horizontalController: moduleStripScrollController,
                      onSelected: onModuleSelected ?? (_) {},
                    ),
                  ),
                if (search != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppTokens.pagePadding,
                      AppTokens.spaceSm,
                      AppTokens.pagePadding,
                      AppTokens.spaceSm,
                    ),
                    child: search,
                  ),
                if (showTabs)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: AppTokens.spaceSm,
                    ),
                    child: ContextualTabStrip(
                      tabs: tabs,
                      selectedId: selectedTabId,
                      onSelected: onTabSelected ?? (_) {},
                    ),
                  ),
                Expanded(child: body),
              ],
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: media.padding.bottom + AppTokens.spaceMd,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingBottomDock(
                  items: dockItems,
                  selectedId: dockSelectedId,
                  onSelected: onDockSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
