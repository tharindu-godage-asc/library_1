# Feature Spec: Borrowings Backend Integration

branch: claude/feature/borrowings-backend-integration
spec: _specs/borrowings-backend-integration.md
owner: numustafa
date: 2026-09-25

---

## 0) Summary

**One-liner:** Replace BooksnU's mock, in-memory borrowings with real borrow, return and "my borrowings" data from Library.Api, so that borrowing a book actually reduces its availability on the server.
**Why now:** Auth, Members and Books are already integrated with Library.Api. Borrowings is the last mock-backed feature, and it currently leaves a gap: borrow and return no longer change a book's visible availability after a refetch, because the books integration made that write a no-op.
**Who is this for:** BooksnU end users borrowing and returning books and tracking due dates; the engineer(s) maintaining BooksnU's connection to Library.Api.
**Success looks like:** A signed-in user can borrow an available book, see it in their borrowings with the correct due date, return it, and see the book's availability change accordingly, with all of that surviving an app restart and matching what the backend holds.

---

## 1) Goals and Non-Goals

### Goals
- Source the signed-in user's borrowings, and single borrowing details, from Library.Api instead of the mock list.
- Perform borrow and return through Library.Api so the backend owns the borrowing record and the book's available-copies count.
- Follow the pattern already used for Members and Books: the existing borrowing data contract stays as-is and gains a remote-backed implementation that the app switches to, sending the signed-in user's access token.
- Resolve the "who is the current member" question so borrowings are always the caller's own, without the app inventing member identifiers.
- Decide where the borrowing rules live (see Business Rules) and make the app surface the backend's rejections as clear, user-friendly messages.
- Keep the overdue status correct for borrowings whose due date has passed.
- Keep the reminder banner on the Books home screen working from real data.
- Provide clear loading, empty and error states on the borrowings screens.
- Document the change in BooksnU's existing `docs/phase-NN-*.md` convention.

### Non-Goals
- Changing what Library.Api enforces or adding endpoints to it; where the backend lacks something, this spec records the gap rather than working around it silently.
- Admin features such as viewing other members' borrowings.
- Fines, renewals, reservations or holds.
- Push notifications or background reminders beyond the existing in-app reminder banner.
- Offline caching of borrowings.
- Physical-device or non-emulator network configuration.
- Deleting the existing mock borrowing datasource — it stays in the repo, unreferenced.
- Backfilling book descriptions or cover images (tracked separately in the books work).

---

## 2) User Workflow

### Primary workflow
1. A signed-in user opens a book's details and taps Borrow.
2. The app asks Library.Api to create the borrowing and shows a loading state meanwhile.
3. On success the user sees confirmation, and the book's available copies reflect the change.
4. The user opens My Borrowings and sees the new borrowing with its borrowed date, due date and status.
5. The user opens a borrowing's details and taps Return.
6. The app asks Library.Api to return it; the borrowing shows as returned and the book's availability goes back up.

### Secondary workflows
- **Borrow rejected:** the user is told plainly why (no copies available, already borrowing this book, borrowing limit reached, account inactive) and nothing changes.
- **Return rejected:** the user is told if the borrowing was already returned or no longer exists.
- **Overdue:** a borrowing past its due date is shown as overdue until it is returned.
- **Reminder banner:** when a borrowing is due soon or overdue, the Books home screen banner shows it, with its return action still working.
- **Backend unreachable or request fails:** the user sees an error state with a retry, and no local state is left half-changed.
- **Expired session:** the existing session-refresh behavior applies; if the session cannot be recovered, the user returns to a signed-out state.
- **Empty history:** a user with no borrowings sees a friendly empty state.

---

## 3) Exposed API Surface (What this feature exposes internally)

### 3.1 Functions

- **Name:** `getBorrowingsForMember`
  - **Purpose:** Returns the signed-in user's borrowings.
  - **Parameters:** The member identifier the app already passes; the backend resolves the caller from the token (see Open Questions).
  - **Returns:** A list of Borrowing, or a failure.
  - **Errors/warnings behavior:** An empty list is a success. Network, unauthorized and server errors surface as failures the screens can display.

- **Name:** `getBorrowingById`
  - **Purpose:** Returns one borrowing's details.
  - **Parameters:** The borrowing identifier.
  - **Returns:** A Borrowing, or a failure.
  - **Errors/warnings behavior:** A missing borrowing (or one belonging to someone else) surfaces as "not found".

