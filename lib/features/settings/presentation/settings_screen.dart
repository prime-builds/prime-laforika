import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_appearance.dart';
import 'package:laforika/core/theme/app_appearance_controller.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/profile/profile.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

typedef SettingsDockItemsBuilder =
    List<ShellDockItem> Function(AppLocalizations l10n);
typedef SettingsDockSelected =
    void Function(BuildContext context, String dockId);

/// Guest-accessible Settings: appearance, About, and authenticated account actions.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.dockItems,
    required this.onDockSelected,
  });

  final SettingsDockItemsBuilder dockItems;
  final SettingsDockSelected onDockSelected;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _logoutPending = false;

  Future<void> _logout() async {
    if (_logoutPending) return;
    setState(() => _logoutPending = true);
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } finally {
      if (mounted) {
        setState(() => _logoutPending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final appearance = ref.watch(appAppearanceControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final authenticated = auth is AuthAuthenticated;

    return AppShellScaffold(
      scaffoldKey: const Key('settings_screen'),
      dockItems: widget.dockItems(l10n),
      dockSelectedId: ShellDockIds.profile,
      onDockSelected: (id) => widget.onDockSelected(context, id),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsHeader(
            title: l10n.settingsTitle,
            backLabel: l10n.settingsBack,
            onBack: () => context.go(profileRoutePath),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.spaceLg,
                AppTokens.spaceMd,
                AppTokens.spaceLg,
                AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
              ),
              children: [
                Text(
                  l10n.settingsAppearanceSection,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppTokens.spaceSm),
                RadioGroup<AppAppearance>(
                  groupValue: appearance,
                  onChanged: (value) {
                    if (value == null) return;
                    ref
                        .read(appAppearanceControllerProvider.notifier)
                        .setAppearance(value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<AppAppearance>(
                        key: const Key('settings_appearance_system'),
                        value: AppAppearance.system,
                        title: Text(l10n.settingsAppearanceSystem),
                      ),
                      RadioListTile<AppAppearance>(
                        key: const Key('settings_appearance_light'),
                        value: AppAppearance.light,
                        title: Text(l10n.settingsAppearanceLight),
                      ),
                      RadioListTile<AppAppearance>(
                        key: const Key('settings_appearance_dark'),
                        value: AppAppearance.dark,
                        title: Text(l10n.settingsAppearanceDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXl),
                Text(
                  key: const Key('settings_about'),
                  l10n.settingsAboutSection,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Text(l10n.appTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppTokens.spaceSm),
                Text(
                  l10n.settingsAboutDescription,
                  style: theme.textTheme.bodyLarge,
                ),
                if (authenticated) ...[
                  const SizedBox(height: AppTokens.spaceXl),
                  Text(
                    key: const Key('settings_account_section'),
                    l10n.settingsAccountSection,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  OutlinedButton(
                    key: const Key('settings_account_security'),
                    onPressed: _logoutPending
                        ? null
                        : () => context.go(accountSecurityRoutePath),
                    child: Text(l10n.accountSecurityAction),
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  TextButton(
                    key: const Key('settings_logout'),
                    onPressed: _logoutPending ? null : _logout,
                    child: Text(l10n.authLogout),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
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
            key: const Key('settings_back'),
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
