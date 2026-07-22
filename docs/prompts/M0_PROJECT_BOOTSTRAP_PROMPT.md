# Laforika M0 ΓÇö Project Bootstrap Agent Prompt

## TASK

Turn the current documentation-only Laforika repository into the complete **M0 project bootstrap** defined by the frozen architecture.

Create a runnable Flutter application with the frozen identity and toolchain, native `dev` / `staging` / `prod` flavors, validated compile-time configuration, Riverpod bootstrap, `go_router`, Persian localization and RTL, Vazirmatn-based theme foundations, a minimal Home feature, import-boundary enforcement, proportionate tests, and GitHub Actions quality gates.

Start from the current `origin/main` documentation baseline. Preserve `AGENTS.md`, `README.md`, `LICENSE`, and `docs/architecture/`. Do not add this prompt or `PROMPT_TEMPLATE.md` to the repository.

## WHY

M0 establishes the smallest reliable foundation on which M1 and later feature work can proceed without changing application identity, environment handling, module boundaries, localization direction, or CI expectations.

## MILESTONE

**M0 ΓÇö Project bootstrap**

M0 is complete only when the application runs in Persian RTL, configuration and flavor identity are validated, the minimal Home route works, generated localization is reproducible, required checks pass, and all three Android debug flavor builds succeed.

## OWNER DECISIONS

- Required resolved decisions: none.
- Decisions that must remain untouched: **O1ΓÇôO8**.
- Do not choose an auth/backend provider, telemetry vendor, distribution channel, maps/push vendor, Jalali calendar behavior, final branding, signing setup, or privacy/account-data policy.
- Use the frozen interim defaults only.

## AUTHORITATIVE CONTEXT

Read these files fully before editing:

1. `AGENTS.md`
2. `docs/architecture/ARCHITECTURE.md`
3. `docs/architecture/adr/README.md`
4. ADR-0001 through ADR-0006
5. `README.md`
6. `LICENSE`
7. The complete existing repository tree and Git status

Authority order is the one defined in `AGENTS.md`. Do not modify the frozen architecture or accepted ADRs unless an actual contradiction blocks implementation; report such a blocker instead.

Relevant architecture sections:

- ┬º1ΓÇô┬º5: architecture, repository structure, boundaries, module layering, bootstrap/flavors
- ┬º6ΓÇô┬º7: Riverpod ownership and `go_router`
- ┬º11ΓÇô┬º13: localization/RTL/theme/accessibility, security baseline, testing and CI
- ┬º14 M0 roadmap
- ┬º15 owner decisions

Relevant ADRs:

- ADR-0001: modular feature-first architecture
- ADR-0002: Riverpod state and DI
- ADR-0003: `go_router`
- ADR-0004 through ADR-0006: read to preserve their deferred boundaries; do not implement their M1+ infrastructure

## SCOPE

### In scope

- Initialize Flutter in the existing repository without deleting or overwriting frozen documentation.
- Configure the frozen Dart/Flutter project and native application identities.
- Configure Android and iOS native flavors.
- Add only the dependencies required by M0.
- Build the minimal `app/`, `core/`, and `features/home/` structure.
- Implement checked `AppConfig` loading and deterministic startup failure handling.
- Add Riverpod root composition and `go_router` route aggregation.
- Add Persian ARB localization, generated localization, RTL root configuration, and Vazirmatn.
- Add a neutral placeholder theme with centralized tokens actually used by M0.
- Implement the executable import-boundary checker.
- Add necessary M0 tests only.
- Add GitHub Actions quality and Android flavor-build jobs.
- Update repository documentation and ignore rules for the actual M0 workflow.
- Create a branch, atomic commits, push it, and open a pull request.

### Out of scope

Do **not** implement or scaffold unused infrastructure for:

- Real or fake authentication, session controllers, login screens, auth redirects, or token handling
- Dio, HTTP interceptors, `Failure` / `Result`, repositories, DTO generation, or API clients
- `shared_preferences`, secure storage, connectivity services, caching, Drift, offline sync, or outboxes
- Analytics, crash-reporting SDKs, remote telemetry, maps, push notifications, or third-party backend SDKs
- Future feature/module directories beyond the minimal Home feature
- Empty `data/` or `domain/` layers
- A shared UI component catalog, speculative utilities, or premature abstractions
- Jalali dates, final branding, production icons/splash assets, signing, publishing, or store configuration
- Release workflows, deployment automation, branch-protection settings, or integration-test infrastructure
- Desktop or web platform targets
- Architecture or ADR edits
- Hard coverage thresholds or broad test matrices

