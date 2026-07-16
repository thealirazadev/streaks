import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/core/date_utils.dart' as date_utils;
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/database_provider.dart';
import 'package:streaks/features/habits/presentation/habit_detail_screen.dart';
import 'package:streaks/features/streaks/presentation/heatmap_calendar.dart';

void main() {
  late AppDatabase database;

  Future<Habit> insertHabit(AppDatabase db) async {
    final id = await db
        .into(db.habits)
        .insert(
          HabitsCompanion.insert(
            name: 'Read',
            color: 0xFFE4572E,
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return (db.select(db.habits)..where((t) => t.id.equals(id))).getSingle();
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('shows the empty history message and an empty heatmap', (
    tester,
  ) async {
    final habit = await insertHabit(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(home: HabitDetailScreen(habit: habit)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No completions yet. Mark today done to begin.'),
      findsOneWidget,
    );
    expect(find.byType(HeatmapCalendar), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2)); // current and best streak
  });

  testWidgets('tapping today\'s heatmap cell toggles completion', (
    tester,
  ) async {
    final habit = await insertHabit(database);
    final todayKey = date_utils.todayKey();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(home: HabitDetailScreen(habit: habit)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('heatmap-cell-$todayKey')));
    await tester.pumpAndSettle();

    expect(
      find.text('No completions yet. Mark today done to begin.'),
      findsNothing,
    );
    expect(find.text('1'), findsOneWidget); // current streak is now 1

    // Tapping again removes the entry (idempotent toggle).
    await tester.tap(find.byKey(ValueKey('heatmap-cell-$todayKey')));
    await tester.pumpAndSettle();

    expect(
      find.text('No completions yet. Mark today done to begin.'),
      findsOneWidget,
    );
  });
}
