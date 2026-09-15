import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/navigation/production_dock.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

void main() {
  test('production dock is Profile then Home visual LTR; no Chat', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    final items = ProductionDock.items(l10n);
    expect(items.map((e) => e.id).toList(), [
      ShellDockIds.profile,
      ShellDockIds.home,
    ]);
    expect(items.any((e) => e.id == ShellDockIds.chat), isFalse);
    expect(items.first.semanticLabel, l10n.shellProfileLabel);
    expect(items.last.semanticLabel, l10n.shellHomeLabel);
  });

  testWidgets(
    'production dock swipe moves between Profile and Home without wrap',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(
        const Locale('fa', 'IR'),
      );
      final items = ProductionDock.items(l10n);
      var selected = ShellDockIds.home;

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          locale: const Locale('fa', 'IR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return FloatingBottomDock(
                    items: items,
                    selectedId: selected,
                    onSelected: (id) => setState(() => selected = id),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final dock = find.byType(FloatingBottomDock);

      // Tap adjacency: tapping Profile selects it directly.
      await tester.tap(find.byKey(const Key('shell_dock_profile')));
      await tester.pump();
      expect(selected, ShellDockIds.profile);

      await tester.tap(find.byKey(const Key('shell_dock_home')));
      await tester.pump();
      expect(selected, ShellDockIds.home);

      // Swipe visual-left: Home → Profile (two-item dock, no Chat).
      await tester.fling(dock, const Offset(-80, 0), 800);
      await tester.pump();
      expect(selected, ShellDockIds.profile);

      // Edge: further visual-left swipe on a two-item dock is a no-op.
      await tester.fling(dock, const Offset(-80, 0), 800);
      await tester.pump();
      expect(selected, ShellDockIds.profile);

      // Swipe visual-right: Profile → Home.
      await tester.fling(dock, const Offset(80, 0), 800);
      await tester.pump();
      expect(selected, ShellDockIds.home);

      // Edge: further visual-right swipe is a no-op (no wrap).
      await tester.fling(dock, const Offset(80, 0), 800);
      await tester.pump();
      expect(selected, ShellDockIds.home);
    },
  );
}
