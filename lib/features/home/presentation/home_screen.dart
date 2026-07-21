import 'package:flutter/material.dart';

import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// Minimal presentation-only Home screen for M0.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Align(
          alignment: AlignmentDirectional.center,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
            child: Text(
              l10n.homeWelcomeMessage,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
