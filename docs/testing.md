# Testing: streaks

## Strategy

streaks uses a mix of automated tests and manual QA. Automated tests focus where they give the most value for the least fragility; the rest is verified manually on a device or emulator.

### Automated: `flutter_test`
- **Unit tests (highest priority).** The streak calculator (`features/streaks/domain/streak_calculator.dart`) is pure and must be covered thoroughly: empty history, single day, consecutive days, gaps, schedule-aware skipping (non-scheduled days do not break streaks), current vs longest divergence, today incomplete, date-rollover via injected `todayKey`, and walks across daylight-saving changes. `core/date_utils.dart` steps by calendar day (`nextDay`, `previousDay`), never by a 24 hour `Duration`, and `test/core/date_utils_test.dart` checks that a year of steps yields every day once.
- **DAO / database tests.** Run DAOs against an **in-memory** Drift database (`NativeDatabase.memory()`), no device needed. Cover insert habit, insert/delete entry (toggle idempotency, unique (habit_id, date)), archive/unarchive, cascade delete of entries with a habit, and bulk entry insert. The schema is still at version 1, so there is no migration test yet; add one with the first schema change.
- **Widget tests.** Cover the habit list (renders tiles, shows the empty state when there are no habits, toggles today), and the habit form (name validation: empty, whitespace, too long; save enabled/disabled). Use `ProviderScope` overrides to inject a test database or fake repository so widget tests do not touch a real device database.

### Manual QA (on device/emulator)
Reserved for things that are impractical or brittle to automate:
- Real date rollover across midnight on a physical device.
- Visual review of light/dark themes, text scaling, empty and loading states, and long habit names.
- App icon, splash, and release build behavior.

Unhappy paths to walk through by hand: empty and whitespace-only names, a 80+ character name, deleting a habit and pressing Undo, archiving and unarchiving, and toggling days on the heatmap including today.

## Exact commands

Run from the repository root.

```bash
# Install dependencies
flutter pub get

# Generate Drift code (after any table or DAO change)
dart run build_runner build --delete-conflicting-outputs

# Static analysis: must report zero issues
flutter analyze

# Format check (CI-friendly; fails if unformatted)
dart format --output=none --set-exit-if-changed .

# Run all unit and widget tests
flutter test

# Run a single test file
flutter test test/data/streak_calculator_test.dart

# Debug build sanity checks
flutter build apk --debug
flutter build ios --debug --no-codesign

# Release build sanity checks (used before launch)
flutter build apk --release
flutter build appbundle --release
flutter build ios --release --no-codesign
```

## CI

`.github/workflows/ci.yml` runs on every push to `main` and every pull request against `main`,
using the Flutter version pinned in `pubspec.yaml` (`environment.flutter`):

1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs`
3. `flutter analyze`
4. `flutter test`
5. `flutter test test/core/date_utils_test.dart test/data/streak_calculator_test.dart` again with
   `TZ=America/New_York`, so the day-stepping and streak tests run in a zone with daylight-saving
   changes (the runner's default zone is UTC, which has none)

CI does not run the `dart format` check or any platform build; run those locally. The
`android/` and `ios/` platform folders are not committed, so the build commands above need them
generated first (see the Install section of the README).

## Definition of "passing"

Before any feature is considered done:

1. `flutter analyze` reports **zero** issues (no warnings, no infos that the lint set flags as errors).
2. `dart format --output=none --set-exit-if-changed .` passes (code is formatted).
3. `flutter test` passes with **all** tests green.
4. The relevant debug build succeeds for at least one target platform.
5. The relevant manual checks above have been walked through.

If a test is legitimately outdated by a change, update it in the same commit with a clear reason.

## Coverage expectations

- The streak calculator: aim for full branch coverage; it is the core logic.
- DAOs: cover every public method at least once, including failure/edge inputs.
- Widgets: cover the primary happy path plus the key unhappy path (empty state, validation).
- Do not chase a coverage percentage at the expense of meaningful tests; prioritize the calculator and DAOs.
