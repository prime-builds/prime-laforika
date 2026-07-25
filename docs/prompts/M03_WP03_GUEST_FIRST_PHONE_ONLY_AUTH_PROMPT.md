# Laforika M03_WP03 — Guest-First Routing and Phone-Only Authentication Prompt

## TASK

Deliver **M03_WP03 — Guest-first routing and phone-only authentication** for Laforika.

Change the current M1/M2 authenticated-first, dual-credential implementation so that:

1. session restoration still runs deterministically at startup;
2. both authenticated and unauthenticated users enter the public Home after restoration;
3. authentication is required only when entering an explicitly protected capability;
4. protected destinations redirect to the **direct phone-number OTP flow** and resume the validated destination after successful verification;
5. phone-number OTP is the only user-facing sign-in method;
6. the auth-method chooser, email/password login, password reset, credential attachment/removal, and password-management flows are removed;
7. backend, OpenAPI, Prisma, fixture delivery, Flutter DTOs, localization, tests, and integration coverage match the phone-only contract;
8. existing RS256 access-token, opaque rotating refresh-token, session revocation, replay detection, secure storage, redaction, and server-authority behavior remain intact.

Do **not** implement the adaptive application shell, bottom dock, Chat, Profile, Settings, Notifications, or profile editing in this package.

Persist this exact task prompt in the repository as:

```text
docs/prompts/M03_WP03_GUEST_FIRST_PHONE_ONLY_AUTH_PROMPT.md
```

---

## WHY

The owner-approved product direction no longer requires authentication on first launch. Users must be able to explore Laforika as guests and authenticate only when a protected capability actually needs an account.

The current implementation still:

- redirects every unauthenticated route, including Home, to an auth-method chooser;
- exposes phone OTP and email/password as parallel credentials;
- includes password reset, email credential attachment, phone credential removal, and password management;
- returns credential-status fields in the session principal;
- treats Home as authenticated-only.

M03_WP01 documented the approved guest-first / phone-only target through architecture v1.4 and ADR-0008. M03_WP02 implemented the light/dark theme foundation. M03_WP03 must now close the authentication and routing gap without redesigning the shell.

The outcome that matters is a secure and testable access model in which public exploration is frictionless, phone OTP is the sole login path, protected navigation resumes correctly, and no deprecated email/password credential surface remains active or documented as current behavior.

---

## MILESTONE

**M03_WP03 — Guest-first routing and phone-only authentication.**

This package implements the routing/authentication portion of architecture v1.4 and ADR-0008. It does not change the approved architecture direction and should not create a new ADR or architecture version unless an actual conflict is discovered and explicitly approved.

Exact next package after successful review, inventory, and merge:

**M03_WP04 — Adaptive application shell.**

---

## REVIEWED BASELINE AND MANDATORY PRECONDITIONS

The final externally reviewed M03_WP02 implementation head is:

```text
98729a6f0f3953448db40706e78322bc46c3b1d5
```

PR #9 was reported green for Flutter/backend CI, all three Android debug flavors, and the real dev auth integration flow. The final M03_WP02 inventory update and merge were intentionally held until external approval.

Before creating the M03_WP03 branch:

1. Read `AGENTS.md` fully.
2. Finish the terminating M03_WP02 workflow on its existing PR/branch:
   - add exactly one M03_WP02 entry to `docs/project_inventory.md`;
   - record implementation SHA `98729a6f0f3953448db40706e78322bc46c3b1d5`;
   - record M03_WP04 only after M03_WP03 is completed; for the M03_WP02 entry the exact next package is **M03_WP03**;
   - commit and push the inventory update;
   - rerun CI;
   - merge only after final green CI and owner approval.
3. Synchronize the local default branch with the remote and confirm it is clean.
4. Confirm the merged repository contains:
   - M03_WP01 inventory entry;
   - M03_WP02 inventory entry;
   - theme implementation and remediation from the reviewed M03_WP02 head;
   - no unrecorded local source, generated, environment, Gradle, or documentation changes.
5. Record the actual M03_WP03 base commit SHA in the plan and final report.
6. Preserve Composer's current runtime/build fixes. Do not restore older archive files over a newer working repository.
7. Machine-local Android workarounds such as `GRADLE_USER_HOME` or temporary Kotlin incremental settings must remain uncommitted unless separately approved.

**Stop** if M03_WP02 is not inventoried, green, merged, and present on the synchronized default branch. Work packages must remain isolated.

---

## AUTHORITATIVE DOCUMENTS

Read fully before planning or editing:

