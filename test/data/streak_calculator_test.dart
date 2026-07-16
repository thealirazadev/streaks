import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/streaks/domain/streak.dart';
import 'package:streaks/features/streaks/domain/streak_calculator.dart';

// Reference week used throughout (all in 2026, verified against the
// proleptic Gregorian calendar): Mon 13, Tue 14, Wed 15, Thu 16, Fri 17,
// Sat 18, Sun 19 July 2026. "Today" in most cases below is Thursday 16.
const int mon13 = 20260713;
const int tue14 = 20260714;
const int wed15 = 20260715;
const int thu16 = 20260716;
const int fri17 = 20260717;
const int fri10 = 20260710;
const int jul01 = 20260701;
const int jul02 = 20260702;
const int jul03 = 20260703;
const int jul04 = 20260704;
const int jul05 = 20260705;

void main() {
  group('computeStreaks', () {
    test('empty history yields zero for both streaks', () {
      final result = computeStreaks(
        completedDayKeys: {},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      expect(result, StreakResult.zero);
    });

    test('a habit with no scheduled days always yields zero', () {
      final result = computeStreaks(
        completedDayKeys: {thu16, wed15, tue14},
        scheduleMask: Schedule.none.mask,
        todayKey: thu16,
      );
      expect(result, StreakResult.zero);
    });

    test('a single completed day yields current and longest of one', () {
      final result = computeStreaks(
        completedDayKeys: {thu16},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      expect(result, const StreakResult(current: 1, longest: 1));
    });

    test('consecutive completed days accumulate the streak', () {
      final result = computeStreaks(
        completedDayKeys: {tue14, wed15, thu16},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      expect(result, const StreakResult(current: 3, longest: 3));
    });

    test('a gap before the current run does not extend it, but sets '
        'the longest', () {
      final result = computeStreaks(
        completedDayKeys: {fri10, tue14, wed15, thu16},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      expect(result, const StreakResult(current: 3, longest: 3));
    });

    test('non-scheduled weekend days do not break a weekday streak', () {
      final weekdays = Schedule.fromWeekdays([
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      ]);
      final result = computeStreaks(
        completedDayKeys: {fri10, mon13, tue14, wed15, thu16},
        scheduleMask: weekdays.mask,
        todayKey: thu16,
      );
      expect(result, const StreakResult(current: 5, longest: 5));
    });

    test('current and longest streak can diverge', () {
      final result = computeStreaks(
        completedDayKeys: {jul01, jul02, jul03, jul04, jul05, thu16},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      expect(result, const StreakResult(current: 1, longest: 5));
    });

    test('an incomplete scheduled today does not break the prior streak', () {
      final result = computeStreaks(
        completedDayKeys: {tue14, wed15},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      expect(result, const StreakResult(current: 2, longest: 2));
    });

    test('a scheduled but incomplete day before today breaks the streak', () {
      final result = computeStreaks(
        completedDayKeys: {wed15},
        scheduleMask: Schedule.everyDay.mask,
        todayKey: thu16,
      );
      // thu16 (today) is skipped-not-broken since it is incomplete; wed15
      // is completed and counts; tue14 is scheduled, incomplete, and is
      // not "today", so the backward walk halts there.
      expect(result.current, 1);
    });

    test('date rollover: streak survives one unmarked day then breaks', () {
      // Only wed15 was ever completed.
      final completed = {wed15};
      final schedule = Schedule.everyDay.mask;

      final sameDay = computeStreaks(
        completedDayKeys: completed,
        scheduleMask: schedule,
        todayKey: wed15,
      );
      expect(sameDay.current, 1);

      final nextDayGrace = computeStreaks(
        completedDayKeys: completed,
        scheduleMask: schedule,
        todayKey: thu16,
      );
      expect(nextDayGrace.current, 1, reason: 'unmarked today has grace');

      final twoDaysLater = computeStreaks(
        completedDayKeys: completed,
        scheduleMask: schedule,
        todayKey: fri17,
      );
      expect(
        twoDaysLater.current,
        0,
        reason: 'the grace day has itself passed unmarked',
      );
    });
  });
}
