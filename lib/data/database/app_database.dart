import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:streaks/data/database/tables/habit_entries_table.dart';
import 'package:streaks/data/database/tables/habits_table.dart';

part 'app_database.g.dart';

/// The app's local SQLite database. A single instance is opened for the
/// lifetime of the app (see `data/database/database_provider.dart`); tests
/// construct their own instance over `NativeDatabase.memory()`.
@DriftDatabase(tables: [Habits, HabitEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'streaks.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
