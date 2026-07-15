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
}