- `AGENTS.md`
- `README.md`
- `docs/project_inventory.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/adr/0001-modular-feature-first-architecture.md`
- `docs/architecture/adr/0002-riverpod-state-and-di.md`
- `docs/architecture/adr/0003-go-router-navigation.md`
- `docs/architecture/adr/0004-networking-and-error-model.md`
- `docs/architecture/adr/0006-authentication-and-session.md`
- `docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md`
- `docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md`
- `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`
- `docs/design/UI_FOUNDATION.md`
- `docs/design/APP_SHELL.md` only to preserve package boundaries; do not implement the shell here
- `docs/prompts/M03_WP01_GUEST_FIRST_UI_FOUNDATION_DOCUMENTATION_PROMPT.md`
- `docs/prompts/M03_WP02_LIGHT_DARK_THEME_FOUNDATION_PROMPT.md`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `l10n.yaml`
- `.gitignore`
- `.github/workflows/*`
- `backend/README.md`
- `backend/package.json`
- `backend/package-lock.json`
- `backend/prisma/schema.prisma`
- every existing Prisma migration
- `backend/openapi/openapi.json`

Inspect the current implementation and tests, especially:

### Flutter

- `lib/app/router/app_router.dart`
- `lib/app/router/routes.dart`
- `lib/core/auth/`
- `lib/core/utils/auth_utils.dart`
- `lib/core/network/`
- `lib/core/storage/`
- `lib/features/auth/auth.dart`
- all files under `lib/features/auth/data/`
- all files under `lib/features/auth/presentation/`
- `lib/features/home/home.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/l10n/app_fa.arb`
- generated localization/JSON files and their generation commands
- `test/app/auth_router_and_security_test.dart`
- `test/core/auth/`
- `test/core/network/`
- `test/features/auth/`
- `test/features/home/`
- `test/support/fake_auth_repository.dart`
- `integration_test/auth_flow_test.dart`

### Backend

- `backend/src/auth/application/auth.service.ts`
- `backend/src/auth/application/session.service.ts`
- `backend/src/auth/presentation/auth.controller.ts`
- `backend/src/auth/presentation/auth.dto.ts`
- `backend/src/auth/delivery/`
- backend configuration validation and `.env.example`
- backend security/crypto utilities
- `backend/src/auth/presentation/openapi.contract.spec.ts`
- `backend/test/auth.e2e-spec.ts`
- migration tests under `backend/src/auth/application/`
- OpenAPI export script and drift check

The current synchronized repository wins over path suggestions in this prompt when it has evolved without conflicting with architecture v1.4 or accepted ADRs.

---

## OWNER DECISIONS

### Required resolved decisions

- **O1 is resolved** by ADR-0007: Laforika owns a custom NestJS + PostgreSQL authentication backend.
- ADR-0008 amends the user-facing credential model to **phone-number OTP only**.
- Home and public content are guest-accessible after deterministic session restoration.
- Authentication occurs only at protected-capability boundaries.
- Email is optional profile/contact data, not a login credential.
- The verified phone number is the primary login identity and is not removable through ordinary account UI.
- A future change-phone security flow is not approved.
- Existing access/refresh/session security from ADR-0007 remains authoritative.
- Real-account builds remain controlled-test-only until O8 is resolved.

### Decisions that must remain untouched

- O2–O6 and O8 remain unresolved.
- O3 push-provider selection remains unresolved; do not create Notifications or push infrastructure.
- O7 in-app visual direction is already implemented by M03_WP02; do not restyle or rebaseline theme goldens.
- Do not select or create an M04 specialized module.
- Do not add anonymous guest accounts, guest access tokens, guest database records, or fake production auth.
- Do not invent profile-field validation, profile APIs, first/last-name schema, change-phone flow, email verification policy, account deletion, or retention behavior. Those belong to later packages/owner decisions.

---

## APPROVED TARGET CONTRACT

### 1. Session and startup

- `AuthState` remains conceptually:
  - `unknown` while restoring session;
  - `unauthenticated` for a guest;
  - `authenticated(principal)` for a signed-in account.
- The startup surface remains deterministic while state is `unknown`.
- A temporary hydration transport failure remains retryable and must not destroy a potentially valid refresh secret.
- When hydration completes:
  - unauthenticated → Home as guest;
  - authenticated → Home as authenticated user.
- The application must not flash an auth screen during hydration.

### 2. Route matrix

| Session | Destination | Required result |
|---|---|---|
| `unknown` | any | stay on startup/hydration surface |
| hydration error | any | recoverable startup error/retry surface |
| `unauthenticated` | Home/public route | allow |
| `unauthenticated` | protected route | redirect to direct phone OTP with validated internal return destination |
| `unauthenticated` | direct phone login route | allow |
| `authenticated` | direct phone login route | return to validated destination, otherwise Home |
| `authenticated` | public/protected route | allow |

Current protected capability in this package includes the existing Account Security destination. Do not create Chat, Notifications, Profile, Settings, or module routes merely to exercise protection.

### 3. Canonical auth route

Use one canonical user-facing auth entry:

```text
/auth
```

`/auth` renders the phone-number OTP experience directly. It is not a method chooser.

Remove the active route contracts and constants for:

```text
/auth/phone
/auth/email
/auth/password-reset
```

Do not keep deprecated hidden routes active indefinitely. Update all internal navigation and tests atomically.

A protected redirect uses the canonical shape:

```text
/auth?from=<percent-encoded-validated-internal-destination>
```

The preserved destination must:

- parse as an internal URI without scheme or authority;
- resolve to a registered application route;
- not be startup or auth-only;
- not create a redirect loop;
- preserve only reconstructable internal path/query state that passes validation;
- fall back to Home when missing, malformed, external, unknown, or forbidden.

