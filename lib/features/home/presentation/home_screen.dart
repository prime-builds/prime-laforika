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

/// Width at which account-status and quick-action may sit side by side.
const double _homeWideBreakpoint = 600;

/// Authenticated Home / discovery shell.
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
    final principal = auth is AuthAuthenticated ? auth.principal : null;

    return Scaffold(
      key: const Key('home_discovery_shell'),
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            key: const Key('home_account_security_action'),
            tooltip: l10n.accountSecurityAction,
            onPressed: () => context.push(accountSecurityRoutePath),
            icon: const Icon(Icons.security),
          ),
          IconButton(
            key: const Key('home_logout'),
            tooltip: l10n.homeLogoutTooltip,
            onPressed: _logoutPending ? null : _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _homeWideBreakpoint;
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
                      if (principal != null)
                        wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _AccountStatusCard(
                                      l10n: l10n,
                                      theme: theme,
                                      principal: principal,
                                    ),
                                  ),
                                  const SizedBox(width: AppTokens.spaceMd),
                                  Expanded(
                                    child: _HomeDestinationCard(
                                      l10n: l10n,
                                      theme: theme,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _AccountStatusCard(
                                    l10n: l10n,
                                    theme: theme,
                                    principal: principal,
                                  ),
                                  const SizedBox(height: AppTokens.spaceMd),
                                  _HomeDestinationCard(
                                    l10n: l10n,
                                    theme: theme,
                                  ),
                                ],
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

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({
    required this.l10n,
    required this.theme,
    required this.principal,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final AuthPrincipal principal;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('home_account_status'),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.homeAccountStatusTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            _CredentialStatusRow(
              key: const Key('home_phone_status'),
              ready: principal.hasPhone,
              readyLabel: l10n.homePhoneReady,
              missingLabel: l10n.homePhoneMissing,
              maskedValue: principal.maskedPhone,
              readyIcon: Icons.phone_android,
              missingIcon: Icons.phone_disabled_outlined,
            ),
            const SizedBox(height: AppTokens.spaceSm),
            _CredentialStatusRow(
              key: const Key('home_email_status'),
              ready: principal.hasEmail,
              readyLabel: l10n.homeEmailReady,
              missingLabel: l10n.homeEmailMissing,
              maskedValue: principal.maskedEmail,
              readyIcon: Icons.email_outlined,
              missingIcon: Icons.mail_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialStatusRow extends StatelessWidget {
  const _CredentialStatusRow({
    super.key,
    required this.ready,
    required this.readyLabel,
    required this.missingLabel,
    required this.maskedValue,
    required this.readyIcon,
    required this.missingIcon,
  });

  final bool ready;
  final String readyLabel;
  final String missingLabel;
  final String? maskedValue;
  final IconData readyIcon;
  final IconData missingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = ready ? readyLabel : missingLabel;
    final showMask =
        ready && maskedValue != null && maskedValue!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(ready ? readyIcon : missingIcon)),
        const SizedBox(width: AppTokens.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyLarge),
              if (showMask) ...[
                const SizedBox(height: AppTokens.spaceSm / 2),
                Text(
                  maskedValue!.trim(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeDestinationCard extends StatelessWidget {
  const _HomeDestinationCard({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

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
            label: l10n.homeOpenAccountSecurity,
            excludeSemantics: true,
            onTap: () => context.push(accountSecurityRoutePath),
            child: InkWell(
              onTap: () => context.push(accountSecurityRoutePath),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTokens.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: theme.colorScheme.primary),
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
