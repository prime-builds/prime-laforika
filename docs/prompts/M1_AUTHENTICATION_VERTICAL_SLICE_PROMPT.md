# Laforika M1 Coding-Agent Prompt — Custom Authentication Vertical Slice

Use this prompt together with the repository root `AGENTS.md`. The repository's frozen architecture remains authoritative except for the explicit owner-approved M1 decisions and architecture changes stated below.

## TASK

Deliver **M1 — Authentication decision and real vertical slice** as one reviewable work package in the existing `prime-builds/prime-laforika` repository.

Extend the repository with a production-shaped custom authentication backend and integrate the Flutter client end-to-end so controlled development testing supports:

1. signup and login by phone-number OTP,
2. signup and login by email/password,
3. attaching the missing verified credential to the same authenticated account,
4. secure session hydration, refresh-token rotation, replay detection, revocation, protected routing, and logout,
5. a real Android-emulator integration flow against the local backend and PostgreSQL.

The authentication lifecycle and security controls must be real. Only delivery of SMS/email verification messages may use a development-only fixture adapter. No fake Flutter session, hardcoded authenticated user, bypassed credential validation, universal production OTP, or stubbed production authentication flow may remain.

## WHY

M0 is complete. M1 must establish the real account/session boundary that every authenticated Laforika module will depend on. The result must prove the custom backend, mobile session lifecycle, secure storage, Dio authentication/refresh behavior, and `go_router` protection pattern before M2 builds the authenticated Home/discovery shell.

## MILESTONE

**M1 — Authentication decision and real vertical slice**

M1 exit condition:

- real authentication works against Laforika's custom backend in controlled testing;
- both approved sign-in methods work;
- protected-route redirects and startup hydration are deterministic;
- access/refresh security, replay detection, and revocation are implemented and tested;
- no fake client session or stubbed auth flow remains;
- the Android-emulator integration job is part of CI;
- the build remains controlled-test-only because O8 is unresolved.

## OWNER DECISIONS

### O1 — resolved and authoritative for this task

Laforika owns a custom authentication API with these approved decisions:

- Backend language/framework: **TypeScript + NestJS on Node.js 24 LTS**.
- Server database: **PostgreSQL**.
- Repository topology for M1: keep the Flutter application at the repository root and add a sibling **`backend/`** NestJS application in the same repository. This explicit task approval authorizes the required architecture-document update.
- Local development: native Windows 11 installations of Node.js and PostgreSQL; **Docker and WSL must not be required** for everyday development.
- Production direction: direct deployment to a Linux VPS with Node.js, PostgreSQL, Nginx, and `systemd`; provisioning and production deployment are not part of M1.
- Access credentials: short-lived **RS256 JWT access tokens**.
- Refresh credentials: opaque cryptographically random rotating refresh tokens, stored only as protected hashes, with token families, reuse detection, and revocation.
- Secrets/signing material: outside version control; development uses ignored local secret files or environment values, CI creates ephemeral test material, and production receives protected server-side secrets.
- Login methods: phone-number OTP/SMS and email/password. The user may initially register with either method.
- Credential attachment: an authenticated user may later add and verify the missing phone or email/password credential. Both credentials belong to the same stable Laforika account. This is not account merging.
- Identifier conflicts: normalized phone numbers and normalized email addresses are globally unique. An identifier already owned by another account is never silently moved or merged.
- Delivery adapters: OTP/email verification lifecycle is real. Development uses fixture delivery adapters; staging/prod fail closed until real delivery adapters are configured.

### Decisions that remain unresolved and untouched

- **O2:** maps provider.
- **O3:** push provider.
- **O4:** crash/analytics vendor. Do not add remote telemetry.
- **O5:** distribution/signing/publishing. CI artifacts remain debug-signed and non-publishable.
- **O6:** Jalali calendar.
- **O7:** final branding.
- **O8:** legal/privacy/account-data lifecycle. Real authentication remains controlled-test-only; do not externally distribute real-account builds.

### Explicit approvals carried by this task

This prompt explicitly authorizes only the changes needed for M1:

- add the `backend/` NestJS application and PostgreSQL schema/migrations;
- add a new provider-specific authentication ADR and update architecture version/references;
- add the Flutter dependencies required by the frozen Dio/secure-storage/DTO/testing decisions;
- add the backend dependencies listed below;
- modify `.github/workflows/ci.yml` to add backend gates and the required M1 Android-emulator integration job;
- add Android backup exclusions required to keep authenticated secrets/private data out of backup;
- create the initial API contract and generated outputs required by this task;
- create new M1 tests and, only if deliberately selected in the plan, a new initial RTL golden baseline for newly introduced auth UI. Never modify an unrelated visual baseline.

No other architecture, owner decision, deployment, release, signing, toolchain, SDK-target, or vendor change is approved.

## AUTHORITATIVE INPUTS

Read completely before editing:

