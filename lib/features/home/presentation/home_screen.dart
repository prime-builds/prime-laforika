import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// Maximum content width for tablet/wide Home layouts.
const double _homeMaxContentWidth = 720;

/// Guest-first Home / discovery shell.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _logoutPending = false;

  Future<void> _logout() async {
    if (_logoutPending) {
      return;
    }
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
    final auth = ref.watch(authControllerProvider);
    final authenticated = auth is AuthAuthenticated;

    final iconStyle = IconButton.styleFrom(
      minimumSize: const Size(
        AppTokens.minTouchTarget,
        AppTokens.minTouchTarget,
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    return Scaffold(
      key: const Key('home_discovery_shell'),
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            key: const Key('home_account_security_action'),
            tooltip: l10n.accountSecurityAction,
            style: iconStyle,
            onPressed: _logoutPending
                ? null
                : () => context.push(accountSecurityRoutePath),
            icon: const Icon(Icons.security),
          ),
          if (authenticated)
            IconButton(
              key: const Key('home_logout'),
              tooltip: l10n.homeLogoutTooltip,
              style: iconStyle,
              onPressed: _logoutPending ? null : _logout,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: AlignmentDirectional.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _homeMaxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeWelcome(l10n: l10n, theme: theme),
                      const SizedBox(height: AppTokens.spaceLg),
                      _HomeDestinationCard(
                        l10n: l10n,
                        theme: theme,
                        enabled: !_logoutPending,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeWelcome extends StatelessWidget {
  const _HomeWelcome({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.homeWelcomeTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: AppTokens.spaceSm),
        Text(
          l10n.homeWelcomeSubtitle,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

class _HomeDestinationCard extends StatelessWidget {
  const _HomeDestinationCard({
    required this.l10n,
    required this.theme,
    required this.enabled,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: false,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppTokens.spaceMd,
              AppTokens.spaceMd,
              AppTokens.spaceMd,
              AppTokens.spaceSm,
            ),
            child: Text(
              l10n.homeAvailableSectionsTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Semantics(
            key: const Key('home_account_security'),
            button: true,
            enabled: enabled,
            label: l10n.homeOpenAccountSecurity,
            excludeSemantics: true,
            child: InkWell(
              onTap: enabled
                  ? () => context.push(accountSecurityRoutePath)
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTokens.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: enabled
                            ? theme.colorScheme.primary
                            : theme.disabledColor,
                      ),
                      const SizedBox(width: AppTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeAccountSecurityTitle,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppTokens.spaceSm / 2),
                            Text(
                              l10n.homeAccountSecurityDescription,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: enabled ? null : theme.disabledColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
