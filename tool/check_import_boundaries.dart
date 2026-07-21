import 'dart:io';

/// Executable import-boundary gate for Laforika's modular monolith.
///
/// Usage: `dart run tool/check_import_boundaries.dart [libRoot]`
void main(List<String> args) {
  final root = Directory(args.isEmpty ? 'lib' : args.first);
  final result = checkImportBoundaries(root);
  for (final violation in result.violations) {
    stderr.writeln(violation);
  }
  if (result.violations.isNotEmpty) {
    stderr.writeln(
      'Import boundary check failed with ${result.violations.length} violation(s).',
    );
    exit(1);
  }
  stdout.writeln('Import boundary check passed.');
}

/// Result of scanning a `lib`-shaped tree for import/export boundary violations.
class BoundaryCheckResult {
  const BoundaryCheckResult(this.violations);

  final List<String> violations;

  bool get isClean => violations.isEmpty;
}

/// Scans [libRoot] for Dart import/export boundary violations.
BoundaryCheckResult checkImportBoundaries(Directory libRoot) {
  if (!libRoot.existsSync()) {
    return BoundaryCheckResult(<String>[
      'Library root does not exist: ${libRoot.path}',
    ]);
  }

  final files =
      libRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final graph = <String, Set<String>>{};
  final violations = <String>[];

  for (final file in files) {
    final module = _moduleOf(libRoot, file);
    if (module == null) {
      continue;
    }

    final directives = _readDirectives(file);
    for (final directive in directives) {
      if (module.isFeature &&
          module.layer == 'domain' &&
          _isFlutterUiImport(directive.uri)) {
        violations.add(
          '${file.path}:${directive.line}: domain/ must not import Flutter UI libraries.',
        );
        continue;
      }

      final target = _resolveTarget(
        libRoot: libRoot,
        fromFile: file,
        uri: directive.uri,
      );
      if (target == null) {
        continue;
      }

      final targetModule = _moduleOf(libRoot, target);
      if (targetModule == null) {
        continue;
      }

      final message = _validateEdge(
        fromFile: file,
        fromModule: module,
        toFile: target,
        toModule: targetModule,
        line: directive.line,
      );
      if (message != null) {
        violations.add(message);
      }

      if (module.isFeature && targetModule.isFeature) {
        graph.putIfAbsent(module.featureName!, () => <String>{});
        if (module.featureName != targetModule.featureName) {
          graph[module.featureName!]!.add(targetModule.featureName!);
        }
      }
    }
  }

  violations.addAll(_detectCycles(graph));
  return BoundaryCheckResult(violations);
}

class _Directive {
  const _Directive({required this.uri, required this.line});

  final String uri;
  final int line;
}

class _Module {
  const _Module._({required this.kind, this.featureName, this.layer});

  factory _Module.app() => const _Module._(kind: _ModuleKind.app);

  factory _Module.core() => const _Module._(kind: _ModuleKind.core);

  factory _Module.feature({required String name, required String? layer}) {
    return _Module._(
      kind: _ModuleKind.feature,
      featureName: name,
      layer: layer,
    );
  }

  final _ModuleKind kind;
  final String? featureName;
  final String? layer;

  bool get isFeature => kind == _ModuleKind.feature;
  bool get isCore => kind == _ModuleKind.core;
  bool get isApp => kind == _ModuleKind.app;
}

enum _ModuleKind { app, core, feature }

_Module? _moduleOf(Directory libRoot, File file) {
  final relative = _posixRelative(libRoot, file);
  final parts = relative.split('/');
  if (parts.isEmpty) {
    return null;
  }

  switch (parts.first) {
    case 'app':
      return _Module.app();
    case 'core':
      return _Module.core();
    case 'features':
      if (parts.length < 2) {
        return null;
      }
      final feature = parts[1];
      String? layer;
      if (parts.length >= 3 &&
          (parts[2] == 'presentation' ||
              parts[2] == 'data' ||
              parts[2] == 'domain')) {
        layer = parts[2];
      }
      return _Module.feature(name: feature, layer: layer);
    default:
      return null;
  }
}

List<_Directive> _readDirectives(File file) {
  final lines = file.readAsLinesSync();
  final directives = <_Directive>[];
  final pattern = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

  for (var i = 0; i < lines.length; i++) {
    final match = pattern.firstMatch(lines[i]);
    if (match != null) {
      directives.add(_Directive(uri: match.group(1)!, line: i + 1));
    }
  }
  return directives;
}

