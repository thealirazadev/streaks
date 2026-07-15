import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/database_provider.dart';
import 'package:streaks/features/habits/presentation/habit_list_screen.dart';

void main() {
  testWidgets('shows the empty state with no habits', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: HabitListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('Add habit'), findsOneWidget);
  });

  testWidgets('shows a previously created habit', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.habits)
        .insert(
          HabitsCompanion.insert(
            name: 'Read',
            color: 0xFFE4572E,
            createdAt: DateTime.now().toUtc(),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: HabitListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('No habits yet'), findsNothing);
  });
}
