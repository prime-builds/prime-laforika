import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/presentation/auth_error_mapper.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// Protected account security surface — sessions and logout only.
class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  List<SessionDto> _sessions = const [];
  String? _error;
  bool _loading = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final me = await ref.read(authRepositoryProvider).me();
    final sessions = await ref.read(authRepositoryProvider).listSessions();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    me.when(
      success: (account) {
        ref
            .read(authControllerProvider.notifier)
            .updatePrincipal(AuthPrincipal(accountId: account.accountId));
      },
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
    sessions.when(
      success: (value) {
        setState(() {
          _sessions = value;
          _loaded = true;
          _loading = false;
        });
      },
      failure: (failure) {
        setState(() {
          _error = mapAuthFailure(l10n, failure);
          _loading = false;
          _loaded = true;
        });
      },
    );
  }

  Future<void> _revoke(String sessionId) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .revokeSession(sessionId);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await result.when(
      success: (_) async => _refresh(),
      failure: (failure) async {
        setState(() {
          _loading = false;
          _error = mapAuthFailure(l10n, failure);
        });
      },
    );
  }

  Future<void> _logoutCurrent() async {
    if (_loading) return;
    setState(() => _loading = true);
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    // Guest-first: land on public Home, not the preserved protected return path.
    context.go('/');
  }

  Future<void> _logoutAll() async {
    if (_loading) return;
    setState(() => _loading = true);
    await ref.read(authControllerProvider.notifier).logoutAll();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final accountId = auth is AuthAuthenticated
        ? auth.principal.accountId
        : null;

    return Scaffold(
      key: const Key('account_security_screen'),
      appBar: AppBar(title: Text(l10n.accountSecurityTitle)),
      body: SafeArea(
        child: _loading && !_loaded
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
                  children: [
                    if (accountId != null) ...[
                      Text(
                        l10n.accountIdLabel(accountId),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppTokens.spaceLg),
                    ],
                    Text(
                      l10n.accountSessionsTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    if (_loaded && _sessions.isEmpty)
                      Text(
                        l10n.accountSessionsEmpty,
                        style: theme.textTheme.bodyLarge,
                      ),
                    for (final session in _sessions)
                      Card(
                        key: Key('account_session_${session.sessionId}'),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(
                            AppTokens.spaceMd,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.deviceLabel?.trim().isNotEmpty == true
                                    ? session.deviceLabel!
                                    : l10n.accountSessionDevice,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppTokens.spaceSm / 2),
                              Text(
                                session.isCurrent
                                    ? l10n.accountSessionCurrent
                                    : session.lastSeenAt,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (!session.isCurrent) ...[
                                const SizedBox(height: AppTokens.spaceSm),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton(
                                    key: Key(
                                      'account_revoke_${session.sessionId}',
                                    ),
                                    onPressed: _loading
                                        ? null
                                        : () => _revoke(session.sessionId),
                                    child: Text(l10n.accountRevokeSession),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppTokens.spaceLg),
                    FilledButton(
                      key: const Key('account_logout_current'),
                      onPressed: _loading ? null : _logoutCurrent,
                      child: Text(l10n.authLogout),
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    OutlinedButton(
                      key: const Key('account_logout_all'),
                      onPressed: _loading ? null : _logoutAll,
                      child: Text(l10n.accountLogoutAll),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppTokens.spaceMd),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
