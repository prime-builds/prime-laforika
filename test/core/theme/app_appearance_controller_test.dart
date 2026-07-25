import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/storage/in_memory_prefs_facade.dart';
import 'package:laforika/core/storage/prefs_facade.dart';
import 'package:laforika/core/storage/prefs_facade_provider.dart';
import 'package:laforika/core/theme/app_appearance.dart';
import 'package:laforika/core/theme/app_appearance_controller.dart';

final class _ThrowingReadPrefs implements PrefsFacade {
  @override
  String? getString(String key) => throw StateError('read failed');

  @override
  Future<void> setString(String key, String value) async {}
}

final class _ThrowingWritePrefs implements PrefsFacade {
  _ThrowingWritePrefs(this._inner);

  final PrefsFacade _inner;

  @override
  String? getString(String key) => _inner.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    throw StateError('write failed');
  }
}

ProviderContainer _container(PrefsFacade prefs) {
  return ProviderContainer(
    overrides: [prefsFacadeProvider.overrideWithValue(prefs)],
  );
}

void main() {
  test('absent key defaults to System', () {
    final container = _container(InMemoryPrefsFacade());
    addTearDown(container.dispose);

    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.system,
    );
  });

  test('stored values restore deterministically', () {
    final cases = <String, AppAppearance>{
      AppAppearanceCodec.system: AppAppearance.system,
      AppAppearanceCodec.light: AppAppearance.light,
      AppAppearanceCodec.dark: AppAppearance.dark,
    };

    for (final entry in cases.entries) {
      final container = _container(
        InMemoryPrefsFacade({AppAppearancePrefsKeys.appearanceMode: entry.key}),
      );
      addTearDown(container.dispose);
      expect(container.read(appAppearanceControllerProvider), entry.value);
    }
  });

  test('unknown value falls back to System', () {
    final container = _container(
      InMemoryPrefsFacade({AppAppearancePrefsKeys.appearanceMode: 'sepia'}),
    );
    addTearDown(container.dispose);

    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.system,
    );
  });

  test('setting each mode updates state and persists stable strings', () async {
    final prefs = InMemoryPrefsFacade();
    final container = _container(prefs);
    addTearDown(container.dispose);
    final controller = container.read(appAppearanceControllerProvider.notifier);

    for (final mode in AppAppearance.values) {
      await controller.setAppearance(mode);
      expect(container.read(appAppearanceControllerProvider), mode);
      expect(
        prefs.getString(AppAppearancePrefsKeys.appearanceMode),
        AppAppearanceCodec.encode(mode),
      );
    }
  });

  test('repeated selection keeps the same mode', () async {
    final prefs = InMemoryPrefsFacade();
    final container = _container(prefs);
    addTearDown(container.dispose);
    final controller = container.read(appAppearanceControllerProvider.notifier);

    await controller.setAppearance(AppAppearance.dark);
    await controller.setAppearance(AppAppearance.dark);

    expect(container.read(appAppearanceControllerProvider), AppAppearance.dark);
    expect(
      prefs.getString(AppAppearancePrefsKeys.appearanceMode),
      AppAppearanceCodec.dark,
    );
  });

  test('read failure degrades to System', () {
    final container = _container(_ThrowingReadPrefs());
    addTearDown(container.dispose);

    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.system,
    );
  });

  test('write failure keeps in-memory mode', () async {
    final container = _container(_ThrowingWritePrefs(InMemoryPrefsFacade()));
    addTearDown(container.dispose);
    final controller = container.read(appAppearanceControllerProvider.notifier);

    await controller.setAppearance(AppAppearance.light);

    expect(
      container.read(appAppearanceControllerProvider),
      AppAppearance.light,
    );
  });
}
