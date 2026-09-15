# Feature Spec: Auth Flow Implementation Guide

branch: claude/feature/auth-flow-implementation-guide
spec: _specs/auth-flow-implementation-guide.md
owner: tngodage
date: 2026-09-15

---

## 0) Summary

**One-liner:** A step-by-step documentation guide that walks through how this app's already-implemented authentication flow was built — starting from creating the domain-layer files through to a fully wired login/register/session flow enforced by routing — so it can be used as a learning reference and as a template for building similarly-structured features.
**Why now:** the auth flow already exists in the codebase (domain/data/presentation layers, a central Riverpod controller, router-enforced redirects) but there is no narrative walkthrough tying the pieces together in build order. A guide closes that gap.
**Who is this for:** the app owner/developer, as a personal reference and as an onboarding walkthrough for understanding (or reproducing) this codebase's feature architecture.
**Success looks like:** a markdown guide exists that, followed top to bottom, explains the auth feature's build order file by file / layer by layer, matching exactly what's implemented today — so a reader ends up with an accurate mental model of both *what* exists and *why* it was built in that order.

---

## 1) Goals and Non-Goals

### Goals
- Produce a step-ordered guide covering every layer of the existing auth feature, in the order the files would sensibly be created from scratch:
  1. Domain — entities, repository contract, use cases
  2. Data — models, local datasource, repository implementation
  3. Presentation — provider graph/controller, screens
  4. Integration — secure session storage, onboarding preference, app bootstrap, router redirect enforcement
- Ground every step in the real files that exist today under `lib/features/auth/` and the related `lib/core/` files — not a hypothetical or idealized version of the feature.
- Explain *why* each layer exists and *why* it's built in that order (e.g., domain contracts before data implementations, so the dependency direction is clear) — not just *what* the code does.
- Cover how auth state reaches the rest of the app (the central controller) and how routing enforces it (redirect logic), since that's the payoff that ties the whole flow together.
- Be explicit that today's data source is a mock, in-memory backend (seeded fake users, simulated delay) — not a real API — so the guide isn't mistaken for production backend-integration guidance.

### Non-Goals
- Not implementing any new auth functionality (forgot-password, email verification, biometrics, etc.) — the guide documents what's already built; it doesn't propose new features.
- Not a security audit of the current auth implementation.
- Not writing tests — the guide can note that no auth tests exist today, but authoring them is out of scope unless requested separately.
- Not a generic "how OAuth/JWT works" tutorial — it documents this app's specific implementation.

---

## 2) User Workflow

### Primary workflow
1. Reader opens the guide and follows it top to bottom, in the same order the feature's pieces would be created from scratch: domain layer, then data layer, then presentation layer, then routing integration.
2. At each step, the guide names the real file(s) responsible, explains its role, and explains its relationship to the previous and next steps (what it depends on / what depends on it).
3. By the end, the reader has traced the complete path from "no auth feature exists" to "a signed-in user's session is restored on cold start, silently refreshed, and enforced by the router" — matching the app's current behavior exactly.

### Secondary workflows (optional)
- Reader uses the guide as a lookup reference — jumping straight to, say, "how does session restoration on cold start work?" to find the relevant file and explanation without reading start to finish.

---

## 3) Guide Content Structure (What the guide exposes)

### 3.1 Step sequence
Based on the auth feature as it exists today, the guide covers these steps in order:

1. **Domain — entities**: `AuthSession` (session data, `UserRole` enum, token-expiry helpers). The foundational data model everything else depends on.
2. **Domain — repository contract**: the abstract `AuthRepository` interface (login, register, restore session, refresh session, logout). Defines *what* the feature can do before deciding *how*.
3. **Domain — use cases**: one class per operation, thin wrappers around the repository. Gives each operation a single-purpose entry point for the presentation layer to depend on.
4. **Data — model**: the data-layer DTO mapping to/from the domain entity. Keeps the storage/wire representation separate from the domain model.
5. **Data — local datasource**: today's mock, in-memory "backend" (seeded users, simulated network delay, typed exceptions). Documents that swapping in a real API later only means re-implementing this piece.
6. **Data — repository implementation**: orchestrates the datasource plus secure session storage, and maps low-level exceptions to domain-level failures. Where domain contracts meet real (or mocked) I/O.
7. **Presentation — provider graph & controller**: the central session-state holder the rest of the app watches — handles cold-start restore, expired-token refresh, a self-scheduling silent-refresh cycle, and the login/register/logout operations.
8. **Presentation — screens**: splash (bootstrap gate), onboarding (first-run), login, register — the user-facing surface wired to the controller.
9. **Integration — persistence**: secure token storage and the onboarding-completion preference, both outside the auth feature folder but depended on by it.
10. **Integration — app bootstrap**: the cold-start decision between onboarding, login, or home.
11. **Integration — router enforcement**: redirect logic that gates authenticated routes and bounces already-signed-in users away from login/onboarding.

