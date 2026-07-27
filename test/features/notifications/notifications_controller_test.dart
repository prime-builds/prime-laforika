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

  test('failed load then Retry invokes the same loader twice', () async {
    var attempts = 0;
    final container = ProviderContainer(
      overrides: [
        notificationsInboxLoaderProvider.overrideWithValue(() async {
          attempts += 1;
          if (attempts == 1) {
            throw StateError('fixture_load_failed');
          }
          return const <NotificationListItem>[];
        }),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(notificationsControllerProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(attempts, 1);
    expect(container.read(notificationsControllerProvider).hasError, isTrue);

    await container.read(notificationsControllerProvider.notifier).reload();
    final items = await container.read(notificationsControllerProvider.future);
    expect(attempts, 2);
    expect(items, isEmpty);
    expect(container.read(notificationsControllerProvider).hasValue, isTrue);
  });

  test('Retry transitions through loading then empty', () async {
    final gate = Completer<void>();
    var attempts = 0;
    final container = ProviderContainer(
      overrides: [
        notificationsInboxLoaderProvider.overrideWithValue(() async {
          attempts += 1;
          if (attempts == 1) {
            throw StateError('fixture');
          }
          await gate.future;
          return const <NotificationListItem>[];
        }),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(notificationsControllerProvider, (_, _) {});
    addTearDown(sub.close);

    await expectLater(
      container.read(notificationsControllerProvider.future),
      throwsA(isA<StateError>()),
    );

    final reloadFuture = container
        .read(notificationsControllerProvider.notifier)
        .reload();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(notificationsControllerProvider).isLoading, isTrue);

    gate.complete();
    await reloadFuture;
    expect(
      container.read(notificationsControllerProvider).asData?.value,
      isEmpty,
    );
  });

  test('pending reload after dispose does not throw or mutate', () async {
    final gate = Completer<List<NotificationListItem>>();
    var attempts = 0;
    final container = ProviderContainer(
      overrides: [
        notificationsInboxLoaderProvider.overrideWithValue(() {
          attempts += 1;
          if (attempts == 1) {
            return Future<List<NotificationListItem>>.value(
              const <NotificationListItem>[],
            );
          }
          return gate.future;
        }),
      ],
    );

    final sub = container.listen(notificationsControllerProvider, (_, _) {});
    await container.read(notificationsControllerProvider.future);
    expect(attempts, 1);

    final reloadFuture = container
        .read(notificationsControllerProvider.notifier)
        .reload();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(notificationsControllerProvider).isLoading, isTrue);

    sub.close();
    container.dispose();

    gate.complete(const <NotificationListItem>[]);
    await expectLater(reloadFuture, completes);
    expect(attempts, 2);
  });
}
