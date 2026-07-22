# Laforika M1 Authentication Review Fixes — Coding-Agent Prompt

Use this prompt with the repository’s current `AGENTS.md`. Work from the reviewed M1 source archive/PR-head commit `8c05bb5bb55231846f6180183649306682f9b966` and remain on the same M1 branch.

## TASK

Correct the M1 authentication review findings in the existing Flutter + NestJS/PostgreSQL vertical slice, preserving the approved O1 architecture and all completed M1 behavior.

Fix every item in this prompt, add regression tests, run the applicable local/backend checks, commit atomically on the existing M1 branch, push/update the existing pull request, create a clean archive from the corrected PR-head commit, and stop for owner review. Do not merge and do not update `docs/project_inventory.md` yet.

## WHY

The current implementation contains security and correctness defects that can bypass email verification, prevent OTP attempt counters and refresh-replay revocation from persisting, allow unsafe concurrent refresh rotation, expose sensitive data through logging/fixture persistence, and risk destructive e2e cleanup against a non-test database. M1 cannot be approved until these defects are corrected and tested.

## MILESTONE

**M1 — authentication review remediation.**

This is a correction of the existing M1 implementation, not a new milestone or redesign.

## OWNER DECISIONS

- **O1 remains resolved and unchanged:** custom NestJS + PostgreSQL API; phone OTP and email/password credentials on one stable account; RS256 access tokens; opaque rotating refresh tokens; replay detection and revocation; Flutter root plus `backend/`.
- **O8 remains unresolved and unchanged:** real-account builds remain controlled-test-only; no external distribution.
- **Owner-approved exception:** review finding #4 is intentionally excluded. Do **not** restore the three-flavor Android matrix or Android-emulator integration job to GitHub Actions in this task. Do not reopen or debate that decision.
- Decisions O2–O7 remain untouched.

## SOURCE OF TRUTH AND PRECEDENCE

1. This remediation prompt’s explicit scope and acceptance criteria.
2. `AGENTS.md`.
3. `docs/architecture/ARCHITECTURE.md`.
4. ADR-0006 and ADR-0007.
5. The original `docs/prompts/M1_AUTHENTICATION_VERTICAL_SLICE_PROMPT.md` where it does not conflict with the owner-approved CI exception above.
6. Existing repository conventions.

Read all of them fully before editing.

## SCOPE

### In scope

1. Persist failed OTP/email-code attempts and enforce maximum attempts correctly.
2. Persist refresh-token replay revocation and security events even when the API returns an authentication error.
3. Make refresh-token rotation transactionally safe under concurrent requests.
4. Prevent unverified email/password credentials from authenticating or appearing as verified credentials.
5. Ensure email signup and email credential attachment activate credentials only after successful verification.
6. Make backend e2e database cleanup fail closed unless an explicitly dedicated test database is configured.
7. Preserve the one-shared-Dio rule during idempotent retries.
8. Remove sensitive URI/query/error data from Flutter and backend logs.
9. Generate a meaningful deterministic OpenAPI contract with populated request/response/error schemas.
10. Implement concurrency-safe destination and request-origin rate limiting without storing raw IP addresses.
11. Introduce explicit SMS/email delivery adapter boundaries; isolate fixture delivery to dev/test; fail closed when delivery is unavailable.
12. Remove persistent plaintext fixture-code storage.
13. Fix resend countdown/re-enable behavior and add missing resend flows for email verification, password reset, and credential attachment.
14. Add/update focused backend, Flutter, widget, and integration regression tests.
15. Update documentation only where behavior/configuration/API contracts changed as part of these fixes.

### Explicitly out of scope

