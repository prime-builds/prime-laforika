# ADR-0003 — go_router for navigation and route protection

**Status:** Accepted · **Date:** 2026-07-21

## Context

Navigation must support authenticated route protection, deep links (needed later for
notifications and sharing), and clean integration of independently added modules. It should not
require heavy code generation for a small team.

## Decision

Use **`go_router`** (first-party) with a single `GoRouter` in `app/router/`. Each feature exposes
its routes from its public barrel as a `List<RouteBase>`; `app/` aggregates them (route registry).
Route protection uses a **`redirect`** reading `authControllerProvider`. A stable, app-owned
`Listenable` adapter subscribes to that provider through Riverpod and is supplied as
`refreshListenable`, so authentication changes re-run redirects without reconstructing the router.
The unknown/unauthenticated/authenticated redirect matrix and validated internal return-route
rules are specified in `ARCHITECTURE.md` §7–§8.

## Alternatives rejected

- **`auto_route`.** Powerful and typed, but code-gen-heavy; more setup and build cost than needed
  here. `go_router`'s route registry gives us modular integration without generation.
- **Raw Navigator 2.0.** Rejected: high complexity, easy to get wrong; go_router is the
  well-supported abstraction over it.
- **Navigator 1.0 (`push`/`pop` only).** Rejected: no declarative deep-linking or centralized
  guards; poor fit for URL/notification-driven navigation.

## Consequences

- Adding a module's navigation is a one-line registry change; no central switch statement.
- Deep links and in-app navigation share one route table (single source of truth).
- Auth redirect centralizes protection; client guards are UX only (the backend or selected
  identity provider remains authoritative).
- Route parameters rely on convention rather than generated type-safety. Reconstructable state
  uses path/query parameters; `extra` is limited to optional ephemeral in-process data and must
  never be required for a cold-start or deep-linked route. Enforced by review and router tests.

## Revisit when

- Route param type-safety pain becomes significant → reconsider `auto_route` or go_router's typed
  routes generator.
