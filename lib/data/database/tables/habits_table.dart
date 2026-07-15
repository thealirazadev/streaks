import 'package:drift/drift.dart';

/// A habit the user tracks. See `docs/architecture.md` for the field
/// reference and `docs/design.md` for the habit color palette.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Required, trimmed, 1..80 chars; enforced in the repository and form.
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// ARGB value from the fixed habit color palette.
  IntColumn get color => integer()();

  /// Bitmask of scheduled weekdays: bit 0 = Monday .. bit 6 = Sunday.
  /// `0x7F` means every day.
  IntColumn get scheduleMask =>
      integer().withDefault(const Constant(0x7F))();

  /// Whether a daily reminder is scheduled for this habit.
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Minutes since local midnight for the reminder; null when disabled.
  IntColumn get reminderMinuteOfDay => integer().nullable()();

  /// Hidden from the active list when true; entries are retained.
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Creation timestamp, stored in UTC for auditability.
  DateTimeColumn get createdAt => dateTime()();
}