- Any GitHub Actions restoration or expansion related to the three-flavor build matrix or Android-emulator integration job.
- Changes to `.github/workflows/ci.yml` solely to address review finding #4.
- Reversing the owner-approved local-only treatment of those long-running checks.
- New authentication methods, OAuth, social login, passkeys, Firebase, or account merging.
- Real SMS or SMTP provider integration.
- External distribution, account deletion, legal/privacy policy work, telemetry, production deployment, signing, or publishing.
- Redis, a second database, a second ORM, microservices, Docker/WSL requirements, or speculative infrastructure.
- M2 feature work or Home redesign.
- Drive-by refactors.
- `docs/project_inventory.md` completion entry.

## PRIMARY REVIEW TARGETS

Inspect these files first, then inspect every caller, test, migration, DTO, generated contract, and UI flow affected by the fix:

- `backend/src/auth/application/session.service.ts`
- `backend/src/auth/application/auth.service.ts`
- `backend/src/auth/presentation/auth.controller.ts`
- `backend/src/auth/auth.module.ts`
- `backend/src/config/env.validation.ts`
- `backend/src/common/errors/app-error.ts`
- `backend/prisma/schema.prisma`
- `backend/prisma/migrations/**`
- `backend/test/jest-e2e.setup.ts`
- `backend/test/auth.e2e-spec.ts`
- `backend/openapi/openapi.json` and its source-generation script
- `lib/core/network/dio_provider.dart`
- `lib/core/network/http_redactor.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/presentation/phone_auth_screen.dart`
- `lib/features/auth/presentation/email_auth_screen.dart`
- `lib/features/auth/presentation/password_reset_screen.dart`
- `lib/features/auth/presentation/account_security_screen.dart`
- related Flutter tests under `test/`
- `integration_test/auth_flow_test.dart`

Do not assume the listed files are the complete change surface.

## REQUIRED FIXES

### 1. Challenge attempt persistence and atomic consumption

The current `consumeChallenge()` increments `attempts` and then throws inside the same Prisma transaction, causing the increment to roll back.

Correct the design so that:

- every incorrect code attempt is committed before the API returns `AUTH_CHALLENGE_INVALID`;
- the maximum-five-attempt rule is effective and cannot be bypassed by transaction rollback;
- attempts are updated atomically under concurrent requests;
- a challenge that reaches its limit cannot later be consumed successfully;
- expiry, invalidation, and consumed state remain enforced;
- concurrent correct verification requests cannot both succeed;
- challenge consumption and the security-sensitive action it authorizes remain transactional where required;
- new challenge generation invalidates older active challenges for the same destination/purpose but does not reset rolling abuse counters;
- no plaintext code is persisted outside the isolated dev/test fixture mechanism.

Do not “fix” this by swallowing errors, weakening attempt limits, or relying on process-local counters.

A valid pattern is to return a discriminated outcome from a committing transaction and throw the public `AppError` only after commit. An equivalent design is acceptable if persistence and concurrency are proven by tests.

### 2. Refresh replay persistence and concurrent rotation

The current refresh flow writes family revocation/security events and then throws inside the transaction, rolling those writes back. It also reads and rotates without a row lock or equivalent atomic claim.

Correct the design so that:

- a replayed, used, replaced, revoked, or expired refresh token causes the applicable session/token family to be revoked persistently;
- the sanitized `REFRESH_REPLAY` security event persists before the endpoint returns `AUTH_SESSION_REVOKED`;
- only one concurrent request can successfully claim a valid refresh token;
- old-token use and replacement creation are atomic;
- concurrent use of the same refresh token cannot produce two valid replacement tokens;
- the losing concurrent/replay request triggers the defined family-revocation policy;
- replacement tokens become unusable after family revocation;
- transaction retries, if needed for PostgreSQL serialization/deadlock errors, are bounded and limited to the exact transaction;
- raw refresh tokens never enter logs, events, exceptions, or database records.

Use PostgreSQL row locking (`SELECT … FOR UPDATE`) or a proven conditional atomic-claim design within Prisma/PostgreSQL. Do not implement a process-local mutex as the security boundary.

Return/throw the public authentication error only after the revocation transaction has committed.

### 3. Verified email credential state

