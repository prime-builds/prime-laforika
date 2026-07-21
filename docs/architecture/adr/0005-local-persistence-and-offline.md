# ADR-0005 — Local persistence and deferred offline strategy

**Status:** Accepted · **Date:** 2026-07-21

## Context

Some future modules need local persistence and must tolerate unreliable connectivity (offline
reads, queued writes). But the exact modules and their data shapes are not yet known. We must
pre-decide the tools so no one improvises, while not building infrastructure whose requirements
are still unknown.

## Decision

Tiered storage, each with a designated tool; **build on demand, not speculatively**:

- **Preferences (non-sensitive key/values):** `shared_preferences` behind a `PrefsFacade`.
- **Small credentials and session/cryptographic secrets owned by Laforika:**
  `flutter_secure_storage` behind `SecureStore`. Other personal data requires an explicit
  retention, encryption, deletion, and database policy.
- **Structured/relational + offline:** **Drift (SQLite)** is the default. The application owns one
  database connection and schema-version/migration authority by default; app composition owns a
  curated schema-contribution seam, while each module owns its tables, DAOs, mappings, and
  repository logic.
- **Account isolation:** every user-derived row, protected-media cache entry, and outbox item is
  partitioned by `{environment, accountId}` and is never read or replayed for another account.
- **Media cache:** `cached_network_image` only for public/non-sensitive media; protected media
  requires a user-scoped cache and purge policy.
- **Offline sync pattern (documented, per-module):** local store as read source of truth + write
  outbox. Each mutation and its outbox row commit in one Drift transaction. The outbox stores a
  stable idempotency key; replay assumes at-least-once delivery and marks/removes the item only
  after server acknowledgement. Connectivity changes are retry hints only; replay still requires
  timeouts, bounded backoff, idempotency, and server-response handling. Conflict policy is defined
  per module.

Details in `ARCHITECTURE.md` §10.

## Alternatives rejected

- **Hive / Isar as the default structured store.** Rejected as default: weaker relational
  querying and migration story than Drift for the transactional modules we anticipate (shop, chat,
  bookings); Isar's maintenance trajectory adds risk. (A module may still use a simple box-style
  store if its needs are genuinely non-relational — justified per module.)
- **`sqflite` raw.** Rejected: Drift adds type-safety, migrations, and reactive queries over the
  same SQLite engine with little cost.
- **Building an offline-sync engine up front.** Rejected: requirements per module are unknown;
  a speculative sync framework is exactly the over-engineering to avoid. Pattern is documented,
  implementation is per-module.
- **A shared god database with unowned tables and migrations.** Rejected: it becomes a coupling
  dumping ground. A single application database connection is acceptable and preferred when
  module ownership of schema and data access remains explicit.

## Consequences

- Sensitive vs. non-sensitive storage separation is explicit and enforced.
- The first module needing structured/offline data adopts Drift (a roadmap dependency, ~M4).
- Module-owned schemas keep boundaries clean; one application migration authority coordinates
  version ordering and cross-module schema upgrades through the curated contribution seam.
- Account-scoped persistence prevents cross-account reads and replay on shared devices.
- Transactional mutation/outbox writes prevent a crash from separating local state from sync intent.
- The sync pattern is consistent across modules that adopt it, without a premature framework.

## Revisit when

- A concrete module's requirements contradict the default (e.g. needs a non-relational store, or
  needs CRDT/merge conflict resolution beyond last-write-wins).
