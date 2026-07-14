# Project Memory: streaks

A running log of progress and decisions. Keep entries short and dated. Update this as work proceeds.

## Completed

- 2026-07-15 - Planning documentation created (README, PRD, architecture, rules, design, phases, testing, launch checklist, this memory file).

## In progress

- (none)

## Decisions log

- 2026-07-15 - **Persistence: Drift (SQLite) over Hive.** streaks stores relational, range-queried, migration-prone data (habits with many dated entries). Drift provides a typed relational schema, reactive streams that integrate with Riverpod, and first-class versioned migrations. Hive would push relational modeling and migrations into hand-written code. Recorded in `docs/architecture.md`.
- 2026-07-15 - **State management: Riverpod.** Compile-safe providers, easy test overrides, and natural derivation of streak state from database streams.
- 2026-07-15 - **Dates stored as integer day keys (yyyymmdd, local).** Avoids timezone ambiguity from timestamps and makes equality/range queries simple. `created_at` remains a UTC timestamp for auditability.
- 2026-07-15 - **Completion modeled as insert-or-delete of a HabitEntry row.** Absence of a row for (habit_id, date) means not done. The `done` column is retained for a future explicit not-done marker without a migration.
- 2026-07-15 - **Streak calculator is a pure function with injected todayKey.** Keeps date-rollover and timezone behavior fully testable without device time.
- 2026-07-15 - **Reminders via flutter_local_notifications + timezone package.** Required for DST-correct daily scheduling.