The current schema has no verified-email state. Email signup and attachment persist active email/password credentials before verification, and email login checks only the password.

Correct the lifecycle so that:

- an unverified email/password can never authenticate;
- `hasEmail`, account responses, and credential-removal guards count only a verified active email credential;
- email signup does not create a login-eligible credential until verification succeeds;
- attaching/changing email/password does not replace or activate the account’s current credential before verification succeeds;
- failed, expired, exhausted, or abandoned verification leaves no active unverified login credential;
- verification activates the normalized email and password hash atomically with challenge consumption;
- duplicate verified or pending identifiers cannot merge two accounts or transfer ownership silently;
- sign-in failures remain generic and enumeration-resistant;
- password reset is available only for the verified active email credential;
- removal of a verified email is blocked when it would leave no other verified sign-in method.

Use purposeful pending-credential persistence linked to the verification challenge, or an equivalent schema that keeps pending data distinct from active verified credentials. Do not store a pending password in plaintext or in challenge JSON. Use Argon2id plus the configured pepper exactly as for active credentials.

Add a Prisma migration. Never hand-edit generated Prisma client output.

### 4. Dedicated test-database guard

The current e2e setup may retain an arbitrary `DATABASE_URL`, while tests execute table-wide cleanup.

Before any destructive e2e setup or teardown:

- require `APP_ENVIRONMENT=test`;
- parse and validate `DATABASE_URL` deterministically;
- require an explicit dedicated database name, for example through `TEST_DATABASE_NAME`, and require that name to end in `_test`;
- require the parsed URL database name to exactly match `TEST_DATABASE_NAME`;
- fail immediately before connecting or deleting when any guard is absent or mismatched;
- remove any fallback that can silently reuse a development, staging, production, or arbitrary database;
- keep cleanup deterministic and limited to the dedicated test database.

Add tests for safe acceptance and all refusal cases. Never make the safeguard bypassable by a default value.

### 5. Preserve the one-shared-Dio contract

`IdempotentRetryInterceptor` currently calls `Dio().fetch(...)`, creating an unconfigured second client.

Correct it so that:

- application requests and retries use the single configured Dio instance from `dioProvider`;
- retry preserves base URL, adapter, timeouts, headers, extras, cancellation token, response type, and configured interceptors;
- retry remains limited to safe/idempotent requests and bounded attempts;
- retry counters prevent recursion;
- auth refresh still remains single-flight and retries the original request exactly once;
- refresh calls never recursively trigger refresh;
- no service locator or second HTTP client is introduced.

Inject/pass the configured Dio instance or a narrow retry callback without creating a provider cycle. Add regression tests proving no new Dio instance is used and retry retains configuration.

### 6. Logging and redaction

#### Flutter

The current debug interceptor logs full `RequestOptions.uri`, including query values.

- Never log raw query strings, fragments, email, phone, tokens, OTPs, passwords, fixture keys, or request/response bodies without redaction.
- Log only the HTTP method, a safe path/route representation with query values removed, status/type, and already-redacted metadata.
- Ensure dynamic path identifiers are not accidentally treated as safe personal/token data.
- Expand redactor tests for query parameters, nested values, case variants, and fixture headers.

#### Backend

The fallback exception filter currently logs `exception.message`.

- Do not print raw exception messages, request URLs/query values, bodies, credentials, codes, tokens, database URLs, or personal identifiers.
- Use Nest’s logger or an equivalent structured local logger with correlation ID, stable error category/code, and safe technical context only.
- Client envelopes must remain sanitized and must not expose internal exception messages/stacks.
- Validation details must not echo secret field values.
- Add captured-log tests proving representative secrets and PII do not appear.

### 7. Deterministic OpenAPI contract

The committed OpenAPI file currently contains request schemas with empty `properties` and lacks meaningful response contracts.

Correct source annotations and DTO structure so generated OpenAPI includes:

