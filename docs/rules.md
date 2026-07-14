# Engineering Rules: streaks

These rules are binding for all work on streaks. When something here conflicts with a convenient shortcut, follow the rule.

## Conventions

### Packages and patterns
- State management is **Riverpod** only. Do not introduce Provider, BLoC, GetX, or `setState`-driven app state for anything beyond trivial local widget state.
- Persistence is **Drift over SQLite** only. Do not add a second storage engine (no Hive, no shared_preferences for domain data). Small non-domain flags may use a single documented mechanism if approved.
- Reminders use **flutter_local_notifications** with the **timezone** package. No other notification path.
- Keep layers separated: `presentation` (widgets/screens) depends on `application` (providers/controllers), which depends on `domain` (models/pure logic) and `data` (DAOs/repositories). Domain never imports Flutter.
- Streak logic is a **pure function** with injected `todayKey`; never read `DateTime.now()` inside domain logic.

### What to avoid
- No business logic inside widgets; put it in controllers or domain functions.
- No direct DAO calls from widgets; go through repositories and providers.
- No global mutable singletons except the code-generated database and the notification service, both provided through Riverpod.
- No `print` for logging; use the shared logger.
- No swallowing exceptions silently; surface a failure and log it.

### Naming
- **Files:** `snake_case.dart` (for example, `habit_list_screen.dart`, `streak_calculator.dart`). Generated files keep their `.g.dart` suffix.
- **Classes / enums / typedefs:** `PascalCase` (`Habit`, `HabitEntry`, `StreakResult`, `NotificationService`).
- **Variables / functions / parameters:** `lowerCamelCase` (`currentStreak`, `computeStreaks`, `dayKey`).
- **Constants:** `lowerCamelCase` for `const` values; avoid `SCREAMING_CAPS`. Group shared constants in `core/constants.dart`.
- **Providers:** suffix with role: `habitListProvider`, `streakProvider`, `habitFormControllerProvider`.
- **Drift tables:** plural PascalCase class (`Habits`, `HabitEntries`); the generated row types are singular (`Habit`, `HabitEntry`).
- Follow **Effective Dart** and the `flutter_lints` rule set; `flutter analyze` must be clean.

### Commits
- **Conventional Commits** with a short imperative subject, for example: `feat: add habit creation form`, `fix: correct streak reset at midnight`, `test: cover schedule-aware streaks`, `chore: pin dependency versions`.
- **One commit per feature or task.** Never batch unrelated changes into a single commit. Each phase in `docs/phases.md` lists its commits in order; follow that order.
- Reference the phase in the body when useful, not the subject.
- No authorship or tool attribution in commit messages.

### Dependencies and migrations
- **Pin exact versions** in `pubspec.yaml` (no `^`, no ranges) and **commit `pubspec.lock`**. Version bumps are their own `chore` commit with a clear reason.
- **Schema changes go through Drift schema versions.** Increment `schemaVersion`, add a step in the migration strategy, and record the change in `data/database/migrations/schema_versions.dart`.
- **Applied migrations are never edited.** Once a migration ships, it is immutable; further changes require a new schema version and a new migration step.
- Run `dart run build_runner build --delete-conflicting-outputs` after any table or generated-provider change and commit the regenerated files.

## Error handling and logging

- Adopt **one consistent approach**: data operations return a `Result` type (`core/result.dart`) or throw a typed `Failure` (`core/failures.dart`); pick the pattern per layer and use it everywhere. Repositories translate low-level exceptions (Drift, plugin) into app `Failure`s.
- **Handle database failures.** Wrap DAO calls; on failure, log details and show a friendly in-app message (for example, "Could not save. Please try again."). Never leak raw exception text to the user.
- **Handle notification failures.** Permission denial, scheduling errors, and platform exceptions must be caught. If a reminder cannot be scheduled, disable the toggle, explain why, and keep the app usable.
- **Never crash on bad state.** Guard against missing habits, null reminder times, empty entry sets, and malformed day keys. Invalid states resolve to safe defaults (empty list, zero streak) plus a logged warning.
- **Friendly messaging vs detailed logs.** Users see short, actionable messages via SnackBars or inline text; developers get detailed context (operation, ids, stack) through the logger.
- **Logging from day one.** Use the shared `logger` in `core/logger.dart` from the first phase. Log levels: `debug` for flow, `info` for lifecycle, `warning` for recoverable issues, `error` for failures. No sensitive data in logs (there is none, but keep the habit).

## Security

- **No secrets.** streaks has no API keys, tokens, or credentials. Do not add any. There is no `.env`.
- **Validate and sanitize user input.** Trim habit names, enforce length limits (1..80), reject empty/whitespace-only names with inline feedback, and clamp reminder times to valid ranges. Never build SQL by string interpolation; use Drift's typed query API exclusively.
- **Safe local storage.** All data stays in the app's private database file. Do not write domain data to shared or external storage. Do not log user input beyond what is needed to debug, and never to a remote sink.
- No analytics, telemetry, or network calls. The app must function with all networking unavailable.

## Simplicity (YAGNI / KISS)

- Build only what the current phase requires. Do not add abstractions, plugin layers, or configuration for hypothetical futures.
- Prefer the simplest data model and widget tree that meets the acceptance criteria. The `done` column and schedule bitmask are the only forward-looking allowances, and both are documented.
- No premature generalization: one habit type, one entry type, one notification path.
- Delete dead code rather than commenting it out.

## Code style

- Sparse, purposeful comments; explain **why**, not **what**. No commented-out code.
- Concise `///` docstrings on public classes and non-obvious functions (especially the streak calculator and DAOs).
- No emoji anywhere in code, comments, docs, or commit messages.
- No AI, assistant, or authorship mentions anywhere in the repository.
- Format with `dart format`; keep `flutter analyze` warning-free.
- Conventional Commits, one per feature/task, as above.

## Boundaries

- **No wholesale delete or rewrite** of working modules. Make focused, incremental changes scoped to the task.
- **Do not change `PRD.md` or `architecture.md`** without flagging it first. If implementation reveals a needed change, stop, note the conflict, and get agreement before editing those documents.
- **No new dependency without approval.** Propose the package, the reason, and the exact version; wait for sign-off before adding it and committing the lockfile change.
- **Ask when ambiguous.** If a requirement is unclear or two reasonable interpretations exist, ask rather than guess.
- **Stop after two failed fix attempts.** If a bug resists two genuine attempts, stop, write down what was tried and the current hypothesis, and escalate instead of thrashing.
- **Scope every change.** Classify each proposed change as: belongs to the **current phase**, warrants a **new phase**, or goes to the **backlog** in `docs/phases.md`. Do not silently expand the current phase.