Use the smallest explicit public/protected route registry consistent with the existing feature route-registry pattern. Do not infer that every non-auth route is protected.

### 4. Flutter session principal

The provider-neutral authenticated principal exposes only the stable opaque `accountId` needed for scoping. Credential-status fields such as `hasPhone`, `hasEmail`, `maskedPhone`, and `maskedEmail` must not remain part of the core session principal merely to support the deprecated Home/account UI.

Do not add profile fields to the session principal.

### 5. User-facing credentials

The only login flow is:

```text
phone number → OTP challenge → OTP verification → session accepted
```

Remove user-facing and client repository support for:

- auth-method selection;
- email sign-up;
- email verification as a login credential;
- email/password sign-in;
- password-reset challenge;
- password reset;
- email credential attachment/removal;
- password change;
- phone credential attachment/removal.

The verified phone number is the account identity. Ordinary removal is not allowed. No change-phone flow is introduced.

### 6. Backend API

Retain and secure the phone/session endpoints required by ADR-0007, including the current equivalents of:

- phone challenge creation;
- phone challenge verification;
- refresh;
- session listing;
- individual session revocation;
- current-session logout;
- logout-all;
- a minimal protected account/session probe such as `/account/me` if retained by the current refresh/integration design.

Remove active API/controller/service/DTO/OpenAPI support for:

- email sign-up/verification/sign-in;
- password-reset challenge/reset;
- account email credential attach/verify/remove;
- account password change;
- account phone attach/verify/remove.

If `/account/me` remains, it must not model email as a credential. Keep its response minimal and aligned with the provider-neutral account/session contract; do not implement the later M03_WP05 profile contract here.

Token responses should contain only data needed to accept the session, including the opaque account identifier. Do not return deprecated credential-status fields merely for old UI compatibility.

### 7. Email data boundary

Email may remain as nullable profile/contact data in the database, but it must not:

- authenticate an account;
- create or attach a credential;
- accept a password;
- affect whether a session is valid;
- appear in auth-only client/server DTOs as a sign-in method.

Do not implement profile email editing in this package. That belongs to M03_WP05.

### 8. Migration safety

- Never reset, truncate, silently delete, or recreate an owner database to remove email/password auth.
- Historical migrations are immutable.
- Add a committed forward Prisma migration for any schema change.
- Before enforcing phone-only account invariants or dropping password-bearing fields, the migration must fail safely when existing users would be orphaned.
- At minimum, any existing user without a phone identity must trigger a deliberate stop rather than silent conversion/deletion.
- Do not log or report personal identifiers. A blocker report may include only aggregate counts and schema state.
- Preserve nullable email profile/contact columns needed by later Profile work.
- Remove password-bearing columns and deprecated credential structures only through reviewed forward migration steps.
- If the actual database contains any non-test email-only account, stop for explicit owner migration policy. Do not improvise account linking, phone assignment, deletion, or credential conversion.
- Tests may use isolated disposable test databases according to existing backend conventions; this does not authorize destructive handling of developer/owner data.

### 9. Home during this transition package

M03_WP03 does not implement the approved adaptive shell. Make only the minimum changes needed for guest-first behavior:

- Home renders safely for guests and authenticated users.
- Remove credential-status UI that depends on `hasPhone` / `hasEmail` session-principal fields.
- Do not show email/password language or credential-management cards.
- Keep the existing Home layout structurally simple; no module strip, search row, contextual tabs, or bottom dock.
- The existing Account Security action may remain as a real protected capability and should be usable by guests as the boundary that triggers direct phone login.
- Show Logout only when authenticated.
- Do not add a permanent Profile/login placeholder; M03_WP04/M03_WP05 own the final dock/Profile experience.

### 10. Account Security during this transition package

Keep Account Security protected and reduce it to phone-only-compatible security/session functions:

- active session list;
- revoke another session;
- logout current session;
- logout all sessions;
- stable loading/error/empty/data behavior as already appropriate.

Remove:

- attach/remove phone;
- attach/remove email;
- change password;
- any “last credential” logic or UI;
- raw credential-status controls.

Do not turn Account Security into Profile.

---

## SCOPE

### In scope

1. Finalize and merge M03_WP02 before starting this package.
2. Implement guest-first startup and route behavior.
3. Add explicit public/protected route classification using the existing registry architecture.
4. Make `/auth` the direct phone OTP route.
5. Remove deprecated auth routes, screens, constants, repository calls, DTO fields, generated serializers, localization keys, and tests.
6. Simplify the provider-neutral session principal to opaque `accountId` only.
7. Make Home guest-safe with minimal layout changes.
8. Simplify Account Security to session security/logout only.
9. Remove backend email/password credential and phone attach/remove endpoints, services, DTOs, OpenAPI operations, fixture behavior, tests, and unused dependencies/configuration.
10. Apply safe forward Prisma migration(s) needed for phone-only invariants and removal of password-bearing structures.
11. Preserve email as inactive nullable profile/contact data only.
12. Regenerate and commit generated Flutter JSON/localization output and Prisma/OpenAPI output through normal commands.
13. Rewrite the real Flutter integration flow for guest-first phone OTP, protected return destination, refresh, logout, and guest Home.
14. Add complete focused Flutter/backend unit, widget, route, migration, OpenAPI, e2e, and integration coverage.
15. Update README/current-state documentation to mark M03_WP03 implemented and M03_WP04 exact next.
16. Add this prompt under `docs/prompts/`.

