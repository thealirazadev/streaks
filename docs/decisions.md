# Design decisions

## 1. Drift over SQLite for storage

The data is relational and range-queried: habits with many dated completion rows, queried per
habit and per month, with a schema that will change. Drift gives a typed schema, reactive
`watch()` streams that feed Riverpod providers directly, and versioned migrations
(`schemaVersion` plus `schema_versions.dart` as the change log). A key-value store such as Hive
would have pushed the relational modeling, range queries, and migrations into hand-written code.
Everything stays in one private database file on the device, with no account and no network.

## 2. Days are integer keys, not timestamps

A completion is keyed by an integer `yyyymmdd` built from the local calendar date
(`dayKey` in `core/date_utils.dart`). Equality and range queries on an integer are simple, a
completion cannot drift to a neighbouring day because of the time it was recorded, and the key
means the same thing to the user regardless of when in the day they tapped. `createdAt` on a
habit is the one real timestamp and is stored in UTC.

## 3. Completion is the presence of a row

A day is done when a `HabitEntries` row exists for (`habitId`, `date`); there is no "not done"
row. A unique key on that pair makes a duplicate impossible, and `HabitEntryDao.toggle` checks
for the row and inserts or deletes it inside one transaction, so two quick taps cannot race
between the check and the write, and toggling twice always returns to the starting state. The
`done` column (default `true`) is kept so an explicit not-done marker can be added later without
a migration.

## 4. The streak calculator is a pure function

`computeStreaks` takes the completed day keys, the schedule mask, and an injected `todayKey`, and
never reads the clock, so rollover and schedule behavior are unit tested without device time.
The rules:

- Only scheduled weekdays count; an unscheduled day neither breaks nor extends a streak.
- The current streak walks back from today. An incomplete scheduled today does not break the
  streak, because the day is not over; it is simply not counted. An incomplete scheduled day
  before today ends the walk.
- The longest streak is the longest run of consecutive scheduled, completed days from the first
  completion through today.
- An empty schedule always yields zero.

## 5. Weekly schedule as a seven-bit mask

`scheduleMask` stores the scheduled weekdays in one integer, bit 0 for Monday through bit 6 for
Sunday, defaulting to `0x7F` (every day). It fits in a single column, needs no join table, and
the calculator checks a weekday with one bit test.

## 6. Foreign keys are switched on for every connection

`HabitEntries.habitId` references `Habits` with `ON DELETE CASCADE`, but SQLite ignores foreign
keys unless each connection enables them. Without that, deleting a habit left its entries
behind. `AppDatabase` now runs `PRAGMA foreign_keys = ON` in `beforeOpen`, and a DAO test covers
the cascade.

## 7. Delete with undo, archive without loss

Archiving only hides a habit from the active list; its entries are kept and it can be restored
from the archived screen. Deleting asks for confirmation, then cascades to the entries. Before
the delete, the detail screen snapshots the habit and its completed day keys, so the SnackBar's
Undo can recreate it through `HabitRepository.restoreHabit`, which inserts the habit (with a new
id) and batch-inserts the saved day keys with `HabitEntryDao.insertEntries`.

## 8. Writes return a `Result`, and every failure is shown

Repository writes catch database exceptions, log them with the shared `Logger`, and return a
`Result` carrying a `DbFailure` with a short user-facing message such as "Could not save. Please
try again." Raw exception text never reaches the UI. Callers show the message in a SnackBar. The
habit list's completion toggle originally discarded a failed result; it now shows the same
SnackBar as the detail screen.

## 9. Validation is pure and enforced twice

`validateHabitName` trims the input, rejects an empty or whitespace-only name, and caps it at 80
characters, returning a sealed `HabitNameValid` or `HabitNameInvalid`. It has no Flutter
dependency, so it is tested on its own, and the form controller uses it for inline errors. The
`Habits.name` column carries the same 1 to 80 length rule as a second line of defense.

## 10. Hand-written providers, generated database code

Providers are plain `Provider`, `StreamProvider`, and `NotifierProvider` declarations rather than
`@riverpod` code generation, which keeps the provider layer readable with no generated files to
follow; `riverpod_annotation` and `riverpod_generator` stay pinned in case generation is adopted
later. Drift's `.g.dart` files are generated, not committed: CI runs
`dart run build_runner build --delete-conflicting-outputs` before analysis and tests, and the same
command is needed locally after `flutter pub get`. Widgets go through providers and the
repository, never a DAO.

## 11. A heatmap that stays cheap to scroll

`HeatmapCalendar` builds one section per month, most recent first, rather than one list item per
day, so a year of history stays cheap to build and scroll. A done day uses the habit color, a
scheduled day that was missed uses a neutral surface, and an unscheduled day uses a low-opacity
outline, so the states differ by more than color alone. Today always gets a ring, and future days
render as blank space and cannot be tapped. Known gap: the day cells have a hit area of about
16dp, below the 48dp touch-target minimum in `docs/design.md`; the tappable region needs to grow
without changing the visual cell size.

## 12. Tests use an in-memory database

DAO and widget tests open `AppDatabase(NativeDatabase.memory())`, so they exercise real SQL with
no device. Widget tests pump an empty widget to unmount the screen before closing the database,
which lets Drift's stream timers drain instead of failing the test with pending timers.
