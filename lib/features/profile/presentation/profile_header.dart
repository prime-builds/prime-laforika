import 'package:flutter/material.dart';

import 'package:laforika/core/theme/app_tokens.dart';

/// Focused Profile app-bar style header with optional directional actions.
///
/// Production omits Settings/Notifications until those routes exist. Tests may
/// pass callbacks to verify RTL start/end placement.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.title,
    this.settingsTooltip,
    this.notificationsTooltip,
    this.onSettings,
    this.onNotifications,
  });

  final String title;
  final String? settingsTooltip;
  final String? notificationsTooltip;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;

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
          if (onSettings != null)
            IconButton(
              key: const Key('profile_header_settings'),
              tooltip: settingsTooltip ?? '',
              style: IconButton.styleFrom(
                minimumSize: const Size(
                  AppTokens.minTouchTarget,
                  AppTokens.minTouchTarget,
                ),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
            )
          else
            const SizedBox(width: AppTokens.minTouchTarget),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          if (onNotifications != null)
            IconButton(
              key: const Key('profile_header_notifications'),
              tooltip: notificationsTooltip ?? '',
              style: IconButton.styleFrom(
                minimumSize: const Size(
                  AppTokens.minTouchTarget,
                  AppTokens.minTouchTarget,
                ),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              onPressed: onNotifications,
              icon: const Icon(Icons.notifications_outlined),
            )
          else
            const SizedBox(width: AppTokens.minTouchTarget),
        ],
      ),
    );
  }
}
