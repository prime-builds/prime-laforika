import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/app/navigation/production_dock.dart';
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
}
