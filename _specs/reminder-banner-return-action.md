# Feature Spec: Reminder Banner Return Action

branch: claude/feature/reminder-banner-return-action
spec: _specs/reminder-banner-return-action.md
owner: TharinduGodage
date: 2026-09-12

---

## 0) Summary

**One-liner:** On the Books home screen's due-date reminder banner, replace the "Renew" button (currently a non-functional placeholder) with a "Return" button that takes the user straight to the details screen for the specific borrowing that's due soon.
**Why now:** The app has no renewal flow, and the current "Renew" button is a stub that does nothing when tapped. Users who see the reminder and want to act on it have no way to do so from the banner.
**Who is this for:** Library members using the app to track and manage their borrowed books.
**Success looks like:** Tapping the button on the reminder banner reliably opens the details screen for the exact borrowing that triggered the reminder, with no dead-end or wrong-item navigation.

---

## 1) Goals and Non-Goals

### Goals
- Change the reminder banner's action button label from "Renew" to "Return".
- Wire the button so tapping it navigates the user to the Borrowings tab/page, landing directly on the details screen for the specific borrowing that is due soon (the one described in the banner text).
- Ensure the navigation targets the correct borrowing when a user has multiple active borrowings (not just any borrowing, but the one shown in the banner).

### Non-Goals
- Implementing an actual "return this book" action (e.g., marking the borrowing as returned) as part of this change — the button only navigates to the borrowing's details screen, where existing return functionality (if any) already lives.
- Implementing a book renewal feature. Renewal is being removed from this surface, not improved.
- Redesigning the reminder banner's visuals, copy about due dates, or when the banner appears.
- Changing behavior anywhere else the word "Renew" might appear outside this banner.

---

## 2) User Workflow

### Primary workflow
1. User opens the app and lands on the Books home screen.
2. Because they have a borrowing due soon, the reminder banner is shown (e.g., "<Book Title> is due in <N> days").
3. User taps the button on the banner, which now reads "Return" instead of "Renew".
4. The app navigates the user to the Borrowings section and opens the details screen for that specific borrowing (the one referenced in the banner).
5. User can view the borrowing's details and take any existing return-related action from there.

### Secondary workflows (optional)
- If the underlying borrowing can no longer be resolved (e.g., it was returned or removed between when the banner was rendered and when the button was tapped), the app should fail gracefully (see Edge Cases) rather than navigating to a broken or empty screen.

---

## 3) S****l API Surface (What you expose)
N/A — this feature is a UI label/navigation change within the mobile app, not an exposed API/function surface.

### 3.1 Functions
N/A

## 4) Data Contracts (DF schemas + join keys)
N/A — no dataframe or backend schema changes. The feature relies on the existing borrowing/book data already loaded for the Books home screen.

### 4.1 Inputs
- The existing borrowing used to compute "which borrowing is due soonest" for the reminder banner.
- The book associated with that borrowing (currently used to display the book title in the banner).

### 4.2 Required columns (minimum contract)
- The reminder banner's underlying data must retain (or gain, if not already present) a reference to the specific borrowing's identifier, so the "Return" action can navigate to that exact borrowing's details screen rather than a generic list.

### 4.3 Output schema
N/A

## 5) Business Rules
### 5.1 Portfolio filtering
N/A

### 5.2 ITM/OTM classification
N/A

### 5.3 Pricing / Greeks
N/A

## 6) Architecture (must match TECHNICAL_BLUEPRINT)
N/A — this template section targets a data-pipeline architecture (clients/constants/utils/orchestration) that doesn't apply to this mobile UI/navigation feature. See Section 2 (User Workflow) for the intended flow instead.

### 6.1 clients/ (I/O boundary)
N/A

### 6.2 constants/ (values only)
N/A

### 6.3 utils/ (pure transforms, vectorized)
N/A

### 6.4 orchestration layer (e.g., recon/ or S****l entrypoints)
N/A

## 7) Edge Cases
- The borrowing shown in the reminder banner is returned, cancelled, or otherwise no longer valid by the time the user taps the button — define what the details screen (or the navigation itself) should show instead of a blank/error state.
- The user has no borrowings due soon, so the banner (and its button) never appears — out of scope, but confirms the button is only reachable when a valid borrowing exists.
- The user taps the button multiple times quickly (double-tap) — should not cause duplicate navigation or a broken navigation stack.
- The reminder banner is showing data for a borrowing that isn't the same one navigated to (a mismatch between "soonest due" borrowing and the one actually opened) — must be prevented.

---

## 8) Acceptance Criteria
Checklist that can be tested:
- [ ] The button on the reminder banner reads "Return" instead of "Renew".
- [ ] Tapping the button navigates to the Borrowings section.
- [ ] The screen shown after navigation is the details screen for the specific borrowing referenced in the banner (not the general borrowings list, and not a different borrowing).
- [ ] No leftover references to a "Renew" action remain for this banner (label, semantics/accessibility text, etc.).
- [ ] Navigating back from the borrowing details screen returns the user to the Books home screen as expected.

---

## 9) Test Plan
### 9.1 Golden fixture (required)
A user with at least one active borrowing due within the reminder window (e.g., due in 2 days), with a known borrowing identifier and book title, used to verify both the banner's displayed text and the destination screen after tapping "Return".

### 9.2 Unit tests (utils/)
N/A — no pure data transforms are introduced by this feature.

### 9.3 Integration tests (orchestration)
- Happy path: user with one qualifying borrowing taps "Return" and lands on that borrowing's details screen.
- Multiple active borrowings: only the soonest-due one is targeted by the banner's button, verified by checking the destination matches that specific borrowing.
- Borrowing becomes invalid/missing right before tap: verify graceful handling instead of a crash or blank screen.

## 10) References Used (required)
- lib/features/books/presentation/widgets/reminder_banner.dart: current "Renew" button implementation being relabeled and rewired.
- lib/features/books/presentation/screens/books_screen.dart: hosts the reminder banner and currently wires its button to a placeholder (`_todo('Renew')`); also computes which borrowing is "soonest due".
- lib/core/navigation/app_router.dart: defines the existing Borrowings routes, including the borrowing details route, that the "Return" button should navigate to.

## 11) Open Questions
- Q: Should the button's underlying widget parameter/callback name (e.g., anything referencing "renew" in the reminder banner's API) be renamed to reflect "return", or is this purely a visible label + navigation change? Both
- Decision owner / date: TharinduGodage — TBD

- Q: If the specific borrowing can no longer be resolved when the button is tapped, should the app show an error message, silently fall back to the general Borrowings list, or something else? Once the borrowing has been resolved it must be hidden
- Decision owner / date: TharinduGodage — TBD
