import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/features/notifications/presentation/notifications_controller.dart';

void main() {
  test('production load settles to empty', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final items = await container.read(notificationsControllerProvider.future);
    expect(items, isEmpty);
  });

  test('reload recovers from error to empty', () async {
    final container = ProviderContainer(
      overrides: [
        notificationsControllerProvider.overrideWith(_ErrorThenEmpty.new),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(notificationsControllerProvider.future),
      throwsA(isA<StateError>()),
    );

    await container.read(notificationsControllerProvider.notifier).reload();
    final items = await container.read(notificationsControllerProvider.future);
    expect(items, isEmpty);
  });

  test(
    'hanging load exposes loading then completes empty after dispose-safe reload',
    () async {
      final container = ProviderContainer(
        overrides: [
          notificationsControllerProvider.overrideWith(_HangingThenEmpty.new),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(notificationsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      expect(container.read(notificationsControllerProvider).isLoading, isTrue);

      final hanging =
          container.read(notificationsControllerProvider.notifier)
              as _HangingThenEmpty;
      hanging.completeEmpty();
      final items = await container.read(
        notificationsControllerProvider.future,
      );
      expect(items, isEmpty);
    },
  );
}

class _ErrorThenEmpty extends NotificationsController {
  var _attempt = 0;

  @override
  Future<List<NotificationListItem>> build() async {
    _attempt += 1;
    if (_attempt == 1) {
      throw StateError('fixture_load_failed');
    }
    return const <NotificationListItem>[];
  }
}

class _HangingThenEmpty extends NotificationsController {
  final Completer<List<NotificationListItem>> _completer =
      Completer<List<NotificationListItem>>();

  @override
  Future<List<NotificationListItem>> build() => _completer.future;

  void completeEmpty() {
    if (!_completer.isCompleted) {
      _completer.complete(const <NotificationListItem>[]);
    }
  }
}
