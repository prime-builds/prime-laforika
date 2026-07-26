import 'package:flutter/material.dart';

import 'package:laforika/features/shell/shell_models.dart';
import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/core/theme/app_tokens.dart';

/// Horizontally scrollable contextual tabs for an active module.
///
/// Policy: when [selectedId] is null or not in [tabs], the first tab is treated
/// as selected for rendering and [onSelected] is not auto-fired (caller should
/// normalize selection when activating a module).
class ContextualTabStrip extends StatelessWidget {
  const ContextualTabStrip({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ShellTabItem> tabs;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Resolves a valid selected tab id; falls back to the first tab.
  static String? resolveSelectedId(
    List<ShellTabItem> tabs,
    String? selectedId,
  ) {
    if (tabs.isEmpty) {
      return null;
    }
    if (selectedId != null && tabs.any((t) => t.id == selectedId)) {
      return selectedId;
    }
    return tabs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }
    final effective = resolveSelectedId(tabs, selectedId);
    final colors = Theme.of(context).extension<AppSemanticColors>()!;

    return SizedBox(
      height: AppTokens.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.pagePadding,
        ),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTokens.spaceSm),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = effective == tab.id;
          return _TabChip(
            tab: tab,
            selected: selected,
            colors: colors,
            onTap: () => onSelected(tab.id),
          );
        },
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final ShellTabItem tab;
  final bool selected;
  final AppSemanticColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: Material(
        color: selected ? colors.subtleSelection : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          side: BorderSide(
            color: selected ? colors.brandAccent : colors.border,
            width: selected ? 1.5 : AppTokens.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppTokens.minTouchTarget,
              minHeight: AppTokens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.spaceMd,
              ),
              child: Center(
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? colors.brandAccent : colors.primaryText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
