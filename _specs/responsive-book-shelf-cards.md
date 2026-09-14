# Feature Spec: Responsive Book Shelf Cards

branch: claude/feature/responsive-book-shelf-cards
spec: _specs/responsive-book-shelf-cards.md
owner: TharinduGodage
date: 2026-09-14

---

## 0) Summary

**One-liner:** Make the Books screen's horizontal book shelves (`BooksScreen`) and their `BookVerticalCard` items fully responsive and constraint-safe, replacing fixed pixel dimensions with a sizing strategy that adapts to screen width and text scale.

**Why now:** Book cards currently appear vertically cropped on some devices, with title/author text cut off near the bottom. The layout relies on hard-coded dimensions (`110`, `180`, `200`) that don't scale across phones, tablets, or landscape orientation, and don't account for accessibility text-scaling.

**Who is this for:** Internal Flutter maintainers of this app; the fix benefits all end users viewing the Books tab.

**Success looks like:** No clipped cover or text at any standard device width or system text-scale factor; cards visibly scale between small phones and tablets/landscape; no hard-coded `110`/`180`/`200`-style magic numbers remain in the touched widget tree.

---

## 1) Goals and Non-Goals

### Goals
- Replace the fixed-height `SizedBox` shelves and fixed-width `BookVerticalCard` with a constraint-safe layout that sizes itself from content and available width instead of hard-coded pixel values.
- Guarantee the text block (title, author, optional due-date row) always has enough height to render without clipping, including at larger system font-scale settings.
- Introduce a reusable, centralized sizing/constants strategy (following the existing `AppSpacing` pattern) so shelf and card dimensions are defined once and reused everywhere they're needed.
- Document and apply a sensible, consistent book-cover aspect ratio.
- Ensure cards scale sensibly across phone, tablet, and landscape widths within defined min/max bounds.

### Non-Goals
- Redesigning the visual style/branding of `BookVerticalCard` (colors, elevation, iconography) beyond what's required for responsive sizing.
- Changing the shelves' data source, sorting, or business logic (`_newestPicks`, `recommended`, etc. in `BooksScreen`).
- Touching unrelated card widgets in this feature, e.g. `BookCard` used in search results (`lib/features/books/presentation/widgets/book_card.dart`), unless later found to share the same root cause.
- Implementing real book cover images (the current placeholder icon-based cover stays a placeholder; only its layout/aspect-ratio behavior is in scope).

---

## 2) User Workflow

### Primary workflow
1. User opens the Books tab (`BooksScreen`) and views the "Newest Picks" and "Recommended for You" horizontal shelves.
2. Each `BookVerticalCard` renders its cover, title (up to 2 lines), author (1 line), and — if applicable — a "Due in N days" row, fully visible with no clipping, regardless of device width or system font-scale setting.
3. User scrolls each shelf horizontally; card sizing stays consistent and legible throughout.

### Secondary workflows (optional)
- User rotates the device to landscape, or opens the app on a tablet: cards and shelves scale up proportionally within defined bounds rather than staying pinned at phone-sized dimensions.
- User has a large system font-scale/accessibility setting enabled: card text still fits without overflow errors or visual cropping.

---

## 3) Widget API Surface (What you expose)

### 3.1 Widgets
For each widget introduced or changed:

**`BookVerticalCard`** (existing, to be revised)
- Constructor parameters: `book` (required `Book`), `onTap` (required `VoidCallback`), `dueInDays` (optional `int`)
- No new required parameters expected; any new optional parameters (e.g. an explicit width override) must have a sensible default derived from the shared sizing strategy.
- Output: a self-sizing card widget that no longer depends on being wrapped in a fixed-height `SizedBox` to render correctly.

**Sizing strategy helper(s)** (new)
- A small set of constants and/or a helper function (naming and exact shape decided at implementation time) that computes card width and shelf height from `BuildContext`/`MediaQuery` width, clamped to sensible min/max bounds.
- Consumed by both `BooksScreen` shelf sections and `BookVerticalCard` itself, so the two stay in sync without duplicated literals.

---

## 4) Data Contracts (Book entity + rendering inputs)

### 4.1 Inputs
- `Book` entity (`lib/features/books/domain/entities/book.dart`) — source of `title`, `author`, and (in future) cover image data. No schema changes required for this spec.
- `dueInDays` — optional `int` passed down from `BooksScreen`'s borrowings lookup; purely presentational.

### 4.2 Required fields (minimum contract)
- `book.title` (String) — rendered up to 2 lines, ellipsized.
- `book.author` (String) — rendered up to 1 line, ellipsized.
- `dueInDays` (int?) — when present, renders a small warning-dot + "Due in N days" row.

### 4.3 Output
- No new persisted output; this spec only changes widget rendering/layout behavior. No new fields are added to `Book`.

---

## 5) Business Rules

