import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/daos/habit_dao.dart';
import 'package:streaks/data/database/daos/habit_entry_dao.dart';

void main() {
  late AppDatabase database;
  late HabitDao habitDao;
  late HabitEntryDao entryDao;
  late int habitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    habitDao = HabitDao(database);
    entryDao = HabitEntryDao(database);
    habitId = await habitDao.insertHabit(
      HabitsCompanion.insert(
        name: 'Read',
        color: 0xFFE4572E,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('toggle inserts a row when none exists', () async {
    await entryDao.toggle(habitId, 20260716);

    final completed = await entryDao.watchCompletedDayKeys(habitId).first;

    expect(completed, {20260716});
  });

  test('toggling twice removes the row (idempotent)', () async {
    await entryDao.toggle(habitId, 20260716);
    await entryDao.toggle(habitId, 20260716);

    final completed = await entryDao.watchCompletedDayKeys(habitId).first;

    expect(completed, isEmpty);
  });

  test('toggling does not create duplicate rows for the same day', () async {
    await entryDao.toggle(habitId, 20260716);
    await entryDao.toggle(habitId, 20260716);
    await entryDao.toggle(habitId, 20260716);

    final rows = await database.select(database.habitEntries).get();

    expect(rows, hasLength(1));
    expect(rows.single.date, 20260716);
  });

  test('entries for different days are independent', () async {
    await entryDao.toggle(habitId, 20260715);
    await entryDao.toggle(habitId, 20260716);

    final completed = await entryDao.watchCompletedDayKeys(habitId).first;

    expect(completed, {20260715, 20260716});
  });
}
