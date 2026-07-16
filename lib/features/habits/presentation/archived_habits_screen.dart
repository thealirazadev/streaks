import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/data/repositories/habit_repository_provider.dart';
import 'package:streaks/features/habits/domain/habit.dart';

/// Streams archived habits for [ArchivedHabitsScreen].
final _archivedHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchArchivedHabits();
});

/// Lists archived habits and lets the user unarchive them.
class ArchivedHabitsScreen extends ConsumerWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(_archivedHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archived habits')),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(child: Text('No archived habits.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space16),
            itemCount: habits.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space8),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(habit.color),
                    radius: 12,
                  ),
                  title: Text(habit.name),
                  trailing: TextButton(
                    onPressed: () => _unarchive(ref, habit),
                    child: const Text('Unarchive'),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load archived habits.')),
      ),
    );
  }

  Future<void> _unarchive(WidgetRef ref, Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.setArchived(habit.id, false);
  }
}