### Out of scope / do not touch

- Adaptive application shell.
- Floating bottom dock.
- Module strip, search row, contextual module tabs, or scroll-collapse behavior.
- Chat feature or route.
- Profile page, first name, last name, avatar, editable email, or verified-phone profile UI.
- Settings page or appearance selector UI.
- Notifications feature, push SDK, permissions, or provider configuration.
- Change-phone flow.
- Account deletion, retention, privacy export, or external distribution.
- New auth provider or SDK.
- OAuth, passkeys, magic links, anonymous accounts, guest tokens, or social login.
- New database technology.
- Theme palette changes or golden rebaselining.
- CI workflow changes unless an existing gate is demonstrably broken and explicit approval is obtained.
- Platform identity, flavors, SDK targets, signing, store configuration, or toolchain changes.
- Specialized M04 module selection or placeholder module infrastructure.

---

## EXPECTED IMPLEMENTATION SURFACE

The exact file list must come from inspection, but the expected surface includes the following categories.

### Flutter production

Likely modify:

- `lib/app/router/app_router.dart`
- `lib/app/router/routes.dart`
- `lib/core/auth/auth_state.dart`
- `lib/core/auth/auth_controller.dart` only if required by the simplified principal contract
- `lib/core/utils/auth_utils.dart`
- `lib/features/auth/auth.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/data/auth_dtos.dart`
- generated `auth_dtos.g.dart`
- `lib/features/auth/data/custom_api_auth_gateway.dart`
- `lib/features/auth/presentation/phone_auth_screen.dart`
- `lib/features/auth/presentation/account_security_screen.dart`
- `lib/features/home/home.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/l10n/app_fa.arb`
- generated localization output

Likely remove when no longer referenced:

- `lib/features/auth/presentation/auth_method_screen.dart`
- `lib/features/auth/presentation/email_auth_screen.dart`
- `lib/features/auth/presentation/password_reset_screen.dart`

Do not preserve dead files for hypothetical compatibility.

### Backend production

Likely modify:

- `backend/prisma/schema.prisma`
- a new forward migration directory
- `backend/src/auth/application/auth.service.ts`
- `backend/src/auth/application/session.service.ts`
- `backend/src/auth/presentation/auth.controller.ts`
- `backend/src/auth/presentation/auth.dto.ts`
- `backend/src/auth/delivery/*`
- backend configuration validation / `.env.example` only where password/email delivery settings become unused
- backend security utilities only where password hashing becomes unused
- `backend/package.json`
- `backend/package-lock.json`
- `backend/openapi/openapi.json`

Remove the `argon2` dependency only if inspection confirms password hashing is its sole remaining use. Do not remove security dependencies used by OTP, refresh-token, JWT, or session protection.

### Tests

Update or replace all tests that encode authenticated-first or dual-credential behavior, including:

- app router/security widget tests;
- auth controller/gateway tests;
- auth DTO/repository tests;
- Home tests;
- Account Security tests;
- network refresh tests;
- fake auth repository;
- Flutter integration auth flow;
- backend auth unit/e2e tests;
- migration tests;
- OpenAPI contract tests;
- crypto utility tests if password hashing is removed.

Do not simply delete coverage. Replace deprecated-flow tests with phone-only and guest-first invariants.

---

## ACCEPTANCE CRITERIA

### Startup and guest access

- [ ] `unknown` displays only the deterministic startup/hydration surface.
- [ ] Hydration success with no session enters Home as guest.
- [ ] Hydration success with a valid session enters Home authenticated.
- [ ] Temporary hydration failure remains retryable and preserves the refresh secret.
- [ ] No auth-method chooser or phone screen flashes during hydration.
- [ ] Home is accessible to unauthenticated users.
- [ ] No guest account, guest token, or backend anonymous principal is created.

### Routing

- [ ] Public routes are allowed for guests.
- [ ] Explicit protected routes redirect guests to `/auth`.
- [ ] Redirect includes only a validated internal return destination.
- [ ] Successful OTP login resumes the protected destination.
- [ ] Invalid/external/unknown/auth/startup return destinations fall back to Home.
- [ ] Authenticated navigation to `/auth` redirects to valid `from`, otherwise Home.
- [ ] Redirect loops are prevented.
- [ ] Account Security is classified as protected.
- [ ] No Chat/Profile/Settings/Notifications route is invented.

### Phone-only Flutter flow

