import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laforika/features/shell/adaptive_module_strip.dart';

import 'app/shell/shell_test_harness.dart';

void main() {
  testWidgets('toggle compact via setState only, no scroll', (tester) async {
    var compact = false;
    late void Function(void Function()) rebuild;
    await tester.pumpWidget(
      shellHarness(
        disableAnimations: true,
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return AdaptiveModuleStrip(
              modules: fixtureModules(),
              selectedId: 'm1',
              compact: compact,
              onSelected: (_) {},
            );
          },
        ),
      ),
    );
    await tester.pump();
    rebuild(() => compact = true);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