### 5.1 Card sizing
- Card width is derived from available screen width, not a fixed literal, and clamped between a minimum (comfortable on the smallest supported phone) and a maximum (so cards don't grow unreasonably large on tablets/landscape).
- Shelf height is derived from the card's own intrinsic/aspect-ratio-driven height, not set independently as an unrelated fixed `SizedBox` value.

### 5.2 Book cover aspect ratio
- The cover area uses a fixed, documented aspect ratio (rather than an unconstrained `Expanded`), matching a realistic book-cover proportion (roughly 2:3, consistent with common paperback/hardcover ratios) so cover size is predictable and doesn't consume "leftover" space that the text block needs.

### 5.3 Text/content reservation
- The text block (title + author + optional due row) is guaranteed a minimum height sufficient for its maximum content (2-line title + 1-line author + due row) at the largest supported system text-scale factor, so it is never compressed below what it needs.

---

## 6) Architecture

### 6.1 `lib/features/books/presentation/widgets/book_vertical_card.dart`
- Revised to size itself via the shared aspect-ratio/constraint strategy instead of a fixed `width: 110` and an `Expanded` cover with no reserved text height.

### 6.2 `lib/core/theme/` (constants)
- New sizing constants (card min/max width, cover aspect ratio, related spacing) added alongside the existing `AppSpacing` class (`lib/core/theme/app_spacing.dart`), following that file's established pattern for centralizing literals instead of scattering them across widgets.

### 6.3 `lib/features/books/presentation/screens/books_screen.dart`
- The two shelf sections ("Newest Picks", "Recommended for You") updated to derive their height from the card's own sizing strategy rather than independently hard-coded `SizedBox(height: 200)` / `SizedBox(height: 180)` values.

### 6.4 Reusable sizing strategy
- A single source of truth for card/shelf dimensions consumed by both the screen and the card widget, so future shelves (if added) automatically inherit correct, responsive sizing without re-deriving or duplicating constants.

---

## 7) Edge Cases

- Very long book titles or author names at max line count (ellipsis must trigger, not overflow/clip).
- Large system font-scale / accessibility text-scaling settings.
- Very narrow phone widths (must not go below the minimum comfortable card width).
- Very wide tablets, foldables, or landscape orientation (must not exceed the maximum card width, and must not look sparse/oversized).
- Shelves with very few items (e.g. 1 card) — horizontal `ListView` layout must remain correct.
- `dueInDays` absent vs. present — card height must stay visually consistent within a shelf where some cards show the due row and others don't (or the spec should note if this causes uneven card heights and how that's handled).

---

## 8) Acceptance Criteria

Checklist that can be tested:
- [ ] No clipped cover or text in `BookVerticalCard` at default and maximum supported system text-scale settings.
- [ ] No hard-coded `110`, `180`, or `200` literals remain in `book_vertical_card.dart` or the two shelf sections in `books_screen.dart`.
- [ ] Card width visibly scales between a small-phone-width simulation and a tablet-width simulation, staying within defined min/max bounds.
- [ ] Book cover renders at a consistent, documented aspect ratio rather than an unconstrained `Expanded` fill.
- [ ] Existing shelf behavior (scrolling, item tap navigation, "See all" actions) is unaffected.

---

## 9) Test Plan

### 9.1 Golden fixture (required)
Widget test rendering `BookVerticalCard` with a fixed sample `Book` (long title, long author, with and without `dueInDays`) as the baseline fixture for layout assertions.

### 9.2 Unit/widget tests
- Render `BookVerticalCard` at multiple `MediaQuery` widths (small phone, standard phone, tablet) and assert no layout overflow/exception.
- Render at multiple `textScaleFactor` values (1.0 up to the app's max supported scale) and assert no overflow/exception.
- Assert no remaining literal `110`/`180`/`200` values in the changed files (code-review-level check, not necessarily automated).

### 9.3 Integration/manual verification
- Manual check on at least one narrow phone simulator/device and one tablet or landscape simulator/device to visually confirm no clipping and correct scaling. Per this project's testing preference, this manual device verification will be performed by the user, who will report back the result rather than having it driven automatically.

---

## 10) References Used (required)

- `_specs/template.md`: structure followed for this spec's section layout.
- `lib/core/theme/app_spacing.dart`: existing constants-class pattern reused as the model for the new sizing constants.
- `lib/features/books/presentation/screens/books_screen.dart` (current shelf sections) and `lib/features/books/presentation/widgets/book_vertical_card.dart` (current card implementation): source of the root-cause analysis and scope for this spec.

---

## 11) Open Questions

- Q: What are the final numeric min/max card width bounds, and the exact book-cover aspect ratio (e.g. 2:3 vs. another standard ratio)?
  Decision owner / date: To be decided during implementation planning, not fixed in this spec. Use international aspect ratios which are standardized
- Q: Should shelves with a mix of cards showing/not-showing the `dueInDays` row enforce uniform card height across the shelf, or is per-card height variance acceptable? Need a fixed height for all cards
  Decision owner / date: To be decided during implementation planning.
