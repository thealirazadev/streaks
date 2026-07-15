import 'package:flutter/material.dart';

/// Seed color and habit accent palette. See `docs/design.md` for rationale;
/// screens read colors from the generated `ColorScheme`, never these hex
/// values directly, except when picking or rendering a habit's own color.
abstract final class AppColors {
  /// A calm green, reinforcing growth and streaks.
  static const Color seed = Color(0xFF3B7A57);

  /// Fixed palette of eight accessible swatches a habit can pick as its
  /// accent color. Stored as the ARGB int on the habit row.
  static const List<Color> habitPalette = [
    Color(0xFFE4572E),
    Color(0xFFF3A712),
    Color(0xFF3B7A57),
    Color(0xFF2E86AB),
    Color(0xFF5D5FEF),
    Color(0xFF8E44AD),
    Color(0xFFD6336C),
    Color(0xFF546E7A),
  ];
}
