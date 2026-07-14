# Architecture: streaks

## App flow

1. **Launch.** `main.dart` initializes the local timezone database, opens the Drift database, initializes the notification plugin, and mounts the root `ProviderScope` and `StreaksApp` widget.
2. **Home (habit list).** The app opens on the habit list. Active (non-archived) habits are read from the database via a Riverpod provider that watches a Drift stream. Each row shows the habit name, color, today's completion toggle, and the current streak.
3. **Toggle today.** Tapping the toggle inserts or deletes a `HabitEntry` for that habit and today's local date. The stream emits, providers recompute streaks, and the UI updates.
4. **Create or edit a habit.** A form screen collects name, color, weekly schedule, and optional reminder. Saving writes to the database; if a reminder is enabled the notification is scheduled, otherwise any existing one is cancelled.
5. **Habit detail.** Selecting a habit opens a detail screen with current and longest streaks and a calendar heatmap. Tapping any day in the heatmap toggles that day's completion.
6. **Reminders.** On save and on app launch, enabled reminders are (re)scheduled. Notification permission is requested lazily when the user first enables a reminder.
7. **Date rollover.** When the app resumes or the date changes, the "today" reference is recomputed so toggles and streaks reference the correct local calendar date.

## Folder and file tree (proposed)

```
lib/
  main.dart                          App entry: init timezone, DB, notifications, runApp
  app/
    streaks_app.dart                 Root MaterialApp, theme, home
    theme/
      app_theme.dart                 Light/dark ThemeData from seed color
      app_colors.dart                Seed color and habit color palette
      app_spacing.dart               Spacing and radius constants
  core/
    result.dart                      Result/failure type for data operations
    failures.dart                    App failure definitions (DbFailure, NotificationFailure)
    logger.dart                      Thin logging wrapper used app-wide
    date_utils.dart                  Local-date helpers (dayKey, todayLocal, dateRange)
    constants.dart                   App-wide constants (max name length, etc.)
  data/
    database/
      app_database.dart              Drift @DriftDatabase, schemaVersion, migrations
      app_database.g.dart            Generated (build_runner, not hand-edited)
      tables/
        habits_table.dart           Habits Drift table definition
        habit_entries_table.dart    HabitEntries Drift table definition
      daos/
        habit_dao.dart              Queries/mutations for habits
        habit_entry_dao.dart        Queries/mutations for entries
      migrations/
        schema_versions.dart        Notes mapping schemaVersion -> changes
    repositories/
      habit_repository.dart         Facade over DAOs returning domain models/streams
  features/
    habits/
      domain/
        habit.dart                  Habit domain model + Schedule value object
      application/
        habit_list_provider.dart    Watches active habits
        habit_form_controller.dart  Create/edit form state + validation
      presentation/
        habit_list_screen.dart      Home screen
        habit_list_tile.dart        One habit row with toggle and streak
        habit_form_screen.dart      Create/edit form
        habit_detail_screen.dart    Detail with streaks + heatmap
        widgets/
          color_picker.dart
          schedule_picker.dart
          empty_habits_view.dart
    streaks/
      domain/
        streak.dart                 StreakResult (current, longest)
        streak_calculator.dart      Pure function computing streaks from entries
      application/
        streak_provider.dart        Derives StreakResult per habit
      presentation/
        streak_badge.dart           Current/longest streak display
        heatmap_calendar.dart       Calendar heatmap widget
    reminders/
      application/
        notification_service.dart   Wraps flutter_local_notifications
        reminder_controller.dart    Enable/disable/reschedule reminders
      presentation/
        reminder_tile.dart          Time picker + enable toggle
test/
  data/
    streak_calculator_test.dart      Unit tests for streak logic
    habit_dao_test.dart              DAO tests on in-memory database
  features/
    habit_list_screen_test.dart      Widget test for the list and empty state
    habit_form_screen_test.dart      Widget test for validation
docs/
  ... planning documentation ...
```

The presentation layer holds widgets and screens, the application layer holds Riverpod providers and controllers, and the domain layer holds plain Dart models and pure logic. Data access is isolated in `data/`.

## Tech stack with rationale

- **Flutter / Dart, Material 3.** Single codebase for Android and iOS with a mature widget set and first-class Material 3 support.
- **Drift (SQLite) for persistence.** Chosen over Hive. See the decision below.
- **Riverpod for state management.** Compile-safe providers, easy testing with overrides, and natural integration with Drift streams (`Stream` -> `StreamProvider`). Streak values are derived state, which Riverpod models cleanly as computed providers.
- **flutter_local_notifications + timezone.** The de facto plugin for scheduled local notifications; the timezone package is required for correct daily scheduling across DST.
- **flutter_lints.** Enforces Effective Dart style with the standard lint set.
- **flutter_test + widget tests.** Built-in testing for pure logic (streak calculator), DAOs (in-memory database), and screens (widget tests).