## FROZEN BASELINE

- Dart project: `laforika`
- Organization: `com.primebuilds`
- Flutter: `3.44.6` stable
- Dart: `3.12.2`
- Platforms: Android and iOS only
- Android namespace and production application ID: `com.primebuilds.laforika`
- iOS production bundle ID: `com.primebuilds.laforika`
- Flavor suffixes:
  - `dev`: `.dev`
  - `staging`: `.staging`
  - `prod`: no suffix
- Android minimum SDK: API 24
- iOS deployment target: use the value generated by the frozen Flutter toolchain; do not change it without approval
- State and DI: Riverpod
- Router: `go_router`
- Locale: `fa-IR`
- Direction: RTL
- Font: Vazirmatn
- CI: GitHub Actions
- Generated Dart sources under `lib/`: committed, never hand-edited

## ALLOWED DEPENDENCIES

Add only the latest stable versions compatible with Flutter `3.44.6` / Dart `3.12.2`:

### Runtime

- `flutter_riverpod`
- `go_router`
- `flutter_localizations` from the Flutter SDK
- `intl`

### Development

- `flutter_test` from the Flutter SDK
- `flutter_lints`

Do not add Riverpod code generation, `build_runner`, `mocktail`, Dio, storage packages, a logger, a task runner, or any other package unless it becomes strictly necessary for the acceptance criteria. Prefer handwritten providers in M0.

Remove unused dependencies generated by `flutter create`, including `cupertino_icons` when the final M0 code does not use it.

## STEP 0 ΓÇö INSPECT AND PLAN

1. Fetch and inspect the current `origin/main`; confirm the working tree is clean before branching.
2. Verify the active toolchain:
   - `flutter --version` must report Flutter `3.44.6` stable and Dart `3.12.2`.
   - Stop and report a blocker if it does not match; do not upgrade or downgrade the repository/toolchain silently.
3. Inspect all authoritative files listed above.
4. Confirm there is no existing Flutter scaffold that must be preserved.
5. Create branch:
   - `feat/m0-project-bootstrap`
6. Post a concise plan containing:
   - Expected file surface
   - Native flavor approach
   - App/config/bootstrap structure
   - Minimal tests
   - CI job structure
7. Proceed without waiting unless an `AGENTS.md` guardrail or architecture conflict blocks the work.

## STEP 1 ΓÇö INITIALIZE THE FLUTTER PROJECT

Run from the repository root:

```bash
flutter create \
  --project-name laforika \
  --org com.primebuilds \
  --platforms=android,ios \
  .
```

Requirements:

- Preserve `AGENTS.md`, `README.md`, `LICENSE`, and `docs/architecture/`.
- Do not add web, macOS, Windows, or Linux.
- Remove the generated counter example and its tests.
- Keep `lib/main.dart` thin.
- Set a non-publishable application package in `pubspec.yaml` with `publish_to: none`.
- Set Dart SDK constraints compatible with the frozen Dart baseline.
- Commit `pubspec.lock`.
- Keep generated Flutter project metadata needed by the repository.
- Do not introduce FVM, Melos, a monorepo, or another toolchain manager.

## STEP 2 ΓÇö CONFIGURE NATIVE IDENTITIES AND FLAVORS

### Android

Configure one flavor dimension and these product flavors:

| Flavor | Application ID | Display label |
|---|---|---|
| `dev` | `com.primebuilds.laforika.dev` | neutral non-production label, such as `Laforika Dev` |
| `staging` | `com.primebuilds.laforika.staging` | neutral non-production label, such as `Laforika Staging` |
| `prod` | `com.primebuilds.laforika` | `Laforika` |

Requirements:

- Namespace: `com.primebuilds.laforika`
- Minimum SDK: 24
- Follow the Gradle format generated by Flutter `3.44.6`; do not convert build-script formats unnecessarily.
- Keep target/compile SDK values supplied by the frozen Flutter project unless a required build fix is compatible with `AGENTS.md`.
- Add no permissions beyond generated defaults.
- Do not add signing credentials, release publishing, Google service files, or vendor configuration.
- Debug builds remain debug-signed and non-publishable.

