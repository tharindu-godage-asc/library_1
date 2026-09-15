# Phase 1 — Theme & Core Widgets

## Objective

Establish the visual foundation (design tokens + reusable presentational
widgets) before any real feature is implemented, so `books`, `auth`,
`members`, and `borrowings` all build on the same shared system instead of
each screen inventing its own colors/spacing/components.

## What was built

### Design tokens — `lib/core/theme/`

Plain Dart classes, not merged directly into `ThemeData`, so any widget can
reference a token (`AppColors.primary`, `AppSpacing.md`) without knowing how
`ThemeData` is assembled. `ThemeData` itself is built *from* these tokens in
one place.

| File | Purpose |
|---|---|
| `app_colors.dart` | Color tokens extracted from the BooksnU design system (background gradient, primary gold, text colors, status colors for Borrowed/Returned/Overdue/Available) |
| `app_spacing.dart` | Spacing scale: xs(4) sm(8) md(12) lg(16) xl(24) xxl(32) |
| `app_radius.dart` | Corner radius scale: sm(8) md(14) lg(20) pill(999) |
| `app_text_styles.dart` | Type ramp — **Bricolage Grotesque** for display/headings, **Plus Jakarta Sans** for body/labels/captions (via `google_fonts`) |
| `app_theme.dart` | Assembles the above into a single `ThemeData` (`AppTheme.light`) |

### Reusable widgets — `lib/core/widgets/`

Presentational only — no data fetching, no navigation, no business rules.
This is what keeps them reusable across every feature.

| Widget | Purpose |
|---|---|
| `AppGradientScaffold` | Wraps a screen body in the cream→lilac gradient background used across all mockups; slots for app bar and bottom nav |
| `AppButton` | `primary` / `secondary` / `text` variants, loading + disabled states |
| `AppTextField` | Labeled input matching the fully-rounded field style from Login/Register mockups |
| `StatusBadge` | Pill badge for `available` / `borrowed` / `returned` / `overdue` — mirrors the `BorrowingStatus` values from the API reference |
| `AppBottomNavBar` | Presentational 4-tab bar (Borrowings / Books / Notifications / Profile) — takes `currentIndex` + `onTap`, no real navigation wired yet (that's the Routing phase) |

### Dependency added

- `google_fonts` — to load Bricolage Grotesque + Plus Jakarta Sans, matching
  the design system exactly rather than approximating with system fonts.

### Temporary scaffolding

- `main.dart` currently shows a `_ComponentGalleryScreen` — a throwaway
  screen that renders one of everything above, just to visually confirm the
  theme/widgets work before any real feature exists. **This gets deleted in
  Phase 2** once the real Books screen replaces it as `home:`.

## Decisions made

- **No `shared/` folder alongside `core/`** — the old project structure had
  both, which created ambiguity about where cross-feature UI belonged.
  `core/widgets/` is the single home for that now.
- **`providers/` folders exist in every feature already, empty** — Riverpod
  wiring is a later phase, but the folder shape is in place now so adding
  it later is "fill in a folder," not "restructure the project."
- **Fonts are `static final`, not `const`** — `GoogleFonts.*()` builds the
  `TextStyle` at runtime (resolving/caching the font asset), so it can't be
  a compile-time constant the way a hardcoded `TextStyle(...)` could.

## Open items for later phases

- Bundling font assets locally instead of resolving via CDN at first run —
  revisit in the Production Readiness phase.
- Dark mode is not implemented; `AppColors` currently has one value set,
  not light/dark pairs.

## Next phase

**Phase 2 — Books vertical slice**: `Book` entity → mock datasource →
repository → `BookCard` widget → real Books list/details screens replacing
the component gallery. Still plain `StatefulWidget`/`setState`, no Riverpod
yet — that conversion happens once there's a real feature to convert.