- non-empty request schema properties, required fields, formats, bounds, and descriptions where useful;
- explicit response DTOs for challenge creation, token/session response, account view, session list, health, JWKS, and success acknowledgements;
- a common sanitized error envelope with documented stable error codes/statuses;
- bearer security requirements on protected routes;
- route parameters and safe query parameters;
- no fixture secret value or sensitive example;
- the dev fixture endpoint excluded from the public production contract;
- deterministic generation from source annotations.

Do not hand-edit `backend/openapi/openapi.json`. Regenerate it and make `npm run openapi:check` pass with a clean diff after generation.

Add contract assertions that fail when critical schemas regress to empty properties.

### 8. Concurrency-safe persistent rate limiting

The current destination counter uses read-then-update logic and has no request-origin limiter.

Implement persistent abuse controls so that:

- challenge creation applies both destination/purpose and request-origin windows;
- counters survive process restart;
- parallel requests cannot exceed the configured limit through lost updates/races;
- window reset and increment are atomic;
- raw IP addresses are not stored or logged;
- origin is normalized and converted to a keyed HMAC/fingerprint before persistence;
- forwarded headers are trusted only when an explicit trusted-proxy configuration permits it;
- generic responses continue to prevent identifier enumeration;
- tests cover parallel increments, boundary/reset behavior, destination limit, origin limit, and persistence.

Use PostgreSQL transactional/atomic behavior. Do not add Redis or an in-memory-only production limiter.

### 9. Delivery adapter boundary and fixture isolation

The current challenge service writes fixture messages directly and stores plaintext codes in PostgreSQL. The fixture route remains part of the general auth controller.

Refactor to explicit narrow delivery contracts, for example:

- `SmsDeliveryPort`
- `EmailDeliveryPort`
- dev/test fixture implementations
- future real-provider adapters supplied later

Requirements:

- challenge generation/verification remains real and provider-independent;
- delivery ports receive the generated code/message but auth services do not know fixture persistence details;
- dev/test fixture delivery uses a bounded, short-lived, process-local inbox or equivalently protected mechanism that does **not** persist plaintext codes in PostgreSQL;
- fixture messages expire with the challenge or sooner and are consumed/removed after protected retrieval;
- fixture routes/controllers are registered only in `dev`/`test` and excluded from public OpenAPI;
- fixture access requires the configured fixture key and constant-time comparison where applicable;
- staging/prod must reject fixture mode;
- because no real provider exists yet, staging/prod startup must fail closed when required SMS/email delivery adapters are unconfigured;
- ordinary auth responses and logs never include the code;
- remove the plaintext fixture-code Prisma model/column if no longer needed, with a committed migration;
- tests prove fixture route absence outside dev/test, expiry/one-time retrieval, key rejection, and no database plaintext code.

Do not add an SMS/email vendor SDK in this task.

### 10. Resend countdown and missing resend flows

The phone screen computes `DateTime.now()` only during rebuild, so the disabled resend button does not reliably re-enable when the cooldown expires. Other verification flows lack equivalent resend behavior.

Implement a reusable but non-speculative flow-local countdown approach that:

- uses the server-provided `resendAvailableAt` as authority;
- triggers UI rebuilds until the cooldown expires;
- cancels timers/tickers in `dispose()`;
- prevents duplicate requests while loading;
- updates challenge ID, masked destination, expiry, and resend time after a successful resend;
- clears stale code/error state appropriately;
- formats user-visible countdown text through localization/`intl` and remains Persian RTL safe;
- works with text scaling and accessibility.

Provide resend behavior for:

1. phone OTP login/signup;
2. email signup verification;
3. password-reset verification;
4. phone credential attachment;
5. email/password credential attachment.

Do not add resend endpoints if the existing challenge-request endpoints safely serve that purpose; preserve cohesive API contracts.

## REQUIRED TESTS

### Backend unit tests

Add focused tests for at least:

