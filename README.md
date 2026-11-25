# streaks

streaks is a local-first habit and streak tracker for mobile. You create habits, mark them done each day, and watch your current and longest streaks grow alongside a calendar heatmap of your history. Everything lives on the device in a local SQLite database, so the app works fully offline with no account and no server.

## Features

- Create, edit, archive, and delete habits (name, color, weekly schedule).
- Mark a habit done or not-done for the current day with one tap.
- Current streak and longest streak computed from your history.
- Calendar heatmap showing completion history per habit.
- Light and dark Material 3 themes driven by a single seed color.
- Fully offline, local-first storage. No account, no network calls.

Not built yet: daily reminders. The habit detail screen says so, and the `reminder_enabled` and
`reminder_minute_of_day` columns on the habits table are reserved for it.

## Tech stack

- Flutter and Dart (Material 3).
- Drift (SQLite) for local persistence and schema-versioned migrations.
- Riverpod for state management.
- flutter_lints for static analysis.
- flutter_test plus widget tests for automated testing.

## Prerequisites

- Flutter SDK (stable channel) matching the version pinned in the repository. Verify with `flutter --version` and `flutter doctor`.
- Dart SDK bundled with Flutter.
- Android Studio or Xcode with a configured emulator or simulator, or a physical device with developer mode enabled.

## Install

The repository holds the Dart code only. The `android/` and `ios/` platform folders and
`pubspec.lock` are not committed, so generate the platform projects once before the first run:

```bash
flutter create --project-name streaks --platforms=android,ios .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

`flutter create` adds the platform folders around the existing code without overwriting existing
files, and only needs to run once. If it adds a `test/widget_test.dart` for its counter template,
delete that file, since it does not match this app. The `build_runner` step generates the Drift
database code, which is not committed either. Re-run it after any change to a Drift table or DAO.
Analysis and tests (`flutter analyze`, `flutter test`) only need the last two commands.

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
docs/                    Architecture, design, testing, and design decisions
test/                    Unit and widget tests
```

See `docs/architecture.md` for the full folder tree and rationale.

## Documentation

- `docs/architecture.md`: folder layout, data model, and stack rationale
- `docs/design.md`: screens, theme, and accessibility targets
- `docs/testing.md`: test strategy, commands, and what CI runs
- `docs/decisions.md`: design decisions and the edge cases behind them

## License

License: MIT
