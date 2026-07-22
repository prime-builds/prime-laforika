import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _attachEmailController = TextEditingController();
  final _attachPasswordController = TextEditingController();
  final _attachEmailCodeController = TextEditingController();
  final _attachPhoneController = TextEditingController();
  final _attachPhoneCodeController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  List<SessionDto> _sessions = const [];
  String? _error;
  String? _success;
  bool _loading = false;
  String? _emailChallengeId;
  String? _phoneChallengeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _attachEmailController.dispose();
    _attachPasswordController.dispose();
    _attachEmailCodeController.dispose();
    _attachPhoneController.dispose();
    _attachPhoneCodeController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
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

  Future<void> _startAttachEmail() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .attachEmailChallenge(
          email: _attachEmailController.text,
          password: _attachPasswordController.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    result.when(
      success: (value) => setState(() => _emailChallengeId = value.challengeId),
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  Future<void> _verifyAttachEmail() async {
    final challengeId = _emailChallengeId;
    if (_loading || challengeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .verifyAttachEmail(
          challengeId: challengeId,
          code: _attachEmailCodeController.text,
        );
    if (!mounted) return;
    await result.when(
      success: (account) async {
        setState(() => _emailChallengeId = null);
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
        await _refresh();
      },
      failure: (failure) async {
        setState(() {
          _loading = false;
          _error = mapAuthFailure(l10n, failure);
        });
      },
    );
  }

  Future<void> _startAttachPhone() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .attachPhoneChallenge(phone: _attachPhoneController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    result.when(
      success: (value) => setState(() => _phoneChallengeId = value.challengeId),
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  Future<void> _verifyAttachPhone() async {
    final challengeId = _phoneChallengeId;
    if (_loading || challengeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .verifyAttachPhone(
          challengeId: challengeId,
          code: _attachPhoneCodeController.text,
        );
    if (!mounted) return;
    await result.when(
      success: (account) async {
        setState(() => _phoneChallengeId = null);
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
        await _refresh();
      },
      failure: (failure) async {
        setState(() {
          _loading = false;
          _error = mapAuthFailure(l10n, failure);
        });
      },
    );
  }

  Future<void> _removePhone() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref.read(authRepositoryProvider).removePhone();
    if (!mounted) return;
    await result.when(
      success: (_) => _refresh(),
      failure: (failure) async {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  Future<void> _removeEmail() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref.read(authRepositoryProvider).removeEmail();
    if (!mounted) return;
    await result.when(
      success: (_) => _refresh(),
      failure: (failure) async {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  Future<void> _changePassword() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;
    await result.when(
      success: (_) async {
        setState(() {
          _loading = false;
          _success = l10n.accountChangePasswordSuccess;
          _currentPasswordController.clear();
          _newPasswordController.clear();
        });
        // Backend revokes all sessions on password change.
        await ref.read(authControllerProvider.notifier).forceUnauthenticated();
      },
      failure: (failure) async {
        setState(() {
          _loading = false;
          _error = mapAuthFailure(l10n, failure);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final principal = auth is AuthAuthenticated ? auth.principal : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSecurityTitle)),
      body: SafeArea(
        child: _loading && _sessions.isEmpty && principal == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
                children: [
                  Text(
                    key: const Key('account_id_label'),
                    l10n.accountIdLabel(principal?.accountId ?? ''),
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  Text(
                    principal?.hasPhone == true
                        ? l10n.accountPhoneAttached(
                            principal?.maskedPhone ?? '',
                          )
                        : l10n.accountPhoneMissing,
                  ),
                  if (principal?.hasPhone == true)
                    TextButton(
                      key: const Key('account_remove_phone'),
                      onPressed: _loading ? null : _removePhone,
                      child: Text(l10n.accountRemovePhone),
                    ),
                  Text(
                    principal?.hasEmail == true
                        ? l10n.accountEmailAttached(
                            principal?.maskedEmail ?? '',
                          )
                        : l10n.accountEmailMissing,
                  ),
                  if (principal?.hasEmail == true)
                    TextButton(
                      key: const Key('account_remove_email'),
                      onPressed: _loading ? null : _removeEmail,
                      child: Text(l10n.accountRemoveEmail),
                    ),
                  if (principal?.hasEmail != true) ...[
                    const SizedBox(height: AppTokens.spaceLg),
                    Text(
                      l10n.accountAttachEmailTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextField(
                      key: const Key('account_attach_email'),
                      controller: _attachEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.authEmailLabel,
                      ),
                      enabled: _emailChallengeId == null && !_loading,
                    ),
                    TextField(
                      key: const Key('account_attach_password'),
                      controller: _attachPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.authPasswordLabel,
                      ),
                      enabled: _emailChallengeId == null && !_loading,
                    ),
                    if (_emailChallengeId == null)
                      FilledButton(
                        key: const Key('account_attach_email_send'),
                        onPressed: _loading ? null : _startAttachEmail,
                        child: Text(
                          _loading ? l10n.authPleaseWait : l10n.authSendCode,
                        ),
                      )
                    else ...[
                      TextField(
                        key: const Key('account_attach_email_code'),
                        controller: _attachEmailCodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.authOtpLabel,
                        ),
                      ),
                      FilledButton(
                        key: const Key('account_attach_email_verify'),
                        onPressed: _loading ? null : _verifyAttachEmail,
                        child: Text(
                          _loading ? l10n.authPleaseWait : l10n.authVerifyCode,
                        ),
                      ),
                    ],
                  ],
                  if (principal?.hasPhone != true) ...[
                    const SizedBox(height: AppTokens.spaceLg),
                    Text(
                      l10n.accountAttachPhoneTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextField(
                      key: const Key('account_attach_phone'),
                      controller: _attachPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.authPhoneLabel,
                      ),
                      enabled: _phoneChallengeId == null && !_loading,
                    ),
                    if (_phoneChallengeId == null)
                      FilledButton(
                        key: const Key('account_attach_phone_send'),
                        onPressed: _loading ? null : _startAttachPhone,
                        child: Text(
                          _loading ? l10n.authPleaseWait : l10n.authSendCode,
                        ),
                      )
                    else ...[
                      TextField(
                        key: const Key('account_attach_phone_code'),
                        controller: _attachPhoneCodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.authOtpLabel,
                        ),
                      ),
                      FilledButton(
                        key: const Key('account_attach_phone_verify'),
                        onPressed: _loading ? null : _verifyAttachPhone,
                        child: Text(
                          _loading ? l10n.authPleaseWait : l10n.authVerifyCode,
                        ),
                      ),
                    ],
                  ],
                  if (principal?.hasEmail == true) ...[
                    const SizedBox(height: AppTokens.spaceLg),
                    Text(
                      l10n.accountChangePasswordTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextField(
                      key: const Key('account_current_password'),
                      controller: _currentPasswordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: l10n.accountCurrentPasswordLabel,
                      ),
                      enabled: !_loading,
                    ),
                    TextField(
                      key: const Key('account_new_password'),
                      controller: _newPasswordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.authNewPasswordLabel,
                      ),
                      enabled: !_loading,
                    ),
                    FilledButton(
                      key: const Key('account_change_password'),
                      onPressed: _loading ? null : _changePassword,
                      child: Text(
                        _loading
                            ? l10n.authPleaseWait
                            : l10n.accountChangePasswordAction,
                      ),
                    ),
                  ],
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
                              key: Key('account_revoke_${session.sessionId}'),
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
                    key: const Key('account_logout_all'),
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .logoutAll();
                    },
                    child: Text(l10n.accountLogoutAll),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  FilledButton(
                    key: const Key('account_logout'),
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                    },
                    child: Text(l10n.authLogout),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppTokens.spaceMd),
                    Text(
                      key: const Key('account_security_error'),
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_success != null) ...[
                    const SizedBox(height: AppTokens.spaceMd),
                    Text(
                      key: const Key('account_security_success'),
                      _success!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