- incorrect challenge attempts persist across returned errors;
- fifth failure locks the challenge and later correct code is rejected;
- concurrent correct challenge consumption yields exactly one success;
- concurrent incorrect attempts cannot lose increments;
- replay revocation and `REFRESH_REPLAY` event persist after a 401 response;
- concurrent same-token refresh yields at most one rotation success and enforces family revocation policy;
- replacement refresh token is rejected after family replay revocation;
- unverified email login is rejected with a generic response;
- pending signup/attachment credentials are not active before verification;
- verified email activation is atomic;
- failed/expired verification preserves the previous verified credential;
- duplicate pending/verified email conflicts do not merge accounts;
- request-origin and destination rate-limit atomicity under parallel calls;
- raw origin/IP is not persisted;
- delivery-port selection and fail-closed environment validation;
- fixture inbox TTL, one-time retrieval, key rejection, and no plaintext DB persistence;
- sanitized backend logging/error envelopes;
- OpenAPI critical schemas have properties and protected routes have bearer security.

### Backend e2e tests with PostgreSQL

Update/add tests proving:

1. E2E startup refuses any non-test or mismatched database URL before cleanup.
2. Email signup cannot log in before verification.
3. Successful email verification activates login and returns the same stable `accountId` thereafter.
4. Email attachment does not replace/activate credentials before verification.
5. Failed/expired attachment keeps the existing account state unchanged.
6. Five failed challenge attempts persist and block the correct code.
7. Concurrent challenge verification allows one success only.
8. Concurrent refresh requests cannot create two valid rotations.
9. Replay returns 401 **and** family/session revocation plus security event remain committed.
10. Dev/test fixture route works only with the correct fixture key and is one-time/short-lived.
11. Fixture route is absent or rejected in staging/prod module/configuration tests.
12. No fixture code exists in persistent database records.
13. Captured logs/errors contain none of the test email, phone, password, OTP, refresh token, fixture key, or raw query values.
14. OpenAPI generation matches the committed contract.

Use deterministic isolated test data. Do not connect to or clean a developer’s normal database.

### Flutter unit/widget tests

Add/update tests for at least:

- idempotent retry uses the configured shared Dio and preserves request configuration;
- retry remains bounded and only applies to safe methods/transient errors;
- auth refresh does not recurse and original request retries once;
- logging strips/redacts query values, credentials, OTPs, tokens, fixture headers, and nested sensitive data;
- phone resend button re-enables after the server cooldown without unrelated interaction;
- email verification resend updates the active challenge;
- password-reset resend updates the active challenge;
- phone/email credential-attachment resend works;
- timers are cancelled safely on disposal/navigation;
- loading prevents double submission;
- Persian RTL/localized countdown and error states render correctly.

Do not update goldens unless explicitly approved; none are required by this remediation unless existing coverage demands it.

### Integration test

Update `integration_test/auth_flow_test.dart` and its fixture helper as required by the new delivery adapter/inbox contract. Preserve a real backend/PostgreSQL authentication path and cover at least:

- challenge delivery through protected dev fixture adapter;
- verified phone signup/login;
- verified email attachment and later email login to the same account;
- refresh and logout;
- no direct/stubbed session injection.

The owner-approved exception concerns GitHub Actions only; do not fake the integration path to compensate.

## ACCEPTANCE CRITERIA

