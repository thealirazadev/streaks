/// Local-date helpers used throughout the app.
///
/// Completions are keyed by an integer "day key" (`yyyymmdd`) derived from
/// the local calendar date rather than a timestamp, so equality and range
/// queries are simple and unaffected by time-of-day or timezone shifts.
library;

/// Converts [date] to an integer day key: `year * 10000 + month * 100 + day`.
int dayKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

/// Today's date in local time, truncated to the calendar day.
DateTime todayLocal() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Today's day key in local time.
int todayKey() => dayKey(todayLocal());

/// Reconstructs a local [DateTime] (midnight) from a day key produced by
/// [dayKey].
DateTime dateFromDayKey(int key) {
  final year = key ~/ 10000;
  final month = (key ~/ 100) % 100;
  final day = key % 100;
  return DateTime(year, month, day);
}

/// Yields each calendar day from [start] to [end] inclusive, both truncated
/// to midnight local time. Returns an empty iterable if [start] is after
/// [end].
Iterable<DateTime> dateRange(DateTime start, DateTime end) sync* {
  var current = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);
  while (!current.isAfter(last)) {
    yield current;
    current = current.add(const Duration(days: 1));
  }
}
