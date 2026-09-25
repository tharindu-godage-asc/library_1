# Feature Spec: Books Backend Integration

branch: claude/feature/books-backend-integration
spec: _specs/books-backend-integration.md
owner: numustafa
date: 2026-09-25

---

## 0) Summary

**One-liner:** Replace BooksnU's mock, in-memory book catalogue with real book data fetched from Library.Api, showing a placeholder cover image for every book until the backend exposes an image URL.
**Why now:** Auth (Keycloak) and Members are already integrated with Library.Api, so Books is the next feature to move off local/mock data. Library.Api's book schema has no image URL property yet, so cover images are deliberately deferred rather than blocking the integration.
**Who is this for:** BooksnU end users browsing, searching and viewing books; the engineer(s) maintaining BooksnU's connection to Library.Api.
**Success looks like:** The Books screen, book details and search results show real books returned by Library.Api for a signed-in user; every book displays the placeholder cover; loading, empty and error states behave sensibly; and the app never breaks because an image URL is missing.

---

## 1) Goals and Non-Goals

### Goals
- Source the book list and single-book details from Library.Api instead of the mock catalogue.
- Follow the same approach already used for Members: the existing book data contract stays as-is and gains a remote-backed implementation that the app switches to.
- Send the signed-in user's access token with book requests, consistent with the Members integration.
- Map the backend's book fields onto the app's existing Book model, with a documented mapping for each field.
- Display the existing placeholder cover for every book, since the backend supplies no image URL.
- Keep the app's image handling ready for a real image URL so that adding one later is a small, isolated change.
- Provide clear loading, empty and error states on the Books, details and search screens.
- Document the change in BooksnU's existing `docs/phase-NN-*.md` convention.

### Non-Goals
- Adding an image URL property to Library.Api's book schema or serving book images — tracked as later work.
- Wiring Borrowings (borrow/return actions, availability changes) to the backend; those keep their current behavior in this pass.
- Creating, editing or deleting books from the app.
- Offline caching or persistence of the book catalogue.
- Server-side search, filtering or pagination unless the backend already provides them (see Open Questions); search continues to work on the loaded list.
- Physical-device or non-emulator network configuration.
- Deleting the existing mock book datasource — it stays in the repo, just unreferenced.

---

## 2) User Workflow

### Primary workflow
1. A signed-in user opens the Books screen.
2. The app requests the book list from Library.Api using the user's access token, showing a loading state meanwhile.
3. The books appear on the shelves and cards, each with the placeholder cover.
4. The user taps a book and sees its details (title, author, ISBN, published year, description, copies available), again with the placeholder cover.

### Secondary workflows
- **Search:** the user searches from the Books screen and sees matching books from the fetched list, each with the placeholder cover.
- **Backend unreachable or request fails:** the user sees an error state with a way to retry, not a blank or crashed screen.
- **Empty catalogue:** the user sees a friendly empty state rather than an empty shelf.
- **Expired session:** if the request is rejected as unauthorized, the app's existing session-refresh behavior applies; if the session cannot be recovered, the user returns to a signed-out state.
- **Later, when the backend adds an image URL:** real covers replace the placeholder with no change to the rest of the flow.

---

## 3) Exposed API Surface (What this feature exposes internally)

### 3.1 Functions

- **Name:** `getBooks`
  - **Purpose:** Returns the full list of books from Library.Api.
  - **Parameters:** None.
  - **Returns:** A list of Book, or a failure.
  - **Errors/warnings behavior:** Network, unauthorized and server errors surface as failures the screens can display. An empty list is a valid success, not an error.

- **Name:** `getBookById`
  - **Purpose:** Returns a single book's details from Library.Api.
  - **Parameters:** The book's identifier.
  - **Returns:** A Book, or a failure.
  - **Errors/warnings behavior:** A book that does not exist surfaces as a distinct "not found" failure; other failures behave as for `getBooks`.

Both functions keep the signatures the rest of the app already uses; only where the data comes from changes.

---

## 4) Data Contracts (backend book fields and mapping)

### 4.1 Inputs
- Library.Api's book list response.
- Library.Api's single-book response.
- The signed-in user's access token, supplied by the existing auth session.

### 4.2 Required fields (minimum contract)
Each backend book field maps to a Book field: identifier, title, author, ISBN, published year, total copies, available copies, and optional description.