- [ ] Failed challenge attempts persist and the five-attempt limit is enforceable.
- [ ] Challenge consumption is single-use and concurrency-safe.
- [ ] Refresh replay revocation/security events persist even though the endpoint returns 401.
- [ ] Concurrent refresh cannot produce two valid replacement tokens.
- [ ] Unverified email/password credentials cannot authenticate or count as an active login method.
- [ ] Signup/attachment activates email/password only after successful verification.
- [ ] Test cleanup cannot run against a non-dedicated database.
- [ ] Application retries use the one configured Dio instance.
- [ ] Flutter/backend logs contain no raw query values, credentials, OTPs, tokens, fixture keys, or personal identifiers.
- [ ] OpenAPI request/response/error schemas are populated and deterministic.
- [ ] Destination and request-origin rate limits are persistent and concurrency-safe.
- [ ] Fixture delivery is behind explicit adapters, unavailable outside dev/test, and stores no plaintext code in PostgreSQL.
- [ ] Staging/prod fail closed while real delivery adapters are absent.
- [ ] Resend countdown and resend actions work in all five scoped flows.
- [ ] All new behavior has focused regression tests.
- [ ] Existing M1 auth, routing, secure storage, localization, and account/session behavior continue to pass.
- [ ] No changes are made to restore the excluded CI matrix/emulator jobs.
- [ ] `docs/project_inventory.md` remains untouched.

## DEPENDENCIES

- Prefer **no new dependencies**.
- Use existing NestJS, Prisma/PostgreSQL, Node `crypto`, Dio, Riverpod, Flutter SDK, `intl`, Jest, and Flutter test capabilities.
- Do not add Redis, a rate-limit SaaS/package, another HTTP client, another ORM, another validation library, a service locator, or an auth framework.
- If a genuinely unavoidable dependency is required, stop and report the exact package, purpose, maintained status, alternatives considered, and architecture impact before adding it.

## CONSTRAINTS

- Preserve Flutter `3.44.6`, Dart `3.12.2`, Node.js 24 LTS direction, PostgreSQL, NestJS, Prisma, app identity, flavors, Android minimum API 24, Riverpod, `go_router`, Dio, `Failure`/`Result`, `fa-IR`, RTL, and Vazirmatn.
- Preserve `app → features → core` Flutter boundaries and curated feature barrels.
- Keep backend as a modular monolith under root-level `backend/`.
- Never hand-edit generated Dart, Prisma client, localization, or OpenAPI output.
- Never commit `.env` files, keys, secrets, tokens, dumps, fixture inbox contents, or real account data.
- Do not weaken security rules to make tests pass.
- Do not use production defaults or fallback secrets.
- Do not require Docker or WSL.
- Do not change signing, publishing, deployment infrastructure, target SDK, or iOS deployment target.
- Do not modify CI to address excluded finding #4.
- Check-in mode: **same M1 branch + atomic Conventional Commits + push/update existing PR + clean source archive; stop for owner review; do not merge.**

## STEP 0 — INSPECT

1. Read `AGENTS.md`, `docs/architecture/ARCHITECTURE.md`, ADR-0006, ADR-0007, and the original M1 prompt fully.
2. Confirm the working tree/branch corresponds to reviewed commit `8c05bb5bb55231846f6180183649306682f9b966` or a descendant on the same M1 branch.
3. Inspect all target files, migrations, generated outputs, package locks, tests, CI, and the current PR diff.
4. Identify exact transaction boundaries, schema migration impact, API contract changes, environment variables, and Flutter UI state changes.
5. Confirm no secret or real account data is present before editing.
6. Treat the excluded CI finding as an approved deviation; do not spend implementation time on it.

## STEP 1 — PLAN

Before editing, provide a concise plan containing:

- transaction strategy for challenge attempts/consumption;
- transaction/locking strategy for refresh rotation and replay revocation;
- pending-versus-verified email credential model and migration;
- e2e test-database guard;
- shared-Dio retry design;
- rate-limit origin fingerprinting and atomic counter design;
- delivery interfaces, conditional module registration, fixture TTL/consumption, and fail-closed configuration;
- OpenAPI DTO/response strategy;
- resend timer/state design for each flow;
- exact expected file surface and tests;
- migration/data compatibility concerns;
- verification commands.

Proceed without waiting unless an actual architecture conflict or new dependency approval blocker exists.

## STEP 2 — IMPLEMENT

