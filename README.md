# Laforika

Laforika (لفوریکا) is a Persian-first, RTL Flutter mobile application with a sibling NestJS
authentication API under `backend/`.

**Approved product direction (architecture v1.4):** the app is guest-explorable — Home is public
after session restoration, and phone OTP is required only for protected capabilities. Appearance
targets System / Light / Dark (System default) with a Fluent-inspired but Laforika-owned visual
system. See [`docs/design/UI_FOUNDATION.md`](docs/design/UI_FOUNDATION.md) and
[`docs/design/APP_SHELL.md`](docs/design/APP_SHELL.md).

**Current implementation vs approved target:** M03_WP02 delivers the semantic light/dark Material 3
theme foundation with System/Light/Dark appearance persistence. Remaining transition gaps include
authenticated-first Home / dual-credential auth UI (M03_WP03) and the adaptive shell / Profile /
Settings / Notifications packages (M03_WP04–M03_WP07).

Exact next work package: **M03_WP03 — Guest-first routing and phone-only authentication**.

## Technical baseline

- Flutter `3.44.6` stable · Dart `3.12.2`
- Android API 24+ · iOS deployment target from the Flutter toolchain (do not change without approval)
- Riverpod for state management and dependency injection
- `go_router` for navigation · `dio` for HTTP
- Persian (`fa-IR`) and RTL from day one
- Native flavors: `dev`, `staging`, `prod`
- Backend: NestJS on Node.js 24 LTS + PostgreSQL (Prisma)
- GitHub Actions quality gates (Flutter unit/analyze + backend Postgres gates)
- Android-emulator auth integration is **local-only** (saves Actions minutes/storage on free plans)

The frozen architecture is the source of truth: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) (v1.4). Supporting decisions are recorded under [`docs/architecture/adr/`](docs/architecture/adr/). Design specs live under [`docs/design/`](docs/design/). Merged delivery state is tracked in [`docs/project_inventory.md`](docs/project_inventory.md).

## Prerequisites

### Flutter client

- Flutter `3.44.6` stable (Dart `3.12.2`)
- Android SDK with API 24+
- Xcode (for iOS builds on macOS)

### Backend (native Windows)

- Node.js **24 LTS** and npm
- PostgreSQL 16+ installed as a native Windows service (Docker/WSL are **not** required)
- OpenSSL (or PowerShell) available to generate development RS256 keys

## Install Flutter dependencies

```powershell
flutter pub get
```

## Localization and DTO generation

ARB sources live in `lib/l10n/`. Generated output is committed under `lib/l10n/generated/`.

```powershell
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

After regenerating, the working tree must remain clean (`git diff --exit-code`).

## Backend local setup (PowerShell)

1. Create a local PostgreSQL database and role (example names only):

```powershell
# After PostgreSQL is installed and `psql` is on PATH:
createdb laforika_dev
```

2. Copy environment templates and generate development keys:

```powershell
cd backend
Copy-Item .env.example .env
npm run keys:generate
# Edit .env: set DATABASE_URL, peppers, FIXTURE_INBOX_KEY, and key paths
npm ci
npx prisma migrate deploy
npm run start:dev
```

Health check: `GET http://127.0.0.1:3000/v1/health`

See [`backend/README.md`](backend/README.md) for full operator commands, fixture inbox usage, and test database setup.

**Secrets:** never commit `.env`, PEM/key files, database dumps, or fixture inbox contents.

## Run the Flutter app

`config/*.json` contains **non-secret** values only. Never put credentials or signing material there.

Dev default API base URL targets the Android emulator loopback to the local backend:

`http://10.0.2.2:3000/v1`

For iOS simulator or a physical device, use an ignored local override of `API_BASE_URL` (do not commit machine-specific hosts).

```powershell
$FLAVOR = "dev"

flutter run --flavor $FLAVOR `
  --dart-define=APP_FLAVOR=$FLAVOR `
  --dart-define-from-file="config/$FLAVOR.json"
```

| Flavor | Android application ID / iOS bundle ID | API URL policy |
|---|---|---|
| `dev` | `com.primebuilds.laforika.dev` | HTTP emulator loopback allowed |
| `staging` | `com.primebuilds.laforika.staging` | HTTPS only (placeholder `.invalid` until real host) |
| `prod` | `com.primebuilds.laforika` | HTTPS only (placeholder `.invalid` until real host) |

Staging/prod configs with `.invalid` hosts are **not deployable** until replaced with real HTTPS endpoints and delivery adapters.

## Quality gates

### Flutter

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

### Backend

```powershell
npm ci --prefix backend
npm run format:check --prefix backend
npm run lint --prefix backend
npm run typecheck --prefix backend
npm run prisma:format:check --prefix backend
npm run prisma:validate --prefix backend
npm run test --prefix backend
npm run test:e2e --prefix backend
npm run openapi:check --prefix backend
```

