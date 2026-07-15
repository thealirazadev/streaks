import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_colors.dart';
import 'package:streaks/app/theme/app_spacing.dart';

/// Lets the user pick one swatch from the fixed habit color palette.
class ColorPicker extends StatelessWidget {
  const ColorPicker({required this.value, required this.onChanged, super.key});

  /// Selected color as an ARGB int (matches the stored `Habit.color`).
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space12,
      runSpacing: AppSpacing.space12,
      children: [
        for (final swatch in AppColors.habitPalette)
          _Swatch(
            color: swatch,
            selected: swatch.toARGB32() == value,
            onTap: () => onChanged(swatch.toARGB32()),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Habit color',
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: selected
                  ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                  : null,
            ),
            child: selected
                ? Icon(Icons.check, color: _onColorFor(color))
                : null,
          ),
        ),
      ),
    );
  }

  /// Picks a legible icon color (black or white) for the given swatch.
  Color _onColorFor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
