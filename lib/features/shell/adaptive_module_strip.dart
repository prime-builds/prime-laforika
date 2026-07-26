import 'package:flutter/material.dart';

import 'package:laforika/features/shell/shell_models.dart';
import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/core/theme/app_tokens.dart';

/// Horizontally scrollable adaptive module strip (expanded or compact).
///
/// Omit from the tree when [modules] is empty. Horizontal scroll position is
/// preserved across compact transitions by reusing [horizontalController].
class AdaptiveModuleStrip extends StatelessWidget {
  const AdaptiveModuleStrip({
    super.key,
    required this.modules,
    required this.selectedId,
    required this.compact,
    required this.onSelected,
    this.horizontalController,
  });

  final List<ShellModuleItem> modules;
  final String? selectedId;
  final bool compact;
  final ValueChanged<String> onSelected;
  final ScrollController? horizontalController;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).extension<AppSemanticColors>()!;

    return SizedBox(
      height: compact ? AppTokens.minTouchTarget : 72,
      child: ListView.separated(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.pagePadding,
        ),
        itemCount: modules.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTokens.spaceSm),
        itemBuilder: (context, index) {
          final module = modules[index];
          final selected = selectedId == module.id;
          return _ModuleChip(
            module: module,
            selected: selected,
            compact: compact,
            colors: colors,
            onTap: () => onSelected(module.id),
          );
        },
      ),
    );
  }
}

class _ModuleChip extends StatelessWidget {
  const _ModuleChip({
    required this.module,
    required this.selected,
    required this.compact,
    required this.colors,
    required this.onTap,
  });

  final ShellModuleItem module;
  final bool selected;
  final bool compact;
  final AppSemanticColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: module.label,
      child: Material(
        color: selected ? colors.subtleSelection : colors.secondarySurface,
        elevation: selected ? AppTokens.elevationLow : AppTokens.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            compact ? AppTokens.radiusSm : AppTokens.radiusMd,
          ),
          side: BorderSide(
            color: selected ? colors.brandAccent : colors.border,
            width: selected ? 1.5 : AppTokens.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            compact ? AppTokens.radiusSm : AppTokens.radiusMd,
          ),
          child: AnimatedSize(
            duration: AppTokens.motionStandard,
            curve: Curves.easeInOut,
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppTokens.minTouchTarget,
                minHeight: AppTokens.minTouchTarget,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: compact ? AppTokens.spaceMd : AppTokens.spaceLg,
                  vertical: AppTokens.spaceSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!compact) ...[
                      Icon(
                        module.icon,
                        color: selected
                            ? colors.brandAccent
                            : colors.secondaryText,
                      ),
                      const SizedBox(width: AppTokens.spaceSm),
                    ],
                    Text(
                      module.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? theme.textTheme.labelLarge
                                  : theme.textTheme.titleSmall)
                              ?.copyWith(
                                color: selected
                                    ? colors.brandAccent
                                    : colors.primaryText,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
