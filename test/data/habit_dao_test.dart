import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/daos/habit_dao.dart';

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
}
