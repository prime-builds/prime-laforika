# ADR-0004 — Dio + sealed Failure/Result error model

**Status:** Accepted · **Date:** 2026-07-21

## Context

Modules will call HTTP APIs under unreliable connectivity, needing timeouts, cancellation,
careful retries, logging, and—only when the selected identity model requires it—authentication
credential attachment or refresh. Errors must be handled predictably and surfaced to users in
Persian, without leaking raw exceptions or personal data.

## Decision

- **HTTP client:** one configured **`dio`** instance behind `dioProvider` (base URL from
  `AppConfig`), with ordered interceptors introduced as required: request authentication whenever
the selected backend requires authenticated Dio calls, retry-with-backoff for safe/idempotent
requests, and sanitized logging in debug development builds only. Credential retrieval and
refresh delegate to the selected auth adapter whether SDK-managed or Laforika-owned. Logging is
disabled in profile/release and redacts `Authorization`, `Cookie`, `Set-Cookie`, token-like fields,
and personal query/body values; the redactor is tested.
- **Error model:** data layer catches transport/`Exception`s and maps them to a **sealed
  `Failure`** hierarchy; repository methods return a **sealed `Result<T>`** (`Success` /
  `FailureResult`) using **plain Dart 3 sealed classes + pattern matching** — no `dartz`.
- **API ownership:** each feature's repository is the only place that knows its endpoints/DTOs;
  controllers/use cases never touch Dio directly. Details in `ARCHITECTURE.md` §9.

## Alternatives rejected

- **`package:http` only.** Rejected: no built-in interceptors/retry/cancellation; we'd rebuild
  Dio's features by hand.
- **`dartz` / functional `Either`.** Rejected: extra dependency and a functional idiom unfamiliar
  to a small team; Dart 3 sealed classes + exhaustive `switch` give the same safety natively.
- **Throwing exceptions across layers.** Rejected: error handling becomes implicit and easy to
  miss; typed `Result` makes the failure path explicit and testable.
- **A generic wrapper interface around Dio ("just in case").** Rejected as speculative
  abstraction; the repository already isolates callers from the client.

## Consequences

- One place to configure networking and retries; request authentication is integrated there when
  the selected backend requires it, while credential/session mechanics remain adapter-owned.
- Callers must handle both `Result` branches (exhaustive switch), making failures explicit.
- Presentation owns `Failure` → localized message mapping; raw errors never reach the UI/logs.
- Retry/timeout tuning is centralized, aiding unreliable-connectivity resilience.

## Revisit when

- A need for GraphQL, gRPC, or streaming transport appears (would extend, not replace, the
  repository boundary).
- Certificate pinning is adopted (backend certs known) — added in the Dio layer.
