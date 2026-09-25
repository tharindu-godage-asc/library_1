# Feature Spec: Keycloak Auth Integration for BooksnU

branch: claude/feature/keycloak-auth-integration
spec: _specs/keycloak-auth-integration.md
owner: numustafa
date: 2026-09-16

---

## 0) Summary

**One-liner:** Replace BooksnU's mock, in-memory email/password auth with real Keycloak login (Authorization Code + PKCE via `flutter_appauth`), scoped to auth only, verified on the Android emulator.
**Why now:** Library.Api's Phase 4 Keycloak cutover is complete and documented. This is Part B of an already-approved plan that had been deliberately deferred, and BooksnU is the last piece needed to close out that plan.
**Who is this for:** BooksnU end users signing in and registering; the engineer(s) maintaining BooksnU's auth flow and its connection to Library.Api.
**Success looks like:** Tapping Login or Sign Up opens Keycloak's hosted page in a Custom Tab; a successful sign-in or registration returns the user to the app already signed in with a real, token-backed session; the session survives an app restart without re-login; and the existing silent-refresh loop keeps the session alive transparently past the access token's lifetime — all confirmed manually against a running Keycloak + Library.Api stack, including one smoke-test call proving the API accepts the token.

---

## 1) Goals and Non-Goals

### Goals
- Replace the mock/local email-password auth datasource with a Keycloak-backed datasource using Authorization Code + PKCE.
- Preserve existing session persistence, restore-on-launch, and silent-refresh behavior exactly as-is; no changes to that infrastructure.
- Update the login and register screens so they trigger the hosted Keycloak flow instead of collecting credentials locally, while keeping loading/error states intact.
- Add the Android redirect-scheme plumbing required for the OAuth redirect to return control to the app.
- Add the corresponding redirect URI to Library.Api's realm configuration (additive; already applied on its own branch, not part of this spec's delivery).
- Prove the full chain end-to-end with one manual smoke-test call to Library.Api's `/api/keycloak-whoami` endpoint.
- Document the change in BooksnU's existing `docs/phase-NN-*.md` convention.

### Non-Goals
- Wiring Books, Borrowings, or Members features to the real Library.Api — they continue running on existing local/mock data.
- Any backend integration beyond the one manual smoke test; nothing in Library.Api is called from real app navigation in this pass.
- Deleting or altering the existing mock auth datasource — it stays in the repo untouched, just unreferenced.
- Reconciling the app's user identifier (Keycloak's `sub` claim) with Library.Api's internal Member identifier — that is later backend-integration work.
- Testing on a physical device or any non-emulator network configuration.
- Direct file edits to the BooksnU repository by the assistant — delivery is a text manifest for the user to apply by hand.

---

## 2) User Workflow

### Primary workflow
1. User opens BooksnU and taps "Login" on the login screen.
2. The app launches Keycloak's hosted login page in a Custom Tab, using Authorization Code + PKCE.
3. The user enters their credentials on the Keycloak-hosted page and submits.
4. Keycloak redirects back into the app with an authorization code, which the app exchanges for tokens.
5. The app reads the returned access token's claims, builds a session from them, and persists it via the existing secure session storage.
6. The user lands back in the app already signed in.

### Secondary workflows
- **Registration:** tapping "Sign Up" opens Keycloak's hosted registration page directly (rather than a local form); on completion the user returns to the app signed in.
- **Session restore:** relaunching the app after a prior sign-in restores the session automatically, without another login.
- **Silent refresh:** while the app is open past the access token's lifetime, the session refreshes in the background using the stored refresh token, with no visible interruption.
- **Rejected refresh:** if a refresh attempt is rejected by Keycloak, the stored session is cleared and the user returns to a signed-out state.

---

## 3) Exposed API Surface (What this feature exposes internally)

### 3.1 Functions
For each function in the auth contract used by the rest of the app:

- **Name:** `login`
  - **Purpose:** Starts the hosted Keycloak sign-in flow and returns an authenticated session on success.
  - **Parameters:** None (credentials are no longer collected by the app).
  - **Returns:** A session result, or a failure if the user cancels or the flow fails.
  - **Errors/warnings behavior:** User cancellation and flow failures surface as a failure the login screen can display; no distinct "invalid credentials" case reaches the app, since Keycloak's hosted page handles that itself.

- **Name:** `register`
  - **Purpose:** Starts the hosted Keycloak registration flow and returns an authenticated session on success.
  - **Parameters:** None.
  - **Returns:** A session result, or a failure if the user cancels or the flow fails.
  - **Errors/warnings behavior:** Same as `login`; Keycloak's hosted page handles duplicate-email and validation errors before the app receives anything.

- **Name:** `restoreSession`
  - **Purpose:** Restores a previously persisted session on app launch. Unchanged by this feature.
  - **Parameters:** None.
  - **Returns:** A session if one is stored and valid, or an empty/failure result otherwise.
  - **Errors/warnings behavior:** Unchanged.

