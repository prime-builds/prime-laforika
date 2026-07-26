# Laforika — Project Inventory

Compact operational inventory of what is merged and verified. Not a changelog; does not duplicate [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md).

Recording rules (see [`AGENTS.md`](../AGENTS.md) §19): each completed check-in records the work package, PR number, final reviewed **implementation** commit SHA, verification, remaining decisions, and next package. Never record the inventory-update commit, the merge commit, branch status, or “pending merge.” Presence of the entry on `main` proves the PR was merged.

## Project identity

| Field | Value |
|---|---|
| App / Dart project | Laforika / `laforika` |
| Organization | `com.primebuilds` |
| Frozen architecture | [`ARCHITECTURE.md`](architecture/ARCHITECTURE.md) v1.4 (`FROZEN`) |
| Agent / delivery rules | [`../AGENTS.md`](../AGENTS.md) |
| Package prompts | [`prompts/`](prompts/) (versioned on the remote; not gitignored) |
| Design specs | [`design/`](design/) (UI foundation + app shell) |

## Current merged baseline

M03_WP04 adaptive application shell on top of M03_WP03 guest-first / phone-only auth, the
M03_WP02 theme foundation, M03_WP01 documentation freeze, M2 Home / discovery shell, and M1
custom authentication (ADR-0007 / O1, amended by ADR-0008). Architecture v1.4 records the
guest-first, phone-only, Fluent-inspired adaptive-shell target; M03_WP05–M03_WP07 implement
the remaining named code-to-target gaps.

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

### M2 — Home / discovery shell — PR [#7](https://github.com/prime-builds/prime-laforika/pull/7)

| Field | Value |
|---|---|
| Work package | M2 — Home / discovery shell |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/7 |
| Final reviewed implementation commit | `0bdcb625b37f6e6b41ce5a8d1310790a3612c0b5` |
| Completed scope | Authenticated Persian RTL Home discovery shell from session principal (credential status + Account security only; no raw `accountId`); `homeRegisteredPaths` / `appRegisteredPaths` aggregation; README feature route-integration docs; M2 package prompt; session-gateway stability and Dio attach for 401 refresh retry; Home widget/router/integration coverage |
| Verification | Local: Flutter format/analyze/tests/import boundaries; Android debug APKs `dev`/`staging`/`prod`; emulator `integration_test/auth_flow_test.dart` against real local Nest backend; CI green on PR #7 (`backend` + `quality`) |
| Remaining decisions / limitations | O2–O8 unresolved; M3 module choice not assumed; GitHub Actions Android emulator job and three-flavor debug APK matrix intentionally omitted (owner-approved); local Android builds may require TUN + user Gradle mirror when Google Maven is unreachable |
| Exact next work package | M3 — choose and implement one specialized production module |

### M03_WP01 — Documentation and decision freeze — PR [#8](https://github.com/prime-builds/prime-laforika/pull/8)

| Field | Value |
|---|---|
| Work package | M03_WP01 — Documentation and decision freeze |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/8 |
| Final reviewed implementation commit | `129fc62e430e3627288c4e3e593f58c8eac5c9a1` |
| Completed scope | ADR-0008 (guest-first + phone OTP only; partial supersession of ADR-0007 credential/access product choice); ADR-0009 (Fluent-inspired visual foundation + adaptive shell); architecture v1.4 with controlled M03_WP01–M03_WP07 transition note; `docs/design/UI_FOUNDATION.md` and `docs/design/APP_SHELL.md`; AGENTS/README alignment; package prompt `docs/prompts/M03_WP01_GUEST_FIRST_UI_FOUNDATION_DOCUMENTATION_PROMPT.md`; later product milestones renumbered to M04/M05 |
| Verification | Docs-only: `git diff --check`; relative Markdown links resolve; naming remediation verified; CI green on PR #8 (`backend` + `quality`); Flutter/backend source gates not run (documentation-only) |
| Remaining decisions / limitations | O2–O6 and O8 unresolved; O7 partially resolved for in-app visual system (external brand assets deferred); M03_WP02–M03_WP07 implementation pending; M2 code may temporarily differ from the v1.4 target in named transition gaps |
| Exact next work package | M03_WP02 — Light/dark theme foundation |