### Decision: Drift over Hive

streaks stores relational data: habits and their many dated entries, queried by ranges and joined for streak computation. Drift gives us:

- A real relational schema with foreign keys and indexed date lookups.
- Typed queries and reactive streams that plug directly into Riverpod.
- First-class, versioned schema migrations, which we need because the schema will evolve (for example, adding reminder fields or archiving).

Hive is a fast key-value store but would push relational modeling, range queries, and migration handling into hand-written code. Given the query and migration needs, Drift is the better fit. This decision is recorded in `docs/memory.md`.

## Data model

### Habit

| Field | Type | Notes |
| --- | --- | --- |
| `id` | int (PK, autoincrement) | Primary key |
| `name` | text | Required, trimmed, 1..80 chars |
| `color` | int | ARGB value from the app palette |
| `schedule_mask` | int | Bitmask of weekdays (bit 0 = Monday .. bit 6 = Sunday); `0x7F` = every day |
| `reminder_enabled` | bool | Whether a daily reminder is scheduled |
| `reminder_minute_of_day` | int nullable | Minutes since local midnight for the reminder; null when disabled |
| `archived` | bool | Hidden from the active list when true; entries retained |
| `created_at` | datetime | Creation timestamp (UTC stored) |

### HabitEntry

| Field | Type | Notes |
| --- | --- | --- |
| `id` | int (PK, autoincrement) | Primary key |
| `habit_id` | int (FK -> Habit.id, cascade delete) | Owning habit |
| `date` | int | Day key: `year * 10000 + month * 100 + day` in local time |
| `done` | bool | True when completed for that day |

Constraints:

- Unique index on (`habit_id`, `date`) so a day is recorded at most once per habit.
- Index on `habit_id` and on `date` for range queries.
- Toggling "done" is implemented as insert-or-delete of the row for that (`habit_id`, `date`); an absent row means not done. The `done` column exists to allow an explicit not-done marker in future without a migration, but Phase 1 treats absence as not-done.

### Day key and dates

Dates are stored as an integer day key (`yyyymmdd`) computed from the local calendar date. This avoids timezone ambiguity from storing timestamps and makes range and equality queries trivial. `core/date_utils.dart` provides `dayKey(DateTime)`, `todayLocal()`, and helpers to iterate a date range. The habit `created_at` is stored as a UTC timestamp for auditability; day keys are always local.

## Streak computation

Implemented as a pure function in `features/streaks/domain/streak_calculator.dart`:

```
StreakResult computeStreaks({
  required Set<int> completedDayKeys,   // day keys with done == true
  required int scheduleMask,            // weekdays the habit is expected
  required int todayKey,                // today's local day key
});
```

Rules:

- Only scheduled weekdays count. A non-scheduled day is skipped (it neither breaks nor extends a streak).
- **Current streak:** walk backward from today (or the most recent scheduled day if today is not scheduled). For each scheduled day, if it is completed, increment; on the first scheduled-but-incomplete day, stop. Today being incomplete does not break the streak until the day it was scheduled has passed the toggle window; for computation, an incomplete scheduled today yields the streak up to the previous scheduled day.
- **Longest streak:** scan the full ordered set of scheduled days from first entry to today, counting the longest run of consecutive scheduled completed days.
- Empty history yields `StreakResult(current: 0, longest: 0)`.

The calculator is pure (no I/O, no DateTime.now inside), so `todayKey` is injected. This makes date-rollover and timezone cases fully testable.

## Where state lives

- **Source of truth:** the Drift SQLite database on the device.
- **Reactive reads:** DAOs expose Drift streams; repositories wrap them; Riverpod `StreamProvider`s expose them to the UI.
- **Derived state:** streak results are computed in Riverpod providers that depend on the entries provider and the habit's schedule; nothing derived is persisted.
- **Ephemeral UI state:** form fields and pickers use Riverpod controllers (`Notifier`/`AsyncNotifier`) scoped to the screen.
- **Reminders:** the notification service holds no durable state; reminder settings live on the Habit row and are rescheduled from the database on launch.

## External dependencies

Pinned exact versions live in `pubspec.yaml` and `pubspec.lock` (committed). Planned direct dependencies:

- `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` (database and native SQLite).
- `flutter_riverpod`, `riverpod_annotation` (state).
- `flutter_local_notifications`, `timezone`, `flutter_timezone` (reminders).
- `intl` (date formatting).

Dev dependencies:

- `build_runner`, `drift_dev`, `riverpod_generator` (code generation).
- `flutter_lints`, `custom_lint`, `riverpod_lint` (analysis).
- `flutter_test` (bundled).

No dependency is added without approval per `docs/rules.md`.

## Environment variables

None. streaks has no backend, no secrets, and no configuration that varies by environment. There is no `.env` file. Any build-time configuration (for example, app id) lives in the platform project files and `pubspec.yaml`.