- **Name:** `refreshSession`
  - **Purpose:** Silently renews the current session's tokens using the stored refresh token. Unchanged in shape; the underlying token exchange now targets Keycloak.
  - **Parameters:** None (reads the persisted session's own refresh token).
  - **Returns:** A renewed session, or a failure.
  - **Errors/warnings behavior:** A rejected refresh grant is treated as an invalid-refresh-token condition, which clears the stored session, matching existing behavior.

- **Name:** `logout`
  - **Purpose:** Clears the persisted session. Unchanged by this feature.
  - **Parameters:** None.
  - **Returns:** Confirmation of completion.
  - **Errors/warnings behavior:** Unchanged.

---

## 4) Data Contracts (session and token data)

### 4.1 Inputs
- **Authorization response:** returned by the hosted Keycloak flow after a successful login/registration — carries an authorization code exchanged for tokens.
- **Token response:** access token, refresh token, and access-token expiry, returned by Keycloak's token endpoint.
- **Access token claims:** the decoded payload of the access token, sourced from Keycloak, containing the subject identifier, email, display name, and assigned roles.

### 4.2 Required fields (minimum contract)
From the token response:
- Access token (string) — used for authenticated API calls.
- Refresh token (string) — used to silently renew the session.
- Access token expiry (timestamp) — drives the existing silent-refresh scheduling.

From the decoded access token claims:
- Subject identifier — the only stable per-user identifier available to the app in this pass; used as the app's user identifier.
- Email — user's email address.
- Display name — user's full name.
- Assigned roles — a list; used only to derive a single-value role for display purposes (see §5.2).

Refresh-token expiry is not guaranteed to be present in the token response; see Open Questions (§11).

### 4.3 Output contract (session shape)
- The existing session entity's fields (access token, access-token expiry, refresh token, refresh-token expiry, user identifier, role, full name, email) are populated from the sources in §4.2.
- No fields are added, removed, or renamed on the existing session entity; this pass only changes what populates it.

---

## 5) Business Rules

### 5.1 Scope filtering
- Not applicable — this feature does not filter or scope any dataset; it governs sign-in/sign-up only.

### 5.2 Role classification
- The app's role is a single-value convenience derived from the assigned-roles list: if the list contains an admin role, the user is classified as Admin; otherwise, Member.
- This classification is a client-side display convenience only — it is not treated as a contract with the backend, and no attempt is made to reconcile it against a backend-authoritative role.

### 5.3 Session freshness
- Access-token expiry always comes directly from the token response and drives the existing silent-refresh timing — no change from current behavior.
- Refresh-token expiry: if Keycloak does not surface an explicit refresh-token expiry in the token response, a conservative estimated expiry is used instead, and the actual observed behavior is recorded in this feature's documentation once verified.

---

## 6) Architecture (must match existing BooksnU clean-architecture layering)

### 6.1 Data-source layer (I/O boundary)
- A new, additive authentication data source replaces the existing mock data source as the one wired into the app, without modifying or removing the mock. It is responsible for driving the hosted sign-in/sign-up flow and exchanging/refreshing tokens.

### 6.2 Configuration (values only)
- Centralized configuration values for the Keycloak connection used by this feature (issuer host, client identifier, redirect target, requested scopes), scoped to the Android emulator for this pass.

### 6.3 Pure transforms
- A small, pure transform that extracts identity and role information from an access token's claims, used to populate the session.

### 6.4 Orchestration layer
- The existing repository and provider wiring is updated to point at the new data source instead of the mock one, with no change to how sessions are persisted, restored, or silently refreshed.
- The login and register screens are updated to trigger the hosted flow directly, dropping local field collection and validation, while preserving existing loading and error-display behavior.
- A one-off, manually-triggered API call proves the issued token is accepted by Library.Api; it is not wired into normal app navigation.

---

## 7) Edge Cases
- User cancels or backs out of the hosted Keycloak page before completing sign-in/sign-up.
- Refresh-token expiry is absent from the token response (see §5.3).
- A refresh grant is rejected by Keycloak (expired/revoked refresh token).
- The assigned-roles claim is missing or empty.
- The app is killed and relaunched while a session is close to or past its access-token expiry.
- The Keycloak host is unreachable (emulator not pointed at a running stack).

---

## 8) Acceptance Criteria
- [ ] Tapping Login opens Keycloak's hosted login page and a successful sign-in returns the user to the app, signed in.
- [ ] Tapping Sign Up opens Keycloak's hosted registration page and a successful registration returns the user to the app, signed in.
- [ ] The resulting session's user identifier, email, display name, and role are populated correctly from the token's claims.
- [ ] Killing and relaunching the app restores the session without requiring another login.
- [ ] Leaving the app open past the access token's lifetime triggers a transparent silent refresh that keeps the session alive.
- [ ] A rejected refresh grant clears the stored session.
- [ ] The manual `/api/keycloak-whoami` smoke test succeeds using the issued token.
- [ ] The existing mock auth data source remains present and unreferenced, with no other app behavior (Books/Borrowings/Members) affected.

---

## 9) Test Plan

### 9.1 Golden fixture
- A test user provisioned in the Keycloak realm used for manual verification, plus one negative case (a deliberately expired/revoked refresh token) to exercise the rejected-refresh path.

### 9.2 Unit tests
- The claims-extraction transform (§6.3): correct extraction of subject identifier, email, display name, and role classification, including the case where the roles list is missing or does not contain an admin role.

### 9.3 Integration/manual verification
- Happy path: login through to a signed-in state, including the smoke-test API call.
- Registration happy path.
- Session restore after app restart.
- Silent refresh across an access-token expiry boundary.
- Rejected refresh grant clearing the session.

---

## 10) References Used
- `docs/keycloak-authserver-phase4-cutover.md`: confirms the Phase 4 Keycloak cutover this feature builds on.
- `docs/NEXT_TODO_keycloak-authserver-phase4-flutter-integration-plan.md`: the previously-approved, deferred plan this feature re-verifies and carries out (Part B).
- BooksnU's existing `docs/phase-NN-*.md` series: convention followed for this feature's own documentation.

---

## 11) Open Questions
- **Q:** Does Keycloak's refresh-token expiry surface through the app's token exchange, or must a conservative estimate be used instead? Use app's token exchange
  **Decision owner / date:** Confirm during implementation/manual verification; record the actual observed behavior in this feature's documentation.
- **Q:** Does BooksnU have a docs index (e.g. `docs/README.md`) that needs updating alongside the new phase document? Yes and you can create a new phase
  **Decision owner / date:** Confirm at implementation time by checking the docs folder.