- **Name:** `createBorrowing` (borrow a book)
  - **Purpose:** Borrows a book for the signed-in user through the backend.
  - **Parameters:** The book identifier; due date is determined by the backend or agreed with it (see Open Questions).
  - **Returns:** The created Borrowing, or a failure.
  - **Errors/warnings behavior:** Backend rejections (unavailable, duplicate, limit, inactive member) map to the app's existing distinct failures so users get specific messages.

- **Name:** `updateBorrowing` (return a book)
  - **Purpose:** Marks a borrowing returned through the backend.
  - **Parameters:** The borrowing identifier.
  - **Returns:** The updated Borrowing, or a failure.
  - **Errors/warnings behavior:** Already-returned and not-found map to existing distinct failures.

The existing borrow and return actions keep their current names and how screens call them; what changes is that the backend, not the app, applies the result.

---

## 4) Data Contracts (backend borrowing fields and mapping)

### 4.1 Inputs
- Library.Api's borrowings list response for the caller.
- Library.Api's single borrowing response.
- Library.Api's borrow and return responses.
- The signed-in user's access token, supplied by the existing auth session.

### 4.2 Required fields (minimum contract)
Each backend borrowing field maps onto a Borrowing field: identifier, book identifier, member identifier, borrowed date, due date, optional returned date, and status.

- Exact backend field names, types, date format and time-zone handling must be confirmed against Library.Api before implementation and recorded in the phase doc.
- Identifiers are treated as opaque strings (the backend uses GUIDs).
- The backend's status values must be mapped onto the app's borrowed, returned and overdue statuses, including what the backend does when a due date has passed.
- The list response may be a paged envelope, as the books list is.
- The borrowing's book identifier must match the identifiers of the books now coming from the backend, so a borrowing can be shown with its book's title.

### 4.3 Output schema
- The app's Borrowing model is unchanged.
- The book title and cover shown on borrowing rows continue to come from the Books data, looked up by book identifier.

---

## 5) Business Rules

### 5.1 Rules that exist today in the app
The app currently enforces these itself before calling storage: the member must be active, the book must have an available copy, the user must not already hold the same book, the user may hold at most three active borrowings, and the loan period is fourteen days. A returned borrowing cannot be returned again.

### 5.2 Where the rules live after this feature
- The backend is the source of truth. It must enforce these rules, because it is the only place that can do so safely under concurrent use.
- Whether the app keeps its own pre-checks for faster feedback is a decision recorded under Open Questions. Whatever is decided, the backend's answer always wins, and the app must never show a borrow as successful unless the backend confirmed it.

### 5.3 Status
- A borrowing is overdue when it is not returned and its due date has passed. Where this is computed (backend or app) is confirmed in the contract step; the displayed result must be the same either way.

### 5.4 Availability
- Book availability shown in the app must reflect the backend after a borrow or return, so the Books list and details are refreshed after either action.

---

## 6) Architecture (must match existing BooksnU clean-architecture layering)

### 6.1 data/ (I/O boundary)
- A new remote borrowing datasource implements the existing borrowing datasource contract by calling Library.Api, mirroring the remote Members and Books datasources.
- The shared API client gains the borrowing endpoints it needs.
- The borrowing model converts backend responses to Borrowing, including date parsing and status mapping.
- Backend rejections are translated into the app's existing distinct failures.

### 6.2 domain/
- The Borrowing entity, repository contract and use cases stay in place. The borrow and return use cases stop directly changing book copy counts, since the backend does that as part of the borrow or return. This is the main structural change and must be reviewed carefully against the existing use-case rules.
- The Books repository's copy-count update, which currently does nothing, is no longer needed by these flows.

### 6.3 presentation/
- The provider that supplies the borrowing datasource switches from the mock to the remote implementation, passing the access token provider as Members and Books do.
- After a borrow or return, the borrowings list, the affected book and the book list are refreshed so screens show backend truth.
- Screens keep their existing layout and only need correct loading, empty and error handling.

### 6.4 Wiring
- Flow: signed-in user → provider → use case → repository → remote datasource → Library.Api → mapped Borrowings → screens.
- Base URL and emulator networking setup already used for Members and Books apply unchanged.

---

