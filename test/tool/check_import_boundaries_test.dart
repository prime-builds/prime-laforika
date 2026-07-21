import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_import_boundaries.dart';

void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('laforika_boundary_');
  });

  tearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  test('accepts a valid modular layout', () {
    _write(
      tempRoot,
      'app/router/routes.dart',
      "import 'package:laforika/features/home/home.dart';\n",
    );
    _write(
      tempRoot,
      'features/home/home.dart',
      "import 'package:laforika/features/home/presentation/home_screen.dart';\n",
    );
    _write(
      tempRoot,
      'features/home/presentation/home_screen.dart',
      "import 'package:laforika/core/theme/app_tokens.dart';\n",
    );
    _write(tempRoot, 'core/theme/app_tokens.dart', 'class AppTokens {}\n');

    final result = checkImportBoundaries(tempRoot);
    expect(result.isClean, isTrue, reason: result.violations.join('\n'));
  });

  test('rejects core importing features', () {
    _write(
      tempRoot,
      'core/config/bad.dart',
      "import 'package:laforika/features/home/home.dart';\n",
    );
    _write(tempRoot, 'features/home/home.dart', 'class Home {}\n');

    final result = checkImportBoundaries(tempRoot);
    expect(result.isClean, isFalse);
    expect(
      result.violations.any((v) => v.contains('core/ must not import/export')),
      isTrue,
    );
  });

  test('rejects cross-feature internal imports and cycles', () {
    _write(
      tempRoot,
      'features/a/a.dart',
      "import 'package:laforika/features/b/presentation/b_screen.dart';\n",
    );
    _write(tempRoot, 'features/b/b.dart', 'class B {}\n');
    _write(
      tempRoot,
      'features/b/presentation/b_screen.dart',
      "import 'package:laforika/features/a/a.dart';\n",
    );

    final internal = checkImportBoundaries(tempRoot);
    expect(internal.violations.any((v) => v.contains('public barrel')), isTrue);

    // Cycle through public barrels.
    tempRoot.deleteSync(recursive: true);
    tempRoot.createSync(recursive: true);
    _write(
      tempRoot,
      'features/a/a.dart',
      "import 'package:laforika/features/b/b.dart';\n",
    );
    _write(
      tempRoot,
      'features/b/b.dart',
      "import 'package:laforika/features/a/a.dart';\n",
    );

    final cycle = checkImportBoundaries(tempRoot);
    expect(cycle.violations.any((v) => v.contains('cycle')), isTrue);
  });

  test('rejects core or feature importing bootstrap.dart', () {
    _write(tempRoot, 'bootstrap.dart', 'void bootstrap() {}\n');
    _write(
      tempRoot,
      'core/config/bad.dart',
      "import 'package:laforika/bootstrap.dart';\n",
    );

    final coreResult = checkImportBoundaries(tempRoot);
    expect(coreResult.isClean, isFalse);
    expect(
      coreResult.violations.any(
        (v) => v.contains('core/ must not import/export'),
      ),
      isTrue,
    );

    tempRoot.deleteSync(recursive: true);
    tempRoot.createSync(recursive: true);
    _write(tempRoot, 'bootstrap.dart', 'void bootstrap() {}\n');
    _write(
      tempRoot,
      'features/home/presentation/home_screen.dart',
      "import 'package:laforika/bootstrap.dart';\n",
    );

    final featureResult = checkImportBoundaries(tempRoot);
    expect(featureResult.isClean, isFalse);
    expect(
      featureResult.violations.any(
        (v) => v.contains('features/ must not import/export app/'),
      ),
      isTrue,
    );
  });

  test('rejects domain importing package:flutter/foundation.dart', () {
    _write(
      tempRoot,
      'features/home/domain/entity.dart',
      "import 'package:flutter/foundation.dart';\n",
    );

    final result = checkImportBoundaries(tempRoot);
    expect(result.isClean, isFalse);
    expect(
      result.violations.any(
        (v) => v.contains('domain/ must not import Flutter libraries'),
      ),
      isTrue,
    );
  });
}

void _write(Directory root, String relativePath, String contents) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
