# Laforika — Project Inventory

Compact operational inventory of what is merged and verified. Not a changelog; does not duplicate [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md).

Recording rules (see [`AGENTS.md`](../AGENTS.md) §19): each completed check-in records the work package, PR number, final reviewed **implementation** commit SHA, verification, remaining decisions, and next package. Never record the inventory-update commit, the merge commit, branch status, or “pending merge.” Presence of the entry on `main` proves the PR was merged.

## Project identity

| Field | Value |
|---|---|
| App / Dart project | Laforika / `laforika` |
| Organization | `com.primebuilds` |
| Frozen architecture | [`ARCHITECTURE.md`](architecture/ARCHITECTURE.md) v1.3 (`FROZEN`) |
| Agent / delivery rules | [`../AGENTS.md`](../AGENTS.md) |
| Package prompts | [`prompts/`](prompts/) (versioned on the remote; not gitignored) |

## Current merged baseline

M1 custom authentication vertical slice on `main`, including ADR-0007 (O1), NestJS auth API, Flutter auth client, and versioned milestone prompts under `docs/prompts/`.

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
| Final reviewed implementation commit | `0981c8f99d276a392e07853afd14a8d455a3c4c5` |
| Completed scope | Flutter `laforika` / `com.primebuilds`; Android/iOS native `dev`/`staging`/`prod` flavors; checked `AppConfig`; Riverpod bootstrap; `go_router` Home; `fa-IR` RTL + Vazirmatn; localized app title; import-boundary checker; proportionate tests; GitHub Actions quality + three Android debug flavor builds |
| Verification | Local: format, analyze, tests (15), boundaries, `gen-l10n` clean, Android debug APKs for all flavors; CI green on PR #3 (quality + android-debug-dev/staging/prod); iOS schemes/xcconfigs corrected (Xcode build not run on non-macOS host) |
| Remaining decisions / limitations | Owner decisions O1–O8 unresolved; iOS build/run not verified on this host |
| Exact next work package | M1 authentication decision and vertical slice |

### Track package prompts — PR [#4](https://github.com/prime-builds/prime-laforika/pull/4)

| Field | Value |
|---|---|
| Work package | Versioned package prompts under `docs/prompts/` |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/4 |
| Final reviewed implementation commit | `34b6eee3f5152254b5d63897cdc7857f732c02e3` |
| Completed scope | Stop ignoring `docs/prompts/`; commit milestone package prompts on the remote (starting with M0); clarify terminating inventory recording rules in `AGENTS.md` |
| Verification | Docs-only change; Flutter quality gates and CI matrix not re-run (owner-directed) |
| Remaining decisions / limitations | Owner decisions O1–O8 unresolved; M1 prompt not yet present (removed before check-in) |
| Exact next work package | M1 authentication decision and vertical slice |

### M1 — Custom authentication vertical slice — PR [#6](https://github.com/prime-builds/prime-laforika/pull/6)

| Field | Value |
|---|---|
| Work package | M1 — Custom authentication vertical slice |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/6 |
| Final reviewed implementation commit | `247c98f606d57455b596e7624aea2ccb23f31924` |
| Completed scope | ADR-0007 + architecture v1.3 resolving O1 to custom NestJS/Prisma auth; provider-neutral `core/auth` with Flutter custom adapter; phone OTP and email/password flows; account attach/remove, sessions, logout, password change; shared Dio with refresh, retry, and sanitized logging; Nest `/v1` auth API with RS256 access tokens, rotating refresh, challenges, verified-email credentials, atomic challenge consumption, HMAC destination rate-limit keys, OpenAPI contracts; process-local fixture inbox for controlled delivery; Android backup exclusions for auth storage; M1 package prompt under `docs/prompts/` |
| Verification | Local: Flutter format/analyze/tests/import boundaries; backend unit + e2e + OpenAPI check; CI green on PR #6 (`backend` + `quality`); Android emulator `flutter run --flavor dev` verified locally after owner VPN/TUN + user-level Aliyun Gradle mirror workaround |
| Remaining decisions / limitations | O2–O8 unresolved; GitHub Actions Android emulator job and three-flavor debug APK matrix intentionally omitted (owner-approved CI quota deviation); local Android builds may require TUN + user Gradle mirror init script when Google Maven is unreachable |
| Exact next work package | M2 — Home / discovery shell |

## Current milestone

**M1 — Custom authentication vertical slice** delivered in PR #6. Exact next work package: **M2 — Home / discovery shell**.

## Implemented capabilities

- Frozen architecture document and accepted ADRs (0001–0007)
- Repository agent guidance (`AGENTS.md`)
- Operator-facing README and project inventory
- Versioned milestone package prompts under `docs/prompts/`
- License baseline (Apache-2.0)
- Flutter application scaffold with frozen identity and toolchain
- Native `dev` / `staging` / `prod` flavors (Android + iOS schemes/xcconfigs)
- Checked compile-time configuration and fatal startup surface
- Riverpod composition root and `go_router` Home feature
- Persian `fa-IR` localization, RTL, Vazirmatn theme foundation
- Import-boundary enforcement tool and CI quality gates
- Custom authentication vertical slice (NestJS API + Flutter client)

## Deferred capabilities and owner decisions

Deferred until later milestones or owner input (see architecture §14–§15):

- Networking beyond auth, persistence, telemetry, maps, push, Jalali display, final branding, signing/distribution, privacy/account-data lifecycle (O2–O8 and later milestones)

## Verification evidence

- PR [#1](https://github.com/prime-builds/prime-laforika/pull/1): final reviewed implementation commit `99e6b35173df29614250882188c27a547c0c852b`
- PR [#3](https://github.com/prime-builds/prime-laforika/pull/3): final reviewed implementation commit `0981c8f99d276a392e07853afd14a8d455a3c4c5` (includes review corrections)
- PR [#4](https://github.com/prime-builds/prime-laforika/pull/4): final reviewed implementation commit `34b6eee3f5152254b5d63897cdc7857f732c02e3`
- PR [#6](https://github.com/prime-builds/prime-laforika/pull/6): final reviewed implementation commit `247c98f606d57455b596e7624aea2ccb23f31924`

## Known limitations / risks

- iOS flavor configuration is committed and list membership corrected; iOS build/run was not executed on the delivery host (non-macOS)
- Owner decisions O2–O8 remain open and must not be assumed
- CI no longer runs Android emulator integration or the three-flavor debug APK matrix (owner-approved quota deviation); local emulator verification was performed on the delivery host

## Exact next step

Begin **M2 — Home / discovery shell** per architecture roadmap and `AGENTS.md`.