### iOS

Create shared `dev`, `staging`, and `prod` schemes/configurations that work with `flutter run --flavor <flavor>`.

Bundle IDs:

- `dev`: `com.primebuilds.laforika.dev`
- `staging`: `com.primebuilds.laforika.staging`
- `prod`: `com.primebuilds.laforika`

Requirements:

- Mirror the three native flavors without changing the generated iOS deployment target.
- Commit shared schemes and required `.xcconfig`/project changes.
- Do not configure signing teams, profiles, capabilities, push, analytics, or store publishing.
- If the environment is not macOS, configure iOS carefully but report iOS build/run as not run for that reason.

## STEP 3 ΓÇö ADD CHECKED ENVIRONMENT CONFIGURATION

Create:

```text
config/dev.json
config/staging.json
config/prod.json
lib/core/config/app_config.dart
lib/core/config/app_config_provider.dart
lib/app/config/env.dart
```

Use a small immutable configuration contract containing only M0 concerns:

- Typed environment: `dev`, `staging`, `prod`
- Optional API base URL, allowed to be absent/empty until networking is introduced
- Typed log level
- Immutable feature-flag map, empty by default

Use clear compile-time keys and document them. A suitable M0 schema is:

```json
{
  "APP_ENVIRONMENT": "dev",
  "API_BASE_URL": "",
  "APP_LOG_LEVEL": "debug",
  "FEATURE_FLAGS_JSON": "{}"
}
```

Use corresponding environment/log values for staging and production. Do not insert fake production endpoints or secrets.

Configuration requirements:

- `APP_FLAVOR` is always passed separately with `--dart-define`.
- `app/config/env.dart` reads the compile-time values and constructs `AppConfig`.
- Reject missing or unsupported environment names.
- Reject a mismatch between `APP_FLAVOR` and `APP_ENVIRONMENT`.
- Reject invalid log levels.
- Parse feature flags safely and reject malformed/non-boolean entries.
- Allow an absent/empty API URL while networking is absent.
- If a non-development API URL is provided, require HTTPS.
- Do not guess defaults for required values.
- Never expose raw configuration exceptions or secret-like values in the UI/logs.
- `core/config/` owns the contract/provider; `app/config/` owns construction and validation.
- `appConfigProvider` must require a root override rather than silently constructing fallback configuration.

Canonical command shape:

```bash
flutter run --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
```

## STEP 4 ΓÇö IMPLEMENT BOOTSTRAP AND STARTUP FAILURE HANDLING

Required structure:

```text
lib/main.dart
lib/bootstrap.dart
lib/app/app.dart
lib/app/fatal_startup_app.dart
```

Requirements:

- `main.dart` contains only the thin call to `bootstrap()`.
- `bootstrap()`:
  - Calls `WidgetsFlutterBinding.ensureInitialized()`
  - Loads and validates `AppConfig`
  - Runs the app inside `runZonedGuarded`
  - Installs `FlutterError.onError` while preserving normal debug presentation
  - Wraps `LaforikaApp` in `ProviderScope`
  - Overrides `appConfigProvider` with the validated value
- Until O4 is resolved:
  - Add no remote telemetry SDK
  - Preserve Flutter's normal debug error output
  - Emit only sanitized local diagnostics
  - Do not log raw exception messages, request/config values, credentials, or personal data
- A configuration/startup failure must render a deterministic localized fatal-startup app/screen.
- The fatal surface must not display raw exceptions or implementation details.
- Do not create a generic error framework or `core/error/` hierarchy for M0.

## STEP 5 ΓÇö LOCALIZATION, RTL, FONT, AND THEME

### Localization

Configure:

- `flutter.generate: true` in `pubspec.yaml`
- `flutter_localizations`
- `intl`
- `l10n.yaml`
- `lib/l10n/app_fa.arb`
- Generated output under `lib/l10n/generated/`

`l10n.yaml` must explicitly define:

- `arb-dir: lib/l10n`
- `template-arb-file: app_fa.arb`
- `output-localization-file: app_localizations.dart`
- Generated output directory under `lib/l10n/generated/`

