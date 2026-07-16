import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/core/date_utils.dart' as date_utils;
import 'package:streaks/features/habits/domain/habit.dart';

/// Calendar heatmap of a habit's completion history, one cell per day,
/// grouped by month with the most recent month first.
///
/// Fill follows `docs/design.md`: a not-scheduled or no-data day uses a
/// low-opacity outline, a scheduled-but-not-done day uses a neutral
/// surface, and a done day uses the habit color. Today's cell always gets
/// a ring. Tapping a cell invokes [onDayTap] when set (a later phase wires
/// this to toggle completion); future days are rendered as blank space and
/// are never tappable.
///
/// Only [monthsBack] month sections are built (not one item per day), so
/// scrolling a year of history stays cheap.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({
    required this.completedDayKeys,
    required this.scheduleMask,
    required this.habitColor,
    required this.todayKey,
    this.monthsBack = 12,
    this.onDayTap,
    super.key,
  });

  final Set<int> completedDayKeys;
  final int scheduleMask;
  final Color habitColor;
  final int todayKey;
  final int monthsBack;
  final ValueChanged<int>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final today = date_utils.dateFromDayKey(todayKey);
    final schedule = Schedule(scheduleMask);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: monthsBack,
      itemBuilder: (context, index) {
        final monthDate = DateTime(today.year, today.month - index);
        return _MonthGrid(
          monthDate: monthDate,
          todayKey: todayKey,
          completedDayKeys: completedDayKeys,
          schedule: schedule,
          habitColor: habitColor,
          onDayTap: onDayTap,
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.monthDate,
    required this.todayKey,
    required this.completedDayKeys,
    required this.schedule,
    required this.habitColor,
    required this.onDayTap,
  });

  final DateTime monthDate;
  final int todayKey;
  final Set<int> completedDayKeys;
  final Schedule schedule;
  final Color habitColor;
  final ValueChanged<int>? onDayTap;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(monthDate.year, monthDate.month);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    // Leading blanks so day 1 lands under its correct weekday column
    // (Monday-first week, matching the schedule bitmask convention).
    final leadingBlanks = firstOfMonth.weekday - DateTime.monday;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_monthNames[firstOfMonth.month - 1]} ${firstOfMonth.year}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.space8),
          Wrap(
            spacing: AppSpacing.space4,
            runSpacing: AppSpacing.space4,
            children: [
              for (var i = 0; i < leadingBlanks; i++)
                const SizedBox(width: 16, height: 16),
              for (var day = 1; day <= daysInMonth; day++)
                _dayCell(
                  context,
                  DateTime(monthDate.year, monthDate.month, day),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(BuildContext context, DateTime date) {
    final key = date_utils.dayKey(date);
    if (key > todayKey) {
      // Future day: reserve the grid cell but render nothing.
      return const SizedBox(width: 16, height: 16);
    }

    final theme = Theme.of(context);
    final isToday = key == todayKey;
    final isScheduled = schedule.isScheduled(date.weekday);
    final isDone = completedDayKeys.contains(key);

    final Color fill;
    if (isDone) {
      fill = habitColor;
    } else if (isScheduled) {
      fill = theme.colorScheme.surfaceContainerHighest;
    } else {
      fill = theme.colorScheme.outlineVariant.withValues(alpha: 0.4);
    }

    final status = isDone ? 'done' : (isScheduled ? 'not done' : 'not scheduled');
    final label =
        '${_monthNames[date.month - 1]} ${date.day}, ${date.year}: $status';

    return Semantics(
      label: label,
      button: onDayTap != null,
      child: GestureDetector(
        key: ValueKey('heatmap-cell-$key'),
        onTap: onDayTap == null ? null : () => onDayTap!(key),
        child: SizedBox(
          width: 16,
          height: 16,
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(3),
              border: isToday
                  ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
