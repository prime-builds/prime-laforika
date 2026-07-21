# ADR-0002 — Riverpod for state management and dependency injection

**Status:** Accepted · **Date:** 2026-07-21

## Context

We need state management and a way to provide/scope dependencies (Dio, storage, repositories,
session). Requirements favor low boilerplate, strong testability, safe async handling, and
avoiding two tools that solve overlapping problems. The team is small.

## Decision

Use the **latest stable Riverpod release compatible with the selected Flutter SDK** as **both**
the state manager and the DI container. Providers form the dependency graph; there is no separate
service locator. Use code generation (`riverpod_annotation` / `riverpod_generator`) selectively
where it improves maintainability; handwritten providers remain valid. `AsyncValue` is the standard
shape for async state. State placement and ownership rules are in `ARCHITECTURE.md` §6.

## Alternatives rejected

- **Bloc/Cubit.** Solid and popular, but more boilerplate/ceremony per feature and still needs a
  separate DI solution (e.g. `get_it`). Heavier than warranted for a small team.
- **`get_it` (+ `injectable`) for DI alongside a separate state tool.** Rejected: introduces a
  second dependency-wiring mechanism (runtime service locator) next to the state layer — exactly
  the "multiple tools for one problem" we want to avoid; weaker compile-time safety.
- **Provider (vanilla).** Lower ceiling for async/derived state and testing than Riverpod.
- **GetX.** Rejected: broad, opinionated, mixes routing/DI/state with weaker testability and
  boundary discipline.

## Consequences

- One mental model for both state and dependencies; wiring is compile-checked.
- Testing is cheap: override providers with fakes in a `ProviderContainer`/`ProviderScope`.
- Features that adopt generated providers require the `build_runner` step (acceptable; DTOs and
  Drift may use it later as well), but code generation is not mandatory for every provider.
- Team must follow provider discipline: auto-dispose by default, keep-alive only with a stated
  reason, no mutation outside notifiers.

## Revisit when

- A future need arises that Riverpod cannot serve cleanly (none anticipated), or code-gen becomes
  a bottleneck. Switching state tools is a large change; treat as a new ADR.
