import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_spacing.dart';

/// Shown on the home screen when there are no habits yet.
class EmptyHabitsView extends StatelessWidget {
  const EmptyHabitsView({required this.onAddHabit, super.key});

  final VoidCallback onAddHabit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text('No habits yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Create your first habit to start a streak.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            FilledButton(
              onPressed: onAddHabit,
              child: const Text('Add habit'),
            ),
          ],
        ),
      ),
    );
  }
}