Requirements:

- All visible M0 strings come from ARB, including Home and fatal-startup text.
- `MaterialApp.router` uses generated delegates.
- Supported and active locale is exactly `Locale('fa', 'IR')`.
- Directionality must derive as RTL.
- Generated localization files under `lib/` are committed and never manually edited.
- `flutter gen-l10n` must be reproducible and leave a clean diff after committed outputs are regenerated.

### Vazirmatn

- Bundle a pinned Vazirmatn font asset from the official upstream project.
- Include its applicable open-source license/attribution in the repository.
- Register it once in `pubspec.yaml`.
- Use it as the application default font family.
- Add only the font files/weights actually needed by the M0 type scale.
- Do not add a font package dependency or expose font files outside the repository artifact.

### Theme and UI baseline

Create only the theme files/tokens used by the M0 app.

Requirements:

- Use Material 3.
- Use a neutral, accessible placeholder palette; do not make final O7 branding decisions.
- Centralize the font family and a small type scale.
- Use directional APIs only:
  - `EdgeInsetsDirectional`
  - `AlignmentDirectional`
  - `start` / `end`
- Avoid fixed-height text containers that break text scaling.
- Use at least 48dp touch targets for any interactive control.
- Do not create an unused design-system catalog, responsive framework, or speculative shared widgets.

## STEP 6 ΓÇö ADD ROUTING AND THE MINIMAL HOME FEATURE

Required shape:

```text
lib/app/router/app_router.dart
lib/app/router/routes.dart
lib/features/home/home.dart
lib/features/home/presentation/home_screen.dart
```

Requirements:

- Use one `GoRouter` owned under `app/router/`.
- `features/home/home.dart` is the curated public barrel.
- Export the Home route name/path constants and route registry from the public barrel.
- `app/router/routes.dart` imports only the Home public barrel and aggregates its routes.
- The root route is the minimal Home screen.
- Use route names/path constants; no repeated raw route strings.
- Home displays a small localized Persian M0-ready message.
- Keep Home presentation-only:
  - No `data/`
  - No `domain/`
  - No controller/provider unless real state requires it
- Do not add auth routes, redirects, refresh listeners, nested navigators, or deep-link payload models in M0.

## STEP 7 ΓÇö IMPLEMENT THE IMPORT-BOUNDARY GATE

Create:

```text
tool/check_import_boundaries.dart
```

The executable must scan Dart `import` and `export` directives under `lib/`, normalize package and relative references, print actionable file/line diagnostics, and exit non-zero on violations.

Enforce at least:

1. `core/` cannot import/export `app/` or `features/`.
2. Features cannot import/export `app/`.
3. A feature may access another feature only through that feature's top-level public barrel.
4. `app/` may consume feature public barrels but not feature internals.
5. Cross-feature dependencies must be one-way and acyclic.
6. If a feature contains `domain/`:
   - `domain/` cannot depend on `data/` or `presentation/`
   - `data/` cannot depend on `presentation/`
   - `presentation/` cannot bypass `domain/` to depend on `data/`
   - `domain/` cannot import Flutter UI libraries
7. If a feature has no `domain/`, its own `presentation/ ΓåÆ data/` dependency remains allowed.
8. Generated files are not a loophole around boundaries.

Keep the checker dependency-free unless the Dart SDK cannot reasonably support the implementation. Do not add a custom analyzer plugin.

## STEP 8 ΓÇö REPOSITORY AND DEVELOPMENT CONFIGURATION

### `analysis_options.yaml`

- Extend `package:flutter_lints/flutter.yaml`.
- Keep additions small and non-controversial.
- Do not create a large bespoke lint policy.
- Generated sources must remain analyzable unless the generator itself requires an explicit narrow exclusion.

### `.gitignore`

Preserve Flutter defaults and ensure these are ignored where applicable:

- Local IDE/build outputs
- `.dart_tool/`, `build/`, platform transient files
- `local.properties`
- `key.properties`, keystores, provisioning/signing material
- `.env*` and local/private config variants
- Private service files
- Split-debug-info output

Do **not** ignore:

- `config/dev.json`, `config/staging.json`, `config/prod.json`
- `pubspec.lock`
- Generated Dart localization files under `lib/`
- Shared iOS schemes required for flavors

