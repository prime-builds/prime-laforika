import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

class SessionStartupScreen extends ConsumerStatefulWidget {
  const SessionStartupScreen({super.key});

  @override
  ConsumerState<SessionStartupScreen> createState() =>
      _SessionStartupScreenState();
}

class _SessionStartupScreenState extends ConsumerState<SessionStartupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).hydrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppTokens.spaceLg),
            child: switch (state) {
              AuthHydrationError() => Column(
                key: const Key('startup_error'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.authStartupError,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: AppTokens.minTouchTarget,
                      minHeight: AppTokens.minTouchTarget,
                    ),
                    child: FilledButton(
                      key: const Key('startup_retry'),
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .retryHydration();
                      },
                      child: Text(l10n.authRetry),
                    ),
                  ),
                ],
              ),
              _ => Column(
                key: const Key('startup_loading'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  Text(
                    l10n.authStartupLoading,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }
}
