import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/daos/habit_dao.dart';
import 'package:streaks/data/database/daos/habit_entry_dao.dart';

void main() {
  late AppDatabase database;
  late HabitDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = HabitDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('watchActiveHabits emits an inserted habit', () async {
    await dao.insertHabit(
      HabitsCompanion.insert(
        name: 'Read',
        color: 0xFFE4572E,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    final habits = await dao.watchActiveHabits().first;

    expect(habits, hasLength(1));
    expect(habits.single.name, 'Read');
    expect(habits.single.archived, isFalse);
  });

  test('watchActiveHabits excludes archived habits', () async {
    final id = await dao.insertHabit(
      HabitsCompanion.insert(
        name: 'Meditate',
        color: 0xFF3B7A57,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await (database.update(
      database.habits,
    )..where((t) => t.id.equals(id))).write(
      const HabitsCompanion(archived: Value(true)),
    );

    final habits = await dao.watchActiveHabits().first;

    expect(habits, isEmpty);
  });

  test('watchActiveHabits is empty for a fresh database', () async {
    final habits = await dao.watchActiveHabits().first;

    expect(habits, isEmpty);
  });

  test('setArchived(true) moves a habit from active to archived', () async {
    final id = await dao.insertHabit(
      HabitsCompanion.insert(
        name: 'Stretch',
        color: 0xFF2E86AB,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    await dao.setArchived(id, true);

    expect(await dao.watchActiveHabits().first, isEmpty);
    final archived = await dao.watchArchivedHabits().first;
    expect(archived, hasLength(1));
    expect(archived.single.id, id);
  });

  test('setArchived(false) restores an archived habit to the active list', () async {
    final id = await dao.insertHabit(
      HabitsCompanion.insert(
        name: 'Stretch',
        color: 0xFF2E86AB,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await dao.setArchived(id, true);

    await dao.setArchived(id, false);

    expect(await dao.watchArchivedHabits().first, isEmpty);
    final active = await dao.watchActiveHabits().first;
    expect(active, hasLength(1));
    expect(active.single.id, id);
  });

  test('updateHabit changes name, color, and schedule', () async {
    final id = await dao.insertHabit(
      HabitsCompanion.insert(
        name: 'Stretch',
        color: 0xFF2E86AB,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    await dao.updateHabit(
      id: id,
      name: 'Stretch daily',
      color: 0xFF8E44AD,
      scheduleMask: 0x01,
    );

    final habit = (await dao.watchActiveHabits().first).single;
    expect(habit.name, 'Stretch daily');
    expect(habit.color, 0xFF8E44AD);
    expect(habit.scheduleMask, 0x01);
  });

  test('deleteHabit cascade-deletes its entries', () async {
    final id = await dao.insertHabit(
      HabitsCompanion.insert(
        name: 'Stretch',
        color: 0xFF2E86AB,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    final entryDao = HabitEntryDao(database);
    await entryDao.toggle(id, 20260716);

    await dao.deleteHabit(id);

    expect(await dao.watchActiveHabits().first, isEmpty);
    final remainingEntries = await database.select(database.habitEntries).get();
    expect(remainingEntries, isEmpty);
  });
}
