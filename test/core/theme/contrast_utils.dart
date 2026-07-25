import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Relative luminance for sRGB [color] (WCAG 2.x).
double relativeLuminance(Color color) {
  double linearize(double channel) {
    final value = channel / 255.0;
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize(color.r * 255.0);
  final g = linearize(color.g * 255.0);
  final b = linearize(color.b * 255.0);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Contrast ratio between [foreground] and [background] (WCAG 2.x).
double contrastRatio(Color foreground, Color background) {
  final lighter = math.max(
    relativeLuminance(foreground),
    relativeLuminance(background),
  );
  final darker = math.min(
    relativeLuminance(foreground),
    relativeLuminance(background),
  );
  return (lighter + 0.05) / (darker + 0.05);
}
