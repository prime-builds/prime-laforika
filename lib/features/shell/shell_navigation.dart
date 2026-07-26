import 'package:laforika/features/shell/shell_models.dart';

/// Minimum drag distance (logical px) before a dock swipe changes selection.
const double kShellDockSwipeDistanceThreshold = 32;

/// Minimum drag velocity (logical px/s) that can complete a dock swipe.
const double kShellDockSwipeVelocityThreshold = 280;

/// Whether a drag should be treated as a dock swipe rather than a tap.
bool shellDockSwipeExceedsThreshold({
  required double primaryDelta,
  required double primaryVelocity,
}) {
  return primaryDelta.abs() >= kShellDockSwipeDistanceThreshold ||
      primaryVelocity.abs() >= kShellDockSwipeVelocityThreshold;
}

/// Next dock id when swiping toward visual left in RTL.
///
/// Approved sequence: Home → Chat → Profile. Does not wrap.
String? shellDockNeighborVisualLeft(
  String selectedId,
  List<String> availableIdsInVisualRtlOrder,
) {
  return _neighbor(
    selectedId: selectedId,
    availableIdsInVisualRtlOrder: availableIdsInVisualRtlOrder,
    towardVisualLeft: true,
  );
}

/// Next dock id when swiping toward visual right in RTL.
///
/// Approved sequence: Profile → Chat → Home. Does not wrap.
String? shellDockNeighborVisualRight(
  String selectedId,
  List<String> availableIdsInVisualRtlOrder,
) {
  return _neighbor(
    selectedId: selectedId,
    availableIdsInVisualRtlOrder: availableIdsInVisualRtlOrder,
    towardVisualLeft: false,
  );
}

/// Canonical full-shell visual RTL order: Profile (left), Chat, Home (right).
List<String> shellDockCanonicalVisualRtlOrder({
  required bool includeProfile,
  required bool includeChat,
  required bool includeHome,
}) {
  return [
    if (includeProfile) ShellDockIds.profile,
    if (includeChat) ShellDockIds.chat,
    if (includeHome) ShellDockIds.home,
  ];
}

String? _neighbor({
  required String selectedId,
  required List<String> availableIdsInVisualRtlOrder,
  required bool towardVisualLeft,
}) {
  if (availableIdsInVisualRtlOrder.length < 2) {
    return null;
  }
  final index = availableIdsInVisualRtlOrder.indexOf(selectedId);
  if (index < 0) {
    return null;
  }
  // Visual-left swipe moves toward earlier indices in RTL visual order list
  // when the list is Profile…Home (Profile at visual left = index 0).
  // Swipe toward visual left: Home(2)→Chat(1)→Profile(0) ⇒ decreasing index.
  // Swipe toward visual right: Profile(0)→Chat(1)→Home(2) ⇒ increasing index.
  final nextIndex = towardVisualLeft ? index - 1 : index + 1;
  if (nextIndex < 0 || nextIndex >= availableIdsInVisualRtlOrder.length) {
    return null;
  }
  return availableIdsInVisualRtlOrder[nextIndex];
}