- The exact backend field names, types and casing must be confirmed against Library.Api's book response before implementation and recorded in the phase doc (see Open Questions).
- Backend identifiers may be numeric or GUID; the app treats the identifier as an opaque string.
- Optional fields (description) may be absent or null and must not cause failures.
- Uniqueness: the book identifier is the unique key; duplicates in a response are not expected.

### 4.3 Output schema
- The app's Book model is unchanged.
- Its image URL is always empty for now, because the backend provides none; this is what triggers the placeholder cover.
- No fields are renamed or removed.

---

## 5) Business Rules

### 5.1 Access
- Book requests require a signed-in user; the access token is attached to every request, as with Members.

### 5.2 Availability
- A book is available when it has at least one available copy, using the backend's available-copies value. This rule stays on the Book model and is unchanged.

### 5.3 Cover images
- Every book displays the placeholder cover for now.
- If an image URL is ever present but fails to load, the placeholder is shown instead of a broken image.
- The placeholder is the app's existing one; no new artwork is required.

---

## 6) Architecture (must match existing BooksnU clean-architecture layering)

### 6.1 data/ (I/O boundary)
- A new remote book datasource implements the existing book datasource contract by calling Library.Api, mirroring how the remote Members datasource is built.
- The shared API client gains the book endpoints it needs.
- The book model handles converting backend responses to Book, tolerating missing optional fields, and treating the absent image URL as empty.

### 6.2 domain/
- The Book entity, repository contract and use cases stay as they are.

### 6.3 presentation/
- The provider that supplies the book datasource switches from the mock to the remote implementation, passing the access token provider the way the Members provider does.
- Screens and widgets consume the same providers and only need to handle loading, empty and error states correctly.
- The cover image widget keeps its placeholder fallback.

### 6.4 Wiring
- Flow: signed-in user → provider → repository → remote datasource → Library.Api → mapped Books → screens.
- The base URL and emulator networking setup already used for Members apply unchanged.

---

## 7) Edge Cases
- Backend returns an empty list.
- Backend returns a book with a missing or null description.
- Backend returns a book with unexpected or missing required fields — treated as a failure for that request, not a crash.
- Request times out or the backend is unreachable.
- Access token expired or rejected while loading books.
- Book identifier from a stale screen no longer exists on the backend.
- Available copies exceeding total copies in backend data.
- Very long titles or descriptions on cards with the placeholder cover.

---

## 8) Acceptance Criteria
- [ ] The Books screen shows books returned by Library.Api, not the mock catalogue.
- [ ] Book details show the backend data for the selected book.
- [ ] Every book, everywhere it appears, shows the placeholder cover.
- [ ] A book with no description renders correctly.
- [ ] Loading, empty and error states each appear appropriately, and retry works.
- [ ] Search works over the fetched books.
- [ ] Requests carry the signed-in user's access token; an unauthorized response is handled by the existing session behavior.
- [ ] Borrowing and other unrelated features behave exactly as before.
- [ ] The mock book datasource remains in the repo, unreferenced.
- [ ] The phase doc records the field mapping and the pending image-URL follow-up.

---

## 9) Test Plan

### 9.1 Golden fixture (required)
A small sample backend book list of two or three books: one with all fields, one with no description, one with zero available copies. Expected result: matching Books, with the image URL empty on all, and availability correct.

### 9.2 Unit tests
- Book model conversion from backend response: full book, missing description, missing image field, malformed response.
- Remote datasource: success, empty list, not found, unauthorized, network failure.
- Availability rule on the Book model.

### 9.3 Integration and manual tests
- Manual run on the Android emulator against a running Library.Api: Books list, details, search, empty backend, backend stopped, and expired session.
- Confirm the placeholder appears on every screen where a cover is shown.

---

## 10) References Used
- `_specs/keycloak-auth-integration.md`: format and depth of an existing feature spec, and the auth session this feature relies on.
- The remote Members datasource: the pattern for calling Library.Api with an access token.
- The existing Book entity and cover image widget: the current placeholder behavior.

---

## 11) Open Questions
- Q: What are Library.Api's exact book endpoints and response field names, and is the identifier numeric or GUID? Do they include pagination or server-side search?
- Decision owner / date: numustafa / before implementation starts.
- Yes books has pagination
- Q: Should the book list require sign-in on the backend, or can it be read anonymously?
- Decision owner / date: numustafa / before implementation starts.
- Book list doesnt need sign in
- Q: When the backend adds an image URL, will it be an absolute URL or a path relative to the API's base URL?
- it will be an absoulte url
- Decision owner / date: numustafa / when the backend change is scoped.