File? _resolveTarget({
  required Directory libRoot,
  required File fromFile,
  required String uri,
}) {
  if (uri.startsWith('dart:') || uri.startsWith('package:flutter')) {
    return null;
  }

  if (uri.startsWith('package:laforika/')) {
    final relative = uri.substring('package:laforika/'.length);
    final file = File('${libRoot.path}/$relative');
    return file.existsSync() ? file : null;
  }

  if (uri.startsWith('package:')) {
    return null;
  }

  final resolved = File(_normalizePath('${fromFile.parent.path}/$uri'));
  final libPath = _normalizePath(libRoot.absolute.path);
  final resolvedPath = _normalizePath(resolved.absolute.path);
  if (!resolvedPath.startsWith(libPath)) {
    return null;
  }
  return resolved.existsSync() ? resolved : null;
}

String? _validateEdge({
  required File fromFile,
  required _Module fromModule,
  required File toFile,
  required _Module toModule,
  required int line,
}) {
  final location = '${fromFile.path}:$line';

  if (fromModule.isCore && (toModule.isApp || toModule.isFeature)) {
    return '$location: core/ must not import/export app/ or features/.';
  }

  if (fromModule.isFeature && toModule.isApp) {
    return '$location: features/ must not import/export app/.';
  }

  if (fromModule.isApp &&
      toModule.isFeature &&
      !_isFeaturePublicBarrel(toFile, toModule.featureName!)) {
    return '$location: app/ may only import feature public barrels '
        '(features/${toModule.featureName}/${toModule.featureName}.dart).';
  }

  if (fromModule.isFeature &&
      toModule.isFeature &&
      fromModule.featureName != toModule.featureName) {
    if (!_isFeaturePublicBarrel(toFile, toModule.featureName!)) {
      return '$location: cross-feature access must use the public barrel '
          'features/${toModule.featureName}/${toModule.featureName}.dart.';
    }
  }

  if (fromModule.isFeature && toModule.isFeature) {
    final featureDir = Directory(
      _parentFeatureRoot(fromFile, fromModule.featureName!),
    );
    final hasDomain = Directory('${featureDir.path}/domain').existsSync();
    if (hasDomain && fromModule.featureName == toModule.featureName) {
      final fromLayer = fromModule.layer;
      final toLayer = toModule.layer;
      if (fromLayer == 'domain' &&
          (toLayer == 'data' || toLayer == 'presentation')) {
        return '$location: domain/ must not depend on data/ or presentation/.';
      }
      if (fromLayer == 'data' && toLayer == 'presentation') {
        return '$location: data/ must not depend on presentation/.';
      }
      if (fromLayer == 'presentation' && toLayer == 'data') {
        return '$location: presentation/ must not bypass domain/ to depend on data/.';
      }
    }
  }

  return null;
}

bool _isFeaturePublicBarrel(File file, String featureName) {
  final normalized = _normalizePath(file.path).replaceAll('\\', '/');
  return normalized.endsWith('/features/$featureName/$featureName.dart');
}

String _parentFeatureRoot(File file, String featureName) {
  final normalized = _normalizePath(file.path).replaceAll('\\', '/');
  final marker = '/features/$featureName/';
  final index = normalized.lastIndexOf(marker);
  if (index < 0) {
    return file.parent.path;
  }
  return normalized.substring(0, index + marker.length - 1);
}

bool _isFlutterUiImport(String uri) {
  if (!uri.startsWith('package:flutter/')) {
    return false;
  }
  return uri != 'package:flutter/foundation.dart';
}

List<String> _detectCycles(Map<String, Set<String>> graph) {
  final violations = <String>[];
  final visiting = <String>{};
  final visited = <String>{};
  final stack = <String>[];

  void dfs(String node) {
    if (visiting.contains(node)) {
      final cycleStart = stack.indexOf(node);
      final cycle = <String>[...stack.sublist(cycleStart), node];
      violations.add(
        'Cross-feature dependency cycle detected: ${cycle.join(' -> ')}',
      );
      return;
    }
    if (visited.contains(node)) {
      return;
    }
    visiting.add(node);
    stack.add(node);
    for (final next in graph[node] ?? <String>{}) {
      dfs(next);
    }
    stack.removeLast();
    visiting.remove(node);
    visited.add(node);
  }

  final nodes = graph.keys.toList()..sort();
  for (final node in nodes) {
    dfs(node);
  }
  return violations;
}

String _posixRelative(Directory root, File file) {
  final rootPath = _normalizePath(root.absolute.path);
  final filePath = _normalizePath(file.absolute.path);
  var relative = filePath.substring(rootPath.length);
  if (relative.startsWith('/') || relative.startsWith('\\')) {
    relative = relative.substring(1);
  }
  return relative.replaceAll('\\', '/');
}

String _normalizePath(String path) {
  return Uri.file(path).normalizePath().toFilePath(windows: Platform.isWindows);
}
