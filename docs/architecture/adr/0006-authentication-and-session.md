# ADR-0006 — Authentication and session model

**Status:** Accepted · **Date:** 2026-07-21

## Context

Authentication is a confirmed requirement, but the backend/identity provider is not yet chosen
(owner decision O1 — custom API, Firebase Auth, OTP/SMS, OAuth, etc.). The application needs a
stable session and route-protection boundary without assuming that Laforika owns JWTs, refresh
tokens, or credential persistence.

## Decision

Adopt a **provider-neutral application session contract** now; finalize provider-specific token or
SDK behavior after O1.

- **Session:** `authControllerProvider` exposes
  `AuthState = { unknown, authenticated(principal), unauthenticated }`. The principal exposes an
  opaque, stable `accountId` for persistence/provider scoping only. `unknown` covers
  provider/session hydration and prevents a login flash during startup.
- **Provider adapter:** `core/auth/` defines the provider-neutral session contract and overridable
  provider. The auth feature exports the selected provider adapter through its public barrel, and
  app composition supplies the override. Provider-managed SDK sessions remain provider-managed; a
  custom API adapter may own bearer/refresh credentials if O1 selects that model.
- **Credential storage:** only small credentials or session secrets owned by Laforika use
  `flutter_secure_storage`. Never use preferences and never log credentials.
- **Refresh/recovery:** defined by the selected provider. If O1 selects bearer + refresh tokens,
  use a single-flight refresh, let concurrent failures await it, retry the original request once,
  and transition to `unauthenticated` on refresh failure. Do not build this before the model is
  confirmed.
- **Logout:** call the provider's sign-out/revocation behavior when available, stop outbox replay,
  clear Laforika-owned secrets, dispose the current `{environment, accountId}` scope, and
  transition to `unauthenticated`. Retention/purge follows approved module policy; account deletion
  purges the scope.
- **Route protection:** `go_router` `redirect` reads current session state. A stable app-owned
  `Listenable` adapter subscribes to `authControllerProvider` through Riverpod and is supplied as
  `refreshListenable`; this re-runs redirects without rebuilding the router. The intended
  destination is preserved through login.

Details in `ARCHITECTURE.md` §8.

## Alternatives rejected

- **Assuming bearer + refresh tokens before O1.** Rejected: Firebase Auth, OAuth SDKs, cookie
  sessions, passkeys, or another provider may own session lifecycle differently.
- **Access token only, no recovery strategy.** Rejected as a universal design; it either forces
  frequent re-login or encourages long-lived credentials. The selected provider must define a
  secure recovery/renewal model.
- **Storing credentials in `shared_preferences`.** Rejected: preferences are not appropriate for
  secrets.
- **Building a fake auth backend or stubbed production flow.** Rejected: implement authentication
  only against the selected real provider, while using test doubles solely in tests.

## Consequences

- Session state, logout semantics, and route protection can be designed before the vendor is
  selected without locking Laforika to a token model.
- O1 determines credential/session mechanics and whether Laforika owns secure credential
  persistence. Authenticated Dio requests integrate with the selected adapter whenever the backend
  requires them, including SDK-managed session models.
- Client route guards are UX; the backend/provider remains authoritative for access control.
- Authentication implementation remains blocked until O1 is resolved; no fake production flow is
  created to bypass that decision.

## Revisit when

- When O1 is resolved, record provider-specific session, credential, recovery, logout, and
  account-revocation behavior in a new ADR. Supersede ADR-0006 only if the provider-neutral boundary
  itself changes.
