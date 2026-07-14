# Phases: streaks

Phases are ordered so each one ships something useful and testable. Do not start a phase until the previous phase's Definition of Done and manual checklist pass. Every commit is a single feature or task using Conventional Commits, listed in order.

---

## Phase 1: Project skeleton and habit list with local persistence

The smallest useful app: create habits and see them in a list, stored in the local database and surviving restart. No streaks, no reminders yet.

### Definition of done
- App launches on Android and iOS emulators to the habit list screen.
- Drift database is set up with `Habits` and `HabitEntries` tables at `schemaVersion` 1.
- Riverpod is wired with a root `ProviderScope`.
- Material 3 theme (light/dark from the seed color) is applied.
- User can create a habit (name, color, weekly schedule) via a form and see it in the list.
- Habits persist across app restart.
- Empty state shows when there are no habits.
- Name validation works (required, trimmed, max 80 chars).
- Logger and error-handling scaffolding exist and are used by the DAO/repository layer.
- `flutter analyze` clean; `flutter test` green.

### Manual test checklist
- [ ] Launch app cold: empty state "No habits yet" appears with an "Add habit" action.
- [ ] Create a habit; it appears immediately in the list.
- [ ] Force-quit and relaunch; the habit is still there.
- [ ] Try to save an empty name; inline validation blocks it.
- [ ] Try a very long name; it is rejected or truncated per the 80-char rule.
- [ ] Switch device to dark mode; theme updates correctly.

### Commits
1. `chore: scaffold flutter project and pin dependency versions`
2. `chore: configure flutter_lints and analysis options`
3. `feat: add material 3 theme from seed color`
4. `feat: set up drift database with habits and habit_entries tables`
5. `feat: add logger and result/failure error handling scaffolding`
6. `feat: add habit dao and repository`
7. `feat: wire riverpod provider scope and habit list provider`
8. `feat: build habit list screen with empty state`
9. `feat: add create habit form with validation`
10. `test: cover habit dao and habit form validation`

---

## Phase 2: Mark habits done and compute streaks

Add the core loop: toggle today's completion and see current and longest streaks.

### Definition of done
- User can toggle today's completion from the list tile.
- Toggling is idempotent (mark then unmark leaves no row for that day).
- Completion persists across restart.
- Streak calculator is implemented as a pure function with injected `todayKey` and covered by unit tests.
- Current and longest streaks show on the list tile and are schedule-aware.
- Streaks recompute after toggling and after a simulated date change.
- `flutter analyze` clean; `flutter test` green.

### Manual test checklist
- [ ] Toggle a habit done today; streak shows 1.
- [ ] Toggle it off; streak returns to 0 and no row remains for today.
- [ ] Mark several consecutive days (via detail/heatmap in Phase 3, or a seeded fixture); current streak counts correctly.
- [ ] Create a habit scheduled only on weekdays; a skipped weekend day does not break the streak.
- [ ] Change device date forward one day; an unmarked "today" does not retroactively break the prior streak incorrectly.

### Commits
1. `feat: add habit entry dao with toggle idempotency`
2. `feat: implement schedule-aware streak calculator`
3. `test: cover streak calculator edge cases`
4. `feat: add streak provider deriving current and longest streaks`
5. `feat: add completion toggle to habit list tile`
6. `feat: show current and longest streak on habit list`

---

## Phase 3: Habit detail and calendar heatmap

Give each habit a detail screen with streak display and an interactive history heatmap.

### Definition of done
- Tapping a habit opens its detail screen.
- Detail shows the habit name, color, current and longest streaks, and reminder settings placeholder.
- Calendar heatmap renders completion history and scrolls back through months.
- Tapping any past day toggles its completion and updates streaks.
- Detail shows the "no history" empty message when there are no entries.
- `flutter analyze` clean; `flutter test` green.

### Manual test checklist
- [ ] Open a habit with no history; heatmap is empty and message shows.
- [ ] Toggle a past day in the heatmap; it fills and streaks update.
- [ ] Scroll back several months; performance is smooth with a year of seeded data.
- [ ] Today's cell shows the "today" ring.
- [ ] Long habit name displays fully on detail (not truncated).

### Commits
1. `feat: add habit detail screen`
2. `feat: add calendar heatmap widget`
3. `feat: enable toggling past days from the heatmap`
4. `feat: show streak badges on habit detail`
5. `test: widget test heatmap toggling and empty history`

---

## Phase 4: Edit, archive, and delete habits

Full lifecycle management for habits.

