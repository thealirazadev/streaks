import 'package:streaks/core/date_utils.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/streaks/domain/streak.dart';

/// Computes a habit's current and longest streak from its completed day
/// keys and weekly schedule.
///
/// Pure function: no I/O, no `DateTime.now()`. [todayKey] is injected by
/// the caller (see `core/date_utils.dart#todayKey`), which makes date
/// rollover and timezone behavior fully unit-testable.
///
/// Rules (see `docs/architecture.md`):
/// - Only scheduled weekdays count; a non-scheduled day neither breaks nor
///   extends a streak.
/// - The current streak walks backward from today. An incomplete *today*
///   that is scheduled does not break the streak (the day may still be
///   completed before it ends); it is simply not counted. An incomplete
///   scheduled day before today stops the walk.
/// - The longest streak is the longest run of consecutive scheduled,
///   completed days anywhere from the first completion through today.
/// - A habit with no scheduled days at all (an empty schedule) always
///   yields a zero streak.
StreakResult computeStreaks({
  required Set<int> completedDayKeys,
  required int scheduleMask,
  required int todayKey,
}) {
  final schedule = Schedule(scheduleMask);
  if (scheduleMask == 0) {
    return StreakResult.zero;
  }
  final current = _currentStreak(completedDayKeys, schedule, todayKey);
  final longest = _longestStreak(completedDayKeys, schedule, todayKey);
  return StreakResult(current: current, longest: longest);
}

int _currentStreak(Set<int> completed, Schedule schedule, int todayKey) {
  var cursor = dateFromDayKey(todayKey);
  var streak = 0;
  while (true) {
    final key = dayKey(cursor);
    if (schedule.isScheduled(cursor.weekday)) {
      if (completed.contains(key)) {
        streak++;
      } else if (key != todayKey) {
        break;
      }
      // key == todayKey and incomplete: not counted, but does not break.
    }
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int _longestStreak(Set<int> completed, Schedule schedule, int todayKey) {
  if (completed.isEmpty) {
    return 0;
  }
  final startKey = completed.reduce((a, b) => a < b ? a : b);
  var cursor = dateFromDayKey(startKey);
  final end = dateFromDayKey(todayKey);
  var running = 0;
  var longest = 0;
  while (!cursor.isAfter(end)) {
    final key = dayKey(cursor);
    if (schedule.isScheduled(cursor.weekday)) {
      if (completed.contains(key)) {
        running++;
        if (running > longest) {
          longest = running;
        }
      } else {
        running = 0;
      }
    }
    cursor = cursor.add(const Duration(days: 1));
  }
  return longest;
}