- [ ] `/auth` renders phone-number OTP directly.
- [ ] Auth-method chooser is removed.
- [ ] Email/password login and password-reset screens/routes are removed.
- [ ] Auth repository exposes no email/password, attach/remove credential, or password-change methods.
- [ ] Session principal contains only opaque `accountId`.
- [ ] Token/session DTOs no longer expose deprecated credential-status fields.
- [ ] Phone and OTP values are never persisted or logged.
- [ ] Existing secure refresh-token storage remains unchanged in intent.
- [ ] Existing single-flight refresh and definitive-vs-temporary failure behavior remains intact.

### Home and Account Security

- [ ] Home renders correctly as guest and authenticated user in both light and dark themes.
- [ ] Home no longer depends on phone/email credential-status fields.
- [ ] Guest use of the real Account Security action triggers direct phone login.
- [ ] Logout is shown only when authenticated.
- [ ] Account Security contains session security/logout functions only.
- [ ] Phone/email attach/remove and password change are absent.
- [ ] No adaptive shell or Profile placeholder is introduced.

### Backend/API

- [ ] Phone challenge/verification, refresh, sessions, revocation, logout, and logout-all continue to work.
- [ ] Email sign-up/verify/sign-in endpoints are absent.
- [ ] Password-reset endpoints are absent.
- [ ] Account email credential endpoints are absent.
- [ ] Account phone attach/remove endpoints are absent.
- [ ] Password-change endpoint is absent.
- [ ] Token response contains only approved session data.
- [ ] `/account/me`, if retained, contains no email/password credential semantics.
- [ ] OpenAPI contains only the approved phone/session/account operations.
- [ ] Staging/prod still fail closed without a real SMS adapter.
- [ ] Dev/test fixture delivery remains controlled and SMS-only.
- [ ] Logs/redaction never expose phone, OTP, tokens, or request bodies.

### Prisma/migration

- [ ] Historical migrations are unchanged.
- [ ] New schema changes use committed forward migration(s).
- [ ] Migration refuses to orphan any existing account without a phone identity.
- [ ] No database reset/truncate/recreate instruction is added.
- [ ] Password-bearing columns/structures are removed safely where approved by the inspected data model.
- [ ] Email contact columns needed for later Profile work remain nullable and non-authenticating.
- [ ] Test database migrates cleanly from zero through all migrations.
- [ ] Migration behavior is tested against a legacy phone-backed account and an unsafe email-only/account-without-phone case.

### Localization/generated files

- [ ] All visible text remains generated from ARB.
- [ ] Deprecated email/password/method-choice strings are removed when unused.
- [ ] Home localization descriptions no longer claim authenticated-only behavior.
- [ ] Generated localization and JSON code are regenerated, never hand-edited.
- [ ] Generation leaves the repository clean after committed outputs.

### Documentation/repository

- [ ] No new ADR or architecture version bump is made unless a real conflict is explicitly approved.
- [ ] README/current-state docs mark M03_WP03 implemented.
- [ ] Exact next package is M03_WP04 — Adaptive application shell.
- [ ] This prompt is committed under `docs/prompts/`.
- [ ] No M03_WP03 inventory entry is added before external review.
- [ ] Diff contains no unrelated refactor, theme rebaseline, or shell work.

---

## REQUIRED TESTS

### Flutter unit tests

Cover at minimum:

- simplified `AuthPrincipal` equality/value behavior;
- hydration without refresh secret → unauthenticated guest;
- hydration with valid refresh → authenticated principal with accountId only;
- temporary hydration failure → retryable hydration error without secret deletion;
- definitive refresh/auth failure → local session cleared and unauthenticated;
- single-flight refresh remains correct;
- phone challenge and verification repository requests use Latin digits and skip auth where required;
- removed email/password repository methods are truly absent from production/test fakes;
- return-destination validation:
  - registered public path accepted;
  - registered protected path accepted as a post-login destination;
  - auth/startup rejected;
  - external scheme rejected;
  - protocol-relative authority rejected;
  - malformed/unknown rejected;
  - allowed query state handled according to the chosen documented policy;
  - fragments discarded or rejected consistently.

### Flutter router/widget tests

Cover the route matrix:

- unknown startup: startup surface only;
- unauthenticated hydration: guest Home;
- authenticated hydration: Home;
- unauthenticated direct Home: allowed;
- unauthenticated protected Account Security: `/auth?from=...`;
- canonical `/auth`: phone UI directly, no chooser;
- OTP acceptance after protected redirect: Account Security restored;
- OTP acceptance with invalid/missing `from`: Home;
- authenticated `/auth`: valid return or Home;
- no redirect loop;
- Home guest state has no logout and no credential-status UI;
- Home authenticated state exposes authenticated actions without email/password language;
- Account Security loading/empty/data/error/session revoke/logout behavior;
- Account Security contains no attach/remove/change-password controls;
- Persian RTL remains active;
- light/dark theme wiring from M03_WP02 remains intact.

Do not update M03_WP02 theme goldens. Add no new broad visual baseline unless explicitly necessary and separately approved.

### Backend unit tests

Cover at minimum:

- phone normalization/challenge/verification;
- first phone verification creates a phone-backed account and session;
- repeated phone login uses the same stable accountId;
- phone uniqueness conflict/concurrency behavior remains safe;
- challenge expiry, attempts, atomic consumption, and rate limiting remain safe;
- refresh rotation, reuse detection, session revocation, and JWT claim validation remain safe;
- account/session view contains only approved phone-only/session fields;
- removed email/password service methods and DTOs do not remain reachable;
- SMS fixture delivery only;
- redaction/rate-limit bucket keys never contain raw phone/OTP;
- password utility tests/dependency are removed only if no longer used.

### Backend e2e tests

Replace dual-credential scenarios with phone-only equivalents. Cover at minimum:

1. phone challenge → verify → token pair/accountId;
2. repeat phone login → same accountId;
3. refresh rotation and replay/family revocation;
4. protected `/account/me` or equivalent probe;
5. session list, individual revoke, logout, logout-all;
6. revoked session rejected despite unexpired access token;
7. expired/invalid/consumed OTP behavior;
8. concurrent phone verification allows only the safe expected outcome;
9. deprecated email/password/account-credential endpoints return 404/not registered and are absent from OpenAPI;
10. fixture inbox exposes SMS challenge data only in dev/test and remains unavailable outside allowed environments.

### Migration tests

Add focused migration verification that:

- a clean database migrates through the complete history;
- a legacy phone-backed account survives with stable account identity/session relations;
- a user lacking phone identity causes the new migration to fail safely before credential-bearing data is dropped;
- password-bearing schema elements are removed only after the guard;
- email profile/contact columns remain nullable if retained;
- historical migration files are byte-for-byte unchanged.

Do not use a production/developer database for destructive migration tests.

### OpenAPI tests

Verify:

- export is deterministic and committed;
- phone challenge/verify, refresh, sessions, logout endpoints are present with expected security/status contracts;
- removed email/password/password-reset/account-credential endpoints and schemas are absent;
- protected endpoints retain bearer security and documented 401 behavior;
- `npm run openapi:check` leaves no diff.

### Real Flutter integration test

Rewrite the existing Android-emulator integration scenario so it exercises the approved product behavior against the real local Nest/PostgreSQL backend and fixture SMS delivery.

Required flow:

1. clean app session starts on guest Home, not login;
2. trigger the real protected Account Security destination;
3. app shows direct phone login at `/auth`, with no method chooser/email option;
4. submit unique phone number;
5. obtain OTP through the controlled dev fixture endpoint;
6. verify OTP;
7. app resumes Account Security;
8. verify authenticated state and stable accountId;
9. exercise a protected API call;
10. force access-token expiry through the existing test hook and verify refresh succeeds without logout;
11. verify session list/revocation behavior as practical without making the test brittle;
12. logout current session;
13. app returns to guest Home, not the login screen;
14. reopening the protected destination returns to direct phone login.

Use no fake auth provider. Never print fixture keys, OTPs, tokens, phone numbers, or personal data in the report/log.

---

## CONSTRAINTS

- Follow `app → features → core` boundaries.
- `core/` remains provider-neutral and must not import `features/` or `app/`.
- Riverpod remains state and DI; no service locator.
- `go_router` remains the single router.
- Dio remains the single shared HTTP client.
- `Result<T>` / sealed failures remain the data boundary.
- NestJS/PostgreSQL/Prisma remain the backend stack.
- RS256 access tokens and opaque rotating refresh tokens remain unchanged in security intent.
- No new Flutter or backend dependency is expected.
- Removing an unused password-only dependency is allowed when the lockfile is updated and inspection proves no remaining use.
- Do not add an auth SDK, SMS provider, UI framework, database, state tool, router, mocking library, or migration tool.
- Do not change token lifetime, signing keys, refresh-family rules, secure-storage keys, environment scoping, or session revocation semantics unless required to fix a demonstrated defect and explicitly approved.
- Do not expose raw accountId in ordinary Home UI merely because it remains in the session principal.
- Do not persist phone, OTP, form values, access tokens, or profile data in preferences.
- Do not log raw request bodies, credentials, phone values, OTPs, tokens, fixture keys, or database rows.
- Do not hand-edit generated Dart, localization, Prisma client, or OpenAPI output.
- Do not edit historical migrations.
- Do not reset any non-disposable database.
- Preserve M03_WP02 appearance persistence and theme tests.
- Do not update theme goldens.
- Do not modify platform identity, flavors, signing, deployment targets, toolchain, or CI without explicit approval.
- Do not introduce Profile/Settings/Notifications/Chat/module placeholders.
- Check-in mode: branch + atomic commits + PR + CI + exact reviewed source archive; inventory only after external approval.

---

## STOP CONDITIONS

Stop before editing or during implementation and report clearly if:

1. M03_WP02 is not inventoried, merged, green, and present on synchronized default branch.
2. The default branch is dirty, behind remote, or contains unexplained changes.
3. Architecture v1.4 or ADR-0008 is missing or conflicts with the task.
4. Any non-test user/account exists without a phone identity and migration would orphan it.
5. Safe migration requires an owner policy for existing email-only accounts.
6. Removing password/email auth would require deleting owner data or resetting a database.
7. A change-phone, profile-email-verification, account-deletion, or retention decision becomes necessary.
8. A new identity/SMS provider, dependency, CI change, platform change, or architecture change appears necessary.
9. Current Composer runtime/build fixes would need to be reverted.
10. OpenAPI/generated code cannot be regenerated with the frozen toolchain.
11. The real integration environment is unavailable and no exact blocker can be documented.
12. Any secret, `.env`, PEM, fixture key, OTP, token, real phone/email, database dump, signing material, or machine-specific configuration is staged.

Do not silently weaken acceptance criteria or preserve deprecated auth routes to avoid a blocker.

---

## STEP 0 — INSPECT

1. Read every authoritative document listed above.
2. Confirm M03_WP02 terminating workflow completion and record the actual base SHA.
3. Inspect Git status, branch ancestry, current PR/CI state, and current Composer fixes.
4. Inspect all current auth routes, constants, redirects, route registries, and return-destination utilities.
5. Inspect Home and Account Security behavior for guest assumptions.
6. Inspect all Flutter DTOs/repositories/fakes/generated serializers/localization keys tied to email/password or credential attachment.
7. Inspect backend endpoint/controller/service/DTO/delivery/config/security code tied to email/password and phone attachment/removal.
8. Inspect Prisma schema and all historical migrations.
9. Determine whether any actual non-test database contains accounts without phone identity using read-only, non-PII inspection. Do not modify data during inspection.
10. Inspect backend/Flutter tests and identify which must be rewritten rather than deleted.
11. Inspect OpenAPI export/drift workflow.
12. Inspect CI, build matrix, emulator conventions, and current local Gradle workaround requirements.
13. Confirm no new dependency is needed.
14. Report any stop condition before editing.

---

## STEP 1 — PLAN

Before editing, provide a concise but concrete implementation plan containing:

- actual base commit SHA;
- branch name;
- exact current gaps found;
- proposed public/protected route classification;
- canonical auth route and return-destination policy;
- Flutter files to modify/remove/generate;
- Home and Account Security minimal transition behavior;
- backend endpoints/services/DTOs/config/dependencies to retain/remove;
- proposed Prisma migration sequence and orphan-account guard;
- treatment of nullable email profile/contact columns;
- expected OpenAPI changes;
- test rewrite matrix;
- real integration scenario;
- documentation updates;
- verification commands;
- architecture/ADR impact (`none; implements existing v1.4/ADR-0008` expected);
- any deviations or blockers.

Proceed without waiting only when no `AGENTS.md` guardrail or stop condition blocks the task.

---

## STEP 2 — IMPLEMENT

### A. Routing and session behavior

1. Keep startup/hydration deterministic.
2. Change unauthenticated post-hydration destination from auth chooser to Home.
3. Add explicit public/protected path classification.
4. Redirect only protected paths to canonical `/auth`.
5. Preserve and validate return destination safely.
6. Make authenticated visits to `/auth` continue to valid `from`, otherwise Home.
7. Remove deprecated auth paths/constants/routes.
8. Add route tests with the implementation.

### B. Phone-only Flutter auth

1. Make `/auth` build the existing phone OTP flow directly.
2. Remove chooser/email/password-reset screens and dead imports.
3. Remove deprecated repository methods and DTO fields.
4. Simplify `AuthPrincipal` and gateway mapping to accountId only.
5. Preserve secure refresh/session behavior.
6. Regenerate serializers/localization through normal commands.

### C. Home and Account Security

1. Make Home render for guests.
2. Remove credential-status dependence and email/password wording.
3. Keep a real protected Account Security navigation action without adding the future shell.
4. Show Logout only when authenticated.
5. Reduce Account Security to session list/revoke/logout functions.
6. Preserve Persian RTL, light/dark theme, accessibility, and 48dp controls.

### D. Backend phone-only contract

1. Remove deprecated controllers, DTOs, service methods, delivery paths, and tests.
2. Preserve phone OTP and session security.
3. Reduce token/account responses to approved session data.
4. Keep email nullable as profile/contact data only.
5. Remove unused password hashing/config/dependency only when truly unused.
6. Preserve sanitized logs, rate limiting, fixture restrictions, JWT/refresh behavior.

### E. Prisma/OpenAPI

1. Add forward migration(s) only.
2. Add safe orphan-account guard before enforcing phone-only schema/removing password structures.
3. Keep historical migrations unchanged.
4. Regenerate Prisma client if required.
5. Export and commit OpenAPI.
6. Test absent deprecated endpoints and present phone/session endpoints.

### F. Tests/docs

1. Replace dual-credential tests with guest-first/phone-only tests.
2. Rewrite the real integration flow.
3. Update README/current-state docs and exact next package.
4. Commit this prompt.
5. Do not add inventory before external review.

Keep the diff strictly inside scope. Do not preserve unused code “for later.” Do not create future feature infrastructure.

---

## STEP 3 — VERIFY

Run and report actual results for every applicable command.

### Flutter formatting, generation, analysis, tests

```bash
dart format --output=none --set-exit-if-changed .
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code -- lib/l10n/generated lib/features/auth/data
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
git diff --check
```

