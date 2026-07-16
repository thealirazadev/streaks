import 'package:drift/drift.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/tables/habits_table.dart';

part 'habit_dao.g.dart';

/// Queries and mutations for the `Habits` table.
@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  /// Streams non-archived habits, oldest first.
  Stream<List<Habit>> watchActiveHabits() {
    return (select(
      habits,
    )..where((t) => t.archived.equals(false))..orderBy([
      (t) => OrderingTerm.asc(t.createdAt),
    ])).watch();
  }

  Future<int> insertHabit(HabitsCompanion entry) => into(habits).insert(entry);

  /// Updates the name, color, and schedule of the habit with [id].
  Future<void> updateHabit({
    required int id,
    required String name,
    required int color,
    required int scheduleMask,
  }) {
    return (update(habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(
        name: Value(name),
        color: Value(color),
        scheduleMask: Value(scheduleMask),
      ),
    );
  }

  /// Streams archived habits, oldest first.
  Stream<List<Habit>> watchArchivedHabits() {
    return (select(
      habits,
    )..where((t) => t.archived.equals(true))..orderBy([
      (t) => OrderingTerm.asc(t.createdAt),
    ])).watch();
  }

  /// Sets the archived flag for the habit with [id]. Entries are untouched;
  /// archiving only hides a habit from the active list.
  Future<void> setArchived(int id, bool archived) {
    return (update(habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(archived: Value(archived)),
    );
  }

  /// Permanently deletes the habit with [id]. Its entries cascade-delete
  /// via the foreign key defined on `HabitEntries`.
  Future<void> deleteHabit(int id) {
    return (delete(habits)..where((t) => t.id.equals(id))).go();
  }
}