### 3.2 Per-step template
Each step in the guide follows this template:
- Step name / title
- File(s) involved (exact paths)
- What it's responsible for, in plain language
- What it depends on (earlier steps) and what depends on it (later steps)
- Why it exists, and why it's built at this point in the sequence

---

## 4) Data Contracts (DF schemas + join keys)

N/A — this is a documentation artifact, not a data-processing feature. The guide describes the shape of `AuthSession` and related models conceptually (as part of Section 3.1, step 1) rather than as a formal schema/contract.

### 4.1 Inputs
N/A

### 4.2 Required columns (minimum contract)
N/A

### 4.3 Output schema
N/A — the guide's "output" is the markdown document itself, structured per Section 3.

---

## 5) Business Rules

### 5.1 Portfolio filtering
N/A — not applicable to this feature.

### 5.2 ITM/OTM classification
N/A — not applicable to this feature.

### 5.3 Pricing / Greeks
N/A — not applicable to this feature.

### 5.4 Documentation accuracy rules
- Every file path and responsibility described in the guide must match what's actually in the codebase at time of writing — no hypothetical or aspirational content.
- The guide must state plainly, up front, that the local datasource is a mock/in-memory backend, and must list which adjacent auth flows are **not** implemented (forgot-password, email verification, biometrics) so a reader doesn't assume they exist.
- The guide should note that no automated tests currently cover the auth feature, without implying a test-writing step is included.

---

## 6) Architecture (must match TECHNICAL_BLUEPRINT)

This app doesn't use a `clients/`/`constants/`/`utils/`/orchestration folder structure — it follows Flutter clean architecture (`domain/` / `data/` / `presentation/` per feature). Mapping the template's categories onto that reality:

### 6.1 clients/ (I/O boundary)
Maps to `data/datasources/` — specifically the mock local datasource that stands in for a real backend today.

### 6.2 constants/ (values only)
N/A as a dedicated folder — the closest equivalent is the `UserRole` enum living inside the domain entity file.

### 6.3 utils/ (pure transforms, vectorized)
Maps to `domain/usecases/` (one thin operation wrapper per action) and `data/models/` (DTO ↔ entity mapping).

### 6.4 orchestration layer (e.g., recon/ or S****l entrypoints)
Maps to `presentation/providers/` (the central auth controller wiring use cases + repository together) and, one level up, the router's redirect logic that consumes auth state to gate navigation.

---

## 7) Edge Cases

- The guide can drift out of date if the auth implementation changes later — consider a "last verified against commit/date" note so staleness is visible.
- Must not imply the mock datasource is production-ready or describe it as if it were a real backend integration.
- Must not describe forgot-password, email verification, or biometric flows as existing, since they aren't implemented.
- Must not imply auth test coverage exists, since none currently does.

---

## 8) Acceptance Criteria

Checklist that can be tested:
- [ ] The guide covers all 11 steps from Section 3.1, each following the per-step template from Section 3.2.
- [ ] Every step names real, currently-existing file paths — verified against the actual codebase, not hypothetical.
- [ ] The guide clearly explains the dependency ordering (domain → data → presentation → integration) at least once.
- [ ] The guide explicitly states the datasource is a mock and explicitly lists which related flows are not implemented.
- [ ] A reader unfamiliar with this codebase can, after reading the guide, correctly describe how a login attempt flows from the login screen down to the mock datasource and back up to the router redirect.

---

## 9) Test Plan

### 9.1 Golden fixture (required)
N/A — no data fixtures involved. Verification instead means: having someone unfamiliar with the auth feature read the guide and then correctly trace, unaided, how a real request (e.g. a login attempt) flows through the layers described.

### 9.2 Unit tests (utils/)
N/A — no code produced by this feature.

### 9.3 Integration tests (orchestration)
N/A — verification is the manual read-through described in 9.1.

---

## 10) References Used (required)

- This app's existing `lib/features/auth/` implementation and related `lib/core/` files (storage, preferences, bootstrap, navigation) as the source of truth for every step described.
- `_specs/template.md`: structure followed for this spec (with data/pipeline-specific sections marked N/A where they don't apply to a documentation feature).
- `_specs/flutter-error-handling-guide.md`: structural precedent for adapting this template to a documentation-guide feature.

---

## 11) Open Questions

- Q: Where should the finished guide live (e.g. a new `docs/` or `guides/` folder, alongside `error_docs/`, or elsewhere)?
  - Decision owner / date: tngodage — TBD before implementation begins. Create a new guides folder and in there
- Q: Should the guide close with a "how to apply this pattern to a new feature" section, or stay strictly descriptive of what already exists? Yes close with how to apply section
  - Decision owner / date: tngodage — TBD before implementation begins.
- Q: Should the step order mirror the literal git history of when these files were committed, or the pedagogically cleaner domain → data → presentation order used in this spec (which may not match commit order)? Use clean domain approach
  - Decision owner / date: tngodage — TBD before implementation begins.
