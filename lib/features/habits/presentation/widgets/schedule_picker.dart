import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/features/habits/domain/habit.dart';

const List<(int weekday, String label)> _weekdayLabels = [
  (DateTime.monday, 'Mon'),
  (DateTime.tuesday, 'Tue'),
  (DateTime.wednesday, 'Wed'),
  (DateTime.thursday, 'Thu'),
  (DateTime.friday, 'Fri'),
  (DateTime.saturday, 'Sat'),
  (DateTime.sunday, 'Sun'),
];

/// Lets the user pick which weekdays a habit is scheduled for.
class SchedulePicker extends StatelessWidget {
  const SchedulePicker({
    required this.schedule,
    required this.onToggle,
    super.key,
  });

  final Schedule schedule;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space8,
      runSpacing: AppSpacing.space8,
      children: [
        for (final (weekday, label) in _weekdayLabels)
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: FilterChip(
              label: Text(label),
              selected: schedule.isScheduled(weekday),
              onSelected: (_) => onToggle(weekday),
            ),
          ),
      ],
    );
  }
}
