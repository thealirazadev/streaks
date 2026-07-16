import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/core/date_utils.dart' as date_utils;
import 'package:streaks/data/repositories/habit_repository_provider.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/habits/presentation/habit_form_screen.dart';
import 'package:streaks/features/streaks/application/streak_provider.dart';
import 'package:streaks/features/streaks/domain/streak.dart';
import 'package:streaks/features/streaks/presentation/heatmap_calendar.dart';

/// Detail screen for a single habit: name, color, streaks, reminder
/// settings placeholder, and a calendar heatmap of completion history.
/// Tapping a past (or today's) heatmap cell toggles that day.
class HabitDetailScreen extends ConsumerStatefulWidget {
  const HabitDetailScreen({required this.habit, super.key});

  final Habit habit;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  void _openEditForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HabitFormScreen(habit: widget.habit),
      ),
    );
  }

  Future<void> _toggleDay(int dayKey) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.toggleDay(widget.habit.id, dayKey);
    if (!mounted) return;
    result.when(
      ok: (_) {},
      error: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final completedAsync = ref.watch(completedDayKeysProvider(habit.id));
    final streakAsync = ref.watch(streakProvider(habit));
    final streak = streakAsync.maybeWhen(
      data: (value) => value,
      orElse: () => StreakResult.zero,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit habit',
            onPressed: () => _openEditForm(context),
          ),
        ],
      ),
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
            _StreakStats(streak: streak),
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
              data: (completed) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (completed.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.space12),
                      child: Text(
                        'No completions yet. Mark today done to begin.',
                      ),
                    ),
                  HeatmapCalendar(
                    completedDayKeys: completed,
                    scheduleMask: habit.scheduleMask,
                    habitColor: Color(habit.color),
                    todayKey: date_utils.todayKey(),
                    onDayTap: _toggleDay,
                  ),
                ],
              ),
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

/// Current and longest streak, shown large per `docs/design.md`
/// (`displaySmall` for the headline number on habit detail).
class _StreakStats extends StatelessWidget {
  const _StreakStats({required this.streak});

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
        children: [
          Expanded(
            child: _StatColumn(
              value: streak.current,
              label: 'Current streak',
              theme: theme,
            ),
          ),
          Expanded(
            child: _StatColumn(
              value: streak.longest,
              label: 'Best streak',
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.theme,
  });

  final int value;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: theme.textTheme.displaySmall),
        const SizedBox(height: AppSpacing.space4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
