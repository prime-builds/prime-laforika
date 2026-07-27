import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/notifications/presentation/notifications_controller.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

typedef NotificationsDockItemsBuilder =
    List<ShellDockItem> Function(AppLocalizations l10n);
typedef NotificationsDockSelected =
    void Function(BuildContext context, String dockId);

/// Protected Notifications surface with honest async presentation states.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({
    super.key,
    required this.dockItems,
    required this.onDockSelected,
  });

  final NotificationsDockItemsBuilder dockItems;
  final NotificationsDockSelected onDockSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncInbox = ref.watch(notificationsControllerProvider);

    return AppShellScaffold(
      scaffoldKey: const Key('notifications_screen'),
      dockItems: dockItems(l10n),
      dockSelectedId: ShellDockIds.profile,
      onDockSelected: (id) => onDockSelected(context, id),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NotificationsHeader(
            title: l10n.notificationsTitle,
            backLabel: l10n.notificationsBack,
            onBack: () => context.go(profileRoutePath),
          ),
          Expanded(
            child: asyncInbox.when(
              loading: () => Center(
                child: Semantics(
                  key: const Key('notifications_loading'),
                  label: l10n.notificationsLoading,
                  child: const CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => _NotificationsError(
                message: l10n.notificationsError,
                retryLabel: l10n.notificationsRetry,
                onRetry: () =>
                    ref.read(notificationsControllerProvider.notifier).reload(),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _NotificationsEmpty(l10n: l10n);
                }
                return ListView.separated(
                  key: const Key('notifications_list'),
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppTokens.spaceLg,
                    AppTokens.spaceMd,
                    AppTokens.spaceLg,
                    AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppTokens.spaceMd),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final theme = Theme.of(context);
                    return ListTile(
                      key: Key('notifications_item_${item.id}'),
                      contentPadding: const EdgeInsetsDirectional.all(
                        AppTokens.spaceMd,
                      ),
                      title: Text(
                        item.title,
                        style: item.unread
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(item.body),
                      leading: Icon(
                        item.unread
                            ? Icons.mark_email_unread_outlined
                            : Icons.mark_email_read_outlined,
                        color: item.unread
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.title,
    required this.backLabel,
    required this.onBack,
  });

  final String title;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppTokens.spaceSm,
        AppTokens.spaceSm,
        AppTokens.spaceSm,
        AppTokens.spaceSm,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('notifications_back'),
            tooltip: backLabel,
            style: IconButton.styleFrom(
              minimumSize: const Size(
                AppTokens.minTouchTarget,
                AppTokens.minTouchTarget,
              ),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppTokens.minTouchTarget),
        ],
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      key: const Key('notifications_empty'),
      label: '${l10n.notificationsEmptyTitle}. ${l10n.notificationsEmptyBody}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppTokens.spaceLg,
                  AppTokens.spaceXl,
                  AppTokens.spaceLg,
                  AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppTokens.spaceLg),
                    Text(
                      l10n.notificationsEmptyTitle,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTokens.spaceSm),
                    Text(
                      l10n.notificationsEmptyBody,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    key: const Key('notifications_error'),
                    message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  FilledButton(
                    key: const Key('notifications_retry'),
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
