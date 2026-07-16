import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/streaks/application/streak_provider.dart';

/// Detail screen for a single habit: name, color, streaks, reminder
/// settings placeholder, and (from a later commit) a calendar heatmap of
/// completion history.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({required this.habit, super.key});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedDayKeysProvider(habit.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(habit.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(habit.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: Text(habit.name, style: theme.textTheme.headlineSmall),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            Text('Reminders', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Reminders are not available yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text('History', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space12),
            completedAsync.when(
              data: (completed) => completed.isEmpty
                  ? const Text('No completions yet. Mark today done to begin.')
                  : Text('${completed.length} day(s) completed so far.'),
              loading: () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const Text('Could not load history.'),
            ),
          ],
        ),
      ),
    );
  }
}
