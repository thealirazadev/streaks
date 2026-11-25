import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/core/date_utils.dart';

/// Asserts [days] are local midnights with unique day keys, each exactly one
/// calendar day after the previous one.
void expectContiguousCalendarDays(List<DateTime> days) {
  final keys = days.map(dayKey).toList();
  expect(keys.toSet().length, keys.length, reason: 'a day repeated');
  for (final day in days) {
    expect(
      [day.hour, day.minute, day.second],
      [0, 0, 0],
      reason: '$day is not local midnight',
    );
  }
  for (var i = 1; i < days.length; i++) {
    final previous = days[i - 1];
    final expected = DateTime(previous.year, previous.month, previous.day + 1);
    expect(
      dayKey(days[i]),
      dayKey(expected),
      reason: 'a day was skipped after ${dayKey(previous)}',
    );
  }
}

void main() {
  group('dayKey and dateFromDayKey', () {
    test('round-trip a day key', () {
      expect(dayKey(DateTime(2026, 3, 8)), 20260308);
      expect(dateFromDayKey(20260308), DateTime(2026, 3, 8));
      expect(dayKey(dateFromDayKey(20241231)), 20241231);
    });
  });

  group('nextDay and previousDay', () {
    test('step across month, year, and leap-day boundaries', () {
      expect(nextDay(DateTime(2026, 1, 31)), DateTime(2026, 2, 1));
      expect(nextDay(DateTime(2026, 12, 31)), DateTime(2027, 1, 1));
      expect(nextDay(DateTime(2028, 2, 28)), DateTime(2028, 2, 29));
      expect(previousDay(DateTime(2026, 3, 1)), DateTime(2026, 2, 28));
      expect(previousDay(DateTime(2028, 3, 1)), DateTime(2028, 2, 29));
      expect(previousDay(DateTime(2027, 1, 1)), DateTime(2026, 12, 31));
    });

    test('step across the 2026 daylight-saving changes one day at a time', () {
      // 8 March and 1 November 2026 are DST changes in America/New_York
      // and similar zones; CI runs this file with TZ set to such a zone.
      expect(dayKey(previousDay(DateTime(2026, 3, 9))), 20260308);
      expect(dayKey(nextDay(DateTime(2026, 3, 8))), 20260309);
      expect(dayKey(nextDay(DateTime(2026, 11, 1))), 20261102);
      expect(dayKey(previousDay(DateTime(2026, 11, 2))), 20261101);
      // European zones change on 29 March and 25 October 2026.
      expect(dayKey(previousDay(DateTime(2026, 3, 30))), 20260329);
      expect(dayKey(nextDay(DateTime(2026, 10, 25))), 20261026);
    });

    test('walking back a whole year yields every day once, in order', () {
      final days = <DateTime>[];
      var cursor = DateTime(2026, 12, 31);
      while (cursor.year == 2026) {
        days.add(cursor);
        cursor = previousDay(cursor);
      }
      expect(days.length, 365);
      expectContiguousCalendarDays(days.reversed.toList());
    });
  });

  group('dateRange', () {
    test('yields every calendar day of a year exactly once', () {
      final days = dateRange(DateTime(2026), DateTime(2026, 12, 31)).toList();
      expect(days.length, 365);
      expect(days.first, DateTime(2026));
      expect(days.last, DateTime(2026, 12, 31));
      expectContiguousCalendarDays(days);
    });

    test('truncates times of day and includes both ends', () {
      final days = dateRange(
        DateTime(2026, 10, 31, 18, 30),
        DateTime(2026, 11, 2, 6),
      ).map(dayKey).toList();
      expect(days, [20261031, 20261101, 20261102]);
    });

    test('is empty when start is after end', () {
      expect(dateRange(DateTime(2026, 3, 9), DateTime(2026, 3, 8)), isEmpty);
    });
  });
}
