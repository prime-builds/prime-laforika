import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tolerant_golden_comparator.dart';

Future<Uint8List> _encodeSolidPng({
  required Color color,
  int width = 16,
  int height = 16,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = color,
  );
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

Future<Uint8List> _encodeNearlySolidPng({
  required Color base,
  required Color outlier,
  int width = 10,
  int height = 10,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = base,
  );
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = outlier);
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File goldenFile;
  late TolerantGoldenComparator comparator;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('laforika_golden_');
    goldenFile = File('${tempDir.path}${Platform.pathSeparator}sample.png');
    comparator = TolerantGoldenComparator(
      Uri.file('${tempDir.path}${Platform.pathSeparator}comparator_test.dart'),
      precisionTolerance: 0.02,
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('rejects precisionTolerance below 0.0', () {
    expect(
      () => TolerantGoldenComparator(
        Uri.parse('test/core/theme/comparator_test.dart'),
        precisionTolerance: -0.01,
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.name,
          'name',
          'precisionTolerance',
        ),
      ),
    );
  });

  test('rejects precisionTolerance above 1.0', () {
    // Legacy maxDiffPercent: 2.0 was invalid as a fraction and would accept
    // every mismatch; construction must fail instead.
    expect(
      () => TolerantGoldenComparator(
        Uri.parse('test/core/theme/comparator_test.dart'),
        precisionTolerance: 2.0,
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.name,
          'name',
          'precisionTolerance',
        ),
      ),
    );
  });

  test('identical images pass within fractional tolerance', () async {
    final bytes = await _encodeSolidPng(color: const Color(0xFF112233));
    await goldenFile.writeAsBytes(bytes, flush: true);

    final matched = await comparator.compare(bytes, Uri.file(goldenFile.path));
    expect(matched, isTrue);
  });

  test('within-tolerance single-pixel mismatch passes', () async {
    final golden = await _encodeSolidPng(
      color: const Color(0xFF112233),
      width: 10,
      height: 10,
    );
    final candidate = await _encodeNearlySolidPng(
      base: const Color(0xFF112233),
      outlier: const Color(0xFFFF0000),
    );
    await goldenFile.writeAsBytes(golden, flush: true);

    // 1 / 100 pixels = 0.01 <= 0.02
    final matched = await comparator.compare(
      candidate,
      Uri.file(goldenFile.path),
    );
    expect(matched, isTrue);
  });

  test('materially different images fail fractional tolerance', () async {
    final golden = await _encodeSolidPng(color: const Color(0xFF0000FF));
    final candidate = await _encodeSolidPng(color: const Color(0xFFFF0000));
    await goldenFile.writeAsBytes(golden, flush: true);

    // Under the old maxDiffPercent: 2.0 semantics this would incorrectly pass.
    await expectLater(
      comparator.compare(candidate, Uri.file(goldenFile.path)),
      throwsA(isA<FlutterError>()),
    );
  });
}