Adjust the generated-code clean-diff command to the actual generated file locations. Generated output should be committed first, then regeneration must leave no diff.

### Backend

Run from `backend/`:

```bash
npm ci
npm run format:check
npm run lint -- --no-fix
npm run typecheck
npm run prisma:format:check
npm run prisma:validate
npm run prisma:generate
npm test -- --runInBand
npm run test:e2e
npm run openapi:check
npm run build
```

Use the repository's actual non-mutating lint command if the script currently applies fixes; do not let verification silently rewrite files without inspecting the diff.

Verify a clean disposable database migrates through all committed migrations using the existing backend test convention.

### Android flavor matrix

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

Machine-local Gradle workarounds may be used without committing them. Report them accurately.

### Real dev integration

Run the rewritten phone-only integration flow against the real local backend/PostgreSQL and an Android emulator:

```bash
flutter test integration_test/auth_flow_test.dart --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json \
  --dart-define=FIXTURE_INBOX_KEY=<from-backend-env> \
  -d <emulator-id>
```

Do not expose the fixture key or OTP in logs/reporting.

### Manual verification

Verify at minimum:

- first launch as guest → Home;
- no auth flash;
- protected Account Security → direct phone login;
- no chooser/email/password controls;
- successful OTP resumes Account Security;
- logout → guest Home;
- light and dark themes;
- Persian RTL;
- 320dp width and text scale 2.0 on modified Home/auth/security surfaces without overflow;
- back navigation does not create redirect loops.

Do not claim success for commands not run. If an environment prevents a command, report the exact command, blocker, and whether owner deviation is required.

---

## STEP 4 — CHECK IN AND TERMINATING WORKFLOW

Use this branch unless the current repository convention requires an equivalent approved name:

```text
feat/m03-wp03-guest-phone-auth
```

Use atomic Conventional Commits, for example:

```text
feat(auth): make routing guest-first and phone-only
refactor(auth): remove deprecated credential flows
feat(backend): enforce phone-only authentication contract
test(auth): cover guest routing and protected return flow
docs(auth): record M03_WP03 implementation status
```

Do not force artificial commit separation when changes must remain atomic, but keep unrelated concerns out.

### Before opening/updating the PR

- inspect `git status`;
- inspect `git diff --stat`;
- inspect the full diff;
- inspect staged files for secrets and machine-local configuration;
- ensure historical migrations are unchanged;
- ensure generated outputs are committed and reproducible;
- run all applicable gates;
- push the task branch;
- open one PR using the `AGENTS.md` PR body;
- include API removals, migration guard, test evidence, build matrix, emulator device, and any local-only Gradle workaround in reviewer notes.

### External-review stop

After implementation CI is green:

1. create a clean source archive from the exact PR-head implementation commit;
2. name it using the established pattern, for example:

   ```text
   laforika-m03-wp03-guest-phone-auth-<short-sha>-src.zip
   ```

3. exclude `.git`, build outputs, dependencies, local `.env`, keys, fixture data, and machine-specific files;
4. report the full implementation SHA and archive name;
5. **stop for external review**;
6. do not update inventory and do not merge yet.

### After external approval only

1. apply review fixes on the same branch if requested;
2. rerun all affected gates and CI;
3. obtain final approval;
4. update `docs/project_inventory.md` exactly once for **M03_WP03**;
5. record the final reviewed **implementation SHA**, not the inventory commit or merge commit;
6. record the exact next package:

   ```text
   M03_WP04 — Adaptive application shell
   ```

7. commit and push the inventory update;
8. rerun CI;
9. merge after final approval;
10. synchronize and confirm the default branch is clean.

The inventory entry must not contain “pending merge,” branch state, inventory commit SHA, or merge commit SHA.

---

## REPORT BACK

Return a concise final report containing:

- **Status:** done / partial / blocked
- **Base commit SHA:**
- **Branch:**
- **Final implementation commit SHA:**
- **PR:**
- **Summary:**
- **Flutter files changed/removed/generated:**
- **Backend files changed/removed/generated:**
- **Prisma migration:**
  - migration name;
  - guard behavior;
  - historical migrations unchanged: yes/no;
  - existing-account inspection result without PII;
- **API/OpenAPI changes:**
  - retained endpoints;
  - removed endpoints;
- **Tests added/rewritten:**
- **Commands and actual results:**
  - Flutter gates;
  - backend gates;
  - clean migration verification;
  - dev/staging/prod APK builds;
  - real emulator integration;
  - CI;
- **Manual verification:**
- **Generated files:**
- **Architecture/ADR impact:**
- **Dependencies removed/changed:**
- **Approved deviations:**
- **Golden files changed:** expected `No`
- **Security/privacy check:**
- **Blockers or owner decisions:**
- **Archive name:**
- **Inventory/merge state:** held for external approval
- **Exact next package after completion:** M03_WP04 — Adaptive application shell

Do not report commands as passed unless they were actually run. Do not include secrets, OTPs, phone numbers, emails, tokens, fixture keys, or raw database records.
