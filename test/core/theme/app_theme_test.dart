import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/theme/app_semantic_colors.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';

import 'contrast_utils.dart';

void main() {
  group('AppSemanticColors', () {
    test('light palette matches approved values', () {
      const c = AppSemanticColors.light;
      expect(c.appBackground, const Color(0xFFF3F3F3));
      expect(c.primarySurface, const Color(0xFFFFFFFF));
      expect(c.secondarySurface, const Color(0xFFF9F9F9));
      expect(c.elevatedSurface, const Color(0xFFFFFFFF));
      expect(c.primaryText, const Color(0xFF242424));
      expect(c.secondaryText, const Color(0xFF616161));
      expect(c.border, const Color(0xFFE5E5E5));
      expect(c.brandAccent, const Color(0xFF0067C0));
      expect(c.onBrandAccent, const Color(0xFFFFFFFF));
      expect(c.subtleSelection, const Color(0xFFE5F1FB));
      expect(c.error, const Color(0xFFC42B1C));
      expect(c.success, const Color(0xFF107C10));
    });

    test('dark palette matches approved values', () {
      const c = AppSemanticColors.dark;
      expect(c.appBackground, const Color(0xFF202020));
      expect(c.primarySurface, const Color(0xFF2C2C2C));
      expect(c.secondarySurface, const Color(0xFF252525));
      expect(c.elevatedSurface, const Color(0xFF323232));
      expect(c.primaryText, const Color(0xFFFFFFFF));
      expect(c.secondaryText, const Color(0xFFC7C7C7));
      expect(c.border, const Color(0xFF454545));
      expect(c.brandAccent, const Color(0xFF60CDFF));
      expect(c.onBrandAccent, const Color(0xFF003E5A));
      expect(c.subtleSelection, const Color(0xFF0F3A4F));
      expect(c.error, const Color(0xFFFF99A4));
      expect(c.success, const Color(0xFF6CCB5F));
    });

    test('essential light and dark surfaces differ', () {
      expect(
        AppSemanticColors.light.appBackground,
        isNot(AppSemanticColors.dark.appBackground),
      );
      expect(
        AppSemanticColors.light.primarySurface,
        isNot(AppSemanticColors.dark.primarySurface),
      );
      expect(
        AppSemanticColors.light.primaryText,
        isNot(AppSemanticColors.dark.primaryText),
      );
    });
  });

  group('ThemeData builders', () {
    test('light theme maps semantic roles into ColorScheme', () {
      final theme = buildLightTheme();
      final colors = theme.semanticColors;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, colors.appBackground);
      expect(theme.colorScheme.surface, colors.primarySurface);
      expect(theme.colorScheme.onSurface, colors.primaryText);
      expect(theme.colorScheme.primary, colors.brandAccent);
      expect(theme.colorScheme.onPrimary, colors.onBrandAccent);
      expect(theme.colorScheme.error, colors.error);
      expect(theme.colorScheme.outline, colors.border);
      expect(colors.secondaryText, const Color(0xFF616161));
      expect(colors.subtleSelection, const Color(0xFFE5F1FB));
      expect(colors.success, const Color(0xFF107C10));
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTokens.fontFamily);
      expect(theme.textTheme.titleMedium?.fontFamily, AppTokens.fontFamily);
    });

    test('dark theme maps semantic roles into ColorScheme', () {
      final theme = buildDarkTheme();
      final colors = theme.semanticColors;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, colors.appBackground);
      expect(theme.colorScheme.surface, colors.primarySurface);
      expect(theme.colorScheme.onSurface, colors.primaryText);
      expect(theme.colorScheme.primary, colors.brandAccent);
      expect(theme.colorScheme.onPrimary, colors.onBrandAccent);
      expect(theme.colorScheme.error, colors.error);
      expect(theme.colorScheme.outline, colors.border);
      expect(colors.success, const Color(0xFF6CCB5F));
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTokens.fontFamily);
    });

    test('non-color tokens keep approved invariants', () {
      expect(AppTokens.spaceSm, 8);
      expect(AppTokens.spaceMd, 16);
      expect(AppTokens.spaceLg, 24);
      expect(AppTokens.spaceXl, 32);
      expect(AppTokens.pagePadding, 16);
      expect(AppTokens.minTouchTarget, 48);
      expect(AppTokens.radiusSm, inInclusiveRange(12, 16));
      expect(AppTokens.radiusMd, inInclusiveRange(12, 16));
      expect(AppTokens.radiusDock, inInclusiveRange(24, 28));
      expect(AppTokens.borderWidth, 1);
      expect(
        AppTokens.motionStandard.inMilliseconds,
        inInclusiveRange(180, 250),
      );
    });
  });

  group('WCAG AA contrast', () {
    const aa = 4.5;
    const aaGraphic = 3.0;

    test('light pairs meet AA for normal text and controls', () {
      const c = AppSemanticColors.light;
      final surfaces = [
        c.appBackground,
        c.primarySurface,
        c.secondarySurface,
        c.elevatedSurface,
      ];

      for (final surface in surfaces) {
        expect(
          contrastRatio(c.primaryText, surface),
          greaterThanOrEqualTo(aa),
          reason: 'primaryText on $surface',
        );
        expect(
          contrastRatio(c.secondaryText, surface),
          greaterThanOrEqualTo(aa),
          reason: 'secondaryText on $surface',
        );
      }

      expect(
        contrastRatio(c.onBrandAccent, c.brandAccent),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.error, c.primarySurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.error, c.elevatedSurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.success, c.primarySurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.success, c.elevatedSurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.brandAccent, c.subtleSelection),
        greaterThanOrEqualTo(aaGraphic),
      );

      // Composited translucent dock surface (elevatedSurface @ 0.92 alpha over appBackground)
      final dockSurface = compositeOver(
        c.elevatedSurface.withValues(alpha: 0.92),
        c.appBackground,
      );
      expect(
        contrastRatio(c.secondaryText, dockSurface),
        greaterThanOrEqualTo(aa),
        reason: 'inactive dock icon on composited dock surface',
      );
    });

    test('dark pairs meet AA for normal text and controls', () {
      const c = AppSemanticColors.dark;
      final surfaces = [
        c.appBackground,
        c.primarySurface,
        c.secondarySurface,
        c.elevatedSurface,
      ];

      for (final surface in surfaces) {
        expect(
          contrastRatio(c.primaryText, surface),
          greaterThanOrEqualTo(aa),
          reason: 'primaryText on $surface',
        );
        expect(
          contrastRatio(c.secondaryText, surface),
          greaterThanOrEqualTo(aa),
          reason: 'secondaryText on $surface',
        );
      }

      expect(
        contrastRatio(c.onBrandAccent, c.brandAccent),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.error, c.primarySurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.error, c.elevatedSurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.success, c.primarySurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.success, c.elevatedSurface),
        greaterThanOrEqualTo(aa),
      );
      expect(
        contrastRatio(c.brandAccent, c.subtleSelection),
        greaterThanOrEqualTo(aaGraphic),
      );

      // Composited translucent dock surface (elevatedSurface @ 0.92 alpha over appBackground)
      final dockSurface = compositeOver(
        c.elevatedSurface.withValues(alpha: 0.92),
        c.appBackground,
      );
      expect(
        contrastRatio(c.secondaryText, dockSurface),
        greaterThanOrEqualTo(aa),
        reason: 'inactive dock icon on composited dock surface',
      );
    });
  });
}
