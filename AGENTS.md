# AGENTS.md

> Read this file fully before changing the repository.

## 1. Authority and precedence

Laforika's frozen architecture is authoritative:

1. The current task's explicit scope and acceptance criteria.
2. `docs/architecture/ARCHITECTURE.md` — the single source of truth.
3. Accepted ADRs under `docs/architecture/adr/` — rationale; the architecture document wins if they disagree.
4. Existing repository conventions that do not conflict with the frozen architecture.
5. General Flutter practice.

Never silently copy code that contradicts the frozen architecture. Treat the conflict as a defect or a proposed architecture change and report it. Material architecture changes require a new or superseding ADR plus an architecture version update.

## 2. Frozen project configuration

| Concern | Decision |
|---|---|
| App / Dart project | Laforika / `laforika` |
| Organization | `com.primebuilds` |
| Android namespace / production application ID | `com.primebuilds.laforika` |
| iOS production bundle ID | `com.primebuilds.laforika` |
| Flavor IDs | `.dev`, `.staging`, and no suffix for production |
| Flutter | `3.44.6` stable |
| Dart | `3.12.2` |
| Android minimum | API 24 |
| iOS deployment target | Not frozen; do not change without explicit approval |
| Architecture | Feature-first modular monolith with pragmatic layering |
| State and DI | Riverpod; providers are the dependency graph |
| Routing | `go_router` |
| HTTP | One shared `dio` instance |
| Errors | Plain Dart sealed `Failure` and `Result<T>` |
| Persistence | `shared_preferences`, `flutter_secure_storage`; Drift deferred until justified |
| Localization | Persian `fa-IR`, RTL from day one |
| Typography | Vazirmatn |
| Access model | Guest-first: public Home after session restore; auth only for protected capabilities |
| User-facing auth | Phone OTP only; email is optional profile/contact data |
| Visual system | Fluent-inspired Laforika semantic light/dark; appearance System/Light/Dark (System default) |
| Mocking | `mocktail` |
| CI | GitHub Actions |
| Generated Dart files | Committed, regenerated in CI, never hand-edited |
| Environments | `dev`, `staging`, `prod` via native flavors and `--dart-define-from-file` |
| Auth backend | NestJS on Node.js 24 LTS + PostgreSQL (`backend/`) |
| Access tokens | Short-lived RS256 JWT; opaque rotating refresh tokens |
| Backend package manager | npm with committed `package-lock.json` |

Toolchain upgrades, deployment-target changes, or replacements for load-bearing libraries require explicit approval and architecture change control.

## 3. Required inspection before implementation

Before writing code:

1. Read this file and `docs/architecture/ARCHITECTURE.md` fully.
2. Read every ADR relevant to the task (including ADR-0006, ADR-0007, and ADR-0008 for auth/access work; ADR-0009 for theme/shell work).
3. For UI, theme, or shell tasks, read `docs/design/UI_FOUNDATION.md` and `docs/design/APP_SHELL.md`.
4. Inspect `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `.gitignore`, and the applicable CI workflow.
5. For backend work, inspect `backend/package.json`, Prisma schema/migrations, `.env.example`, and OpenAPI contract generation.
6. Inspect the target feature, its public barrel, its tests, and the closest existing analog.
7. Confirm the current milestone / work package and do not create future-module infrastructure early.
8. Confirm actual dependencies before importing a package.
9. Check whether generated code is used and follow the repository's generation command.
10. Check configuration and secret handling before touching environment or platform files.

If a referenced file does not exist because the project has not reached that milestone, do not invent infrastructure unless the task explicitly creates it.

## 4. Repository shape

```text
lib/
├─ main.dart
├─ bootstrap.dart
├─ app/
│  ├─ app.dart
│  ├─ router/{app_router.dart,routes.dart}
│  └─ config/env.dart
├─ core/
│  ├─ auth/
│  ├─ config/
│  ├─ connectivity/
│  ├─ error/
│  ├─ localization/
│  ├─ network/
│  ├─ storage/
│  ├─ theme/
│  ├─ ui/
│  └─ utils/
├─ features/
│  └─ <feature>/
│     ├─ <feature>.dart
│     ├─ presentation/
│     ├─ data/        # as needed
│     └─ domain/      # complex features only
└─ l10n/

backend/              # NestJS API (M1+); does not import Flutter
├─ src/
├─ prisma/
├─ test/
└─ scripts/