### Documentation

Update `README.md` to match the implemented project:

- Exact prerequisites
- Dependency installation
- Localization generation
- Canonical flavor run commands
- Required quality gates
- Three-flavor debug build matrix
- Repository structure
- Explicit warning that `config/*.json` is non-secret
- M0 status and next milestone

Remove any instruction or link implying `PROMPT_TEMPLATE.md` belongs in the repository. Do not add this task prompt to the repository.

Do not add `CONTRIBUTING.md`, pre-commit frameworks, FVM, Melos, Make, or a task-runner dependency unless already required by the frozen repository.

## STEP 9 ΓÇö ADD NECESSARY TESTS ONLY

Testing must be proportionate. Add the smallest set that proves M0's load-bearing behavior.

### Required tests

1. **Configuration validation unit tests** in one focused test file:
   - Valid matching configuration succeeds.
   - Flavor/config environment mismatch fails.
   - Unsupported/missing environment or invalid log level fails.
   - Malformed feature flags fail.
   - A configured non-development non-HTTPS API URL fails.
   - Group related cases with table-driven data where practical.

2. **Application-root widget test**:
   - Pumps `LaforikaApp` with an overridden test `AppConfig`.
   - Confirms active locale is `fa-IR`.
   - Confirms root directionality is RTL.
   - Confirms the localized Home screen renders through `go_router`.

3. **Fatal-startup widget test**:
   - Confirms the deterministic localized startup-failure surface renders.
   - Confirms a supplied raw/internal error string is not displayed.

4. **Boundary-checker tests** in one focused test file:
   - One valid fixture passes.
   - A `core ΓåÆ feature/app` violation fails.
   - A cross-feature internal import or feature cycle fails.
   - Keep fixtures compact and temporary; do not build a large architecture-test framework.

### Explicitly not required in M0

- Integration tests
- Golden tests for the placeholder Home screen
- Tests for trivial constants, getters, enums, generated localization, Flutter-created platform boilerplate, or static theme values
- One test file per class
- Snapshot-heavy tests
- A hard coverage percentage
- Mocking where simple pure inputs or provider overrides are sufficient

Do not add `mocktail` unless an M0 test genuinely needs a mock. Prefer pure parsing APIs, temporary fixture directories, and Riverpod overrides.

Target approximately **three focused test files with a small number of grouped cases**, not broad coverage theater.

## STEP 10 ΓÇö GITHUB ACTIONS CI

Create:

```text
.github/workflows/ci.yml
```

Use stable, maintained GitHub Actions and pin Flutter exactly to `3.44.6` on the stable channel.

Trigger on:

- Pull requests
- Pushes to `main`

Use least-privilege permissions and concurrency cancellation for superseded runs.

### Quality job

On Ubuntu:

1. Checkout.
2. Set up a compatible Java toolchain for Android builds.
3. Set up Flutter `3.44.6` stable with caching.
4. Print `flutter --version`.
5. Run `flutter pub get`.
6. Run `flutter gen-l10n`.
7. Verify regeneration leaves the repository clean.
8. Run:
   - `dart format --output=none --set-exit-if-changed .`
   - `flutter analyze --fatal-infos`
   - `flutter test --coverage`
   - `dart run tool/check_import_boundaries.dart`
9. Optionally upload `coverage/lcov.info` as a workflow artifact.
10. Do not add Codecov, another external coverage vendor, or a coverage threshold.

### Android build matrix

Run after the quality job with `FLAVOR = dev, staging, prod`:

```bash
flutter build apk --debug --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
```

Requirements:

- Each flavor is a separate visible matrix result.
- Builds are debug-signed and non-publishable.
- No signing secrets or release publishing.
- Do not add the M1 Android-emulator integration job yet.
- Artifact upload is optional; if added, label APKs clearly as debug/non-publishable.

Use stable job/check names suitable for later branch-protection configuration, but do not change repository branch-protection settings in this task.

## ACCEPTANCE CRITERIA

