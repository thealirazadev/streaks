import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/features/habits/domain/habit.dart';

/// A single row in the habit list: a color bar and the habit name.
/// The completion toggle and streak badge are added in a later phase.
class HabitListTile extends StatelessWidget {
  const HabitListTile({required this.habit, this.onTap, super.key});

  final Habit habit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: Color(habit.color)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space12,
                    ),
                    child: Text(
                      habit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
