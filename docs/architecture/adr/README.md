# Architecture Decision Records

ADRs capture **why** a load-bearing decision was made — its context, the alternatives rejected,
its consequences, and the conditions under which it should be revisited. They complement, and do
not duplicate, [`../ARCHITECTURE.md`](../ARCHITECTURE.md), which describes **how** the system is
built. When they disagree, `ARCHITECTURE.md` wins and the ADR should be superseded.

## Process

- One decision per ADR. Keep it to ~1 page.
- Status: `Proposed` → `Accepted` → `Superseded by ADR-XXXX`. Once `Accepted`, an ADR is
  immutable; change direction by writing a new ADR that supersedes it, not by editing history.
- Number sequentially (`NNNN-kebab-title.md`).

## Index

| ADR | Title | Status |
|---|---|---|
| [0001](./0001-modular-feature-first-architecture.md) | Feature-first modular monolith with pragmatic layering | Accepted |
| [0002](./0002-riverpod-state-and-di.md) | Riverpod for state management and dependency injection | Accepted |
| [0003](./0003-go-router-navigation.md) | go_router for navigation and route protection | Accepted |
| [0004](./0004-networking-and-error-model.md) | Dio + sealed Failure/Result error model | Accepted |
| [0005](./0005-local-persistence-and-offline.md) | Local persistence and deferred offline strategy | Accepted |
| [0006](./0006-authentication-and-session.md) | Authentication and session model | Accepted |
| [0007](./0007-custom-authentication-backend-and-session-security.md) | Custom authentication backend and session security | Accepted |
| [0008](./0008-guest-first-access-and-phone-only-authentication.md) | Guest-first access and phone-only authentication | Accepted (partially supersedes credential/access product choice in ADR-0007) |
| [0009](./0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md) | Fluent-inspired visual foundation and adaptive app shell | Accepted |

ADR-0008 does **not** rewrite ADR-0007. It supersedes only ADR-0007's phone-plus-email/password
credential choice and any authenticated-first product implication. NestJS/PostgreSQL ownership,
token security, session revocation, fixture delivery, and server authority from ADR-0007 remain
in force. ADR-0006 remains the provider-neutral Flutter session boundary.
