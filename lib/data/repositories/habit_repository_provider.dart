import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/core/logger.dart';
import 'package:streaks/data/database/daos/habit_dao.dart';
import 'package:streaks/data/database/database_provider.dart';
import 'package:streaks/data/repositories/habit_repository.dart';

/// The single [HabitRepository] instance for the app's lifetime.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return HabitRepository(HabitDao(database), const Logger('HabitRepository'));
});
