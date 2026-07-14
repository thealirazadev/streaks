# Launch Checklist: streaks

Work top to bottom before releasing. Nothing is checked until it is verified on a real build. Do not tick an item you have not personally confirmed.

## Build and quality

- [ ] `flutter analyze` reports zero issues (no analyzer warnings or infos flagged by the lint set).
- [ ] `dart format --output=none --set-exit-if-changed .` passes.
- [ ] `flutter test` is fully green.
- [ ] Release build works on Android: `flutter build appbundle --release` and `flutter build apk --release` succeed.
- [ ] Release build works on iOS: `flutter build ios --release` succeeds and archives in Xcode.
- [ ] App runs from the release build (not just debug) on a physical Android device.
- [ ] App runs from the release build on a physical iOS device.
- [ ] `pubspec.lock` is committed and dependency versions are pinned (no ranges).

## States and UX

- [ ] Empty states verified: no habits, habit with no history, archived empty (if surfaced).
- [ ] Loading states verified: initial data load and in-flight save/delete.
- [ ] Error states verified: simulated DB failure shows a friendly message and does not crash.
- [ ] Long habit names truncate in tiles and display fully on detail without overflow.
- [ ] Light and dark themes reviewed on every screen.

## Data and correctness

- [ ] Streaks correct for: empty history, single day, consecutive days, gaps, schedule-skipped days, current vs longest divergence.
- [ ] Toggle idempotency: mark then unmark leaves no residual row.
- [ ] Date rollover across midnight updates "today" and recomputes streaks against the correct local day.
- [ ] Timezone / DST boundary does not corrupt streaks or reminder times.
- [ ] DB migration from the prior shipped schema version preserves habits and entries (verified by test and on-device upgrade).
- [ ] Data survives app restart and app update.

## Permissions and notifications

- [ ] Notification permission requested at the right moment (first reminder enable), not on launch.
- [ ] Permission denied path: reminder toggle disabled with a clear explanation; app remains usable.
- [ ] Enabled reminders fire at the correct local time.
- [ ] Reminders reschedule correctly after app restart.
- [ ] Disabling a reminder cancels its notification.
- [ ] Android 13+ POST_NOTIFICATIONS permission handled; iOS notification authorization handled.

## Accessibility

- [ ] Semantics labels present on icon-only controls (completion toggle, heatmap cells, streak badges).
- [ ] All interactive targets are at least 48 x 48 dp.
- [ ] Text scaling to at least 1.3x shows no clipping or overflow.
- [ ] Contrast meets WCAG AA in light and dark; no small text on raw habit colors.
- [ ] Completion is distinguishable without relying on color alone (check icon/fill plus color).

## Branding and store assets

- [ ] App icons set for Android (adaptive icon) and iOS (all required sizes).
- [ ] Splash screen configured for both platforms.
- [ ] App display name and bundle/application id finalized.
- [ ] App version and build number set in `pubspec.yaml`.
- [ ] Store listing assets prepared: title, short and full description, screenshots (light and dark), feature graphic (Android).
- [ ] Privacy details prepared: app is fully local, collects no data, makes no network calls; complete Play Data Safety and iOS App Privacy accordingly.
- [ ] License file present (MIT).

## Project-specific

- [ ] Seed color `#3B7A57` produces accessible light and dark schemes (verified).
- [ ] Habit color palette swatches all pass contrast when used as accents.
- [ ] Heatmap renders and scrolls smoothly with at least one year of history.
- [ ] `docs/memory.md` updated with the release decision and current status.
- [ ] No secrets, no `.env`, no network calls anywhere in the codebase (confirmed by search).
