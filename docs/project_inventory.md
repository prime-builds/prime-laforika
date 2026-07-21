# Laforika — Project Inventory

Compact operational inventory of what is merged and verified. Not a changelog; does not duplicate [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md).

## Project identity

| Field | Value |
|---|---|
| App / Dart project | Laforika / `laforika` |
| Organization | `com.primebuilds` |
| Frozen architecture | [`ARCHITECTURE.md`](architecture/ARCHITECTURE.md) v1.2 (`FROZEN`) |
| Agent / delivery rules | [`../AGENTS.md`](../AGENTS.md) |

## Current merged baseline

Documentation baseline on `main`. No Flutter application scaffold is merged yet.

## Completed check-ins

### Documentation baseline — PR [#1](https://github.com/prime-builds/prime-laforika/pull/1)

| Field | Value |
|---|---|
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/1 |
| Merge commit | `03a0ae9c0f0bd09fc4effec4b40c5a8ec4581e8d` |
| Final reviewed source | Included in merge commit above (docs commits `64d0d07`, `99e6b35`) |
| Completed scope | Frozen architecture + ADRs 0001–0006; root `AGENTS.md`; repository `README.md`; Apache-2.0 `LICENSE` |
| Verification | Documentation review; no Flutter quality gates applicable (no app scaffold) |
| Remaining decisions | Owner decisions O1–O8 unresolved |
| Next step after this check-in | M0 project bootstrap |

## Current milestone

**Pre-M0 / documentation baseline.** M0 (project bootstrap) is the next implementation milestone and is not started on `main`.

## Implemented capabilities

- Frozen architecture document and accepted ADRs (0001–0006)
- Repository agent guidance (`AGENTS.md`)
- Operator-facing README for the documentation baseline
- License baseline (Apache-2.0)

## Deferred capabilities and owner decisions

Deferred until later milestones or owner input (see architecture §14–§15):

- Flutter app scaffold, flavors, localization runtime, theme, routing, CI (M0)
- Authentication / identity provider (O1 → M1)
- Networking, persistence, telemetry, maps, push, Jalali display, final branding, signing/distribution, privacy/account-data lifecycle (O2–O8 and later milestones)

## Verification evidence

- PR [#1](https://github.com/prime-builds/prime-laforika/pull/1) merged to `main` at `03a0ae9c0f0bd09fc4effec4b40c5a8ec4581e8d`
- No application CI matrix on this baseline (Flutter project not yet present)

## Known limitations / risks

- Repository is documentation-only until M0 lands; no runnable app on `main`
- Owner decisions O1–O8 remain open and must not be assumed

## Exact next step

Begin **M0 — Project bootstrap** per architecture §14 and `AGENTS.md` (Flutter identity, flavors, RTL/`fa-IR`, theme, Home route, boundary checker, CI).
