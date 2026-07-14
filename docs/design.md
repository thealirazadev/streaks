# Design: streaks (Material 3)

This document is the visual and interaction specification. It is complete enough to build the UI without further design input. streaks uses Material 3 with a single seed color and a `ColorScheme` generated for light and dark modes.

## Color scheme

### Seed
- **Seed color:** `#3B7A57` (a calm green, reinforcing growth and streaks).
- Generate both schemes with `ColorScheme.fromSeed(seedColor: Color(0xFF3B7A57), brightness: ...)`.
- Light: `brightness: Brightness.light`. Dark: `brightness: Brightness.dark`.
- The app follows the system theme by default (`ThemeMode.system`).

### Roles (used from the generated scheme; do not hardcode hex in widgets)
- **primary / onPrimary:** primary actions (FAB, primary buttons, active toggle).
- **primaryContainer / onPrimaryContainer:** selected chips, today marker.
- **surface / onSurface:** screen background and body text.
- **surfaceContainer / surfaceContainerHigh:** cards and list tiles.
- **secondary / tertiary:** accents in the heatmap legend and schedule chips.
- **error / onError / errorContainer / onErrorContainer:** validation and failure states.
- **outline / outlineVariant:** dividers, card borders, empty heatmap cells.

### Habit colors
- Habits pick from a fixed palette of eight accessible swatches (store the ARGB int on the habit):
  `#E4572E`, `#F3A712`, `#3B7A57`, `#2E86AB`, `#5D5FEF`, `#8E44AD`, `#D6336C`, `#546E7A`.
- Each swatch is used as an accent (left color bar, streak badge tint, heatmap fill base). Never use a habit color for text without checking contrast; pair it with an `onColor` derived for legibility or overlay text on a neutral surface.

### Heatmap intensity
- Empty (not scheduled or no data): `outlineVariant` at low opacity.
- Scheduled, not done: `surfaceContainerHighest`.
- Done: the habit color. Use a single filled level (binary done/not-done); do not fake multiple intensities since a day is binary.
- Today's cell: add a 1.5 dp `primary` ring regardless of state.

## Typography

Use the Material 3 type scale via `Theme.of(context).textTheme`. Do not hardcode font sizes in widgets; map to these roles:

| Role | Usage | Approx size / weight |
| --- | --- | --- |
| `displaySmall` | Large streak number on habit detail | 36 / regular |
| `headlineSmall` | Screen titles in large layouts | 24 / regular |
| `titleLarge` | App bar title | 22 / medium |
| `titleMedium` | Habit name in list tile | 16 / medium |
| `bodyLarge` | Primary body text | 16 / regular |
| `bodyMedium` | Secondary text, helper text | 14 / regular |
| `labelLarge` | Button labels | 14 / medium |
| `labelMedium` | Streak badge caption ("current" / "best") | 12 / medium |

- Default font is the platform default (Roboto on Android, San Francisco on iOS via Flutter). No custom font in the first release.
- All text must respect the system text scale factor (see Accessibility).

## Spacing

Use a 4 dp base unit. Define constants in `app/theme/app_spacing.dart`:

| Token | Value |
| --- | --- |
| `space2` | 2 dp |
| `space4` | 4 dp |
| `space8` | 8 dp |
| `space12` | 12 dp |
| `space16` | 16 dp (default screen padding) |
| `space24` | 24 dp |
| `space32` | 32 dp |

- Screen edge padding: 16 dp horizontal.
- List tile vertical padding: 12 dp; gap between tiles: 8 dp.
- Section spacing on detail screen: 24 dp.
- Heatmap cell gap: 4 dp.

## Shape and corner radii

Define in the theme. Material 3 shape scale:

| Token | Radius | Applied to |
| --- | --- | --- |
| `radiusSmall` | 8 dp | Chips, small buttons |
| `radiusMedium` | 12 dp | Cards, list tiles, heatmap cells (4 dp cells use 3 dp) |
| `radiusLarge` | 16 dp | Bottom sheets, dialogs |
| `radiusFull` | stadium | FAB, toggle pill |

- Heatmap day cells: 3 dp radius, roughly 16 dp square, 4 dp gap.
- Cards use `radiusMedium` with `Card` elevation per below.

## Elevation

Follow Material 3 tonal elevation (color-based) over heavy shadows:

