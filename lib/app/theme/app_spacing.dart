/// Spacing and corner-radius tokens on a 4 dp base unit. See
/// `docs/design.md` for usage guidance per component.
abstract final class AppSpacing {
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
}

/// Material 3 shape scale used across cards, chips, and sheets.
abstract final class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;

  /// Heatmap day cells use a tighter radius than `medium`.
  static const double heatmapCell = 3;
}