### Flavor debug builds

```powershell
foreach ($FLAVOR in @("dev","staging","prod")) {
  flutter build apk --debug --flavor $FLAVOR `
    --dart-define=APP_FLAVOR=$FLAVOR `
    --dart-define-from-file="config/$FLAVOR.json"
}
```

### Android-emulator auth integration (local only)

Not run in GitHub Actions. With PostgreSQL migrated and the backend running in `dev` fixture mode, pass the same `FIXTURE_INBOX_KEY` from `backend/.env`:

```powershell
flutter test integration_test/auth_flow_test.dart --flavor dev `
  --dart-define=APP_FLAVOR=dev `
  --dart-define-from-file=config/dev.json `
  --dart-define=FIXTURE_INBOX_KEY=<from-backend-env> `
  -d emulator-5554
```

Flavor debug APKs are also verified locally (see above), not uploaded as CI artifacts.

## Repository structure

```text
lib/                         # Flutter application
backend/                     # NestJS authentication API
test/                        # Mirrors lib/
integration_test/            # Real-backend end-to-end flows
tool/                        # Architecture boundary checks
config/                      # Non-secret flavor configuration
assets/fonts/vazirmatn/      # Bundled Vazirmatn font + OFL license
docs/architecture/           # Frozen architecture and ADRs
docs/design/                 # UI foundation + app-shell specifications
docs/prompts/                # Versioned work-package prompts
docs/project_inventory.md    # Merged delivery inventory
```

Dependencies flow downward: `app → features → core`. Features expose curated public barrels and must not import another feature's internals. The backend does not import Flutter code.

## Development workflow

1. Read [`AGENTS.md`](AGENTS.md) and the relevant architecture/ADR sections.
2. For UI/theme/shell work, also read [`docs/design/UI_FOUNDATION.md`](docs/design/UI_FOUNDATION.md) and [`docs/design/APP_SHELL.md`](docs/design/APP_SHELL.md).
3. Inspect existing code and the closest analog before implementation.
4. Keep changes within scope and add tests with new logic.
5. Run the applicable quality gates and report actual results.

Architecture, toolchain, identity, flavor, CI/CD, signing, deployment-target, and load-bearing dependency changes require explicit approval.

## Roadmap

### Completed

- **M0:** Bootstrap, flavors, RTL localization, theme placeholder, routing, CI, and boundary enforcement ✅
- **M1:** Custom authentication vertical slice ✅
- **M2:** Authenticated Home/discovery shell (route-registry baseline) ✅

### Approved transition (architecture v1.4 target)

- **M03_WP01:** Guest-first / phone-only / UI-foundation documentation and decision freeze ✅
- **M03_WP02:** Light/dark theme foundation ✅
- **M03_WP03:** Guest-first routing and phone-only authentication ← **exact next package**
- **M03_WP04:** Adaptive application shell
- **M03_WP05:** Profile vertical slice
- **M03_WP06:** Settings and Notifications
- **M03_WP07:** Integration and visual hardening

### Later product milestones

- **M04:** First specialized production module (owner chooses; do not invent during M03_WP01–M03_WP07)
- **M05:** First justified complex/offline module

Do not create future modules or infrastructure before a concrete milestone need. **O1** is resolved (custom NestJS/PostgreSQL; phone OTP only per ADR-0008). **O7** is partially resolved for the in-app visual system; external brand assets remain open. **O2–O6** and **O8** remain unresolved. Real-account builds remain controlled-test-only until **O8**.

## Feature route integration

When adding a module in its roadmap milestone:

1. Create the feature under `lib/features/<feature>/` only when the milestone requires it.
2. Expose route name/path constants, `List<RouteBase>`, and registered paths from the feature public barrel (`features/<feature>/<feature>.dart`).
3. Aggregate only that public barrel in [`lib/app/router/routes.dart`](lib/app/router/routes.dart) (`appRoutes()` and `appRegisteredPaths`).
4. Never import another feature’s `presentation/`, `data/`, or `domain/` internals.
5. Ensure the new internal path is included in `appRegisteredPaths` so return destinations stay validated.
6. Add route/redirect/boundary tests (including guest/authenticated coverage when the route is public or protected).
7. Do not introduce future modules early or ship dead placeholder destinations.

See architecture §3 (module boundaries) and §7 (navigation / route registry) in [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md), and shell rules in [`docs/design/APP_SHELL.md`](docs/design/APP_SHELL.md).

## License

Licensed under the [Apache License 2.0](LICENSE). Vazirmatn font files are covered by their [OFL license](assets/fonts/vazirmatn/OFL.txt).
