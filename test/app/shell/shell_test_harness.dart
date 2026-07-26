import 'package:flutter/material.dart';

import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

Widget shellHarness({
  required Widget child,
  ThemeData? theme,
  TextDirection textDirection = TextDirection.rtl,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme ?? buildLightTheme(),
    locale: const Locale('fa', 'IR'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(body: child),
    ),
  );
}

List<ShellDockItem> threeDockItems() => const [
  ShellDockItem(
    id: ShellDockIds.profile,
    semanticLabel: 'پروفایل',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
  ShellDockItem(
    id: ShellDockIds.chat,
    semanticLabel: 'گفتگو',
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
  ),
  ShellDockItem(
    id: ShellDockIds.home,
    semanticLabel: 'خانه',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
];

List<ShellModuleItem> fixtureModules() => const [
  ShellModuleItem(id: 'm1', label: 'ماژول ۱', icon: Icons.apps),
  ShellModuleItem(id: 'm2', label: 'ماژول ۲', icon: Icons.extension),
];

List<ShellTabItem> fixtureTabs() => const [
  ShellTabItem(id: 't1', label: 'زبانه ۱'),
  ShellTabItem(id: 't2', label: 'زبانه ۲'),
];

/// Test-only shell host that exercises module/tab/dock contracts.
class ShellFixtureHost extends StatefulWidget {
  const ShellFixtureHost({
    super.key,
    this.initialDockId = ShellDockIds.home,
    this.compact = false,
    this.withModules = true,
  });

  final String? initialDockId;
  final bool compact;
  final bool withModules;

  @override
  State<ShellFixtureHost> createState() => ShellFixtureHostState();
}

class ShellFixtureHostState extends State<ShellFixtureHost> {
  late String? dockSelectedId = widget.initialDockId;
  String? moduleId;
  String? tabId;
  late bool compact = widget.compact;
  final stripController = ScrollController();
  final bodyController = ScrollController();

  final selections = <String>[];

  void setCompact(bool value) {
    setState(() => compact = value);
  }

  @override
  void dispose() {
    stripController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modules = widget.withModules
        ? fixtureModules()
        : const <ShellModuleItem>[];
    final tabs = moduleId == null ? const <ShellTabItem>[] : fixtureTabs();

    return AppShellScaffold(
      modules: modules,
      selectedModuleId: moduleId,
      onModuleSelected: (id) {
        setState(() {
          moduleId = id;
          tabId = ContextualTabStrip.resolveSelectedId(fixtureTabs(), null);
          dockSelectedId = null;
        });
      },
      moduleStripCompact: compact,
      moduleStripScrollController: stripController,
      tabs: tabs,
      selectedTabId: tabId,
      onTabSelected: (id) => setState(() => tabId = id),
      dockItems: threeDockItems(),
      dockSelectedId: dockSelectedId,
      onDockSelected: (id) {
        selections.add(id);
        setState(() {
          dockSelectedId = id;
          moduleId = null;
          tabId = null;
        });
      },
      search: const SizedBox(
        height: AppTokens.minTouchTarget,
        child: ColoredBox(color: Colors.transparent),
      ),
      body: ListView(
        key: const Key('fixture_body'),
        controller: bodyController,
        padding: const EdgeInsets.only(
          bottom: AppShellScaffold.dockBottomInset,
        ),
        children: [
          Text(moduleId == null ? 'خانه' : 'ماژول:$moduleId تب:$tabId'),
          const SizedBox(height: 800, child: Placeholder()),
        ],
      ),
    );
  }
}
