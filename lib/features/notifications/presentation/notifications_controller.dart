import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal presentation item for Notifications list rendering.
///
/// Production load never invents items. Test overrides may supply fixtures.
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

/// Production Notifications inbox: settles to an honest empty list.
///
/// Loading / error / data states are exercised via Riverpod overrides in tests.
class NotificationsController
    extends AsyncNotifier<List<NotificationListItem>> {
  @override
  Future<List<NotificationListItem>> build() => _load();

  Future<List<NotificationListItem>> _load() async {
    // No approved notification source (O3 open): production is empty.
    return const <NotificationListItem>[];
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      List<NotificationListItem>
    >(NotificationsController.new);