1. `AGENTS.md`
2. `README.md`
3. `docs/project_inventory.md`
4. `docs/architecture/ARCHITECTURE.md`
5. `docs/architecture/adr/README.md`
6. `docs/architecture/adr/0001-modular-feature-first-architecture.md`
7. `docs/architecture/adr/0002-riverpod-state-and-di.md`
8. `docs/architecture/adr/0003-go-router-navigation.md`
9. `docs/architecture/adr/0004-networking-and-error-model.md`
10. `docs/architecture/adr/0005-local-persistence-and-offline.md`
11. `docs/architecture/adr/0006-authentication-and-session.md`
12. `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `l10n.yaml`, `.gitignore`
13. `.github/workflows/ci.yml`
14. `config/dev.json`, `config/staging.json`, `config/prod.json`
15. current bootstrap, router, Home feature, localization, platform configuration, tests, and `tool/check_import_boundaries.dart`

If an explicit instruction in this prompt conflicts with the current frozen documentation, treat this prompt as the owner approval for that exact M1 change, record it through ADR/change control, and do not broaden it.

## REQUIRED ARCHITECTURE RECORD

Before implementation, create and accept:

- `docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md`

ADR-0007 must record at least:

- custom NestJS API ownership;
- PostgreSQL persistence;
- monorepo topology (`Flutter root + backend/`);
- phone OTP and email/password as two credentials on one stable account;
- credential attachment versus prohibited account merging;
- RS256 access-token model;
- opaque rotating refresh-token model;
- token-family replay detection and revocation;
- server-authoritative authorization;
- development-only fixture delivery and staging/prod fail-closed behavior;
- Windows-native local development and direct Linux VPS deployment direction;
- secret/signing-key handling;
- consequences, rejected alternatives, and revisit conditions.

Do not rewrite accepted ADR-0006. ADR-0007 specializes it after O1 while preserving the provider-neutral Flutter boundary.

Update:

- ADR index;
- `docs/architecture/ARCHITECTURE.md` to the next version;
- assumptions and O1 status;
- high-level/repository structure to describe the backend without weakening the Flutter `app → features → core` contract;
- authentication, networking, security, testing/CI, roadmap, and owner-decision sections;
- `AGENTS.md` with concise backend-specific inspection, security, testing, dependency, generated-file, and quality-gate rules;
- `README.md` with native Windows backend setup and operator commands.

Do not mark M1 completed in `docs/project_inventory.md` during initial implementation. Follow the milestone delivery workflow exactly.

## SCOPE

### In scope — repository and documentation

- Add `backend/` as a NestJS modular monolith using strict TypeScript and npm with a committed lockfile.
- Add backend local-development instructions that work directly in PowerShell with native Node.js and PostgreSQL.
- Add `.env.example` files containing names/placeholders only; ignore actual local environment and key files.
- Add a script or documented commands to generate development RS256 keys outside tracked paths.
- Add a generated OpenAPI authentication contract and a CI drift check, or an equivalently deterministic committed contract generated from source annotations.
- Update documentation and architecture only as required by M1.

### In scope — backend capabilities

- Environment/config validation with deterministic startup failure.
- PostgreSQL schema and committed migrations.
- Health/readiness endpoint.
- Phone OTP request and verification.
- Email/password signup and login.
- Email verification by one-time code using the same secure challenge principles.
- Password reset by verified email code.
- Authenticated attachment/change of phone credential.
- Authenticated attachment/change of email/password credential.
- Credential removal only when another verified sign-in method remains.
- Current-account endpoint.
- Session listing, current-session logout, individual session revocation, and logout-all.
- Short-lived RS256 access tokens with `kid` and a public JWKS endpoint.
- Opaque refresh tokens with rotation, token families, replay detection, and revocation.
- Immediate server-side session-status enforcement for protected API requests; do not rely only on access-token expiry for revocation.
- Sanitized structured security events without raw credentials, OTPs, tokens, passwords, email addresses, phone numbers, request bodies, or personal query values.
- Development-only fixture delivery inbox for integration testing.

### In scope — Flutter capabilities

- Introduce the frozen `core/error`, `core/network`, `core/storage`, and `core/auth` infrastructure only to the extent M1 requires.
- Add the `features/auth/` module with a curated public barrel.
- Implement Persian RTL auth UI with separate phone and email/password forms.
- Implement phone OTP signup/login flow.
- Implement email/password signup/login flow, including email verification where required.
- Implement password-reset UI/flow.
- Implement deterministic session hydration from secure storage.
- Keep access token in memory; persist only the Laforika-owned refresh/session secret material required for restoration.
- Implement single-flight refresh and exactly-one original-request retry.
- Implement protected Home routing, login redirect, validated internal return destination, unknown-session startup surface, and redirect loop prevention.
- Add logout and an auth-focused account-security screen reachable from the current minimal Home screen.
- Allow the authenticated user to attach/change/remove approved credentials through account security.
- List and revoke sessions through account security where proportionate for M1.
- Map backend error codes to localized Persian messages; never display raw exceptions/server details.
- Preserve `fa-IR`, RTL, Vazirmatn, directional APIs, accessibility, and text scaling.

### In scope — testing and CI

- Backend unit, integration, security-invariant, migration, and API-contract tests.
- Flutter unit, widget, router, networking/interceptor, secure-store, controller, repository, and localization tests.
- Android-emulator integration tests against the real local backend and PostgreSQL fixture database.
- CI backend quality/test jobs.
- CI PostgreSQL-backed Android-emulator integration job required from M1.
- Existing Flutter quality and three-flavor debug build matrix.
- Generated localization/DTO/API-contract clean-diff checks.

### Out of scope / do not touch

- Real SMS provider integration or purchase.
- Real SMTP/email service integration or purchase.
- Any fixture delivery in staging or production.
- External distribution of real-account builds.
- Production VPS provisioning, DNS, TLS certificate issuance, Nginx deployment, `systemd` installation, KMS procurement, or production database creation.
- Account deletion, legal retention periods, consent/notice flows, or privacy-policy text before O8.
- OAuth/social login, passkeys, Firebase, cookie sessions, magic-link login, biometric login, or device attestation.
- M2 Home/discovery redesign; keep Home changes limited to auth status, logout, and account-security entry.
- Maps, push, telemetry, Jalali dates, final branding, release signing/publishing.
- Drift/offline/outbox infrastructure.
- Redis, Kafka, RabbitMQ, microservices, Kubernetes, Docker-required local setup, WSL-required setup, GraphQL, or gRPC.
- Generic shared UI catalogs or future feature directories.
- Certificate pinning until production certificates/policy exist.
- Drive-by refactors unrelated to M1.
- `docs/project_inventory.md` completion entry before the reviewed implementation commit and final green CI.

## APPROVED DEPENDENCIES

Use the smallest stable versions compatible with the frozen Flutter/Dart toolchain and Node.js 24. Record exact selected versions in lockfiles and the report.

### Flutter runtime dependencies

Approved only as required:

- `dio`
- `flutter_secure_storage`
- `json_annotation`

### Flutter development dependencies

Approved only as required:

- `build_runner`
- `json_serializable`
- `mocktail`
- Flutter SDK `integration_test`

Riverpod and `go_router` already exist. Do not add another state, DI, router, HTTP, result/error, forms, localization, responsive, or service-locator package.

### Backend runtime dependencies

Approved categories/packages:

- NestJS core/platform packages generated by the official Nest application scaffold
- `@nestjs/config`
- `@nestjs/swagger`
- `class-transformer`
- `class-validator`
- Prisma CLI/client for PostgreSQL migrations and data access
- an Argon2id implementation compatible with Node.js 24
- `jose` for RS256/JWK/JWKS operations
- `libphonenumber-js` for authoritative phone normalization
- `helmet`

Use Node's built-in `crypto` and `randomUUID` instead of adding token/UUID packages.

### Backend development dependencies

Approved only as required:

- official NestJS TypeScript/ESLint/Prettier/Jest scaffold dependencies
- `supertest`
- TypeScript type packages required by the selected approved dependencies

Do not add Redis, a second ORM/query builder, Passport unless demonstrably required, a second validation library, a logging SaaS, an email/SMS SDK, or an auth framework that owns sessions.

If one approved package is incompatible with Node.js 24 or the frozen Flutter toolchain, choose the closest maintained package serving the same approved purpose, explain the substitution before editing, and do not change the underlying architecture.

## REQUIRED REPOSITORY SHAPE

Keep the existing Flutter structure and add only purposeful M1 files. The expected high-level addition is:

```text
backend/
├─ src/
│  ├─ main.ts
│  ├─ app.module.ts
│  ├─ config/
│  ├─ common/
│  │  ├─ errors/
│  │  ├─ guards/
│  │  ├─ logging/
│  │  └─ security/
│  ├─ database/
│  ├─ auth/
│  │  ├─ application/
│  │  ├─ domain/
│  │  ├─ infrastructure/
│  │  └─ presentation/
│  └─ users/
├─ prisma/
│  ├─ schema.prisma
│  └─ migrations/
├─ test/
├─ scripts/
├─ .env.example
├─ package.json
├─ package-lock.json
├─ tsconfig*.json
└─ README.md

