# Product Requirements: streaks

## What we're building

streaks is a local-first mobile app that helps a person build daily habits by tracking completions and rewarding consistency. The user defines habits, checks them off each day, and sees momentum through current and longest streaks and a calendar heatmap. All data is stored locally in a SQLite database on the device. There is no login, no cloud sync, and no network dependency. Optional local notifications remind the user to complete a habit each day.

## Target user

An individual who wants to build or maintain personal daily habits (exercise, reading, meditation, drinking water) and stays motivated by not breaking a streak. They value privacy and offline access, do not want to create an account, and use a single phone. They are not looking for social features, sharing, or team accountability.

## Core features (prioritized)

### P0: Create and manage habits
The user can create a habit with a name, a color, and a weekly schedule (which weekdays the habit is expected). They can edit these fields, archive a habit to hide it without losing history, and delete a habit permanently (with confirmation). The habit list is the app's home screen.

### P0: Mark a habit done for a day
From the habit list and habit detail, the user can toggle today's completion for a habit. Toggling is idempotent: marking then unmarking the same day leaves no completion recorded. Completions are stored per habit per calendar date.

### P0: Current and longest streaks
For each habit, the app computes the current streak (consecutive scheduled days completed up to and including today, respecting the habit's weekly schedule) and the longest streak ever achieved. These are shown on the habit list and habit detail.

### P1: Calendar heatmap of history
Each habit's detail screen shows a calendar heatmap of past completions, letting the user see patterns and gaps across weeks and months. Past days can be toggled to correct mistakes.

### P1: Daily reminders
The user can enable an optional per-habit daily reminder at a chosen time. Reminders use local notifications and require notification permission. If permission is denied, the app explains this clearly and the rest of the app keeps working.

### P2: Theming
The app supports light and dark Material 3 themes derived from a single seed color, following the system theme by default.

## Non-goals

- No user accounts, authentication, or cloud sync.
- No network calls or backend services of any kind.
- No social, sharing, leaderboard, or multi-user features.
- No multi-device sync or backup export in the first release.
- No sub-daily tracking (multiple completions per day) or quantity goals (for example, "8 glasses"); a habit is done or not done for a given day.
- No gamification beyond streak counts (no points, badges, levels).
- No web or desktop targets in the first release; Android and iOS only.

## Success criteria per core feature

### Create and manage habits
- Creating a habit persists it to the local database and it appears in the list immediately.
- Editing a habit updates its stored values and reflects them on next render.
- Archiving hides a habit from the active list but preserves its entries; unarchiving restores it.
- Deleting a habit removes it and its entries after an explicit confirmation.
- A habit name is required, trimmed, and limited to a sensible length; empty or whitespace-only names are rejected with an inline message.

### Mark a habit done for a day
- Toggling today records or removes a `HabitEntry` for that habit and date.
- Toggling twice returns to the original state (no duplicate rows for the same habit and date).
- The completion state survives an app restart (read back from the database).

### Current and longest streaks
- Current streak counts consecutive scheduled, completed days ending today (or the most recent scheduled day if today is not scheduled).
- Longest streak equals the maximum run of consecutive scheduled completed days in the habit's history.
- Both values recompute correctly after toggling any day and after a date rollover (midnight, local time).
- A habit with no entries shows a current and longest streak of zero.

### Calendar heatmap of history
- The heatmap shows one cell per day with intensity or fill indicating completion.
- Tapping a past day toggles its completion and updates streaks accordingly.
- The heatmap scrolls back through prior months without performance problems for at least one year of history.

### Daily reminders
- Enabling a reminder schedules a repeating daily local notification at the chosen local time.
- Disabling a reminder cancels the scheduled notification.
- If notification permission is denied, the app shows a friendly explanation and disables the toggle rather than crashing or silently failing.
- Reminders survive an app restart (rescheduled on launch as needed).

### Theming
- The app renders correctly in both light and dark modes and follows the system setting by default.
- All text meets contrast requirements and all interactive targets meet the minimum tap size (see `docs/design.md`).
