import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/data/repositories/habit_repository_provider.dart';
import 'package:streaks/features/habits/domain/habit.dart';

/// Streams the active (non-archived) habits shown on the home screen.
final habitListProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchActiveHabits();
});
