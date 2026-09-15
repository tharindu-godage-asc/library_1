# BooksnU Evaluation Questions and Answers

Use these as viva/interview preparation. The answers describe the current implementation first, then the strongest engineering justification or next step where the implementation has a known limitation.

## Architecture and Design

### 1. Why did you use Clean Architecture per feature instead of putting all code in screens?

**Answer:** Each feature is split into `domain`, `data`, and `presentation`. The domain contains entities, repository contracts, and use cases; the data layer implements those contracts and handles JSON/storage; the presentation layer contains screens and Riverpod providers. This keeps UI code independent of data-source details and makes a future API replacement localized to the data layer. The dependency direction is `presentation -> domain <- data`, so the domain does not depend on Flutter or infrastructure.

### 2. What is the composition root in this application?

**Answer:** The feature provider files under `presentation/providers/` act as composition roots. For example, `bookRepositoryProvider` creates `BookRepositoryImpl` and injects `BookLocalDataSource`, while the use-case provider injects the repository. Riverpod owns those dependencies and makes them replaceable in tests through provider overrides. `main.dart` only creates the global `ProviderScope` and configures the app; it does not manually construct the feature graph.

### 3. Why do repositories return `Either<Failure, T>` when providers already expose `AsyncValue`?

**Answer:** `Either` represents an expected domain/data operation result without throwing through application layers. The repository translates data-source exceptions into typed `Failure` values. The provider unwraps the `Either` once and throws the `Failure`, allowing Flutter/Riverpod to represent loading, success, and error uniformly as `AsyncValue`. This keeps exception translation at the repository boundary and keeps screens unaware of infrastructure exceptions.

### 4. What is the difference between a domain entity and a data model here?

**Answer:** `BookModel` is responsible for JSON mapping and extends the domain `Book` shape for convenience. `fromJson`, `toJson`, `fromEntity`, and `toEntity` define the conversion boundary. In a stricter design, the model would not extend the entity and would be a separate class, because inheritance can couple persistence representation to the domain representation. The current approach is acceptable for this small app but separation would reduce future schema pressure.

### 5. Why are some providers `keepAlive` and others auto-disposed?

**Answer:** Long-lived infrastructure and lifecycle state use `keepAlive`: the book data source/repository, auth controller, bootstrap provider, and borrowing data source/repository. This prevents cold-start or shared data from being recreated unexpectedly. Action controllers such as borrow/return are intentionally auto-disposed because their state is only meaningful while the action screen is open. A provider should be kept alive only when its state has application-wide or cache-like meaning.

## Startup, Authentication, and Security

### 6. Walk through the cold-start flow from `main()` to the first meaningful screen.

**Answer:** `main()` creates a global `ProviderScope` and starts `LibraryApp`. The router starts at `/splash`. `appBootstrapProvider` checks the onboarding preference and, when onboarding is complete, restores the persisted session through `AuthController`. It also runs a 2.4-second minimum hold concurrently for branding. The router listens to bootstrap and auth changes, then redirects to onboarding, login, or home. The bootstrap provider is kept alive and uses `ref.read` for auth so a later login/logout does not replay the splash decision.

### 7. Why must bootstrap use `ref.read` instead of `ref.watch` for the auth provider?

**Answer:** Bootstrap is a one-time cold-start decision. If it watched auth, every login or logout would invalidate/recompute bootstrap, including the 2.4-second delay, and could show the splash again during an active session. Runtime auth transitions are handled by the router's refresh notifier and redirect guard. `ref.read` deliberately makes the cold-start decision independent from later auth mutations.

### 8. Is authentication actually secure in this implementation?

**Answer:** The persisted session fields are stored through `flutter_secure_storage`, which is appropriate for platform-protected local storage. However, this is a mock authentication system: seeded passwords are plain text in memory, tokens are fabricated, and expiry is not enforced. A production implementation would authenticate against a backend, never store plaintext passwords, store only the necessary token material, validate expiry, implement refresh/revocation, and handle token theft and logout semantics.

### 9. What happens if secure-session storage is only partially written or contains an invalid role/expiry?

**Answer:** `read()` checks for missing fields and clears the entire record if it is incomplete, treating it as signed out rather than crashing. However, `int.parse(expiresIn)` and `UserRole.values.byName(roleStr)` can still throw for malformed values; the repository converts that into an `UnexpectedFailure`, and bootstrap fails safe to login. A stronger storage boundary would validate and catch malformed values explicitly, clear corrupted data, and return a controlled signed-out result.

### 10. Identify a real authentication bug or product inconsistency in the current code.

**Answer:** `login()` persists the returned session, but `register()` returns a session without saving it. Therefore a newly registered user is considered signed in for the current process but becomes signed out after a cold start. The intended fix depends on product policy: either persist the session after successful registration, or deliberately require a separate login and make that behavior explicit in the UI. It should be covered by an integration test.

