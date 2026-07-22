import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class AuthMethodScreen extends StatelessWidget {
  const AuthMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authMethodTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.authMethodSubtitle,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.spaceXl),
              FilledButton(
                onPressed: () => context.push(authPhoneRoutePath),
                child: Text(l10n.authContinueWithPhone),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              OutlinedButton(
                onPressed: () => context.push(authEmailRoutePath),
                child: Text(l10n.authContinueWithEmail),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
