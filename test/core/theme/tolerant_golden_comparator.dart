import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Local golden comparator with a small pixel tolerance for cross-OS font
/// rasterization (Windows baselines vs Linux CI).
///
/// [precisionTolerance] is a fraction of differing pixels in the inclusive
/// range `0.0`–`1.0` (for example `0.02` means 2%).
final class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.precisionTolerance = 0.02}) {
    if (precisionTolerance < 0.0 || precisionTolerance > 1.0) {
      throw ArgumentError.value(
        precisionTolerance,
        'precisionTolerance',
        'must be between 0.0 and 1.0 inclusive',
      );
    }
  }

  /// Maximum allowed pixel difference as a fraction of the image (`0.0`–`1.0`).
  final double precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed = result.passed || result.diffPercent <= precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
