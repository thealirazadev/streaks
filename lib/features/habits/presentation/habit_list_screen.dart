import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/features/habits/application/habit_list_provider.dart';
import 'package:streaks/features/habits/presentation/habit_form_screen.dart';
import 'package:streaks/features/habits/presentation/habit_list_tile.dart';
import 'package:streaks/features/habits/presentation/widgets/empty_habits_view.dart';

/// Home screen: the list of active (non-archived) habits.
class HabitListScreen extends ConsumerWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('streaks')),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyHabitsView(onAddHabit: () => _openForm(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space16),
            itemCount: habits.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space8),
            itemBuilder: (context, index) => HabitListTile(habit: habits[index]),
          );
        },
        loading: () => const _HabitListLoading(),
        error: (error, stackTrace) => _HabitListError(
          onRetry: () => ref.invalidate(habitListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        tooltip: 'Add habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HabitFormScreen()));
  }
}

/// Neutral placeholder tiles shown briefly while the initial habit list
/// loads. Local reads are fast, so this is intentionally simple rather than
/// a full shimmer animation.
class _HabitListLoading extends StatelessWidget {
  const _HabitListLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space8),
      itemBuilder: (_, _) => Container(
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _HabitListError extends StatelessWidget {
  const _HabitListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.space16),
            const Text('Something went wrong'),
            const SizedBox(height: AppSpacing.space8),
            const Text('Please try again.'),
            const SizedBox(height: AppSpacing.space16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
