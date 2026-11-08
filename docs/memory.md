# Project Memory: streaks

A running log of progress and decisions. Keep entries short and dated. Update this as work proceeds.

## Completed

- 2026-07-15 - Planning documentation created (README, PRD, architecture, rules, design, phases, testing, launch checklist, this memory file).

- 2026-07-16 - Phase 1 (project skeleton and habit list with local persistence) implemented: Drift schema (`Habits`, `HabitEntries` tables, schema version 1), `HabitDao`, `HabitRepository`, Riverpod wiring, Material 3 theme, habit list screen with empty/loading/error states, create-habit form with name validation, and unit/DAO/widget tests. Commits: `dcf131b`..`5e0db01` (see `git log`).

- 2026-07-17 - Phase 2 (mark habits done and compute streaks) implemented: `HabitEntryDao` with transactional insert/delete toggle (idempotent), the pure `computeStreaks` calculator (schedule-aware, injected `todayKey`, one-day grace for an incomplete "today"), `streakProvider`/`completedDayKeysProvider`, a completion toggle on the habit list tile, and a `StreakBadge` showing current/best. Commits `dcd4dca`..`c5396b5`.

- 2026-07-17 - Phase 3 (habit detail and calendar heatmap) implemented: `HabitDetailScreen` (reachable by tapping a list tile), `HeatmapCalendar` (month-grouped day cells; habit color when done, neutral when scheduled-and-not-done, low-opacity outline otherwise; today gets a ring; future days render blank), tapping a cell toggles that day via `HabitRepository.toggleDay` with failures surfaced through a SnackBar, streak badges (`displaySmall` current/best numbers) on the detail screen, and a widget test covering the empty-history message and toggling today's cell on and back off. Commits `e9866f8`..`6e93f00`.

- 2026-07-17 - Phase 4 (edit, archive, delete) implemented: `HabitFormScreen` now takes an optional `habit` and `HabitFormController.startEditing` seeds it for editing (submit calls `updateHabit` instead of `createHabit`); `HabitDao.setArchived`/`watchArchivedHabits` plus a new `ArchivedHabitsScreen` (reachable from the home app bar) for archive/unarchive; a detail-screen overflow menu adds Archive and Delete, delete requires an `AlertDialog` confirmation, cascade-deletes entries via the existing FK, and offers an "Undo" SnackBar action that recreates the habit (new id) and re-inserts its snapshotted day keys through a new `HabitEntryDao.insertEntries` batch insert (`HabitRepository.restoreHabit`). DAO tests cover archive/unarchive, `updateHabit`, cascade delete, and bulk `insertEntries`. Commits `8d0ca4d`..`f966117`.

## In progress

- Phases 5 (daily reminders) and 6 (polish, accessibility, launch prep) are not started. Phase 5 integrates `flutter_local_notifications` and the `timezone` package (permission requests, DST-correct scheduling, Android manifest and iOS plist changes) and needs testing on real devices.

## Known gaps

- The heatmap's day cells (`heatmap_calendar.dart`) have a visually-accurate ~16dp hit area, not yet the 48dp minimum `docs/design.md` calls for; Phase 6's dedicated "enforce tap target sizes" commit is the intended place to widen the tappable region without changing the visual cell size.

## Decisions log

- 2026-07-15 - **Persistence: Drift (SQLite) over Hive.** streaks stores relational, range-queried, migration-prone data (habits with many dated entries). Drift provides a typed relational schema, reactive streams that integrate with Riverpod, and first-class versioned migrations. Hive would push relational modeling and migrations into hand-written code. Recorded in `docs/architecture.md`.
- 2026-07-15 - **State management: Riverpod.** Compile-safe providers, easy test overrides, and natural derivation of streak state from database streams.
- 2026-07-15 - **Dates stored as integer day keys (yyyymmdd, local).** Avoids timezone ambiguity from timestamps and makes equality/range queries simple. `created_at` remains a UTC timestamp for auditability.
- 2026-07-15 - **Completion modeled as insert-or-delete of a HabitEntry row.** Absence of a row for (habit_id, date) means not done. The `done` column is retained for a future explicit not-done marker without a migration.
- 2026-07-15 - **Streak calculator is a pure function with injected todayKey.** Keeps date-rollover and timezone behavior fully testable without device time.
- 2026-07-15 - **Reminders via flutter_local_notifications + timezone package.** Required for DST-correct daily scheduling.
- 2026-07-16 - **Hand-written Riverpod providers instead of `@riverpod` code generation.** Plain `Provider`/`StreamProvider`/`NotifierProvider` need no generated code, which keeps the provider layer readable and still satisfies "Riverpod only" in `docs/rules.md`. `riverpod_annotation`/`riverpod_generator` stay pinned in `pubspec.yaml` in case code generation is adopted later; they are currently unused.
- 2026-07-16 - **Drift's generated `.g.dart` files are not committed.** They are produced by `dart run build_runner build --delete-conflicting-outputs`, which CI runs before `flutter analyze` and `flutter test`. Run the same command locally after `flutter pub get`.
- 2026-11-08 - **SQLite foreign keys are enabled on every connection** (`PRAGMA foreign_keys = ON` in `beforeOpen`). SQLite ignores `ON DELETE CASCADE` without it, so deleting a habit left its entries behind. Widget tests unmount the screen before closing the in-memory database so Drift's stream timers drain. CI runs codegen, analysis, and all tests on every push.
- 2026-11-08 - The habit list's completion toggle now shows a SnackBar when the toggle fails, like the detail screen, instead of discarding the error.
