/// Maps each `schemaVersion` to the change it introduced. Update this
/// alongside `AppDatabase.schemaVersion` and its `MigrationStrategy`; never
/// edit a note (or the migration step it documents) once shipped.
const Map<int, String> schemaVersionNotes = {
  1: 'Initial schema: Habits and HabitEntries tables.',
};
