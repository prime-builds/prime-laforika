import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/auth/presentation/auth_error_mapper.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _challengeId;
  String? _masked;
  String? _error;
  bool _loading = false;
  DateTime? _resendAt;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.requestPhoneChallenge(
      phone: _phoneController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    final l10n = AppLocalizations.of(context);
    result.when(
      success: (value) {
        setState(() {
          _challengeId = value.challengeId;
          _masked = value.maskedDestination;
          _resendAt = DateTime.tryParse(value.resendAvailableAt);
        });
      },
      failure: (failure) {
        setState(() => _error = mapAuthFailure(l10n, failure));
      },
    );
  }

  Future<void> _verify() async {
    final challengeId = _challengeId;
    if (_loading || challengeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyPhoneChallenge(
      challengeId: challengeId,
      code: _codeController.text,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
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
    final canResend = _resendAt == null || DateTime.now().isAfter(_resendAt!);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authPhoneTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: InputDecoration(labelText: l10n.authPhoneLabel),
                enabled: _challengeId == null && !_loading,
              ),
              if (_challengeId == null) ...[
                const SizedBox(height: AppTokens.spaceMd),
                FilledButton(
                  onPressed: _loading ? null : _requestCode,
                  child: Text(
                    _loading ? l10n.authPleaseWait : l10n.authSendCode,
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppTokens.spaceMd),
                Text(l10n.authCodeSentTo(_masked ?? '')),
                const SizedBox(height: AppTokens.spaceMd),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: InputDecoration(labelText: l10n.authOtpLabel),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                FilledButton(
                  onPressed: _loading ? null : _verify,
                  child: Text(
                    _loading ? l10n.authPleaseWait : l10n.authVerifyCode,
                  ),
                ),
                TextButton(
                  onPressed: (!_loading && canResend) ? _requestCode : null,
                  child: Text(l10n.authResendCode),
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