lib/
├─ core/
│  ├─ auth/
│  ├─ error/
│  ├─ network/
│  └─ storage/
└─ features/
   └─ auth/
      ├─ auth.dart
      ├─ data/
      └─ presentation/

integration_test/
└─ auth_flow_test.dart
```

This tree is illustrative, not permission to create empty folders or ceremonial layers. Backend authentication has real business/security rules, so purposeful internal layering is appropriate. Flutter layering remains pragmatic; do not add empty `domain/` merely to mirror the backend.

## BACKEND SECURITY CONTRACT

### User/account model

- Generate an opaque UUID account ID; expose it as `accountId`.
- A user may have:
  - one normalized verified phone credential;
  - one normalized verified email credential with a password hash;
  - or both.
- Initial signup may use either method.
- Attaching a second method updates the same account.
- Never create a hidden second account during credential attachment.
- Never merge accounts automatically.
- Enforce global uniqueness at both service and database levels.
- If an identifier belongs to another account, return a stable conflict/recovery code without disclosing unrelated account information.
- Removing a credential is permitted only when at least one other verified login method remains.
- Disabled accounts cannot authenticate, refresh, or access protected endpoints.

### Normalization

- Phone numbers are normalized and stored in E.164 format.
- Treat Iran as the default region for national-form numbers, while accepting valid explicit international numbers.
- Convert Persian/Arabic digits to Latin before authoritative parsing.
- Email is trimmed, Unicode-normalized, and canonicalized according to one documented case-insensitive Laforika policy. Do not implement provider-specific dot/plus rewriting.
- Store and compare normalized identifiers; preserve a display value only if genuinely needed.

### Passwords

- Never store, encrypt, return, log, or expose plaintext passwords.
- Hash server-side with Argon2id using a unique salt generated by the selected library.
- Keep Argon2 parameters centralized, documented, and covered by a verification/rehash test.
- Use a secret password pepper only if implemented consistently through protected configuration; never commit it.
- Minimum length: 15 characters.
- Maximum accepted length: at least 64 characters; use 128 unless the implementation has a documented reason not to.
- Allow spaces, Unicode, and password-manager-generated values.
- Do not impose arbitrary composition rules or forced periodic changes.
- Reject a maintained deterministic set of commonly compromised passwords without calling an external service during authentication.
- Use generic email/password login failures to prevent account enumeration.
- Password change/reset revokes all active sessions and refresh-token families for that account.

### OTP and verification codes

Apply the same core challenge engine to phone OTP and email verification/reset codes where practical.

- Generate codes with a cryptographically secure RNG.
- Use six numeric digits for phone OTP and development email verification/reset codes.
- Expire after five minutes.
- Single use only.
- Maximum five verification attempts per challenge.
- Minimum 60 seconds before resend.
- Enforce rolling destination and request-origin rate limits that survive process restart.
- New challenge generation invalidates older active challenges for the same destination/purpose, but must not reset rolling abuse counters.
- Store only a keyed HMAC/hash representation of the code using an environment secret; never store plaintext codes.
- Compare in constant-time where applicable.
- Mark challenge consumption atomically in PostgreSQL so concurrent verifies cannot both succeed.
- Use generic request responses where necessary to prevent identifier enumeration.
- Return masked destinations only.
- Do not log codes or include them in ordinary auth responses.

### Development fixture delivery

- Define delivery interfaces for SMS and email verification messages.
- Implement development-only fixture adapters that receive the real generated code.
- Provide a development-only fixture inbox endpoint or test harness used by integration tests.
- Fixture access requires an explicit dev-only enable flag and a fixture access secret.
- Fixture routes must not register in staging/prod.
- Backend startup must reject fixture delivery when environment is not `dev` or `test`.
- Staging/prod startup must fail closed if a required real delivery adapter is absent.
- Never write fixture codes to application logs, tracked files, normal API responses, analytics, or crash output.

### Access tokens

- RS256 JWT.
- Ten-minute lifetime.
- Required claims: issuer, audience, subject/account ID, session ID, JWT ID, issued-at, expiration.
- Include `kid` in the protected header.
- Validate algorithm, issuer, audience, signature, timestamps, and required claims explicitly.
- Expose public verification keys through a JWKS endpoint.
- Do not expose the private key.
- Load signing material from ignored local paths/environment values; CI generates ephemeral keys.
- Support at least current-key identification and a documented rotation path.

### Refresh tokens and sessions

- Generate at least 256 bits of cryptographically random entropy and encode safely for transport.
- Refresh tokens are opaque; do not use JWT refresh tokens.
- Store only a keyed hash/HMAC representation using a protected refresh-token secret.
- Bind each token to a server session and token family.
- Rotate on every successful refresh.
- Mark the old token used/replaced in the same transaction that persists the replacement.
- Reuse of a used, replaced, revoked, expired, unknown, or otherwise invalidated family token revokes the entire token family and records a sanitized replay event.
- A refresh request must be transactionally safe under concurrency.
- Session expiration policy:
  - 30-day absolute maximum;
  - update last-seen on successful refresh;
  - no unbounded session.
- Protected requests must confirm that the referenced session/account is still active so explicit revocation takes effect immediately, not only after access-token expiry.
- Current logout revokes the current session/family.
- Logout-all, password reset/change, account disablement, and confirmed replay revoke all applicable sessions.
- Session list exposes only safe metadata: session ID, created/last-active timestamps, coarse device label, current-session flag, and revoked state where appropriate.
- Do not store raw access/refresh tokens, passwords, OTPs, full IP addresses, or full user-agent strings in audit/session records.

### Database transactions and constraints

At minimum, model purposeful equivalents of:

- users/accounts;
- OTP/verification challenges;
- auth sessions;
- refresh-token rotation records;
- persistent auth rate-limit windows/counters;
- sanitized security events.

Requirements:

- PostgreSQL foreign keys and uniqueness constraints are authoritative.
- Use transactions and row locks for challenge consumption, credential attachment, refresh rotation, replay revocation, and password-reset/session-revocation operations.
- Add indexes for normalized identifiers, active challenges, session/family lookups, token hashes, expiry cleanup, and rate-limit lookups.
- Migration history is committed.
- Tests migrate a clean database from zero and verify rollback/reset strategy for test databases.
- No production seed users, credentials, OTPs, keys, or real personal data.

### API and error contract

- Version API routes under `/v1`.
- Generate and commit a deterministic OpenAPI contract from backend source annotations.
- Use stable machine-readable error codes.
- Use one sanitized error envelope; do not leak stack traces, SQL errors, token reasons, password policy internals, or account existence through uncontrolled messages.
- Validation errors may identify invalid submitted fields but must not disclose whether another person's account exists except through the approved credential-conflict path after the requester has proven control where applicable.
- Add a request/correlation ID that is safe to return and log.
- Backend messages are not the Flutter UI localization source. Flutter maps codes to ARB strings.

## MINIMUM API SURFACE

Names may be refined only if the resulting OpenAPI contract remains cohesive and all capabilities/tests are preserved.

### Public/authentication

- `GET /v1/health`
- `GET /v1/auth/jwks`
- `POST /v1/auth/phone/challenges` — request signup/login phone OTP
- `POST /v1/auth/phone/challenges/{challengeId}/verify` — verify and signup/login
- `POST /v1/auth/email/sign-up`
- `POST /v1/auth/email/verify`
- `POST /v1/auth/email/sign-in`
- `POST /v1/auth/password/reset-challenges`
- `POST /v1/auth/password/reset`
- `POST /v1/auth/refresh`

### Authenticated account/session

- `GET /v1/account/me`
- `POST /v1/account/phone/challenges`
- `POST /v1/account/phone/challenges/{challengeId}/verify`
- `DELETE /v1/account/phone`
- `POST /v1/account/email/challenges`
- `POST /v1/account/email/verify`
- `DELETE /v1/account/email`
- `PUT /v1/account/password`
- `GET /v1/auth/sessions`
- `DELETE /v1/auth/sessions/{sessionId}`
- `POST /v1/auth/logout`
- `POST /v1/auth/logout-all`

### Development/test only

- A fixture inbox read/consume endpoint under `/v1/dev/fixtures/...`, registered only in `dev`/`test` and protected by the fixture secret.

Do not add account deletion until O8 defines deletion and retention behavior.

## FLUTTER ARCHITECTURE CONTRACT

### Core auth contract

Create provider-neutral equivalents of:

- `AuthState`: `unknown`, `unauthenticated`, `authenticated(principal)`;
- `AuthPrincipal` exposing only stable opaque `accountId` and minimum non-sensitive account state needed by UI;
- session adapter/gateway contract for hydration, access-token retrieval, refresh, credential acceptance, revocation/logout, and secure clearing;
- `authControllerProvider` as the sole owner of application session state;
- a stable router-refresh `Listenable` bridge.

The auth feature supplies the custom API adapter through its public barrel, and app composition provides the override. `core/` must not import `features/`.

### Dio and refresh behavior

- One configured Dio instance behind `dioProvider`.
- Base URL comes from validated `AppConfig`.
- Add sane connect/send/receive timeouts.
- Request-auth interceptor attaches the in-memory access token only to eligible API requests.
- Auth repository calls can mark login/refresh/fixture routes to skip request authentication and recursive refresh.
- On eligible 401:
  - use one shared in-flight refresh future/completer;
  - concurrent requests await the same refresh;
  - retry each original request at most once;
  - never recursively refresh the refresh call;
  - transition to unauthenticated and securely clear Laforika-owned credentials when refresh definitively fails because the session is invalid/revoked/expired/replayed;
  - distinguish network failure from definitive auth rejection so a temporary network outage does not silently destroy a potentially valid refresh secret.
- General automatic retry is limited to safe/idempotent requests with bounded backoff; do not retry credential submission, OTP verification, password change, refresh, or logout blindly.
- Debug-development logging is sanitized and disabled in profile/release.
- Redact `Authorization`, cookies, token-like fields, passwords, OTP/code fields, email, phone, and personal query/body values. Test the redactor.

### Secure storage

- Add a thin `SecureStore` contract in `core/storage/` backed by `flutter_secure_storage`.
- Partition key names by environment.
- Persist only refresh/session secret material required for restoration; keep access JWT in memory.
- Never store password, OTP, email/password form contents, raw error bodies, or personal profile data in secure storage.
- Clear the current environment's auth keys on confirmed logout/session invalidation.
- Configure Android/iOS storage options conservatively for device-bound app secrets.
- Exclude authenticated private data from Android backup through platform backup rules or an explicitly safer equivalent; do not alter unrelated platform identity/SDK settings.

### Session startup

- Initial state is `unknown`.
- Hydration reads the environment-scoped refresh secret and attempts a real refresh/session restore.
- No stored secret → `unauthenticated`.
- Successful restore → `authenticated`.
- Definitive invalid/revoked/expired response → clear secret and become `unauthenticated`.
- Temporary transport failure → show a deterministic recoverable startup/error state; do not flash login or destroy the refresh token.
- Add a user-triggered retry path.

### Routes and redirects

Add auth routes through `features/auth/auth.dart` and aggregate only through `app/router/routes.dart`.

At minimum define named constants for:

- startup/session-restoration surface;
- auth method selection/login;
- phone entry;
- OTP verification;
- email/password signup/login;
- password reset;
- account security.

Home remains `/` and becomes protected.

Implement the architecture redirect matrix exactly:

| Session | Destination | Required result |
|---|---|---|
| unknown | any | deterministic startup/session-restoration surface |
| unauthenticated | public/auth | allow |
| unauthenticated | protected | login/auth entry with validated internal return destination |
| authenticated | login/auth-only | validated return destination, otherwise Home |
| authenticated | public/protected | allow |

- Preserve return destinations only when they resolve to a known registered internal route.
- Reject external schemes/hosts, malformed values, auth-loop destinations, startup destinations, and unknown routes.
- Do not use required `extra` data.
- Do not reconstruct the `GoRouter` when session state changes.
- Test direct deep links, cold start, return preservation, malformed destinations, and loop prevention.

### Auth UI and account-security behavior

- All text comes from `lib/l10n/app_fa.arb`; regenerate and commit localization outputs.
- Persian RTL is the only configured locale.
- Phone and email/password are visibly separate forms/flows.
- Accept Persian/Arabic digits in phone/OTP inputs and normalize before transport; never localize stored/wire values.
- Use appropriate keyboard/autofill hints without persisting form data.
- Mask phone/email destinations on verification screens.
- Include loading, validation, retry/resend cooldown, incorrect/expired code, rate-limit, network, server, and success states.
- Prevent double submission.
- Respect minimum 48dp targets, semantics, text scaling, focus order, keyboard insets, and directional layout APIs.
- Do not reveal whether an unrelated account exists through UI wording.
- Current Home changes are limited to:
  - authenticated account indication using non-sensitive display data;
  - account-security navigation;
  - logout.
- Account security supports:
  - showing which login methods are verified;
  - attaching/changing phone;
  - attaching/changing email/password;
  - removing a credential only when another remains;
  - changing password;
  - listing/revoking sessions and logout-all where supported.
- Account deletion is absent until O8.

## CONFIGURATION CONTRACT

### Flutter checked config

Networking now exists, so `AppConfig` and `Env` must validate the API base URL required by M1.

- `dev`: checked default suitable for the Android emulator, normally `http://10.0.2.2:3000/v1`.
- Document an ignored local override file for iOS simulator/physical-device host addressing; do not create machine-specific tracked config.
- `staging` and `prod`: use explicit non-secret HTTPS values. If real hosts are not available, use documented non-routable `.invalid` placeholders rather than invented real domains or secrets. Clearly state those builds are not deployable until replaced.
- Non-development URLs remain HTTPS-only.
- Do not place fixture secrets, JWT keys, database URLs, SMS/email credentials, or signing material in Flutter `config/*.json`.