## 7) Edge Cases
- User has no borrowings.
- Borrow attempted on a book whose last copy was just taken by someone else.
- Borrow or return request times out; the user retries and must not create a duplicate borrowing.
- Return attempted twice, including from two screens.
- Borrowing refers to a book that no longer exists.
- Backend and device clocks disagree about whether a borrowing is overdue.
- Due-date and time-zone differences between backend and device.
- Access token expires between opening a screen and confirming an action.
- Backend returns an unexpected status value.
- Borrowing limit reached while another borrowing is being created.
- The signed-in identity has no matching member record yet on first use.

---

## 8) Acceptance Criteria
- [ ] My Borrowings shows the signed-in user's borrowings from Library.Api, not the mock list.
- [ ] Borrowing an available book creates a backend borrowing and lowers that book's availability, visible after a refresh and after an app restart.
- [ ] Returning a borrowing marks it returned and raises the book's availability, visible after a refresh and after an app restart.
- [ ] Each borrow rejection (unavailable, already borrowed, limit reached, inactive account) shows its own clear message and changes nothing.
- [ ] Returning an already-returned borrowing shows a clear message.
- [ ] Overdue borrowings display as overdue.
- [ ] The reminder banner reflects real borrowings and its return action works.
- [ ] Loading, empty and error states each appear appropriately, and retry works.
- [ ] Requests carry the signed-in user's access token; an unauthorized response is handled by the existing session behavior.
- [ ] A user can only see and act on their own borrowings.
- [ ] The mock borrowing datasource remains in the repo, unreferenced.
- [ ] The phase doc records the field and status mapping and any backend gaps found.

---

## 9) Test Plan

### 9.1 Golden fixture (required)
A small sample backend borrowings list: one active borrowing due in the future, one active borrowing past its due date, and one returned borrowing. Expected result: three Borrowings with statuses borrowed, overdue and returned, correct dates, and the returned date present only on the third.

### 9.2 Unit tests
- Borrowing model conversion: each status, missing returned date, malformed date, unexpected status.
- Remote datasource: list success, empty list, not found, unauthorized, network failure, and each borrow and return rejection mapped to the right failure.
- Borrow and return use cases with the copy-count changes removed: rejections pass through, success returns the backend's borrowing.
- Overdue determination.

### 9.3 Integration and manual tests
- Manual run on the Android emulator against a running Library.Api: borrow, see it listed, check book availability dropped, return, check availability restored, restart the app and confirm persistence.
- Manual checks for each rejection path, including borrowing the same book twice and reaching the three-borrowing limit.
- Backend stopped mid-action, and expired session.
- Reminder banner with a due-soon and an overdue borrowing.

---

## 10) References Used
- `_specs/books-backend-integration.md` and `docs/phase-14-books-backend-integration.md`: the pattern followed, and the borrow/return availability gap this feature closes.
- `_specs/keycloak-auth-integration.md`: the auth session and access token this feature relies on.
- The remote Members and Books datasources: the pattern for calling Library.Api with an access token.
- The existing borrow and return use cases and mock borrowing datasource: the current rules and behavior being moved to the backend.

---

## 11) Open Questions
- Q: What are Library.Api's exact borrowing endpoints, request and response shapes, status values, and date format? Is the list paged?
- No pagination, endpoints are,
- {{base_url}}/members/{{memberid}}/borrowings
- {{base_url}}/borrowings/{{borrowingid}}/return
- {{base_url}}/borrowings
- Decision owner / date: numustafa / before implementation starts.
- Q: How does the app identify the current member? The Members feature resolves "me" from the token; do borrowings do the same, and what happens to the member identifier the app currently passes around?
- From the logged in user tokn/creds, please check it
- Decision owner / date: numustafa / before implementation starts.
- Q: Who sets the due date and loan length — the backend or the app?
- Backend must do it, its 14 days
- Decision owner / date: numustafa / before implementation starts.
- Q: Does the backend enforce all current rules (availability, duplicate, three-borrowing limit, inactive member) and return distinguishable errors for each? If not, which gaps does the backend need to close? Yes it does
- Decision owner / date: numustafa / before implementation starts.
- Q: Does the backend decrement and restore available copies as part of borrow and return? (This spec assumes yes.) Yes
- Decision owner / date: numustafa / before implementation starts.
- Q: Should the app keep client-side pre-checks for faster feedback, or rely entirely on the backend's rejections? can rely on front end pre checks
- Decision owner / date: numustafa / at planning.
