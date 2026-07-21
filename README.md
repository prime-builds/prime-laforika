# Laforika

Laforika is a Persian-first Flutter mobile application built as a feature-first modular monolith. The project is currently at **M0 — Project Bootstrap** (complete in this codebase).

## Technical baseline

- Flutter `3.44.6` stable · Dart `3.12.2`
- Android API 24+ · iOS deployment target from the Flutter toolchain (do not change without approval)
- Riverpod for state management and dependency injection
- `go_router` for navigation
- Persian (`fa-IR`) and RTL from day one
- Native flavors: `dev`, `staging`, `prod`
- GitHub Actions quality gates

The frozen architecture is the source of truth: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md). Supporting decisions are recorded under [`docs/architecture/adr/`](docs/architecture/adr/). Merged delivery state is tracked in [`docs/project_inventory.md`](docs/project_inventory.md).

## Prerequisites

- Flutter `3.44.6` stable (Dart `3.12.2`)
- Android SDK with API 24+
- Xcode (for iOS builds on macOS)

## Install dependencies

```bash
flutter pub get
```

## Localization

ARB sources live in `lib/l10n/`. Generated output is committed under `lib/l10n/generated/`.

```bash
flutter gen-l10n
```

After regenerating, the working tree must remain clean (`git diff --exit-code`).

## Run an environment

`config/*.json` contains **non-secret** values only. Never put credentials or signing material there.

```bash
FLAVOR=dev

flutter run --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
```

| Flavor | Android application ID / iOS bundle ID |
|---|---|
| `dev` | `com.primebuilds.laforika.dev` |
| `staging` | `com.primebuilds.laforika.staging` |
| `prod` | `com.primebuilds.laforika` |

## Quality gates

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Before opening a pull request, verify all flavor debug builds:

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

## Repository structure

```text
lib/
├─ main.dart                 # Thin entry point
├─ bootstrap.dart            # Initialization and ProviderScope
├─ app/                      # Root app, router, environment wiring
├─ core/                     # Product-agnostic shared infrastructure
├─ features/                 # Independently bounded product modules
└─ l10n/                     # ARB files and generated localization

test/                        # Mirrors lib/
tool/                        # Architecture boundary checks
config/                      # Non-secret flavor configuration
assets/fonts/vazirmatn/      # Bundled Vazirmatn font + OFL license
docs/architecture/           # Frozen architecture and ADRs
docs/project_inventory.md    # Merged delivery inventory
```

Dependencies flow downward: `app → features → core`. Features expose curated public barrels and must not import another feature's internals.

## Development workflow

1. Read [`AGENTS.md`](AGENTS.md) and the relevant architecture/ADR sections.
2. Inspect existing code and the closest analog before implementation.
3. Keep changes within scope and add tests with new logic.
4. Run the applicable quality gates and report actual results.

Architecture, toolchain, identity, flavor, CI/CD, signing, deployment-target, and load-bearing dependency changes require explicit approval.

## Roadmap

- **M0:** Bootstrap, flavors, RTL localization, theme, routing, CI, and boundary enforcement ✅
- **M1:** Owner-approved authentication and protected-route vertical slice
- **M2:** Authenticated Home/discovery shell
- **M3:** First production feature module
- **M4:** First justified complex/offline module

Do not create future modules or infrastructure before a concrete milestone need. Owner decisions **O1–O8** remain unresolved.

## License

Licensed under the [Apache License 2.0](LICENSE). Vazirmatn font files are covered by their [OFL license](assets/fonts/vazirmatn/OFL.txt).
