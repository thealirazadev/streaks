import 'package:drift/drift.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/tables/habit_entries_table.dart';

part 'habit_entry_dao.g.dart';

/// Queries and mutations for the `HabitEntries` table.
///
/// A day's completion is modeled as the presence or absence of a row for
/// (`habitId`, `date`); there is no "not done" row. Toggling therefore
/// inserts when absent and deletes when present, which keeps the operation
/// naturally idempotent: toggling twice returns to the original state.
@DriftAccessor(tables: [HabitEntries])
class HabitEntryDao extends DatabaseAccessor<AppDatabase>
    with _$HabitEntryDaoMixin {
  HabitEntryDao(super.db);

  /// Streams the set of completed day keys for [habitId].
  Stream<Set<int>> watchCompletedDayKeys(int habitId) {
    final query = select(habitEntries)
      ..where((t) => t.habitId.equals(habitId));
    return query.watch().map(
      (rows) => rows.map((row) => row.date).toSet(),
    );
  }

  /// Toggles completion for ([habitId], [date]): deletes the row if one
  /// exists, otherwise inserts it. Runs in a transaction so a concurrent
  /// toggle cannot race between the existence check and the write.
  Future<void> toggle(int habitId, int date) {
    return transaction(() async {
      final existing =
          await (select(habitEntries)..where(
            (t) => t.habitId.equals(habitId) & t.date.equals(date),
          )).getSingleOrNull();
      if (existing != null) {
        await (delete(
          habitEntries,
        )..where((t) => t.id.equals(existing.id))).go();
      } else {
        await into(habitEntries).insert(
          HabitEntriesCompanion.insert(habitId: habitId, date: date),
        );
      }
    });
  }

  /// Bulk-inserts one row per day key for [habitId]. Used to restore a
  /// habit's history when undoing a delete; the caller guarantees
  /// [dayKeys] contains no duplicates for an existing habit.
  Future<void> insertEntries(int habitId, Set<int> dayKeys) {
    if (dayKeys.isEmpty) {
      return Future.value();
    }
    return batch((batch) {
      batch.insertAll(habitEntries, [
        for (final date in dayKeys)
          HabitEntriesCompanion.insert(habitId: habitId, date: date),
      ]);
    });
  }
}
