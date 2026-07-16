import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/features/streaks/domain/streak.dart';

/// Compact current/longest streak display used on the habit list tile and
/// habit detail screen.
class StreakBadge extends StatelessWidget {
  const StreakBadge({required this.streak, super.key});

  final StreakResult streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label:
          'Current streak ${streak.current} days. '
          'Best streak ${streak.longest} days.',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: streak.current > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: AppSpacing.space4),
          Text('${streak.current}', style: theme.textTheme.labelLarge),
          const SizedBox(width: AppSpacing.space8),
          Text(
            'best ${streak.longest}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