test/                 # mirrors lib/
integration_test/
tool/check_import_boundaries.dart
config/{dev,staging,prod}.json
```

Do not create empty layers, speculative shared components, unused services, or future feature directories.

## 5. Module and import boundaries

The application is a modular monolith with dependencies flowing downward: `app → features → core`.

- `core/` is product-agnostic and must not import `features/` or `app/`.
- `app/` is the composition root and may import feature public barrels.
- Features must not import `app/`.
- A feature may import `core/`, its own files, or another feature's curated public barrel only.
- Never import another feature's internal `presentation/`, `data/`, or `domain/` files.
- Cross-feature dependencies must be one-way and acyclic.
- Shared product logic becomes an explicitly named feature or application capability, not generic `core/` code.
- Public barrels expose only the module contract: routes, entry points, and intentionally shared contracts.

### Simple feature

Use `presentation/ + data/` for read-mostly or low-complexity features. Presentation may call that feature's repository contract directly. A DTO may also be the UI model when the shapes genuinely match.

### Complex feature

Add `domain/` only when the feature has meaningful business rules, multiple data sources, transactions, or offline behavior.

Dependency direction is:

```text
presentation → domain ← data
```

Domain is pure Dart. Repository interfaces live in domain; data implements them. Add use cases only for orchestration or rules worth testing independently.

## 6. Naming and code style

- Follow `dart format` and `analysis_options.yaml`.
- Files: `snake_case.dart`.
- One primary public type per file.
- Route-level widgets: `_screen.dart` or `_page.dart`.
- Riverpod notifiers/controllers: `_controller.dart`.
- DTOs: `_dto.dart`.
- Repository interface: `<name>_repository.dart`.
- Repository implementation: `<name>_repository_impl.dart`.
- Prefer `const` where valid.
- Keep business logic out of widget `build()` methods.
- Avoid null assertions unless immediately justified by a same-scope check.
- Extract deeply nested or oversized widget subtrees into focused widgets.
- Do not add drive-by refactors, speculative abstractions, or unexplained `TODO`s.

## 7. Bootstrap, flavors, and configuration

- Use the single thin `lib/main.dart` entry point calling `bootstrap()`.
- `bootstrap.dart` owns initialization, the error zone, `ProviderScope`, config override, and `runApp`.
- `core/config/` owns the immutable `AppConfig` contract and provider.
- `app/config/env.dart` constructs and validates configuration.
- Use native `dev`, `staging`, and `prod` flavors with matching checked config files.
- Always supply and validate both `APP_FLAVOR` and `config/<flavor>.json`.
- Non-development API URLs must use HTTPS.
- Configuration failures must produce a deterministic fatal-startup surface; never guess defaults silently.

Canonical command shape:

```bash
flutter run --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
```

## 8. Riverpod state and dependency ownership

- Riverpod is both state management and dependency injection; do not add a service locator.
- Providers form the dependency graph through `ref`.
- Ephemeral UI state stays local to the widget.
- Feature/screen state lives in focused Notifier or AsyncNotifier providers under the feature's `presentation/` layer.
- Async state uses `AsyncValue`.
- App-wide infrastructure contracts live in `core/`.
- Auto-dispose by default; keep-alive requires a documented reason.
- State is mutated only by its owning notifier.
- Presentation listeners trigger navigation, snackbars, and dialogs; repositories do not perform UI side effects.
- Riverpod code generation is selective, not mandatory for every provider.

## 9. Navigation

- Use one `GoRouter` under `app/router/`.
- Each feature exports `List<RouteBase>` and route-name/path constants from its public barrel.
- `app/router/routes.dart` aggregates feature routes.
- Do not scatter raw route strings or construct ad-hoc navigators inside features.
- Required reconstructable state belongs in typed path/query parameters.
- `extra` is optional, ephemeral data only; a route must work from cold start or deep link without it.
- Auth protection uses centralized `redirect` logic and a stable Riverpod-backed `refreshListenable` adapter.
- Home and other public routes are guest-accessible after session restoration; authentication is required only for protected capabilities.
- Protected capability redirects preserve validated internal return destinations and continue there after successful phone OTP login.
- Validate preserved return destinations as registered internal routes and prevent redirect loops.
- Approved shell selection rules (M03_WP04): Home selected with no module/tabs; module selection clears bottom-dock selection and shows contextual internal tabs. See `docs/design/APP_SHELL.md`.

## 10. Authentication

O1 is resolved: Laforika owns a custom NestJS + PostgreSQL authentication API
([ADR-0007](docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md)).
Guest-first access and phone-only credentials are recorded in
[ADR-0008](docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md).
The Flutter client keeps the provider-neutral session boundary from ADR-0006.

- Session state is `unknown`, `authenticated(principal)`, or `unauthenticated`.
- The principal exposes an opaque stable `accountId` for scoping only.
- `unknown` must show a deterministic startup state, not flash login.
- Temporary hydration transport failures are recoverable; do not destroy a potentially valid refresh secret.
- `core/auth/` defines the provider-neutral contract; the auth feature exports the custom API adapter; `app/` supplies the override.
- Access tokens are short-lived RS256 JWTs kept in memory; opaque refresh tokens rotate with family reuse detection.
- Phone-number OTP is the only user-facing sign-in method. Do not implement email/password login or password-reset flows.
- Email is optional profile/contact data only and must not silently create a login credential.
- Do not invent a guest backend identity, anonymous principal, or guest access token.
- Do not build fake production authentication. Development fixture delivery is allowed only for SMS message transport.
- Test doubles are allowed only in tests.
- Store only Laforika-owned refresh/session secrets in secure storage.
- Logout must revoke server sessions, clear Laforika-owned secrets, dispose the `{environment, accountId}` scope, and transition to unauthenticated.
- Client guards are UX; NestJS authorization is authoritative.
- Real authentication remains controlled-test-only until O8 is resolved.
- M03_WP03 migration work must use forward non-destructive Prisma migrations; never reset the database to drop deprecated credentials.

## 10a. Backend authentication service

- Backend lives under `backend/` (NestJS, strict TypeScript, npm lockfile committed).
- Validate configuration at startup; reject fixture delivery outside `dev`/`test`; fail closed in staging/prod without real delivery adapters.
- Never commit secrets, PEM keys, `.env` values, dumps, or fixture inbox contents.
- Persist only hashed/HMAC representations of passwords (Argon2id), OTP/email codes, and refresh tokens.
- Sanitize structured security logs; never log credentials, OTPs, tokens, passwords, emails, phones, or raw bodies.
- Version API routes under `/v1`; commit the generated OpenAPI contract and check drift in CI.
- Prisma migrations are committed; migrate clean databases in tests.

## 11. Networking and error handling

- Use one configured `dio` instance behind `dioProvider`.
- Repositories are the only owners of endpoint paths, parameters, and DTO shapes.
- Controllers and use cases never call Dio directly.
- Interceptors, in order: request authentication, bounded retry for safe/idempotent requests, then sanitized debug-development logging.
- Single-flight refresh on eligible 401s; retry each original request at most once; never recursively refresh the refresh call.
- Distinguish definitive auth rejection from temporary network failure.
- Disable HTTP logging in profile/release.
- Redact credentials, cookies, token-like fields, passwords, OTP/code fields, email, phone, and personal request values; test the redactor.
- Catch transport exceptions in data and map them to sealed failures.
- Repository boundaries return `Result<T>`; do not throw raw exceptions across layers.
- Do not add `dartz` or a speculative wrapper around Dio.
- Presentation maps stable backend error codes to localized messages; raw errors and personal data never reach users or logs.

## 12. Storage, caching, and offline

Build storage infrastructure on demand only.

- Non-sensitive preferences use `shared_preferences` behind `PrefsFacade`.
- Laforika-owned small secrets use `flutter_secure_storage` behind `SecureStore`.
- Structured/offline data defaults to Drift when justified.
- The application owns one database connection and migration authority; modules own their tables, DAOs, mappings, and repository logic through a curated schema-contribution seam.
- Partition every user-derived row, protected-media cache entry, and outbox item by `{environment, accountId}`.
- `cached_network_image` is for public/non-sensitive media only unless an explicit protected-cache policy exists.
- Offline reads use the local store as source of truth.
- Offline writes use an outbox committed in the same Drift transaction as the local mutation.
- Outbox replay requires stable idempotency keys, at-least-once handling, bounded backoff, timeouts, acknowledgement before removal, and a feature-specific conflict policy.
- Connectivity changes are retry hints, never proof of internet availability.

## 13. Localization, RTL, UI, and accessibility

- All user-facing text comes from generated localization files.
- Base locale is `fa-IR`; use ARB and `gen_l10n`.
- Never hand-edit generated localization output.
- Use directional layout APIs: `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`, and `end`.
- Avoid hardcoded left/right behavior; mirror directional icons and navigation affordances.
- Format displayed numerals through `intl`; store and compute with Latin digits.
- Dates are stored in Gregorian/UTC. Do not introduce Jalali display before O6 is resolved.
- Use Vazirmatn and centralized semantic theme/type tokens; avoid ad-hoc styles and raw feature colors.
- Appearance modes are System / Light / Dark with System default (M03_WP02). Palette and foundation rules: `docs/design/UI_FOUNDATION.md`.
- Adaptive RTL shell rules: `docs/design/APP_SHELL.md` (M03_WP04).
- Minimum touch target: 48dp.
- Add semantics for icon-only controls and meaningful images.
- Respect text scaling and avoid fixed heights that clip content; verify at 2.0 text scale where shell/theme packages apply.
- Verify light/dark and Persian RTL for themed surfaces; include light/dark RTL goldens when golden coverage exists for those packages.
- Use the small shared breakpoint set; verify phone layouts at 320dp; do not add a heavy responsive framework.
- Do not add a Fluent UI framework dependency.
- Add shared UI primitives only after repeated app-wide use is proven.

## 14. Security and privacy

- Never commit secrets, tokens, signing material, private service files, or real-account data.
- `config/*.json` contains non-secret values only.
- Keep signing material outside VCS and signing changes outside normal feature work.
- Use HTTPS only.
- Do not add certificate pinning until backend certificates and policy are known.
- Do not ship third-party telemetry until O4 and O8 are resolved.
- Logs, errors, and crash reports must be sanitized.
- Request least-privilege permissions at point of use.
- Approved release builds use shrinking plus `--obfuscate --split-debug-info`; do not invent signing or publishing configuration.
- Exclude private authenticated data from Android backup unless an approved encryption and retention policy explicitly allows it.
- Real authentication remains controlled-test-only until the privacy/account-data lifecycle gate is approved.
- Backend JWT keys, peppers, database URLs, and fixture inbox keys are ignored local/CI secrets only.
- Do not require Docker or WSL for everyday backend development.

If a secret is staged, stop, unstage it, and report it. Never commit and remove it later.

## 15. Testing requirements

Tests mirror `lib/` under `test/`. Backend tests live under `backend/test/` (and Nest e2e conventions).

- Unit-test repositories, mappers, use cases, controllers, failure mapping, config validation, redaction, and account scoping.
- Backend unit/e2e tests cover normalization, OTP/token/session security invariants, migrations, and OpenAPI drift.
- Widget-test meaningful loading, error, empty, and data states plus critical interactions.
- Keep the root `fa-IR` and RTL assertion.
- For navigation/auth/shell packages, cover the guest/authenticated × public/protected route matrix and validated return destinations where applicable.
- For theme/shell packages, cover light/dark RTL states, dock swipe / module-header states, 320dp width, and 2.0 text scale where in scope; report those verifications in the task report.
- Golden-test design-system components and at least one full RTL screen when golden coverage exists (light and dark when the theme foundation exists).
- Integration tests are required from M1 for real auth and each module's primary happy path; they must hit the real local backend, not a fake auth provider.
- Use `mocktail`; do not introduce another mocking library.
- Override Riverpod dependencies with fakes in `ProviderContainer` or `ProviderScope`.
- Prefer targeted pumps; use `pumpAndSettle()` only when fully settling async/animation work is intentional.
- Never update goldens unless the task explicitly approves the visual baseline change.

Every new unit of logic requires matching tests in the same task.

## 16. Generated files

- Generated Dart sources under `lib/` are committed (l10n, `json_serializable`, and any selected Riverpod generators).
- Backend Prisma client output follows Prisma conventions; OpenAPI contract output is committed and checked for drift.
- Never hand-edit generated files.
- Edit source annotations/ARB/schema, regenerate, and include the generated diff.
- CI regeneration must leave the repository clean.
- Commit `pubspec.lock` for the application and `backend/package-lock.json` for the API.

## 17. Required quality gates

Run the applicable commands and report their real results:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Backend (from M1):

```bash
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

Before any PR, run the required `dev`, `staging`, and `prod` debug-build matrix **locally** (not uploaded as CI artifacts on the free Actions plan):

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

From M1, run the Android-emulator auth integration **locally** against a started Nest backend (CI does not boot emulators):

```bash
flutter test integration_test/auth_flow_test.dart --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json \
  --dart-define=FIXTURE_INBOX_KEY=<from-backend-env> \
  -d <emulator-id>
```

A task is not complete while an applicable gate fails. Do not claim a command passed unless it was run. If the environment prevents a command, report it as not run with the exact reason.

## 18. Guardrails requiring explicit approval

Do not do any of the following without explicit approval:

- Change the frozen architecture, accepted ADR direction, toolchain, application identity, flavor scheme, min/target SDK, or iOS deployment target.
- Modify CI/CD, release publishing, signing, or store configuration.
- Add or replace a load-bearing dependency, backend SDK, identity provider, analytics/crash vendor, maps provider, push provider, database technology, state tool, DI tool, or router.
- Add a Fluent UI framework dependency or Microsoft proprietary assets.
- Reintroduce email/password login, password-reset, or auth-method-chooser credential UI/backend behavior unless a future approved ADR changes direction.
- Invent a guest backend identity, anonymous principal, or guest access token.
- Ship dead placeholder modules, dead Chat dock actions, or a speculative module registry/persistence framework.
- Resolve owner decisions O2–O6 or O8 by assumption; do not invent external brand assets while O7's remainder is open.
- Introduce external distribution before O8.
- Hand-edit generated files.
- Delete data, rewrite Git history, force-push, delete branches, or commit directly to `main`/`master`.
- Run `flutter test --update-goldens` without explicit visual-baseline approval.
- Create future modules or shared infrastructure before their roadmap milestone or a concrete feature need.

## 19. Git and check-in

Perform Git write operations only when the task requests them.

- Branch: `<type>/<short-kebab-description>` using `feat`, `fix`, `chore`, `refactor`, `docs`, or `test`.
- Commits use Conventional Commits:

```text
<type>(<scope>): <imperative summary without trailing period>
```

- Keep commits atomic by logical change.
- Never commit directly to `main`/`master`.
- Before committing, run applicable quality gates and inspect `git diff --stat` plus the full diff.
- Keep one feature/fix per pull request.
- Update `CHANGELOG.md` and `pubspec.yaml` version only when the task is a release/versioning change and follows repository convention.

### Pull request body

```markdown
## Summary
<what changed and why>

## Related
Closes #<issue>

## Changes
-

## Testing
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter analyze --fatal-infos`
- [ ] `flutter test`
- [ ] `dart run tool/check_import_boundaries.dart`
- [ ] Relevant flavor build
- [ ] Relevant integration test
- [ ] Manual verification on: <device/simulator>

## Screenshots
<UI changes only>

## Notes for reviewer
<tradeoffs, approved deviations, deferred follow-ups>
```

### Milestone / substantial-task delivery workflow

This sequence is mandatory for every milestone or substantial task. Treat this file as the persistent operational memory; do not rely on conversational memory.

1. Implement the scoped work on a task branch (`<type>/...`).
2. Run local verification (applicable quality gates from §17).
3. Commit, push, and open or update the pull request.
4. Wait for CI to pass.
5. Create a clean source archive from the exact PR-head commit:
   - Include tracked source and documentation only.
   - Exclude `.git`, build outputs, caches, secrets, signing files, and local configuration.
   - Report the archive filename and the exact source commit SHA.
6. Stop for owner/external review. Do **not** merge.
7. Apply review fixes on the same branch.
8. Push and obtain a final green CI result after implementation review.
9. Update [`docs/project_inventory.md`](docs/project_inventory.md) **exactly once** on the same task branch, using only facts available **before** that inventory update.
10. Commit the inventory update, push, and rerun applicable CI.
11. Merge the pull request only after that CI result is green **and** explicit approval is given.

#### Inventory recording rules (terminating)

[`docs/project_inventory.md`](docs/project_inventory.md) records the **completed work package**, not its own inventory commit and not the merge commit.

Each completed-check-in entry records only:

- Work package and completed scope
- PR number
- Final reviewed **implementation** commit SHA (the last reviewed implementation commit before the inventory update)
- Verification results
- Remaining owner decisions or limitations
- Exact next work package

Do **not** record:

- Inventory-update commit SHA
- Merge commit SHA
- Temporary branch status
- “Pending merge” or similar transient wording

After archive review and final green CI: update the inventory once → commit it → push and rerun applicable CI → merge when CI is green and approval is given.

The inventory entry appearing on `main` is sufficient proof that the work package was merged. No post-merge inventory update is required.

Do **not** invent a follow-up inventory revision to point at the inventory commit, the merge commit, or any later SHA. That creates a self-referential loop.

## 20. Definition of done

- Acceptance criteria are met.
- The diff is limited to the requested scope.
- Architecture and import boundaries are respected.
- New logic has tests.
- Applicable format, analysis, test, boundary, build, generation, and integration checks pass.
- User-facing text is localized and RTL-safe.
- No secrets, PII leaks, debug prints, unexplained TODOs, or hand-edited generated files exist.
- Documentation is updated when setup, public contracts, architecture, or operator behavior changes.
- Approved deviations and unresolved owner decisions are reported explicitly.

## 21. Required report back

Return a concise final report containing:

- Summary.
- Files changed.
- Tests added or updated.
- Commands run with pass/fail/not-run status.
- Architecture or ADR impacts.
- Approved deviations.
- Remaining blockers or owner decisions.
