# ADR-0007 — Custom authentication backend and session security

**Status:** Accepted · **Date:** 2026-07-22

## Context

Owner decision O1 is resolved: Laforika owns a custom authentication API. ADR-0006 remains the
provider-neutral Flutter session boundary. This ADR records the concrete backend, credential,
token, and delivery model required for M1 without rewriting ADR-0006 history.

## Decision

### Ownership and topology

- Laforika owns a **TypeScript + NestJS** authentication API on **Node.js 24 LTS**.
- Persistence is **PostgreSQL** with committed Prisma migrations.
- Repository topology for M1: Flutter application at the repository root plus a sibling
  **`backend/`** NestJS application in the same repository (monorepo). The Flutter
  `app → features → core` contract is unchanged.
- Local development uses native Windows Node.js and PostgreSQL. Docker and WSL must not be
  required for everyday development.
- Production direction is direct deployment to a Linux VPS (Node.js, PostgreSQL, Nginx,
  `systemd`). Provisioning and production deployment are out of M1 scope.

### Credentials on one stable account

- Login methods: **phone-number OTP/SMS** and **email/password**.
- Initial signup may use either method. An authenticated user may later attach and verify the
  missing phone or email/password credential on the **same** stable opaque `accountId`.
- This is credential attachment, **not** account merging. Normalized phone numbers and normalized
  emails are globally unique. An identifier owned by another account is never silently moved or
  merged.
- Credential removal is allowed only when another verified sign-in method remains.
- Disabled accounts cannot authenticate, refresh, or access protected endpoints.

### Access and refresh security

- Access credentials: short-lived **RS256 JWT** access tokens (10-minute lifetime) with required
  claims (`iss`, `aud`, `sub`/`accountId`, session id, `jti`, `iat`, `exp`) and `kid` in the
  protected header. Public keys are exposed via JWKS; private keys never leave protected server
  configuration.
- Refresh credentials: opaque cryptographically random rotating refresh tokens (≥256 bits of
  entropy), stored only as keyed hashes, bound to sessions and **token families**, with reuse
  detection and family revocation.
- Protected API requests enforce **server-side session status** immediately; revocation does not
  wait for access-token expiry alone.
- Secrets and signing material live outside version control. Development uses ignored local
  secret files or environment values; CI creates ephemeral test material; production receives
  protected server-side secrets.

### Delivery adapters

- OTP and email verification lifecycles are real.
- Development uses fixture delivery adapters and a protected fixture inbox for integration tests.
- Staging and production fail closed until real delivery adapters are configured. Fixture
  delivery must not register outside `dev`/`test`.

### Flutter boundary

- ADR-0006's provider-neutral `AuthState` / `authControllerProvider` / secure-store /
  redirect contract remains authoritative on the client.
- The auth feature exports the custom API adapter; `app/` supplies the override. `core/` does not
  import `features/`.
- Laforika-owned refresh/session secret material may be persisted in `flutter_secure_storage`;
  access JWTs remain in memory. Single-flight refresh retries the original request once.

### Authorization authority

Server-side authorization is authoritative. Client route guards are UX only.

## Alternatives rejected

- **Firebase Auth, OAuth social login, cookie sessions, magic links, passkeys.** Rejected for
  M1: Laforika must own account/session data and Iran-market delivery constraints favor a custom
  API with fixture adapters during controlled testing.
- **JWT refresh tokens.** Rejected: opaque rotating refresh tokens with family reuse detection
  better contain replay.
- **HS256 shared-secret access tokens.** Rejected: RS256 + JWKS supports key rotation and
  verification without sharing signing material with verifiers.
- **Separate backend repository for M1.** Rejected: slows the vertical slice; monorepo keeps
  contract and CI co-located while preserving Flutter module boundaries.
- **Docker/WSL-required local development.** Rejected: native Windows Node.js + PostgreSQL is the
  supported everyday path.
- **Redis or a second messaging bus for rate limits / sessions.** Rejected for M1: PostgreSQL
  persists rate-limit windows and session state; revisit only if scale requires it.
- **Stubbed or fake Flutter production authentication.** Rejected: only delivery of SMS/email
  messages may use development fixtures.

## Consequences

- M1 introduces NestJS, Prisma, PostgreSQL, Dio, secure storage, and auth UI/routes under the
  approved dependency list.
- Architecture documentation and `AGENTS.md` gain backend inspection, security, testing, and
  quality-gate rules without weakening Flutter import boundaries.
- Real authentication remains controlled-test-only until O8 defines the account-data lifecycle
  and external-distribution gate.
- Staging/prod builds require non-fixture delivery configuration before they can authenticate
  end users.

## Revisit when

- Production delivery adapters (SMS/SMTP) are selected and configured.
- Key management moves to a dedicated KMS or rotation automation requires operational change.
- Scale or multi-region needs outgrow single-VPS PostgreSQL session/rate-limit storage.
- Account deletion, retention, or consent requirements (O8) change auth API surface.
- The Flutter provider-neutral boundary itself changes (would require superseding ADR-0006).
