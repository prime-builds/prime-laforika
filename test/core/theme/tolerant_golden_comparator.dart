import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Local golden comparator with a small pixel tolerance for cross-OS font
/// rasterization (Windows baselines vs Linux CI).
final class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(
    super.testFile, {
    this.maxDiffPercent = 2.0,
  });

  /// Maximum allowed differing pixels as a percent of the image.
  final double maxDiffPercent;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final diff = result.diffPercent;
    if (result.passed || (diff != null && diff <= maxDiffPercent)) {
      return true;
    }

    // Preserve Flutter's failure output for out-of-tolerance diffs.
    return super.compare(imageBytes, golden);
  }
}
