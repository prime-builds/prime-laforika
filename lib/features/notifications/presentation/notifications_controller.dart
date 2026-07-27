import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal presentation item for Notifications list rendering.
///
/// Production load never invents items. Test overrides may supply fixtures via
/// [notificationsInboxLoaderProvider].
class NotificationListItem {
  const NotificationListItem({
    required this.id,
    required this.title,
    required this.body,
    this.unread = false,
  });

  final String id;
  final String title;
  final String body;
  final bool unread;
}

/// Feature-owned inbox load seam used by both initial build and Retry.
typedef NotificationsInboxLoader =
    Future<List<NotificationListItem>> Function();

Future<List<NotificationListItem>> _productionInboxLoader() async {
  // No approved notification source (O3 open): production is empty.
  return const <NotificationListItem>[];
}

/// Injectable loader for Notifications inbox reads.
///
/// Override in tests to exercise loading / error / data / Retry against the
/// same seam production uses.
final notificationsInboxLoaderProvider = Provider<NotificationsInboxLoader>(
  (ref) => _productionInboxLoader,
);

/// Production Notifications inbox: settles to an honest empty list.
///
/// Loading / error / data states are exercised via Riverpod overrides in tests.
class NotificationsController
    extends AsyncNotifier<List<NotificationListItem>> {
  Future<List<NotificationListItem>> _loadInbox() {
    return ref.read(notificationsInboxLoaderProvider)();
  }

  @override
  Future<List<NotificationListItem>> build() => _loadInbox();

  Future<void> reload() async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(_loadInbox);
    if (!ref.mounted) {
      return;
    }
    state = next;
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      List<NotificationListItem>
    >(NotificationsController.new);
