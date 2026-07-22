import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/presentation/auth_error_mapper.dart';
import 'package:laforika/features/auth/presentation/resend_cooldown_controller.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  late final ResendCooldownController _resendCooldown =
      ResendCooldownController(
        onChanged: () {
          if (mounted) setState(() {});
        },
      );
  String? _challengeId;
  String? _masked;
  String? _error;
  String? _success;
  bool _loading = false;

  @override
  void dispose() {
    _resendCooldown.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(email: _emailController.text);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _loading = false);
    result.when(
      success: (value) {
        setState(() {
          _challengeId = value.challengeId;
          _masked = value.maskedDestination;
          _error = null;
          _codeController.clear();
        });
        _resendCooldown.update(DateTime.tryParse(value.resendAvailableAt));
      },
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  Future<void> _reset() async {
    final challengeId = _challengeId;
    if (_loading || challengeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          challengeId: challengeId,
          code: _codeController.text,
          newPassword: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    result.when(
      success: (_) {
        setState(() => _success = l10n.authPasswordResetSuccess);
      },
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canResend = _resendCooldown.canResend;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authPasswordResetTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_challengeId == null) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.authEmailLabel),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                FilledButton(
                  onPressed: _loading ? null : _request,
                  child: Text(
                    _loading ? l10n.authPleaseWait : l10n.authSendCode,
                  ),
                ),
              ] else ...[
                Text(l10n.authCodeSentTo(_masked ?? '')),
                const SizedBox(height: AppTokens.spaceMd),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.authOtpLabel),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.authNewPasswordLabel,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                FilledButton(
                  onPressed: _loading ? null : _reset,
                  child: Text(
                    _loading ? l10n.authPleaseWait : l10n.authResetPassword,
                  ),
                ),
                TextButton(
                  key: const Key('auth_password_reset_resend'),
                  onPressed: (!_loading && canResend) ? _request : null,
                  child: Text(
                    canResend
                        ? l10n.authResendCode
                        : l10n.authResendInSeconds(
                            _resendCooldown.remainingSeconds,
                          ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppTokens.spaceMd),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: AppTokens.spaceMd),
                Text(_success!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
