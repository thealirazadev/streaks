import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/data/database/app_database.dart';

/// The single [AppDatabase] instance for the app's lifetime. Kept alive so
/// the connection survives even when no widget is currently watching it.
///
/// Hand-written (not `@riverpod` code-generated): plain Riverpod providers
/// need no generated code, so the provider layer stays readable without
/// `riverpod_generator` output.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
