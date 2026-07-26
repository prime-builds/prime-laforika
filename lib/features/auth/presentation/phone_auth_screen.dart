import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/presentation/phone_auth_panel.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class PhoneAuthScreen extends ConsumerWidget {
  const PhoneAuthScreen({super.key, @visibleForTesting this.clock});

  /// Optional clock for widget tests (fake time / cooldown).
  @visibleForTesting
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authPhoneTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          child: PhoneAuthPanel(clock: clock),
        ),
      ),
    );
  }
}
