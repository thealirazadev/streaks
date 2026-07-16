import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/core/date_utils.dart' as date_utils;
import 'package:streaks/data/repositories/habit_repository_provider.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/streaks/application/streak_provider.dart';

/// A single row in the habit list: a color bar, the habit name, and a
/// toggle for today's completion. The streak badge is added next.
class HabitListTile extends ConsumerWidget {
  const HabitListTile({required this.habit, this.onTap, super.key});

  final Habit habit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedDayKeysProvider(habit.id));
    final isDoneToday = completedAsync.maybeWhen(
      data: (completed) => completed.contains(date_utils.todayKey()),
      orElse: () => false,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Color(habit.color)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space12,
                    ),
                    child: Text(
                      habit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                  ),
                  child: _CompletionToggle(
                    habit: habit,
                    isDone: isDoneToday,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionToggle extends ConsumerWidget {
  const _CompletionToggle({required this.habit, required this.isDone});

  final Habit habit;
  final bool isDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Semantics(
      label: isDone
          ? 'Mark ${habit.name} not done'
          : 'Mark ${habit.name} done',
      button: true,
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: () => _toggle(ref),
          icon: Icon(
            isDone ? Icons.check_circle : Icons.circle_outlined,
            color: isDone ? Color(habit.color) : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.toggleToday(habit.id);
  }
}