### Backend environment

Validate all required values at startup. Use names equivalent to:

- `APP_ENVIRONMENT`
- `PORT`
- `DATABASE_URL`
- `JWT_ISSUER`
- `JWT_AUDIENCE`
- `JWT_ACTIVE_KID`
- `JWT_PRIVATE_KEY_PATH`
- `JWT_PUBLIC_KEY_PATH`
- `REFRESH_TOKEN_PEPPER`
- `OTP_CODE_PEPPER`
- `PASSWORD_PEPPER` if used
- `FIXTURE_DELIVERY_ENABLED`
- `FIXTURE_INBOX_KEY`
- allowed CORS/development documentation settings where required

Rules:

- tracked `.env.example` values are placeholders only;
- actual `.env*`, keys, certificates, dumps, and local databases are ignored;
- staging/prod reject fixture delivery;
- prod rejects debug documentation/logging and unsafe/default secrets;
- no fallback secret literals;
- no raw environment/config values in fatal responses or logs.

## REQUIRED TESTS

Every new unit of logic requires matching tests. Avoid coverage theater; focus on security and behavior.

### Backend unit tests

At minimum:

- email and phone normalization, including Persian/Arabic digits and Iran default-region cases;
- password policy, Argon2id hash/verify, wrong password, and rehash detection;
- challenge code generation range/format, protected storage representation, expiry, attempt count, resend/cooldown, invalidation, and one-time use;
- destination/IP rate-limit windows and restart-persistent behavior;
- access-token issue/verification, claim validation, wrong issuer/audience/algorithm, expiry, and `kid` handling;
- refresh-token entropy/format/hash handling;
- rotation success;
- concurrent refresh safety;
- replay/reuse detection and family revocation;
- logout, individual revocation, logout-all, password-change/reset revocation;
- session-active check on protected requests;
- uniqueness/conflict and no-automatic-merge behavior;
- removal blocked when it would leave no login method;
- fixture adapters rejected outside dev/test;
- sensitive-field redaction and sanitized error envelope.

