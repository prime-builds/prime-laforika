import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/features/shell/shell.dart';

void main() {
  group('shellDockCanonicalVisualRtlOrder', () {
    test('full shell is Profile, Chat, Home', () {
      expect(
        shellDockCanonicalVisualRtlOrder(
          includeProfile: true,
          includeChat: true,
          includeHome: true,
        ),
        [ShellDockIds.profile, ShellDockIds.chat, ShellDockIds.home],
      );
    });

    test('home-only production dock', () {
      expect(
        shellDockCanonicalVisualRtlOrder(
          includeProfile: false,
          includeChat: false,
          includeHome: true,
        ),
        [ShellDockIds.home],
      );
    });
  });

  group('shell dock adjacency', () {
    const full = [ShellDockIds.profile, ShellDockIds.chat, ShellDockIds.home];

    test('visual-left Home → Chat → Profile', () {
      expect(
        shellDockNeighborVisualLeft(ShellDockIds.home, full),
        ShellDockIds.chat,
      );
      expect(
        shellDockNeighborVisualLeft(ShellDockIds.chat, full),
        ShellDockIds.profile,
      );
    });

    test('visual-right Profile → Chat → Home', () {
      expect(
        shellDockNeighborVisualRight(ShellDockIds.profile, full),
        ShellDockIds.chat,
      );
      expect(
        shellDockNeighborVisualRight(ShellDockIds.chat, full),
        ShellDockIds.home,
      );
    });

    test('does not wrap at edges', () {
      expect(shellDockNeighborVisualLeft(ShellDockIds.profile, full), isNull);
      expect(shellDockNeighborVisualRight(ShellDockIds.home, full), isNull);
    });

    test('single item is a no-op', () {
      expect(
        shellDockNeighborVisualLeft(ShellDockIds.home, [ShellDockIds.home]),
        isNull,
      );
      expect(
        shellDockNeighborVisualRight(ShellDockIds.home, [ShellDockIds.home]),
        isNull,
      );
    });
  });

  group('shellDockSwipeExceedsThreshold', () {
    test('rejects small motions', () {
      expect(
        shellDockSwipeExceedsThreshold(primaryDelta: 10, primaryVelocity: 100),
        isFalse,
      );
    });

    test('accepts distance or velocity', () {
      expect(
        shellDockSwipeExceedsThreshold(
          primaryDelta: kShellDockSwipeDistanceThreshold,
          primaryVelocity: 0,
        ),
        isTrue,
      );
      expect(
        shellDockSwipeExceedsThreshold(
          primaryDelta: 0,
          primaryVelocity: kShellDockSwipeVelocityThreshold,
        ),
        isTrue,
      );
    });
  });
}
