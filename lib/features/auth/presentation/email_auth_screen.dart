import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/presentation/auth_error_mapper.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _signUpMode = true;
  bool _loading = false;
  String? _error;
  String? _challengeId;
  String? _masked;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCredentials() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    if (_signUpMode) {
      final result = await repo.emailSignUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      result.when(
        success: (value) {
          setState(() {
            _challengeId = value.challengeId;
            _masked = value.maskedDestination;
          });
        },
        failure: (failure) {
          setState(() => _error = mapAuthFailure(l10n, failure));
        },
      );
    } else {
      final result = await repo.emailSignIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      await result.when(
        success: (tokens) async {
          await ref
              .read(authControllerProvider.notifier)
              .onCredentialsAccepted(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
                principal: AuthPrincipal(
                  accountId: tokens.accountId,
                  hasPhone: tokens.hasPhone,
                  hasEmail: tokens.hasEmail,
                  maskedPhone: tokens.maskedPhone,
                  maskedEmail: tokens.maskedEmail,
                ),
              );
        },
        failure: (failure) async {
          setState(() {
            _loading = false;
            _error = mapAuthFailure(l10n, failure);
          });
        },
      );
    }
  }

  Future<void> _verifyEmail() async {
    final challengeId = _challengeId;
    if (_loading || challengeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    final result = await repo.emailVerify(
      challengeId: challengeId,
      code: _codeController.text,
    );
    if (!mounted) return;
    await result.when(
      success: (tokens) async {
        await ref
            .read(authControllerProvider.notifier)
            .onCredentialsAccepted(
              accessToken: tokens.accessToken,
              refreshToken: tokens.refreshToken,
              principal: AuthPrincipal(
                accountId: tokens.accountId,
                hasPhone: tokens.hasPhone,
                hasEmail: tokens.hasEmail,
                maskedPhone: tokens.maskedPhone,
                maskedEmail: tokens.maskedEmail,
              ),
            );
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authEmailTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(l10n.authSignUp)),
                  ButtonSegment(value: false, label: Text(l10n.authSignIn)),
                ],
                selected: {_signUpMode},
                onSelectionChanged: _challengeId == null
                    ? (value) {
                        setState(() {
                          _signUpMode = value.first;
                          _error = null;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              if (_challengeId == null) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: l10n.authEmailLabel),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: _signUpMode
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: l10n.authPasswordLabel,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                FilledButton(
                  onPressed: _loading ? null : _submitCredentials,
                  child: Text(
                    _loading
                        ? l10n.authPleaseWait
                        : (_signUpMode ? l10n.authSignUp : l10n.authSignIn),
                  ),
                ),
                if (!_signUpMode)
                  TextButton(
                    onPressed: () => context.push(authPasswordResetRoutePath),
                    child: Text(l10n.authForgotPassword),
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
                FilledButton(
                  onPressed: _loading ? null : _verifyEmail,
                  child: Text(
                    _loading ? l10n.authPleaseWait : l10n.authVerifyCode,
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
            ],
          ),
        ),
      ),
    );
  }
}