- Keep the diff limited to these remediation findings.
- Make database changes through Prisma schema and committed migrations.
- Keep security-sensitive writes atomic and ensure errors are raised only after required writes commit.
- Preserve stable public API paths where possible; update generated OpenAPI and Flutter DTO/repository mappings when contract changes are necessary.
- Keep fixture functionality test-only and provider-neutral.
- Add tests in the same logical commits as implementation.
- Do not change unrelated formatting or architecture.

Suggested atomic commits:

1. `fix(auth): make challenge and refresh transactions durable`
2. `fix(auth): require verified email credentials`
3. `fix(auth): isolate delivery fixtures and rate limits`
4. `fix(network): preserve shared Dio and sanitize logs`
5. `fix(auth-ui): complete resend flows`
6. `test(auth): harden database guard and regression coverage`
7. `docs(auth): update remediation contracts` — only if documentation changes are required

Adjust commit grouping when necessary, but keep each commit logically coherent.

## STEP 3 — VERIFY

Report actual pass/fail/not-run results. Do not claim success for commands not executed.

### Backend

From `backend/`:

```powershell
npm ci
npm run format:check
npm run lint
npm run typecheck
npm run prisma:format:check
npm run prisma:validate
npm run prisma:generate
npm run build
npm test -- --runInBand
npm run test:e2e
npm run openapi:check
```

Also:

- apply migrations to a fresh explicitly dedicated test database;
- prove the e2e guard refuses a non-test database without performing cleanup;
- inspect the database after OTP/refresh tests to confirm attempts, revocation, and security events persisted;
- run focused concurrency tests repeatedly enough to detect race regressions;
- regenerate OpenAPI and confirm a clean tree.

### Flutter

From repository root:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
flutter gen-l10n
git diff --exit-code -- lib/l10n/generated
```

Run the local three-flavor debug build matrix when applicable under repository rules. The owner-approved exception means **do not add it back to GitHub Actions**.

Run the dev Android-emulator real-backend integration flow locally when the environment is available. If unavailable, report the exact limitation; do not replace it with a fake session flow.

### Hygiene

```powershell
git status --short
git diff --stat
git diff
```

Additionally verify:

- no tracked secrets, keys, `.env` values, database dumps, fixture messages, tokens, or real account data;
- no plaintext OTP/email code in PostgreSQL models/migrations/data paths;
- no `Dio()` construction remains in application retry paths;
- no raw exception message or raw URI/query logging remains;
- generated files match their source inputs;
- `docs/project_inventory.md` is unchanged;
- excluded CI jobs were not restored.

## STEP 4 — CHECK IN AND STOP

1. Stay on the existing M1 branch; never commit to `main`/`master`.
2. Inspect full diff and test evidence.
3. Commit using atomic Conventional Commits.
4. Push and update the existing M1 pull request.
5. Wait for the currently configured CI and report its actual result.
6. Create a clean source archive from the exact corrected PR-head commit.
7. Exclude `.git`, `node_modules`, Flutter/Dart caches, builds, coverage, database files/dumps, `.env*`, PEM/key files, fixture inbox contents, local configs, and signing material.
8. Name the archive with the corrected short commit SHA.
9. Stop for owner/external review.
10. Do not merge and do not update `docs/project_inventory.md` in this task.

## REPORT BACK

- **Status:** done / partial / blocked
- **Reviewed baseline:** `8c05bb5bb55231846f6180183649306682f9b966`
- **Summary:**
- **Root causes corrected:**
- **Files changed:**
- **Prisma migrations added/updated:**
- **API/OpenAPI changes:**
- **Flutter behavior changes:**
- **Tests added/updated:**
- **Commands and actual results:**
- **Concurrency/security evidence:**
- **Secret/PII/logging audit:**
- **Architecture/ADR impact:**
- **Approved deviation:** finding #4 / long-running GitHub Actions jobs intentionally excluded by owner
- **Remaining blockers or follow-ups:**
- **Branch:**
- **Commits:**
- **PR:**
- **Corrected PR-head commit:**
- **Archive name/path:**
