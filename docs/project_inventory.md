# Laforika â€” Project Inventory

Compact operational inventory of what is merged and verified. Not a changelog; does not duplicate [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md).

Recording rules (see [`AGENTS.md`](../AGENTS.md) Â§19): each completed check-in records the work package, PR number, final reviewed **implementation** commit SHA, verification, remaining decisions, and next package. Never record the inventory-update commit, the merge commit, branch status, or â€œpending merge.â€ Presence of the entry on `main` proves the PR was merged.

## Project identity

| Field | Value |
|---|---|
| App / Dart project | Laforika / `laforika` |
| Organization | `com.primebuilds` |
| Frozen architecture | [`ARCHITECTURE.md`](architecture/ARCHITECTURE.md) v1.2 (`FROZEN`) |
| Agent / delivery rules | [`../AGENTS.md`](../AGENTS.md) |
| Package prompts | [`prompts/`](prompts/) (versioned on the remote; not gitignored) |

## Current merged baseline

M0 project bootstrap on `main`, plus versioned milestone package prompts under `docs/prompts/`.

## Completed check-ins

### Documentation baseline â€” PR [#1](https://github.com/prime-builds/prime-laforika/pull/1)

| Field | Value |
|---|---|
| Work package | Documentation baseline |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/1 |
| Final reviewed implementation commit | `99e6b35173df29614250882188c27a547c0c852b` |
| Completed scope | Frozen architecture + ADRs 0001â€“0006; root `AGENTS.md`; repository `README.md`; Apache-2.0 `LICENSE` |
| Verification | Documentation review; no Flutter quality gates applicable (no app scaffold) |
| Remaining decisions / limitations | Owner decisions O1â€“O8 unresolved |
| Exact next work package | M0 project bootstrap |

### M0 â€” Project bootstrap â€” PR [#3](https://github.com/prime-builds/prime-laforika/pull/3)

| Field | Value |
|---|---|
| Work package | M0 â€” Project bootstrap |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/3 |
| Final reviewed implementation commit | `0981c8f99d276a392e07853afd14a8d455a3c4c5` |
| Completed scope | Flutter `laforika` / `com.primebuilds`; Android/iOS native `dev`/`staging`/`prod` flavors; checked `AppConfig`; Riverpod bootstrap; `go_router` Home; `fa-IR` RTL + Vazirmatn; localized app title; import-boundary checker; proportionate tests; GitHub Actions quality + three Android debug flavor builds |
| Verification | Local: format, analyze, tests (15), boundaries, `gen-l10n` clean, Android debug APKs for all flavors; CI green on PR #3 (quality + android-debug-dev/staging/prod); iOS schemes/xcconfigs corrected (Xcode build not run on non-macOS host) |
| Remaining decisions / limitations | Owner decisions O1â€“O8 unresolved; iOS build/run not verified on this host |
| Exact next work package | M1 authentication decision and vertical slice |

### Track package prompts â€” PR [#4](https://github.com/prime-builds/prime-laforika/pull/4)

| Field | Value |
|---|---|
| Work package | Versioned package prompts under `docs/prompts/` |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/4 |
| Final reviewed implementation commit | `34b6eee3f5152254b5d63897cdc7857f732c02e3` |
| Completed scope | Stop ignoring `docs/prompts/`; commit milestone package prompts on the remote (starting with M0) |
| Verification | Docs-only change; Flutter quality gates and CI matrix not re-run (owner-directed) |
| Remaining decisions / limitations | Owner decisions O1â€“O8 unresolved; M1 prompt not yet present (removed before check-in) |
| Exact next work package | M1 authentication decision and vertical slice |

## Current milestone

**M0 â€” Project bootstrap** delivered in PR #3. Package prompts are tracked under `docs/prompts/`. Exact next work package: **M1 â€” authentication decision and vertical slice**.

## Implemented capabilities

- Frozen architecture document and accepted ADRs (0001â€“0006)
- Repository agent guidance (`AGENTS.md`)
- Operator-facing README and project inventory
- Versioned milestone package prompts under `docs/prompts/`
- License baseline (Apache-2.0)
- Flutter application scaffold with frozen identity and toolchain
- Native `dev` / `staging` / `prod` flavors (Android + iOS schemes/xcconfigs)
- Checked compile-time configuration and fatal startup surface
- Riverpod composition root and `go_router` Home feature
- Persian `fa-IR` localization, RTL, Vazirmatn theme foundation
- Import-boundary enforcement tool and CI quality/flavor gates

## Deferred capabilities and owner decisions

Deferred until later milestones or owner input (see architecture Â§14â€“Â§15):

- Authentication / identity provider (O1 â†’ M1)
- Networking, persistence, telemetry, maps, push, Jalali display, final branding, signing/distribution, privacy/account-data lifecycle (O2â€“O8 and later milestones)

## Verification evidence

- PR [#1](https://github.com/prime-builds/prime-laforika/pull/1): final reviewed implementation commit `99e6b35173df29614250882188c27a547c0c852b`
- PR [#3](https://github.com/prime-builds/prime-laforika/pull/3): final reviewed implementation commit `0981c8f99d276a392e07853afd14a8d455a3c4c5` (includes review corrections)
- PR [#4](https://github.com/prime-builds/prime-laforika/pull/4): final reviewed implementation commit `34b6eee3f5152254b5d63897cdc7857f732c02e3`

## Known limitations / risks

- iOS flavor configuration is committed and list membership corrected; iOS build/run was not executed on the delivery host (non-macOS)
- Owner decisions O1â€“O8 remain open and must not be assumed

## Exact next step

Begin **M1 â€” authentication decision and vertical slice** after owner decision **O1**, per architecture Â§14 and `AGENTS.md`. Place the M1 package prompt under `docs/prompts/` when ready.
