import 'package:flutter/material.dart';

import 'package:laforika/features/shell/shell_models.dart';
import 'package:laforika/features/shell/shell_navigation.dart';
import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/core/theme/app_tokens.dart';

/// Floating centered bottom dock. Callers supply real destinations only.
class FloatingBottomDock extends StatefulWidget {
  const FloatingBottomDock({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  /// Items in **visual left-to-right order**: Profile → Chat → Home when all exist
  /// (Profile leftmost, Home rightmost). The dock lays out with an LTR row so this
  /// order is preserved under an ambient RTL [Directionality].
  final List<ShellDockItem> items;

  /// Selected destination id, or `null` when no dock item is selected (module).
  final String? selectedId;

  final ValueChanged<String> onSelected;

  @override
  State<FloatingBottomDock> createState() => _FloatingBottomDockState();
}

class _FloatingBottomDockState extends State<FloatingBottomDock> {
  double _dragDx = 0;

  @override
  Widget build(BuildContext context) {
    assert(
      widget.items.isNotEmpty,
      'FloatingBottomDock requires at least one destination',
    );
    final colors = Theme.of(context).extension<AppSemanticColors>()!;
    final surface = colors.elevatedSurface.withValues(alpha: 0.92);

    return Material(
      color: Colors.transparent,
      elevation: AppTokens.elevationMedium,
      shadowColor: colors.primaryText.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppTokens.radiusDock),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusDock),
          border: Border.all(
            color: colors.border,
            width: AppTokens.borderWidth,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => _dragDx = 0,
          onHorizontalDragUpdate: (details) {
            _dragDx += details.primaryDelta ?? 0;
          },
          onHorizontalDragEnd: _onSwipe,
          onHorizontalDragCancel: () => _dragDx = 0,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.spaceSm,
              vertical: AppTokens.spaceSm / 2,
            ),
            // Force LTR so visual-order items stay Profile…Home under ambient RTL.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in widget.items)
                    _DockButton(
                      item: item,
                      selected: widget.selectedId == item.id,
                      colors: colors,
                      onTap: () => widget.onSelected(item.id),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSwipe(DragEndDetails details) {
    final selected = widget.selectedId;
    final items = widget.items;
    final dragDx = _dragDx;
    _dragDx = 0;
    if (selected == null || items.length < 2) {
      return;
    }
    // Screen coordinates: negative delta/velocity = finger toward visual left.
    final velocity = details.primaryVelocity ?? 0;
    if (!shellDockSwipeExceedsThreshold(
      primaryDelta: dragDx,
      primaryVelocity: velocity,
    )) {
      return;
    }
    final towardVisualLeft = dragDx.abs() >= kShellDockSwipeDistanceThreshold
        ? dragDx < 0
        : velocity < 0;
    final ids = items.map((e) => e.id).toList(growable: false);
    final next = towardVisualLeft
        ? shellDockNeighborVisualLeft(selected, ids)
        : shellDockNeighborVisualRight(selected, ids);
    if (next != null) {
      widget.onSelected(next);
    }
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final ShellDockItem item;
  final bool selected;
  final AppSemanticColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;
    return Semantics(
      key: Key('shell_dock_${item.id}'),
      button: true,
      selected: selected,
      label: item.semanticLabel,
      child: Material(
        color: selected ? colors.subtleSelection : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppTokens.minTouchTarget,
              minHeight: AppTokens.minTouchTarget,
            ),
            child: Icon(
              icon,
              color: selected ? colors.brandAccent : colors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