### M03_WP02 — Light/dark theme foundation — PR [#9](https://github.com/prime-builds/prime-laforika/pull/9)

| Field | Value |
|---|---|
| Work package | M03_WP02 — Light/dark theme foundation |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/9 |
| Final reviewed implementation commit | `98729a6f0f3953448db40706e78322bc46c3b1d5` |
| Completed scope | ADR-0009 semantic light/dark Material 3 themes via `AppSemanticColors`; System/Light/Dark appearance preference with `PrefsFacade` persistence (System default); app + fatal-startup wiring; Vazirmatn/RTL preserved; focused unit/widget/contrast/text-scale coverage; light/dark RTL goldens; fractional golden tolerance comparator with mismatch rejection; package prompt under `docs/prompts/` |
| Verification | Local: format, analyze, tests, import boundaries; Android debug APKs `dev`/`staging`/`prod`; emulator `integration_test/auth_flow_test.dart` against real local Nest backend; CI green on PR #9 (`backend` + `quality`) |
| Remaining decisions / limitations | O2–O6 and O8 unresolved; O7 external brand assets remain deferred; M03_WP03–M03_WP07 pending; authenticated-first Home and dual-credential auth UI remain until later M03 packages; local Android builds may require TUN + user Gradle mirror and `kotlin.incremental=false` when Pub cache and project are on different drive roots |
| Exact next work package | M03_WP03 — Guest-first routing and phone-only authentication |

### M03_WP03 — Guest-first routing and phone-only authentication — PR [#10](https://github.com/prime-builds/prime-laforika/pull/10)

| Field | Value |
|---|---|
| Work package | M03_WP03 — Guest-first routing and phone-only authentication |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/10 |
| Final reviewed implementation commit | `ba8cd8fc404e1e5d6389de0697a37832bd70382f` |
| Completed scope | Guest-first public Home after session restore; protected Account Security with validated path-only return destinations; canonical `/auth` as phone OTP only (method chooser / email / password-reset removed); Nest phone-only auth (email/password endpoints and Argon2 removed); forward Prisma `phone_only_auth` migration with orphan-phone guard; OpenAPI narrowed; Flutter/backend tests including migration behavior, consumed/expired/concurrent OTP, session revoke, and emulator integration |
| Verification | Local: Flutter format/analyze/tests/import boundaries; backend format/lint/typecheck/unit/e2e/openapi; Android debug APKs `dev`/`staging`/`prod`; emulator `integration_test/auth_flow_test.dart` against real local Nest backend; CI green on PR #10 (`backend` + `quality`) |
| Remaining decisions / limitations | O2–O6 and O8 unresolved; O7 external brand assets remain deferred; M03_WP04–M03_WP07 pending; local Android builds may require TUN + user Gradle mirror and `kotlin.incremental=false` when Pub cache and project are on different drive roots |
| Exact next work package | M03_WP04 — Adaptive application shell |

### M03_WP04 — Adaptive application shell — PR [#11](https://github.com/prime-builds/prime-laforika/pull/11)

| Field | Value |
|---|---|
| Work package | M03_WP04 — Adaptive application shell |
| Delivery PR | https://github.com/prime-builds/prime-laforika/pull/11 |
| Final reviewed implementation commit | `681f0dcad0befa17bd4ab859cd834b38e3ead47d` |
| Completed scope | Adaptive shell under `lib/features/shell/` (public barrel); Home-only production floating dock with correct visual Profile·Chat·Home order under fixtures; local Home discovery search; staged module strip/tabs via test fixtures only (no Chat/Profile/module routes); scroll-driven strip compaction with preserved horizontal offset; Material-icon production Home light/dark goldens; package prompt under `docs/prompts/` |
| Verification | Local: Flutter format/analyze/tests/import boundaries; Android debug APKs `dev`/`staging`/`prod`; emulator `integration_test/auth_flow_test.dart` against real local Nest backend; CI green on PR #11 (`backend` + `quality`); WP02 theme goldens unchanged; delivery packaging correction removed unapproved handoff-instructions file and shipped full `git archive` of PR head `a874ec9b…` |
| Remaining decisions / limitations | O2–O6 and O8 unresolved; O7 external brand assets remain deferred; M03_WP05–M03_WP07 pending; local Android builds may require TUN + user Gradle mirror and `kotlin.incremental=false` when Pub cache and project are on different drive roots |
| Exact next work package | M03_WP05 — Profile vertical slice |

