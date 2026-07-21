# ADR-0001 — Feature-first modular monolith with pragmatic layering

**Status:** Accepted · **Date:** 2026-07-21

## Context

Laforika grows through independent modules added over time (home, maps, tourism, heritage, news,
villas, services, shop, community/chat) with no fixed order. It is built by a small team and must
stay professional and scalable without becoming a reusable framework or an over-engineered
enterprise system. We need clear module boundaries and the ability to add/remove modules
independently, without paying up-front for structure a first release does not need.

## Decision

Adopt a **single-application, feature-first modular monolith**: `features/<module>/` for product
modules, a small `core/` for shared infrastructure, and `app/` as the composition root.
**Layering inside a feature is pragmatic**: simple modules use `data/ + presentation/`; only
modules with real business rules, multiple data sources, or offline needs add a `domain/` layer
and use cases. Import direction is enforced: `app → features → core`; cross-feature access is only through a
curated public contract, remains one-way and acyclic, and never reaches another feature's
internals. `core` is product-agnostic infrastructure and depends on nothing internal. Shared
product/domain logic becomes an explicitly named feature or application capability, not `core`.
(Structure and rules: `ARCHITECTURE.md` §2–§4.)

## Alternatives rejected

- **Full Clean Architecture everywhere (4 layers per feature).** Rejected: forces entities, use
  cases, and mappers onto trivial screens; high ceremony, slow iteration for a small team.
- **Melos multi-package monorepo (one package per module).** Rejected as premature: build/tooling
  overhead, cross-package versioning, and publish friction with no current need for independent
  release or multiple teams.
- **Flat `lib/` with no module boundaries.** Rejected: predictably degrades into shared dumping
  grounds and tangled coupling as modules accumulate.
- **Layer-first top structure (`data/ domain/ presentation/` at root).** Rejected: scatters a
  single feature across the tree, making add/remove-a-module operations non-local.

## Consequences

- Adding a module is local: one directory + one line in the route registry.
- Boundaries are explicit and CI-enforceable, keeping coupling low as the app grows.
- Teams must resist adding empty layers "for later"; the promotion rule (§4) governs when to add
  `domain/`.
- Extraction to packages later is possible but not free; boundaries are designed so it stays a
  mechanical move rather than a redesign.

## Revisit when

- A module needs independent versioning/release, or a separate team owns it end-to-end.
- Build times or coupling degrade enough that package extraction pays for itself.
- Two features repeatedly need the same product/domain logic → introduce an explicitly named
  feature/application capability with a curated public contract; keep `core/` product-agnostic.
  Consider package extraction only if independent ownership or release justifies it.
