import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/core/date_utils.dart' as date_utils;
import 'package:streaks/data/repositories/habit_repository_provider.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/streaks/domain/streak.dart';
import 'package:streaks/features/streaks/domain/streak_calculator.dart';

/// Streams the completed day keys for a single habit, keyed by habit id.
final completedDayKeysProvider = StreamProvider.family<Set<int>, int>((
  ref,
  habitId,
) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchCompletedDayKeys(habitId);
});

/// Derives the current and longest streak for [habit] from its completed
/// day keys. `today` is read once per rebuild via `core/date_utils.dart`
/// and passed into the pure `computeStreaks` function; the calculator
/// itself never reads the clock.
final streakProvider = Provider.family<AsyncValue<StreakResult>, Habit>((
  ref,
  habit,
) {
  final completedAsync = ref.watch(completedDayKeysProvider(habit.id));
  return completedAsync.whenData(
    (completed) => computeStreaks(
      completedDayKeys: completed,
      scheduleMask: habit.scheduleMask,
      todayKey: date_utils.todayKey(),
    ),
  );
});