## Current milestone

**M03_WP04 — Adaptive application shell** delivered in PR #11. Exact next work package: **M03_WP05 — Profile vertical slice**.

## Implemented capabilities

- Frozen architecture document and accepted ADRs (0001–0009)
- Repository agent guidance (`AGENTS.md`)
- Operator-facing README and project inventory
- Approved UI foundation and app-shell design specifications under `docs/design/`
- Versioned milestone package prompts under `docs/prompts/`
- License baseline (Apache-2.0)
- Flutter application scaffold with frozen identity and toolchain
- Native `dev` / `staging` / `prod` flavors (Android + iOS schemes/xcconfigs)
- Checked compile-time configuration and fatal startup surface
- Riverpod composition root and `go_router` Home feature
- Persian `fa-IR` localization, RTL, Vazirmatn theme foundation
- Semantic light/dark appearance (System/Light/Dark) with preference persistence
- Import-boundary enforcement tool and CI quality gates
- Custom authentication vertical slice (NestJS API + Flutter client; phone OTP only)
- Guest-first Home / discovery shell with protected Account Security and path-only return destinations
- Adaptive application shell (Home-only production dock, local Home search, fixture-covered full dock/modules/tabs)
- Documented Profile / Settings / Notifications / visual-hardening target (remaining implementation in M03_WP05–M03_WP07)

## Deferred capabilities and owner decisions

Deferred until later milestones or owner input (see architecture §14–§15):

- M03_WP05–M03_WP07 implementation of Profile, Settings, Notifications, and visual hardening
- Networking beyond auth, persistence, telemetry, maps, push, Jalali display, external brand assets, signing/distribution, privacy/account-data lifecycle (O2–O6, O7 remainder, O8, and later milestones M04+)

## Verification evidence

- PR [#1](https://github.com/prime-builds/prime-laforika/pull/1): final reviewed implementation commit `99e6b35173df29614250882188c27a547c0c852b`
- PR [#3](https://github.com/prime-builds/prime-laforika/pull/3): final reviewed implementation commit `0981c8f99d276a392e07853afd14a8d455a3c4c5` (includes review corrections)
- PR [#4](https://github.com/prime-builds/prime-laforika/pull/4): final reviewed implementation commit `34b6eee3f5152254b5d63897cdc7857f732c02e3`
- PR [#6](https://github.com/prime-builds/prime-laforika/pull/6): final reviewed implementation commit `247c98f606d57455b596e7624aea2ccb23f31924`
- PR [#7](https://github.com/prime-builds/prime-laforika/pull/7): final reviewed implementation commit `0bdcb625b37f6e6b41ce5a8d1310790a3612c0b5`
- PR [#8](https://github.com/prime-builds/prime-laforika/pull/8): final reviewed implementation commit `129fc62e430e3627288c4e3e593f58c8eac5c9a1`
- PR [#9](https://github.com/prime-builds/prime-laforika/pull/9): final reviewed implementation commit `98729a6f0f3953448db40706e78322bc46c3b1d5`
- PR [#10](https://github.com/prime-builds/prime-laforika/pull/10): final reviewed implementation commit `ba8cd8fc404e1e5d6389de0697a37832bd70382f`
- PR [#11](https://github.com/prime-builds/prime-laforika/pull/11): final reviewed implementation commit `681f0dcad0befa17bd4ab859cd834b38e3ead47d`

## Known limitations / risks

- iOS flavor configuration is committed and list membership corrected; iOS build/run was not executed on the delivery host (non-macOS)
- Owner decisions O2–O6 and O8 remain open; O7 external brand assets remain deferred
- CI no longer runs Android emulator integration or the three-flavor debug APK matrix (owner-approved quota deviation); local emulator verification was performed on the delivery host
- M2 runtime historically used authenticated-first Home and dual-credential auth UI; M03_WP03 closes that gap
- M04 specialized-module selection is an owner decision; do not invent a specialized module early

## Exact next step

Begin **M03_WP05 — Profile vertical slice**; do not start M04 until the M03 transition packages are complete and the owner selects the module.