- [ ] Existing frozen documentation and license are preserved.
- [ ] Flutter project was initialized with project name `laforika`, organization `com.primebuilds`, and Android/iOS only.
- [ ] Local toolchain was verified as Flutter `3.44.6` stable / Dart `3.12.2`.
- [ ] Android namespace, flavor IDs, and min SDK match the frozen architecture.
- [ ] Shared iOS `dev`, `staging`, and `prod` schemes use the correct bundle IDs without changing deployment target or signing.
- [ ] `dev`, `staging`, and `prod` config files contain non-secret values only.
- [ ] Startup rejects invalid, missing, unknown, or mismatched flavor configuration.
- [ ] Startup failures show a deterministic localized surface without raw errors.
- [ ] `main.dart` is thin and `bootstrap.dart` owns initialization, error zone, `ProviderScope`, configuration override, and `runApp`.
- [ ] Riverpod is the only DI/state tool.
- [ ] A single `GoRouter` aggregates the minimal Home feature through its public barrel.
- [ ] The app runs with active locale `fa-IR`, RTL directionality, localized visible strings, and Vazirmatn as the default font.
- [ ] Theme choices are neutral placeholders and directional/accessibility-safe.
- [ ] No unused feature layers or M1+ infrastructure were created.
- [ ] Boundary checker enforces the frozen module/import rules and is tested compactly.
- [ ] Generated localization files are committed, never manually edited, and reproducible.
- [ ] Necessary M0 tests pass without excessive test scaffolding.
- [ ] CI runs generation, format, fatal analysis, tests, boundary checks, and all three Android debug flavor builds.
- [ ] README reflects the implemented commands and does not reference a repository `PROMPT_TEMPLATE.md`.
- [ ] `pubspec.lock` is committed.
- [ ] No secrets, signing material, private service files, debug prints, unexplained TODOs, or unrelated refactors exist.
- [ ] Architecture and ADR files remain unchanged unless a blocker was explicitly reported and approved.

## STEP 11 ΓÇö VERIFY LOCALLY

Run and report actual output/status for:

```bash
flutter --version
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Then run:

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

Also run at least the dev application on an available Android emulator/device when the environment permits:

```bash
flutter run --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json
```

Manual verification:

- Home renders in Persian.
- Direction is RTL.
- Vazirmatn is applied.
- No overflow occurs at a larger text scale.
- Dev flavor identity/configuration is visible through safe, non-sensitive UI or diagnostics only if such an indicator is intentionally included.

For generated-code reproducibility:

1. Include generated localization output.
2. Return to a clean working tree after commits.
3. Re-run `flutter gen-l10n`.
4. Confirm `git diff --exit-code` remains clean.

If a command cannot run, report it as **not run** with the exact environmental reason. Never claim success based only on inspection.

## STEP 12 ΓÇö SELF-REVIEW AND CHECK IN

Before committing:

```bash
git status --short
git diff --stat
git diff
```

Confirm:

- No frozen docs were accidentally changed.
- No prompt/template file was added.
- No secret or signing file is staged.
- No M1+ infrastructure exists.
- Generated files are source-derived.
- The diff is limited to M0.

Use atomic Conventional Commits. A reasonable grouping is:

```text
chore(project): initialize Flutter application
feat(app): add M0 bootstrap flavors and RTL shell
test(app): cover M0 configuration and boundaries
ci(project): add Flutter quality and flavor build gates
docs(readme): document M0 development workflow
```

Adjust grouping to the actual diff; do not create artificial one-file commits.

Push `feat/m0-project-bootstrap` and open a pull request using the `AGENTS.md` PR body. Do not merge the PR.

The PR must:

- Explain that this completes M0.
- List native flavor identities.
- State that O1ΓÇôO8 remain unresolved/untouched.
- Report all commands and matrix results accurately.
- Include an Android emulator screenshot only if readily available; do not block the PR solely on a screenshot.
- Note any iOS verification not run due to environment.
- State explicitly that no auth, networking, persistence, telemetry, signing, or release infrastructure was introduced.

## REPORT BACK

Return a concise report:

- Status: done / partial / blocked
- Branch:
- Pull request:
- Commit(s):
- Summary:
- Files changed:
- Dependencies added/removed:
- Tests added and exact case count:
- Commands run with pass/fail/not-run:
- Android flavor build results:
- iOS flavor configuration and verification status:
- Generated-code clean-diff result:
- Architecture/ADR impact:
- Approved deviations:
- Remaining blockers or owner decisions:
