# ADR-0008 — Guest-first access and phone-only authentication

**Status:** Accepted · **Date:** 2026-07-25

## Context

M1 and M2 implemented an authenticated-first Home and dual user-facing credentials
(phone OTP plus email/password), matching ADR-0007's credential choice and the earlier
product assumption that login was required to enter the app. Owner-approved product
direction now requires:

- a guest-accessible Home after session restoration;
- authentication only at protected-capability boundaries;
- phone-number OTP as the only user-facing sign-in method;
- email as optional profile/contact data, not a login credential.

ADR-0006's provider-neutral Flutter session boundary and ADR-0007's NestJS/PostgreSQL
ownership, token security, session revocation, fixture delivery, and server authority remain
correct. Only the product access model and the dual-credential choice need to change.

## Decision

### Guest-first access

- The app must not require login on first launch.
- Startup still restores any existing session through the deterministic `unknown` / hydration
  state from ADR-0006.
- When restoration completes, authenticated users enter Home authenticated; unauthenticated
  users enter the same public Home as guests.
- Home and other public modules/content are explorable without authentication.
- Authentication is required only at the boundary of a protected capability.
- Protected destinations preserve a validated internal return destination and continue there
  after successful login.
- Client route guards remain UX only; NestJS authorization remains authoritative.
- No fake guest account, anonymous backend principal, guest access token, or guest database
  scope is introduced.

### Phone-only authentication

- Phone-number OTP is the only user-facing sign-in credential.
- The auth-method chooser, email/password login, and password-reset flows are deprecated and
  must be removed in the WP2 implementation package.
- Email becomes optional profile/contact data only and must not silently create a login
  credential.
- The verified phone number is the account's primary login identity and is read-only in the
  ordinary profile-edit form. A future change-phone security flow is separate and not approved
  here.
- Existing RS256 access tokens, opaque rotating refresh tokens, session revocation, replay
  detection, secure storage, redaction, and backend-authority decisions from ADR-0007 remain
  unchanged.
- Real-account builds remain controlled-test-only until O8 is resolved.

### Data-migration safety (for WP2)

- Never reset or silently delete a database to remove email/password support.
- Use committed forward Prisma migrations when schema changes are required.
- Inspect the actual data model and test fixtures before deciding which credential
  fields/tables can be removed.
- Historical migrations remain immutable.
- If any non-test account exists with only an email/password credential and no verified phone,
  WP2 must stop for an explicit owner migration decision rather than orphaning the account.

## Relationship to prior ADRs

- [ADR-0006](./0006-authentication-and-session.md) remains authoritative for the
  provider-neutral Flutter session boundary, hydration, secure-store ownership, and redirect
  refresh semantics.
- [ADR-0007](./0007-custom-authentication-backend-and-session-security.md) remains authoritative
  for backend ownership, NestJS/PostgreSQL topology, access/refresh-token security, session
  revocation, fixture delivery, and server authority.
- This ADR **supersedes only** ADR-0007's phone-plus-email/password credential choice and any
  authenticated-first product implication. ADR-0006 and ADR-0007 file contents are not rewritten.

## Alternatives rejected

- **Mandatory login at launch.** Rejected: blocks exploration of public content and conflicts
  with the approved guest-first product model.
- **Email/password plus phone choice.** Rejected: owner-approved direction is phone OTP only.
- **Anonymous backend guest accounts or guest tokens.** Rejected: invents a second identity
  model and expands security/retention surface without product need.
- **Keeping deprecated UI routes hidden but active indefinitely.** Rejected: leaves dual-auth
  debt and invites accidental reuse.
- **Destructive database reset to drop email/password support.** Rejected: violates migration
  safety and risks silent data loss.

## Consequences

- Architecture, `AGENTS.md`, and design docs record guest-first / phone-only as the approved
  target before WP1–WP6 implement the code changes.
- Current M1/M2 code may temporarily retain authenticated-first redirects and dual-credential
  UI until WP2 closes that named gap; new work must not extend the deprecated direction.
- Backend/OpenAPI/Prisma changes required to drop email/password login belong to WP2 and must
  follow the migration guardrails above.
- O8 continues to gate external distribution of real-account builds.

## Revisit when

- A future approved ADR restores an additional sign-in method.
- Account-deletion / retention requirements (O8) change auth or profile surfaces.
- A change-phone security flow is explicitly approved.
- The provider-neutral Flutter session boundary itself changes (would require superseding
  ADR-0006).