| Surface | Elevation | Notes |
| --- | --- | --- |
| Screen background | 0 | `surface` |
| List tiles / cards | 1 | `surfaceContainerLow`/`surfaceContainer` tint |
| App bar | 0 default, 2 on scroll | Scrolled-under color change |
| FAB | 3 | Primary container tint |
| Dialog / bottom sheet | 3 | `surfaceContainerHigh` |
| SnackBar | 3 | Inverse surface |

## Component states

Every interactive component must define all applicable states. Use Material 3 state layers (hover/focus/pressed opacities) from the theme.

### Buttons (FilledButton primary, OutlinedButton secondary, TextButton tertiary)
- **Default:** themed colors, label in `labelLarge`.
- **Pressed:** state-layer overlay per Material 3 (approx 10 percent onColor).
- **Disabled:** 38 percent opacity content, no state layer; used when a form is invalid or an action is unavailable.
- **Loading:** replace label with a 16 dp `CircularProgressIndicator`; button stays disabled while pending. Applies to Save on the habit form.
- **Error:** buttons themselves do not show error; the associated field or a SnackBar does.

### Habit list tile (with completion toggle)
- **Default:** color bar, name, current streak badge, trailing toggle.
- **Pressed:** row state layer; navigates to detail on tap (toggle has its own hit target).
- **Toggle done:** filled circular check in habit color / `onPrimary`.
- **Toggle not done:** outlined circle in `outline`.
- **Disabled:** archived habits are not shown in the active list, so no disabled tile state in the main list.
- **Loading:** on first load, show shimmer/placeholder tiles (see Loading) not a spinner over content.
- **Error:** if the list fails to load, replace the list with the error state view (see below).

### Text fields (habit name, reminder time)
- **Default:** outlined input, label, helper text.
- **Focused:** primary outline, floating label.
- **Disabled:** dimmed, non-editable (reminder time when reminder is off).
- **Error:** `error` outline, error text below (for example, "Name is required" or "Name is too long").

### Toggles and switches (reminder enable, schedule days)
- **Default / selected / unselected** per Material 3 Switch and FilterChip.
- **Disabled:** when notification permission is denied, the reminder switch is disabled with helper text explaining why.

### Snackbars (transient feedback)
- Success and error feedback for save/delete/undo. Include an "Undo" action for destructive actions where feasible (delete habit).

## Empty states

Each empty state has an icon, a short title, one line of guidance, and (where relevant) a primary action.

- **No habits yet (home):** centered illustration/icon, title "No habits yet", body "Create your first habit to start a streak.", primary FilledButton "Add habit". This is `empty_habits_view.dart`.
- **Habit detail, no history:** heatmap renders all cells empty; a line reads "No completions yet. Mark today done to begin."
- **Archived list empty (if surfaced):** "No archived habits."
- Empty states must be reachable and correct before any feature is done (see phase verification).

## Loading states

- **Initial data load:** placeholder tiles (neutral `surfaceContainer` blocks) rather than a blank screen or full-screen spinner. Keep it brief since local reads are fast.
- **Save/delete in flight:** button loading state as above; do not block the whole screen.
- **Error loading:** centered icon, "Something went wrong", body "Please try again.", and a "Retry" button that re-reads the provider.

## Accessibility

- **Semantics labels:** every icon-only control has a `Semantics` label (for example, the completion toggle announces "Mark <habit name> done" / "Mark <habit name> not done"; heatmap cells announce the date and status). Streak badges announce "Current streak N days", "Best streak N days".
- **Large tap targets:** all interactive elements are at least 48 x 48 dp. The completion toggle and heatmap cells expand their hit test area to meet this even when visually smaller.
- **Text scaling:** support system text scale up to at least 1.3x without clipping or overflow. Use flexible layouts, `Wrap`, and `FittedBox`/ellipsis where appropriate. Long habit names truncate with ellipsis in tiles but show in full on the detail screen.
- **Contrast:** all text and essential icons meet WCAG AA (4.5:1 for body text, 3:1 for large text and UI components). Because habit colors vary, never place small text directly on a habit color; use neutral surfaces with the color as an accent. Verify the seed-generated schemes meet contrast in both light and dark.
- **Color is not the only signal:** completion is shown by both color and a check icon/fill shape, so color-blind users can distinguish done from not-done. The heatmap pairs fill with an accessible legend.
- **Focus and traversal:** logical focus order on forms; the Save button is reachable and its enabled/disabled state is announced.
- **Reduced motion:** keep animations short and non-essential; respect the platform reduce-motion setting for any transitions added later.
