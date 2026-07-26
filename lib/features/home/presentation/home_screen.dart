import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/home/presentation/home_search.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// Maximum content width for tablet/wide Home layouts.
const double _homeMaxContentWidth = 720;

typedef HomeDockItemsBuilder =
    List<ShellDockItem> Function(AppLocalizations l10n);
typedef HomeDockSelected = void Function(BuildContext context, String dockId);

/// Guest-first Home / discovery shell with adaptive application chrome.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.dockItems,
    required this.onDockSelected,
  });

  final HomeDockItemsBuilder dockItems;
  final HomeDockSelected onDockSelected;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _bodyScrollController = ScrollController();
  final _moduleStripScrollController = ScrollController();
  bool _moduleStripCompact = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _bodyScrollController.addListener(_onBodyScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bodyScrollController.dispose();
    _moduleStripScrollController.dispose();
    super.dispose();
  }

  void _onBodyScroll() {
    final compact =
        _bodyScrollController.hasClients &&
        _bodyScrollController.offset >=
            AppShellScaffold.moduleStripCompactThreshold;
    if (compact != _moduleStripCompact) {
      setState(() => _moduleStripCompact = compact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final showAccountSecurity = homeSearchMatches(
      query: _searchController.text,
      haystackParts: [
        l10n.homeAccountSecurityTitle,
        l10n.homeAccountSecurityDescription,
        l10n.homeOpenAccountSecurity,
        l10n.accountSecurityAction,
      ],
    );

    return AppShellScaffold(
      scaffoldKey: const Key('home_discovery_shell'),
      dockItems: widget.dockItems(l10n),
      dockSelectedId: ShellDockIds.home,
      onDockSelected: (id) => widget.onDockSelected(context, id),
      moduleStripCompact: _moduleStripCompact,
      moduleStripScrollController: _moduleStripScrollController,
      search: _HomeSearchField(controller: _searchController, l10n: l10n),
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _homeMaxContentWidth),
          child: ListView(
            controller: _bodyScrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppTokens.spaceLg,
              AppTokens.spaceMd,
              AppTokens.spaceLg,
              AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
            ),
            children: [
              _HomeWelcome(l10n: l10n, theme: theme),
              const SizedBox(height: AppTokens.spaceLg),
              // Keep AppBar-era security action available for integration tests.
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  key: const Key('home_account_security_action'),
                  tooltip: l10n.accountSecurityAction,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(
                      AppTokens.minTouchTarget,
                      AppTokens.minTouchTarget,
                    ),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: () => context.go(accountSecurityRoutePath),
                  icon: const Icon(Icons.security),
                ),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              if (showAccountSecurity)
                _HomeDestinationCard(l10n: l10n, theme: theme, enabled: true)
              else
                Semantics(
                  liveRegion: true,
                  label: l10n.shellSearchNoResults,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                    child: Text(
                      l10n.shellSearchNoResults,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.controller, required this.l10n});

  final TextEditingController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: l10n.shellSearchLabel,
      child: TextField(
        key: const Key('home_search_field'),
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.shellSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  key: const Key('home_search_clear'),
                  tooltip: l10n.shellSearchClear,
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
      ),
    );
  }
}

class _HomeWelcome extends StatelessWidget {
  const _HomeWelcome({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.homeWelcomeTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: AppTokens.spaceSm),
        Text(
          l10n.homeWelcomeSubtitle,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

class _HomeDestinationCard extends StatelessWidget {
  const _HomeDestinationCard({
    required this.l10n,
    required this.theme,
    required this.enabled,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: false,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppTokens.spaceMd,
              AppTokens.spaceMd,
              AppTokens.spaceMd,
              AppTokens.spaceSm,
            ),
            child: Text(
              l10n.homeAvailableSectionsTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Semantics(
            key: const Key('home_account_security'),
            button: true,
            enabled: enabled,
            label: l10n.homeOpenAccountSecurity,
            excludeSemantics: true,
            child: InkWell(
              onTap: enabled
                  ? () => context.go(accountSecurityRoutePath)
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTokens.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: enabled
                            ? theme.colorScheme.primary
                            : theme.disabledColor,
                      ),
                      const SizedBox(width: AppTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeAccountSecurityTitle,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppTokens.spaceSm / 2),
                            Text(
                              l10n.homeAccountSecurityDescription,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: enabled ? null : theme.disabledColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
