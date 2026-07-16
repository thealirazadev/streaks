import 'package:drift/drift.dart';
import 'package:streaks/core/date_utils.dart' as date_utils;
import 'package:streaks/core/failures.dart';
import 'package:streaks/core/logger.dart';
import 'package:streaks/core/result.dart';
import 'package:streaks/data/database/app_database.dart';
import 'package:streaks/data/database/daos/habit_dao.dart';
import 'package:streaks/data/database/daos/habit_entry_dao.dart';
import 'package:streaks/features/habits/domain/habit.dart';

/// Facade over the habit DAOs, returning domain models and streams.
///
/// Write operations return a [Result] so callers handle failure explicitly;
/// read streams are exposed directly and surface failures through Riverpod's
/// `AsyncValue.error` at the provider layer.
class HabitRepository {
  HabitRepository(this._habitDao, this._habitEntryDao, this._logger);

  final HabitDao _habitDao;
  final HabitEntryDao _habitEntryDao;
  final Logger _logger;

  /// Streams non-archived habits, oldest first.
  Stream<List<Habit>> watchActiveHabits() => _habitDao.watchActiveHabits();

  /// Streams archived habits, oldest first.
  Stream<List<Habit>> watchArchivedHabits() => _habitDao.watchArchivedHabits();

  /// Streams the set of completed day keys for [habitId].
  Stream<Set<int>> watchCompletedDayKeys(int habitId) =>
      _habitEntryDao.watchCompletedDayKeys(habitId);

  /// Toggles completion for [habitId] on today's local date.
  Future<Result<void>> toggleToday(int habitId) =>
      toggleDay(habitId, date_utils.todayKey());

  /// Toggles completion for [habitId] on the given day [key].
  Future<Result<void>> toggleDay(int habitId, int key) async {
    try {
      await _habitEntryDao.toggle(habitId, key);
      return const Result.ok(null);
    } catch (error, stackTrace) {
      _logger.error('Failed to toggle habit entry', error, stackTrace);
      return Result.error(
        DbFailure('Could not save. Please try again.', cause: error),
      );
    }
  }

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

  /// Updates an existing habit's name, color, and schedule.
  Future<Result<void>> updateHabit({
    required int id,
    required String name,
    required int color,
    required Schedule schedule,
  }) async {
    try {
      await _habitDao.updateHabit(
        id: id,
        name: name.trim(),
        color: color,
        scheduleMask: schedule.mask,
      );
      return const Result.ok(null);
    } catch (error, stackTrace) {
      _logger.error('Failed to update habit', error, stackTrace);
      return Result.error(
        DbFailure('Could not save. Please try again.', cause: error),
      );
    }
  }

  /// Archives or unarchives the habit with [id]. Archiving hides it from
  /// the active list; its entries are never touched.
  Future<Result<void>> setArchived(int id, bool archived) async {
    try {
      await _habitDao.setArchived(id, archived);
      return const Result.ok(null);
    } catch (error, stackTrace) {
      _logger.error('Failed to set archived flag', error, stackTrace);
      return Result.error(
        DbFailure('Could not save. Please try again.', cause: error),
      );
    }
  }
}
