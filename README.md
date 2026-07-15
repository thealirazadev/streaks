# streaks

streaks is a local-first habit and streak tracker for mobile. You create habits, mark them done each day, and watch your current and longest streaks grow alongside a calendar heatmap of your history. Everything lives on the device in a local SQLite database, so the app works fully offline with no account and no server. Optional daily reminders nudge you to keep the streak alive.

## Features

- Create, edit, archive, and delete habits (name, color, weekly schedule).
- Mark a habit done or not-done for the current day with one tap.
- Current streak and longest streak computed from your history.
- Calendar heatmap showing completion history per habit.
- Optional per-habit daily reminder via local notifications.
- Light and dark Material 3 themes driven by a single seed color.
- Fully offline, local-first storage. No account, no network calls.

## Tech stack

- Flutter and Dart (Material 3).
- Drift (SQLite) for local persistence and schema-versioned migrations.
- Riverpod for state management.
- flutter_local_notifications with the timezone package for reminders.
- flutter_lints for static analysis.
- flutter_test plus widget tests for automated testing.

## Prerequisites

- Flutter SDK (stable channel) matching the version pinned in the repository. Verify with `flutter --version` and `flutter doctor`.
- Dart SDK bundled with Flutter.
- Android Studio or Xcode with a configured emulator or simulator, or a physical device with developer mode enabled.

## Install

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The `build_runner` step generates Drift database code and Riverpod providers. Re-run it after any change to a Drift table or a code-generated provider.

## Run

```bash
# List available devices
flutter devices

# Run on the default connected device or emulator
flutter run

# Run on a specific device
flutter run -d <device_id>
```

## Test

```bash
# Static analysis (must be clean, zero warnings)
flutter analyze

# Unit and widget tests
flutter test
```

Both commands must pass before any feature is considered done. See `docs/testing.md` for details.

## Project structure

```
lib/
  main.dart              App entry point and root widget
  app/                   App-level theme, router, and shell
  core/                  Shared utilities, error handling, logging, constants
  data/                  Drift database, tables, DAOs, migrations
  features/
    habits/              Habit list, create/edit, habit detail
    streaks/             Streak computation and streak display widgets
    reminders/           Notification scheduling and permission handling
docs/                    Planning and handoff documentation
test/                    Unit and widget tests
```

See `docs/architecture.md` for the full folder tree and rationale.

## Documentation

Planning and handoff docs live in `docs/`: `PRD.md`, `architecture.md`, `rules.md`, `design.md`, `phases.md`, `testing.md`, `memory.md`, and `launch-checklist.md`.

## License

License: MIT
