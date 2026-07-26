import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/shell/shell.dart';

import 'shell_test_harness.dart';

void main() {
  testWidgets('dock fixture RTL order and taps', (tester) async {
    await tester.pumpWidget(shellHarness(child: const ShellFixtureHost()));
    await tester.pump();

    final dock = tester.widget<FloatingBottomDock>(
      find.byType(FloatingBottomDock),
    );
    expect(dock.items.map((e) => e.id).toList(), [
      ShellDockIds.profile,
      ShellDockIds.chat,
      ShellDockIds.home,
    ]);

    final state = tester.state<ShellFixtureHostState>(
      find.byType(ShellFixtureHost),
    );
    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.chat);
    expect(state.selections, [ShellDockIds.chat]);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.profile);
  });

  testWidgets('dock swipe visual-left and visual-right without wrap', (
    tester,
  ) async {
    await tester.pumpWidget(shellHarness(child: const ShellFixtureHost()));
    await tester.pump();
    final state = tester.state<ShellFixtureHostState>(
      find.byType(ShellFixtureHost),
    );
    expect(state.dockSelectedId, ShellDockIds.home);

    final dock = find.byType(FloatingBottomDock);
    // Finger toward visual left (negative X) → Home → Chat.
    await tester.fling(dock, const Offset(-80, 0), 800);
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.chat);

    await tester.fling(dock, const Offset(-80, 0), 800);
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.profile);

    // Edge: further left is no-op.
    await tester.fling(dock, const Offset(-80, 0), 800);
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.profile);

    // Visual right → Profile → Chat → Home.
    await tester.fling(dock, const Offset(80, 0), 800);
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.chat);
    await tester.fling(dock, const Offset(80, 0), 800);
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.home);
    await tester.fling(dock, const Offset(80, 0), 800);
    await tester.pump();
    expect(state.dockSelectedId, ShellDockIds.home);
  });

  testWidgets('one-item dock swipe is a no-op', (tester) async {
    var selected = ShellDockIds.home;
    await tester.pumpWidget(
      shellHarness(
        child: FloatingBottomDock(
          items: const [
            ShellDockItem(
              id: ShellDockIds.home,
              semanticLabel: 'خانه',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
          ],
          selectedId: selected,
          onSelected: (id) => selected = id,
        ),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(FloatingBottomDock), const Offset(-80, 0));
    await tester.pump();
    expect(selected, ShellDockIds.home);
  });

  testWidgets('module fixture expands then clears dock selection', (
    tester,
  ) async {
    await tester.pumpWidget(shellHarness(child: const ShellFixtureHost()));
    await tester.pump();

    expect(find.text('ماژول ۱'), findsOneWidget);
    expect(find.byIcon(Icons.apps), findsOneWidget);
    expect(find.text('زبانه ۱'), findsNothing);

    await tester.tap(find.text('ماژول ۱'));
    await tester.pump();

    final state = tester.state<ShellFixtureHostState>(
      find.byType(ShellFixtureHost),
    );
    expect(state.moduleId, 'm1');
    expect(state.tabId, 't1');
    expect(state.dockSelectedId, isNull);
    expect(find.text('زبانه ۱'), findsOneWidget);
    expect(find.text('زبانه ۲'), findsOneWidget);
  });

  testWidgets('compact strip keeps selection and drops icons', (tester) async {
    await tester.pumpWidget(
      shellHarness(child: const ShellFixtureHost(compact: false)),
    );
    await tester.pump();
    await tester.tap(find.text('ماژول ۲'));
    await tester.pump();

    final state = tester.state<ShellFixtureHostState>(
      find.byType(ShellFixtureHost),
    );
    expect(state.moduleId, 'm2');
    expect(find.byIcon(Icons.extension), findsOneWidget);

    state.setCompact(true);
    await tester.pump(AppTokens.motionStandard);
    await tester.pump();

    expect(state.moduleId, 'm2');
    expect(find.text('ماژول ۲'), findsOneWidget);
    expect(find.byIcon(Icons.extension), findsNothing);
    expect(find.text('زبانه ۱'), findsOneWidget);
  });

  testWidgets('empty modules omit strip; invalid tab falls back to first', (
    tester,
  ) async {
    await tester.pumpWidget(
      shellHarness(
        child: ContextualTabStrip(
          tabs: fixtureTabs(),
          selectedId: 'missing',
          onSelected: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(
      ContextualTabStrip.resolveSelectedId(fixtureTabs(), 'missing'),
      't1',
    );

    await tester.pumpWidget(
      shellHarness(child: const ShellFixtureHost(withModules: false)),
    );
    await tester.pump();
    expect(find.byType(AdaptiveModuleStrip), findsNothing);
  });

  testWidgets('light and dark dock render without overflow at 320dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final theme in [buildLightTheme(), buildDarkTheme()]) {
      await tester.pumpWidget(
        shellHarness(theme: theme, child: const ShellFixtureHost()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(FloatingBottomDock), findsOneWidget);
    }
  });

  testWidgets('selected dock exposes semantics', (tester) async {
    await tester.pumpWidget(shellHarness(child: const ShellFixtureHost()));
    await tester.pump();
    final semantics = tester.widget<Semantics>(
      find.ancestor(
        of: find.byIcon(Icons.home),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Semantics && (w.properties.label?.contains('خانه') ?? false),
        ),
      ),
    );
    expect(semantics.properties.label, 'خانه');
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.selected, isTrue);
  });
}
