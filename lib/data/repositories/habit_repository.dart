import 'package:drift/drift.dart';
import 'package:streaks/core/failures.dart';
import 'package:streaks/core/logger.dart';
import 'package:streaks/core/result.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/daos/habit_dao.dart';
import 'package:streaks/features/habits/domain/habit.dart';

/// Facade over the habit DAOs, returning domain models and streams.
///
/// Write operations return a [Result] so callers handle failure explicitly;
/// read streams are exposed directly and surface failures through Riverpod's
/// `AsyncValue.error` at the provider layer.
class HabitRepository {
  HabitRepository(this._habitDao, this._logger);

  final HabitDao _habitDao;
  final Logger _logger;

  /// Streams non-archived habits, oldest first.
  Stream<List<Habit>> watchActiveHabits() => _habitDao.watchActiveHabits();

  /// Creates a habit with the given [name], [color], and [schedule].
  Future<Result<int>> createHabit({
    required String name,
    required int color,
    required Schedule schedule,
  }) async {
    try {
      final id = await _habitDao.insertHabit(
        HabitsCompanion.insert(
          name: name.trim(),
          color: color,
          scheduleMask: Value(schedule.mask),
          createdAt: DateTime.now().toUtc(),
        ),
      );
      return Result.ok(id);
    } catch (error, stackTrace) {
      _logger.error('Failed to create habit', error, stackTrace);
      return Result.error(
        DbFailure('Could not save. Please try again.', cause: error),
      );
    }
  }
}
