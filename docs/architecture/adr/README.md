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
