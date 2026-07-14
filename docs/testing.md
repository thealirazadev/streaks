# Testing: streaks

## Strategy

streaks uses a mix of automated tests and manual QA. Automated tests focus where they give the most value for the least fragility; the rest is verified manually on a device or emulator.

### Automated: `flutter_test`
- **Unit tests (highest priority).** The streak calculator (`features/streaks/domain/streak_calculator.dart`) is pure and must be covered thoroughly: empty history, single day, consecutive days, gaps, schedule-aware skipping (non-scheduled days do not break streaks), current vs longest divergence, today incomplete, and date-rollover via injected `todayKey`.
- **DAO / database tests.** Run DAOs against an **in-memory** Drift database (`NativeDatabase.memory()`), no device needed. Cover insert habit, insert/delete entry (toggle idempotency, unique (habit_id, date)), archive/unarchive, cascade delete of entries with a habit, and a migration test from the prior schema version to the current one.
- **Widget tests.** Cover the habit list (renders tiles, shows the empty state when there are no habits, toggles today), and the habit form (name validation: empty, whitespace, too long; save enabled/disabled). Use `ProviderScope` overrides to inject a test database or fake repository so widget tests do not touch a real device database.

### Manual QA (on device/emulator)
Reserved for things that are impractical or brittle to automate:
- Local notification scheduling and delivery, and the permission-denied flow.
- Real date rollover across midnight and timezone/DST behavior on a physical device.
- Visual review of light/dark themes, text scaling, empty and loading states, and long habit names.
- App icon, splash, and release build behavior.

Manual steps are enumerated per phase in `docs/phases.md` and in the phase verification checklist there.

## Exact commands

Run from the repository root.

```bash
# Install dependencies
flutter pub get

# Generate Drift and Riverpod code (after schema/provider changes)
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

## Definition of "passing"

Before any feature is considered done:

1. `flutter analyze` reports **zero** issues (no warnings, no infos that the lint set flags as errors).
2. `dart format --output=none --set-exit-if-changed .` passes (code is formatted).
3. `flutter test` passes with **all** tests green.
4. The relevant debug build succeeds for at least one target platform.
5. The manual checklist items for the feature's phase have been walked through.

Build and tests must pass before the feature's commit is made. A red build or failing test blocks the commit. If a test is legitimately outdated by a scoped change, update it in the same feature commit with a clear reason.

## Coverage expectations

- The streak calculator: aim for full branch coverage; it is the core logic.
- DAOs: cover every public method at least once, including failure/edge inputs.
- Widgets: cover the primary happy path plus the key unhappy path (empty state, validation).
- Do not chase a coverage percentage at the expense of meaningful tests; prioritize the calculator and DAOs.
