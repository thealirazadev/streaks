import 'package:drift/drift.dart';
import 'package:streaks/data/database/tables/habits_table.dart';

/// A single day's completion record for a habit. Absence of a row for a
/// given (`habitId`, `date`) means not done; toggling is implemented as
/// insert-or-delete rather than flipping [done]. The [done] column is
/// retained so a future explicit not-done marker does not require a
/// migration.
class HabitEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();

  /// Day key (`yyyymmdd`) computed from the local calendar date. See
  /// `core/date_utils.dart`.
  IntColumn get date => integer()();

  BoolColumn get done => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, date},
  ];
}
