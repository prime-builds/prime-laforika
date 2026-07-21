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

M0 project bootstrap on `main`: runnable Flutter app with native flavors, Persian RTL, Home route, boundary checker, and CI.

## Completed check-ins

### Documentation baseline — PR [#1](https://github.com/prime-builds/prime-laforika/pull/1)

| Field | Value |
|---|---|
| Work package | Documentation baseline |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/1 |
| Final reviewed implementation commit | `99e6b35173df29614250882188c27a547c0c852b` |
| Completed scope | Frozen architecture + ADRs 0001–0006; root `AGENTS.md`; repository `README.md`; Apache-2.0 `LICENSE` |
| Verification | Documentation review; no Flutter quality gates applicable (no app scaffold) |
| Remaining decisions / limitations | Owner decisions O1–O8 unresolved |
| Exact next work package | M0 project bootstrap |

### M0 — Project bootstrap — PR [#3](https://github.com/prime-builds/prime-laforika/pull/3)

| Field | Value |
|---|---|
| Work package | M0 — Project bootstrap |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/3 |
| Final reviewed implementation commit | `a1c38b2314469637116f4b6c11bced1958fcafc0` |
| Completed scope | Flutter `laforika` / `com.primebuilds`; Android/iOS native `dev`/`staging`/`prod` flavors; checked `AppConfig`; Riverpod bootstrap; `go_router` Home; `fa-IR` RTL + Vazirmatn; localized app title; import-boundary checker; proportionate tests; GitHub Actions quality + three Android debug flavor builds |
| Verification | Local: format, analyze, tests (15), boundaries, `gen-l10n` clean, Android debug APKs for all flavors; CI green on PR #3 (quality + android-debug-dev/staging/prod); iOS schemes/xcconfigs corrected (Xcode build not run on non-macOS host) |
| Remaining decisions / limitations | Owner decisions O1–O8 unresolved; iOS build/run not verified on this host |
| Exact next work package | M1 authentication decision and vertical slice |

## Current milestone

**M0 — Project bootstrap** delivered in PR #3. Exact next work package: **M1 — authentication decision and vertical slice**.

## Implemented capabilities

- Frozen architecture document and accepted ADRs (0001–0006)
- Repository agent guidance (`AGENTS.md`)
- Operator-facing README and project inventory
- License baseline (Apache-2.0)
- Flutter application scaffold with frozen identity and toolchain
- Native `dev` / `staging` / `prod` flavors (Android + iOS schemes/xcconfigs)
- Checked compile-time configuration and fatal startup surface
- Riverpod composition root and `go_router` Home feature
- Persian `fa-IR` localization, RTL, Vazirmatn theme foundation
- Import-boundary enforcement tool and CI quality/flavor gates

## Deferred capabilities and owner decisions

Deferred until later milestones or owner input (see architecture §14–§15):

- Authentication / identity provider (O1 → M1)
- Networking, persistence, telemetry, maps, push, Jalali display, final branding, signing/distribution, privacy/account-data lifecycle (O2–O8 and later milestones)

## Verification evidence

- PR [#1](https://github.com/prime-builds/prime-laforika/pull/1): final reviewed implementation commit `99e6b35173df29614250882188c27a547c0c852b`
- PR [#3](https://github.com/prime-builds/prime-laforika/pull/3): final reviewed implementation commit `a1c38b2314469637116f4b6c11bced1958fcafc0` (includes review corrections)

## Known limitations / risks

- iOS flavor configuration is committed and list membership corrected; iOS build/run was not executed on the delivery host (non-macOS)
- Owner decisions O1–O8 remain open and must not be assumed

## Exact next step

Begin **M1 — authentication decision and vertical slice** after owner decision **O1**, per architecture §14 and `AGENTS.md`.