## Navigation and State

### 11. Why was `StatefulShellRoute.indexedStack` chosen for the home tabs?

**Answer:** Each bottom-navigation tab owns a branch navigator that remains alive in the indexed stack. Switching between Borrowings, Books, and Profile therefore preserves scroll position, search text, and in-progress UI state. A plain `context.go()` to another tab route replaces the current location and previously caused that state to be lost. The branch order matches the bottom-nav item order so `currentIndex` remains a direct mapping.

### 12. When should this app use `goBranch`, `context.push`, and `context.go`?

**Answer:** `goBranch` is for switching bottom-nav branches. `context.push` is for drilling into a book, borrowing, search results, or notifications so the back stack is preserved. `context.go` is for an intentional root reset, such as returning to the Books root from an empty/error action, and for the onboarding completion exception. Using `context.go` for every tab switch would destroy the state-preservation property of the shell.

### 13. How does the router react when authentication changes without every screen navigating manually?

**Answer:** `router()` creates a `ChangeNotifier` refresh bridge. It listens to both `appBootstrapProvider` and `authControllerProvider`; a provider change calls `refresh.ping()`, causing go_router to rerun `redirect`. The redirect sends signed-in users away from login routes and signed-out users away from home routes. This centralizes stack protection and prevents multiple screens from implementing conflicting auth navigation.

### 14. What are the current deep-link limitations?

**Answer:** The route paths exist in go_router, including book and borrowing detail routes, but Android and iOS platform registration for the custom scheme was reverted. Consequently external links, notifications, or shared URLs cannot reliably launch the app into those routes. A production solution needs Android intent filters and iOS URL types or universal links, plus tests for cold and warm deep-link handling and authentication redirects.

### 15. How is unsaved form data protected from accidental navigation?

**Answer:** `RegisterScreen` tracks whether any field is non-empty and uses `PopScope` to guard the system back gesture/button. The in-app login link uses the same discard-confirmation flow. If the form is clean it pops immediately; if dirty it shows `AppConfirmSheet`. Guarding only the visible link would miss OS back navigation, so `PopScope` is the important part.

## Data Flow and Business Rules

### 16. What happens when a user borrows or returns a book?

**Answer:** The action controller sets an `AsyncLoading` state and invokes a domain use case. The use case coordinates the relevant repositories and applies business rules such as availability, borrowing limit, member status, and return state. On success, the controller stores the result and invalidates the affected book list, book detail, borrowing list, and detail providers. This causes stale views to refetch instead of manually mutating several independent caches.

### 17. Why does `myBorrowings` watch auth state, and what problem does that prevent?

**Answer:** It derives the member ID from the current `AuthController` session on every rebuild. If another member signs in during the same process, the provider refetches using the new user ID instead of reusing the previous member's data. If there is no session it returns an empty list. This is a data-isolation safeguard, although a production implementation should also clear or scope all relevant caches on account changes.

### 18. What is the limitation of the bundled JSON data source?

**Answer:** `BookLocalDataSource` loads `assets/data/books.json` once and caches decoded maps in memory. Reads are fast and deterministic, and `updateBook` mutates that in-memory list only; it does not persist changes back to the asset or a database. This is suitable for a vertical-slice prototype, but a real app needs a remote/local persistence strategy, cache invalidation, concurrent-write handling, and a clear source-of-truth policy.

## Errors, UX, and Testing

### 19. How are failures converted into user-facing states?

**Answer:** Data sources throw typed exceptions. Repositories convert them into sealed `Failure` subtypes. `appErrorTypeFrom` exhaustively maps every failure to a UI category, and `ErrorStateView` chooses the illustrated state. Connectivity is checked first, so an offline state overrides a generic failure. The sealed classes and exhaustive switch make adding a new failure a compile-time prompt to decide how it should appear.

### 20. What would you test before calling this production-ready?

**Answer:** I would add unit tests for model parsing, repository exception translation, use-case business rules, secure-storage corruption/round trips, onboarding preference behavior, session restoration, and registration persistence. I would add provider tests for auth and invalidation behavior, widget tests for loading/error/empty states and register discard confirmation, and integration tests for cold-start routing, login/logout redirects, shell tab-state preservation, and deep links. The current automated suite only smoke-tests that the splash appears, so manual verification is not enough for the highest-risk flows.

## Quick Defense Strategy

When challenged, separate three statements clearly:

1. **What exists:** describe the current code path and name the boundary involved.
2. **Why it was chosen:** explain the tradeoff, such as `Either` at repositories or `StatefulShellRoute` for state preservation.
3. **What remains:** acknowledge prototype limitations directly and give the concrete production fix and test that would prove it.