### Definition of done
- User can edit a habit's name, color, and schedule.
- User can archive a habit (hidden from active list, entries retained) and unarchive it.
- User can delete a habit after a confirmation dialog; entries are cascade-deleted.
- Delete offers an Undo where feasible.
- `flutter analyze` clean; `flutter test` green.

### Manual test checklist
- [ ] Edit a habit's name and color; changes persist.
- [ ] Archive a habit; it leaves the active list; unarchive restores it with history intact.
- [ ] Delete a habit; confirmation appears; after confirming, it and its entries are gone.
- [ ] Cancel a delete; nothing changes.

### Commits
1. `feat: add edit habit flow reusing the habit form`
2. `feat: add archive and unarchive habit`
3. `feat: add delete habit with confirmation and undo`
4. `test: cover archive and cascade delete in dao`

---

## Phase 5: Daily reminders

Optional per-habit local notifications.

### Definition of done
- User can enable a per-habit daily reminder at a chosen time.
- Enabling schedules a repeating daily local notification; disabling cancels it.
- Notification permission is requested when first enabling a reminder.
- Permission-denied path shows a friendly explanation and disables the toggle; app stays usable.
- Enabled reminders are rescheduled on app launch.
- Timezone package initialized so scheduling is DST-correct.
- `flutter analyze` clean; `flutter test` green.

### Manual test checklist
- [ ] Enable a reminder; grant permission; notification fires at the set time (or shortly after for a near-time test).
- [ ] Deny permission; toggle disables with a clear explanation; no crash.
- [ ] Disable a reminder; no further notifications.
- [ ] Relaunch app; previously enabled reminders remain scheduled.
- [ ] Set a reminder across a DST boundary (where testable); time stays correct.

### Commits
1. `feat: add notification service wrapping flutter_local_notifications`
2. `feat: initialize timezone data on startup`
3. `feat: add reminder settings to habit form and detail`
4. `feat: schedule and cancel daily reminders`
5. `feat: reschedule reminders on app launch`
6. `feat: handle notification permission denial gracefully`

---

## Phase 6: Polish, accessibility, and launch prep

Final pass before release.

### Definition of done
- Loading and error states implemented per `docs/design.md`.
- Accessibility pass: semantics labels, 48 dp tap targets, text scaling to 1.3x, contrast verified in light and dark.
- App icons and splash configured.
- Release builds succeed for Android and iOS.
- `docs/launch-checklist.md` fully checked.
- `flutter analyze` clean; `flutter test` green.

### Manual test checklist
- [ ] Enable a screen reader; toggle, streaks, and heatmap cells announce correctly.
- [ ] Set system text size to large; no clipping or overflow.
- [ ] Review light and dark themes on all screens.
- [ ] Trigger an error path (simulated DB failure) and confirm a friendly message, no crash.
- [ ] Confirm app icon and splash appear.

### Commits
1. `feat: add loading and error states across screens`
2. `feat: add semantics labels and enforce tap target sizes`
3. `feat: configure app icons and splash screen`
4. `chore: prepare release build configuration`
5. `docs: complete launch checklist`

---

## Phase verification checklist

Run this after every phase, not just at the end. All items must pass before the phase is considered shipped.

- [ ] **Run the app** on both an Android and an iOS emulator/simulator; it launches without errors.
- [ ] **Run the tests:** `flutter test` is fully green.
- [ ] **Check the console:** no unhandled exceptions, no red error logs, no lint warnings from `flutter analyze`.
- [ ] **Unhappy path - no habits yet:** empty state renders correctly; no crash reading an empty database.
- [ ] **Unhappy path - mark/unmark same day:** toggling a habit done then not-done leaves no residual row and returns streaks to the prior value.
- [ ] **Unhappy path - timezone / date rollover:** advancing the device date across midnight updates "today", and streaks compute against the correct local day key; DST boundary does not corrupt streaks or reminder times.
- [ ] **Unhappy path - DB migration:** upgrading from the prior schema version to the current one preserves existing habits and entries (verified by the migration test and, where relevant, on-device).
- [ ] **Unhappy path - notification permission denied:** the reminder flow degrades gracefully with a clear message and no crash (from Phase 5 onward).
- [ ] **Empty states:** every screen that can be empty shows its designed empty state.
- [ ] **Long habit names:** long names truncate with ellipsis in tiles and display fully on detail without overflow.
- [ ] **Loading states:** initial load and in-flight save/delete show their designed loading treatment.

---

## Backlog

Items deliberately deferred. Do not implement without promoting them into a phase first.

- (empty)
