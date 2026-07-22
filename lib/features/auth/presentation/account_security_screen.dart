import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';
import 'package:laforika/features/auth/presentation/auth_error_mapper.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

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
            .updatePrincipal(
              AuthPrincipal(
                accountId: account.accountId,
                hasPhone: account.hasPhone,
                hasEmail: account.hasEmail,
                maskedPhone: account.maskedPhone,
                maskedEmail: account.maskedEmail,
              ),
            );
      },
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
    sessions.when(
      success: (value) => setState(() => _sessions = value),
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final principal = auth is AuthAuthenticated ? auth.principal : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSecurityTitle)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
                children: [
                  Text(l10n.accountIdLabel(principal?.accountId ?? '')),
                  const SizedBox(height: AppTokens.spaceMd),
                  Text(
                    principal?.hasPhone == true
                        ? l10n.accountPhoneAttached(
                            principal?.maskedPhone ?? '',
                          )
                        : l10n.accountPhoneMissing,
                  ),
                  Text(
                    principal?.hasEmail == true
                        ? l10n.accountEmailAttached(
                            principal?.maskedEmail ?? '',
                          )
                        : l10n.accountEmailMissing,
                  ),
                  const SizedBox(height: AppTokens.spaceLg),
                  Text(
                    l10n.accountSessionsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ..._sessions.map(
                    (session) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        session.deviceLabel ?? l10n.accountSessionDevice,
                      ),
                      subtitle: Text(session.lastSeenAt),
                      trailing: session.isCurrent
                          ? Text(l10n.accountSessionCurrent)
                          : IconButton(
                              tooltip: l10n.accountRevokeSession,
                              onPressed: () async {
                                await ref
                                    .read(authRepositoryProvider)
                                    .revokeSession(session.sessionId);
                                await _refresh();
                              },
                              icon: const Icon(Icons.logout),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .logoutAll();
                    },
                    child: Text(l10n.accountLogoutAll),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  FilledButton(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                    },
                    child: Text(l10n.authLogout),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppTokens.spaceMd),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
