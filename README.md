# Laforika

Laforika is a Persian-first Flutter mobile application built as a feature-first modular monolith. The project is currently at the **documentation baseline**; the next implementation milestone is **M0 — Project Bootstrap**.

## Technical baseline

- Flutter `3.44.6` stable · Dart `3.12.2`
- Android API 24+ · iOS target pending owner approval
- Riverpod for state management and dependency injection
- `go_router` for navigation
- Persian (`fa-IR`) and RTL from the first release
- `dev`, `staging`, and `prod` native flavors
- GitHub Actions quality gates

The frozen architecture is the source of truth: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md). Supporting decisions are recorded under [`docs/architecture/adr/`](docs/architecture/adr/). Merged delivery state is tracked in [`docs/project_inventory.md`](docs/project_inventory.md).

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
integration_test/            # End-to-end flows
tool/                        # Architecture boundary checks
config/                      # Non-secret flavor configuration
docs/architecture/           # Frozen architecture and ADRs
docs/project_inventory.md    # Merged delivery inventory
```

Dependencies flow downward: `app → features → core`. Features expose curated public barrels and must not import another feature's internals.

## Getting started

### Prerequisites

- Flutter `3.44.6` stable
- Dart `3.12.2`
- Android SDK with API 24+
- Xcode for iOS development

### Install dependencies

```bash
flutter pub get
```

### Run an environment

```bash
FLAVOR=dev

flutter run --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
```

Valid flavors are `dev`, `staging`, and `prod`. Files under `config/` must contain non-secret values only.

## Quality gates

Run before considering a task complete:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Before opening a pull request, also verify all flavor builds:

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

Generated Dart files are committed but must never be edited manually. Regenerate them from their source and include the resulting diff.

## Development workflow

1. Read [`AGENTS.md`](AGENTS.md) and the relevant architecture/ADR sections.
2. Inspect existing code and the closest analog before implementation.
3. Keep changes within scope and add tests with new logic.
4. Run the applicable quality gates and report actual results.
5. Follow the milestone review and inventory workflow in `AGENTS.md`, and keep [`docs/project_inventory.md`](docs/project_inventory.md) current after final review.

Architecture, toolchain, identity, flavor, CI/CD, signing, deployment-target, and load-bearing dependency changes require explicit approval.

## Roadmap

- **M0:** Bootstrap, flavors, RTL localization, theme, routing, CI, and boundary enforcement
- **M1:** Owner-approved authentication and protected-route vertical slice
- **M2:** Authenticated Home/discovery shell
- **M3:** First production feature module
- **M4:** First justified complex/offline module

Do not create future modules or infrastructure before a concrete milestone need.

## License

Licensed under the [Apache License 2.0](LICENSE).
