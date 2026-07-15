import 'package:streaks/core/constants.dart';

export 'package:streaks/data/database/app_database.dart'
    show Habit, HabitEntry;

/// Value object over a habit's weekday schedule bitmask (bit 0 = Monday ..
/// bit 6 = Sunday). Pure Dart, no Flutter or database dependency, so it is
/// trivially testable and usable from the domain and application layers.
class Schedule {
  const Schedule(this.mask);

  factory Schedule.fromWeekdays(Iterable<int> weekdays) {
    var mask = 0;
    for (final weekday in weekdays) {
      mask |= 1 << (weekday - DateTime.monday);
    }
    return Schedule(mask);
  }

  /// Every weekday scheduled.
  static const Schedule everyDay = Schedule(everyDayScheduleMask);

  /// No weekday scheduled.
  static const Schedule none = Schedule(0);

  final int mask;

  /// True when [weekday] (`DateTime.monday`..`DateTime.sunday`) is
  /// scheduled.
  bool isScheduled(int weekday) =>
      mask & (1 << (weekday - DateTime.monday)) != 0;

  /// The set of scheduled weekdays as `DateTime.monday`..`DateTime.sunday`
  /// values.
  Set<int> get weekdays => {
    for (var i = 0; i < daysPerWeek; i++)
      if (mask & (1 << i) != 0) DateTime.monday + i,
  };

  /// Returns a copy with [weekday] flipped on or off.
  Schedule toggle(int weekday) {
    final bit = 1 << (weekday - DateTime.monday);
    return Schedule(mask ^ bit);
  }

  @override
  bool operator ==(Object other) => other is Schedule && other.mask == mask;

  @override
  int get hashCode => mask.hashCode;
}