### Backend integration/e2e tests with PostgreSQL

At minimum:

1. Apply migrations to a clean test database.
2. Phone signup through real challenge lifecycle + fixture delivery.
3. Phone login to existing account.
4. Email/password signup + email verification.
5. Email/password login success and generic failure.
6. Phone-created user attaches verified email/password, logs out, then logs in by email to the same `accountId`.
7. Email-created user attaches verified phone, logs out, then logs in by phone to the same `accountId`.
8. Duplicate credential attachment is rejected without merging accounts.
9. Password reset works and revokes prior sessions.
10. Refresh rotates tokens; prior-token reuse revokes the family.
11. Revoked session cannot access protected endpoint even with an unexpired access token.
12. Current logout, individual session revocation, and logout-all.
13. Fixture routes absent/blocked in staging/prod configuration tests.
14. No sensitive values appear in captured logs/errors.
15. Generated OpenAPI output matches the committed contract.

Use isolated test data and clean it deterministically. Never use real accounts or destinations.

### Flutter unit tests

At minimum:

- `Failure`/`Result` behavior and Dio error mapping;
- HTTP redaction for headers, cookies, tokens, passwords, OTPs, email, phone, and body/query values;
- secure-store environment partitioning, read/write/delete, and failure behavior;
- auth adapter credential acceptance, hydration, definitive invalidation, and temporary transport failure;
- single-flight refresh with concurrent 401s;
- one retry only and recursion prevention;
- auth controller state transitions;
- login/OTP/email/password/account-security controllers;
- backend error-code to localized failure mapping;
- phone/OTP numeral normalization;
- return-destination validation.

### Flutter widget/router tests

At minimum:

- preserve existing root `fa-IR` and RTL assertion;
- unknown startup surface without login flash;
- unauthenticated protected redirect;
- authenticated auth-route redirect;
- validated return destination and invalid/external destination rejection;
- redirect-loop prevention;
- phone and email/password form loading/error/validation/success states;
- OTP resend cooldown and incorrect/expired/rate-limited states;
- password reset states;
- account-security credential presence/absence, removal guard, session list/revocation, and logout states;
- text scaling and no critical clipping at a large supported scale;
- semantics for icon-only actions and credential/session controls.

### Golden/RTL

- Existing golden coverage is absent. Do not modify unrelated baselines.
- In the plan, explicitly decide whether to create one stable RTL auth-screen golden. If created, this prompt authorizes only that new baseline and requires review evidence. Do not run a broad `--update-goldens` command.

### Android integration test

Create a real end-to-end dev flow against a started backend and PostgreSQL test database. It must not override the auth provider with a fake.

Primary flow:

1. Launch with no stored session and observe deterministic startup → unauthenticated auth entry.
2. Request phone signup OTP.
3. Test harness reads the code from the protected dev fixture inbox.
4. Verify OTP and land on protected Home.
5. Open account security.
6. Attach and verify email/password to the same account using fixture email delivery.
7. Confirm the stable account ID does not change.
8. Log out through the real revocation endpoint.
9. Sign in using the newly attached email/password.
10. Relaunch/restore and confirm secure session hydration.
11. Exercise one forced access-token expiry/401 path and confirm single-flight refresh without user-visible logout.
12. Log out and confirm protected Home redirects to auth.

Add a second focused integration path only if needed to prove email-first → phone attachment without making CI unreliable. Backend e2e tests must cover both directions regardless.

## CI REQUIREMENTS

Modify `.github/workflows/ci.yml` only for M1 and preserve existing gates.

### Backend quality job

Use Node.js 24 and a PostgreSQL service. Run actual equivalents of:

```bash
npm ci --prefix backend
npm run format:check --prefix backend
npm run lint --prefix backend
npm run typecheck --prefix backend
npm run prisma:format:check --prefix backend
npm run prisma:validate --prefix backend
npm run test --prefix backend
npm run test:e2e --prefix backend
npm run openapi:check --prefix backend
```

Generate ephemeral RS256 test keys and test secrets during the job; never commit them or print secret values.

### Flutter quality job

Preserve and extend:

```bash
flutter pub get
flutter gen-l10n
# required DTO/provider generation when introduced
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test --coverage
dart run tool/check_import_boundaries.dart
```

Do not run build_runner if no source generator beyond `gen_l10n` is selected; report the actual generator policy.

### Three-flavor Android build matrix

Preserve dev/staging/prod debug builds with checked configuration. Artifacts remain non-publishable.

### M1 Android-emulator integration job

Add a reliable job that:

1. starts PostgreSQL;
2. applies backend migrations;
3. generates ephemeral keys/secrets;
4. starts the backend in test/dev fixture mode;
5. waits for health readiness;
6. starts an Android emulator;
7. runs `integration_test/auth_flow_test.dart` with the `dev` flavor and checked dev config;
8. always captures sanitized backend/test diagnostics on failure without dumping secrets or personal values;
9. cleans up processes.

Pin third-party GitHub Actions to maintained major versions or immutable SHAs according to repository convention. Do not introduce publishing permissions.

## LOCAL VERIFICATION

Run and report real results for all applicable commands.

### Backend

```bash
npm ci --prefix backend
npm run format:check --prefix backend
npm run lint --prefix backend
npm run typecheck --prefix backend
npm run prisma:format:check --prefix backend
npm run prisma:validate --prefix backend
npm run test --prefix backend
npm run test:e2e --prefix backend
npm run openapi:check --prefix backend
```

Also prove a clean database migration from zero. Report the PostgreSQL version and whether the service was local/native or CI-provided; do not expose connection credentials.

### Flutter

```bash
flutter pub get
flutter gen-l10n
# Run only if selected generators require it:
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

### Flavor builds

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

### Android-emulator integration

With the backend and PostgreSQL running:

```bash
flutter test integration_test/auth_flow_test.dart --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json \
  -d "$EMULATOR_ID"
```

### Repository hygiene

```bash
git diff --check
git status --short
git diff --stat
git diff
```

Inspect tracked files for accidental secrets, PEM/private keys, `.env` values, database dumps, OTPs, tokens, passwords, real email/phone data, debug prints, and generated-file drift. If any secret is staged, stop, unstage it, and report it.

Do not claim success for commands not run. Report environment limitations exactly.

## ACCEPTANCE CRITERIA

### Architecture/documentation

- [ ] ADR-0007 is accepted and indexed without modifying ADR-0006 history.
- [ ] Architecture is versioned and updated for the approved custom backend/session model and repository topology.
- [ ] O1 is recorded as resolved; O2–O8 remain untouched except the explicit O8 controlled-testing gate.
- [ ] `AGENTS.md` and README describe the backend rules and native Windows setup accurately.
- [ ] No M1 completion inventory entry is added before reviewed implementation/final CI.

### Backend

- [ ] NestJS backend starts with validated configuration and PostgreSQL.
- [ ] Clean migrations succeed.
- [ ] Phone OTP signup/login works through the real challenge engine and dev fixture delivery.
- [ ] Email/password signup/login and email verification work.
- [ ] Password reset works and revokes prior sessions.
- [ ] Phone/email credentials can be attached to the same account without changing `accountId`.
- [ ] Duplicate identifiers do not merge accounts.
- [ ] Credential removal cannot leave the user with no sign-in method.
- [ ] Passwords use Argon2id; OTP/email codes and refresh tokens are never stored plaintext.
- [ ] RS256 access tokens, JWKS, claims, `kid`, and session-active enforcement work.
- [ ] Refresh rotation, single-use records, replay detection, family revocation, current logout, individual revocation, and logout-all work.
- [ ] Dev fixture delivery is unavailable outside dev/test and no code is logged/returned through ordinary auth responses.
- [ ] Error/log output is sanitized and enumeration-resistant.
- [ ] OpenAPI contract is deterministic and committed/generated cleanly.

### Flutter

- [ ] `AuthState` unknown/authenticated/unauthenticated contract is implemented.
- [ ] Startup hydration is deterministic and handles temporary network failure without login flash or premature credential deletion.
- [ ] One shared Dio instance, auth interceptor, sanitized logging, and bounded retry behavior follow architecture.
- [ ] Single-flight refresh handles concurrent 401s and retries each request once.
- [ ] Secure storage persists only environment-scoped refresh/session secret material; access token remains in memory.
- [ ] Phone and email/password signup/login forms are separate and fully localized in Persian RTL.
- [ ] OTP/email verification, resend cooldown, password reset, loading/error/success states, and double-submit prevention work.
- [ ] Protected Home routing and validated return-destination behavior match the redirect matrix.
- [ ] Account security supports credential attachment/change/removal guard, password change, session listing/revocation, logout, and logout-all as scoped.
- [ ] No raw backend error, token, password, OTP, email, phone, or personal data reaches logs or UI.
- [ ] Existing M0 identity, flavors, localization, theme, and import boundaries remain intact.

### Tests/CI

- [ ] Backend unit/e2e/security/migration/API-contract tests pass.
- [ ] Flutter unit/widget/router tests pass.
- [ ] Android real-backend integration test passes.
- [ ] Existing and new generated output regenerates to a clean tree.
- [ ] Format, analyze, tests, import boundaries, and all three debug flavor builds pass.
- [ ] CI contains backend gates and the M1 emulator integration job, with final green results before review archive creation.

### Security/hygiene

- [ ] No secrets, keys, tokens, signing material, real account data, dumps, or private config are tracked.
- [ ] Android backup behavior excludes authenticated private data.
- [ ] Staging/prod cannot use fixture delivery.
- [ ] No remote telemetry, external distribution, account deletion, production provider, or later-milestone infrastructure is introduced.

## CONSTRAINTS

- No architecture or owner-decision changes beyond those explicitly approved in this prompt.
- Preserve Flutter 3.44.6, Dart 3.12.2, app identity, flavors, minSdk 24, Riverpod, `go_router`, Dio, plain sealed `Failure`/`Result`, localization direction, typography, and CI artifact policy.
- Do not change iOS deployment target.
- Do not add a service locator.
- Do not add a second HTTP client, router, state tool, DI tool, ORM, validation library, database, or auth/session framework.
- Do not create empty layers or speculative services.
- Do not hand-edit generated Dart/OpenAPI/Prisma output.
- Do not surface raw backend messages directly in Flutter.
- Do not log sensitive request/response data even in debug.
- Do not weaken rate limits or security checks merely to make tests pass; tests must use controlled time/clock/random abstractions where needed.
- Do not require Docker or WSL for local development.
- Do not modify signing, release publishing, target SDK, store config, or deployment infrastructure.
- Check-in mode: **branch + atomic commits + push + pull request + green CI + clean reviewed-source archive; then stop for owner review. Do not merge.**

## STEP 0 — INSPECT

1. Read every authoritative input listed above in full.
2. Inspect current dependencies, generated files, configuration, native manifests/backup rules, CI, router, bootstrap, tests, public barrels, and import-boundary checker.
3. Confirm M0 is the baseline and M1 is the only work package.
4. Identify the exact architecture text superseded/clarified by resolved O1.
5. Confirm no backend already exists and no unrecorded M1 code is present.
6. Verify Node.js 24/PostgreSQL tooling availability. Native Windows is the supported local path; absence of Docker/WSL is not a blocker.
7. Identify any genuine blocker that cannot be resolved within the explicit approvals. Do not invent a blocker from decisions already resolved here.

## STEP 1 — PLAN

Before editing, report a concise but complete plan containing:

- architecture/ADR changes;
- backend modules/schema/migrations/API surface;
- Flutter file/module surface and provider dependency graph;
- session/refresh/replay transaction design;
- fixture delivery isolation design;
- route redirect matrix implementation;
- generated-code strategy;
- tests and CI job changes;
- approved dependency additions with purpose;
- exact commands to run;
- likely risks, especially circular Dio/auth dependencies, refresh concurrency, route loops, fixture leakage, migration isolation, and secret hygiene.

Proceed without waiting unless an explicit guardrail outside this prompt blocks the work.

## STEP 2 — IMPLEMENT

Implement in dependency order:

1. ADR-0007 and architecture contract.
2. Backend scaffold/config/database/migrations.
3. Backend security primitives and auth/session API.
4. Backend tests and OpenAPI generation.
5. Flutter error/network/storage/auth core contracts.
6. Flutter custom API auth feature and forms.
7. Router protection/startup hydration/account security.
8. Flutter tests.
9. Android integration flow.
10. CI and operator documentation.

Keep the diff strictly inside M1. Use atomic transactions and tests with the implementation. Never hand-edit generated files.

## STEP 3 — VERIFY

Run every applicable local verification command above. Fix failures rather than waiving them. Inspect the full diff and tracked-file hygiene before committing.

The task is not ready for PR while an applicable local gate fails. If a command cannot run, report the exact missing tool/environment and still run all unaffected gates.

## STEP 4 — CHECK IN

Follow the repository milestone workflow.

- Branch: `feat/m1-custom-auth`
- Never commit directly to `main`/`master`.
- Use Conventional Commits, atomic by logical change. Recommended logical sequence, adjusted only when the actual diff warrants it:
  1. `docs(architecture): record custom authentication decision`
  2. `feat(backend): add secure custom authentication service`
  3. `feat(auth): add mobile authentication vertical slice`
  4. `test(auth): add real authentication coverage`
  5. `ci(auth): add backend and emulator authentication gates`
  6. `docs(setup): document m1 authentication development`
- Push and open/update one PR using the exact `AGENTS.md` PR body.
- Include UI screenshots for phone, email/password, OTP, startup recovery, and account-security states.
- Wait for all PR CI jobs to pass.
- Create a clean source archive from the exact green PR-head implementation commit. Exclude `.git`, `node_modules`, Flutter/Dart caches, builds, coverage, database files/dumps, `.env*` secrets, PEM/key files, fixture inbox contents, local configs, and signing material.
- Report archive filename and exact source commit SHA.
- Stop for owner/external review. **Do not merge and do not update `docs/project_inventory.md` yet.**

After later owner/external review, fixes must remain on this branch. Only after reviewed implementation and final green CI may `docs/project_inventory.md` be updated once, followed by its own CI and explicit merge approval.

## REPORT BACK

Return a concise final report with:

- Status: done / partial / blocked
- Summary
- Architecture version and ADR impact
- Exact O1 implementation recorded
- Files changed grouped by docs/backend/Flutter/tests/CI
- Dependencies added with exact versions and reasons
- PostgreSQL migrations/schema summary
- API endpoints delivered
- Security controls delivered
- Flutter flows delivered
- Tests added/updated
- Commands run with pass/fail/not-run and exact reasons
- CI jobs/results
- Branch, commits, PR URL
- Reviewed-source archive filename and exact PR-head SHA
- Secret/PII hygiene result
- Approved deviations, if any
- Remaining blockers/owner decisions, especially O8 controlled-testing limitation
- Explicit confirmation that the PR was not merged and project inventory was not updated prematurely
