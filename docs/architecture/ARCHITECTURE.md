# Laforika — Architecture

**Status:** `FROZEN` · **Version:** 1.4 · **Owner:** Principal Architect · **Last updated:** 2026-07-25

This document is the **single source of truth** for how Laforika is built. Any code that
contradicts it is a bug in the code or a needed change to this document — not both silently.
Deep rationale for the most consequential choices lives in [`adr/`](./adr/README.md); this
document states the decisions and the rules that follow from them.

> The repository's `FLUTTER_ARCHITECTURE_TEMPLATE.md` is a topic checklist only. It is not
> authoritative and is superseded by this document.

### Controlled transition (M03_WP01 → M03_WP07)

Version 1.4 freezes the **approved target** for guest-first access, phone-only authentication,
and the Fluent-inspired adaptive shell. M03_WP02 (theme), M03_WP03 (guest-first routing and
phone-only authentication), M03_WP04 (adaptive application shell), and M03_WP05 (Profile vertical
slice) are implemented. Remaining gaps are **known and bounded** to M03_WP06–M03_WP07
(Settings/Notifications, visual hardening). It is **not** permission for new code to extend a
deprecated direction. Architecture contradictions **outside** this approved transition remain defects.

Design specifications: [`../design/UI_FOUNDATION.md`](../design/UI_FOUNDATION.md),
[`../design/APP_SHELL.md`](../design/APP_SHELL.md).

### Assumptions (labeled)

Where a requirement was unstated, these reasonable assumptions were made. Correct any that are
wrong; several map to owner decisions in §15.

- **[A1]** Android minSdk 24 (Android 7.0+); Flutter 3.44.6 stable and Dart 3.12.2 are
  the frozen M0 toolchain baseline. Toolchain upgrades are explicit reviewed changes.
- **[A2]** Login is **not** required to enter the app. Home and public content are guest-accessible
  after session restoration; authentication is required only for protected capabilities
  ([ADR-0008](./adr/0008-guest-first-access-and-phone-only-authentication.md)). O1 remains
  resolved to a custom NestJS + PostgreSQL authentication API
  ([ADR-0007](./adr/0007-custom-authentication-backend-and-session-security.md)), amended by
  ADR-0008 to **phone OTP only**. The Flutter client keeps the provider-neutral session boundary
  from [ADR-0006](./adr/0006-authentication-and-session.md).
- **[A3]** A single Persian locale (`fa-IR`) at launch; all strings are localized so another
  locale can be added without structural refactoring, but it still requires ARB content, locale
  configuration, and tests.
- **[A4]** Vazirmatn is the Persian UI font. In-app visual system, semantic light/dark palette,
  and shell behavior follow [ADR-0009](./adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md)
  and the design specs; external brand assets (logo, store icon, marketing) remain deferred (O7
  remainder).
- **[A5]** Dates are stored in Gregorian/UTC; user-facing calendar (Jalali?) is undecided (O6).
- **[A6]** No third-party telemetry ships until a vendor + privacy policy exist (O4/O8).
- **[A7]** Small team, no separate per-module ownership yet (justifies a monolith over packages).

---

## 1. High-level architecture

**Laforika is a single Flutter application organized feature-first, with a small shared `core`
and pragmatic (not mandatory) layering inside each feature.** It is a *modular monolith*: one
build, one deployable, clear internal module boundaries.

```
┌──────────────────────────────────────────────────────────┐
│  app/          bootstrap · root widget · router · config  │  composition root
├──────────────────────────────────────────────────────────┤
│  features/     auth · home · <module> · <module> ...       │  product modules
├──────────────────────────────────────────────────────────┤
│  core/         network · auth · storage · theme · l10n ... │  shared infrastructure
└──────────────────────────────────────────────────────────┘
        dependencies point downward only:  app → features → core

Repository topology (M1+): Flutter application at the repository root plus sibling
`backend/` NestJS API. The backend does not import Flutter code; Flutter talks to it over HTTP.
```

**Why this and not the alternatives.** Full Clean Architecture (four layers everywhere) and a
Melos multi-package monorepo were both rejected as overengineering for a small team building a
first release: they impose ceremony on every trivial screen and slow iteration. A single global
`lib/` with no boundaries was rejected as unscalable — it becomes a dumping ground as modules
accrue. Feature-first modular gives us **independent modules that can be added, changed, or
removed without touching each other**, while staying one simple codebase. If a module ever needs
independent versioning or a separate team, it can be extracted into a package later (see
_Revisit conditions_ in [ADR-0001](./adr/0001-modular-feature-first-architecture.md)); we do not
pay that cost up front.

**Load-bearing decisions** (each has an ADR):

| Concern | Decision | ADR |
|---|---|---|
| App structure | Feature-first modular monolith, pragmatic layering | [0001](./adr/0001-modular-feature-first-architecture.md) |
| State + DI | Latest stable Riverpod compatible with the chosen Flutter SDK; providers are the DI container | [0002](./adr/0002-riverpod-state-and-di.md) |
| Navigation | `go_router`, redirect-based guards, per-feature route registry | [0003](./adr/0003-go-router-navigation.md) |
| Networking + errors | `dio` + interceptors; sealed `Failure`/`Result`, no `dartz` | [0004](./adr/0004-networking-and-error-model.md) |
| Local data / offline | secure storage + prefs now; **Drift** as the deferred default store | [0005](./adr/0005-local-persistence-and-offline.md) |
| Auth session boundary | Provider-neutral Flutter session contract | [0006](./adr/0006-authentication-and-session.md) |
| Auth backend / tokens | Custom NestJS + PostgreSQL; RS256 access + rotating refresh | [0007](./adr/0007-custom-authentication-backend-and-session-security.md) |
| Access model / credentials | Guest-first Home; phone OTP only; email as profile data | [0008](./adr/0008-guest-first-access-and-phone-only-authentication.md) (partially supersedes credential/access product choice in 0007) |
| Visual foundation / shell | Fluent-inspired semantic light/dark; adaptive RTL app shell | [0009](./adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md) |

---

## 2. Project / folder structure

```text
laforika/
├─ lib/
│  ├─ main.dart                     # thin entry point → bootstrap()
│  ├─ bootstrap.dart                # error zone, ProviderScope, config override, runApp
│  ├─ app/
│  │  ├─ app.dart                   # MaterialApp.router (theme, l10n, locale)
│  │  ├─ router/
│  │  │  ├─ app_router.dart         # go_router instance + auth redirect
│  │  │  └─ routes.dart             # aggregates feature route registries
│  │  └─ config/
│  │     └─ env.dart                # constructs AppConfig from checked build defines/files
│  ├─ core/
│  │  ├─ config/                    # AppConfig value + appConfigProvider contract
│  │  ├─ network/                   # Dio provider; adapter-backed request auth when required
│  │  ├─ error/                     # Failure sealed types, Result, exception mapping
│  │  ├─ auth/                      # provider-neutral session contract and router bridge
│  │  ├─ storage/                   # secure_storage + prefs facades (thin, purposeful)
│  │  ├─ connectivity/              # network-change retry hints, never proof of internet
│  │  ├─ theme/                     # tokens, ThemeData, Vazirmatn typography
│  │  ├─ localization/              # l10n wiring / access helpers
│  │  ├─ ui/                        # proven app-wide primitives only; no speculative catalog
│  │  └─ utils/                     # small pure helpers, extensions, formatters
│  ├─ features/
│  │  └─ <feature>/
│  │     ├─ <feature>.dart          # PUBLIC BARREL: routes + entry API (module contract)
│  │     ├─ presentation/           # screens, widgets, Riverpod controllers
│  │     ├─ domain/                 # (complex only) entities, use cases, repo interfaces
│  │     └─ data/                   # (as needed) dto, data sources, repo impl, mappers
│  └─ l10n/                         # app_fa.arb (+ generated output per l10n.yaml)
├─ backend/                         # NestJS custom authentication API (M1+)
│  ├─ src/                          # Nest modules (auth, users, config, common, database)
│  ├─ prisma/                       # schema + committed migrations
│  ├─ test/                         # unit + e2e
│  ├─ scripts/                      # key generation, OpenAPI export helpers
│  └─ package.json                  # npm lockfile committed
├─ assets/{fonts,images}/           # Vazirmatn font, static images
├─ test/                            # mirrors lib/ ; unit + widget + golden
├─ integration_test/                # end-to-end flows (real backend from M1)
├─ tool/check_import_boundaries.dart # executable §3 boundary gate
├─ l10n.yaml                         # explicit gen_l10n configuration
├─ config/{dev,staging,prod}.json   # --dart-define-from-file (NO secrets committed)
├─ docs/architecture/               # this document + ADRs
├─ docs/design/                     # approved UI foundation + app-shell specs (docs only)
├─ docs/prompts/                    # versioned work-package prompts
├─ .github/workflows/ci.yml         # Flutter + backend quality gates
├─ analysis_options.yaml            # flutter_lints baseline
└─ pubspec.yaml
```

**Naming.** `snake_case.dart` files; one primary public type per file. Screens end in
`_screen.dart` (route-level) or `_page.dart`; Riverpod notifiers in `_controller.dart`; DTOs in
`_dto.dart`; repository interfaces `<x>_repository.dart`, implementations
`<x>_repository_impl.dart`.

---

## 3. Dependency & import-direction rules

These rules are the boundary contract. CI enforces them (see §13).

1. **`core/` depends on nothing internal above it.** It must never import `features/` or `app/`.
   Core is framework/infrastructure only; it knows no product module.
2. **`features/` may import `core/`, their own subtree, and—only under rule 3—another feature's
   curated public barrel.** A feature must never reach into another feature's internals
   (`features/x/presentation/...`).
3. **Cross-feature use is allowed only through the target feature's public barrel**
   (`features/x/x.dart`) for navigation entry points or an explicitly exported contract. Such
   dependencies must remain one-way and acyclic. Product/domain logic never moves into
   infrastructure-only `core/`; when genuinely shared, it becomes an explicitly named feature or
   application capability with a curated public contract.
4. **`app/` is the composition root.** Only `app/` wires features together (registers their
   routes, applies global overrides). `app/` may import feature barrels; features must not import
   `app/`.
5. **Inside a complex feature, dependencies point `presentation → domain ← data`.** The
   `domain` layer defines interfaces and depends on nothing but permitted `core` contracts;
   `data` implements those interfaces; `presentation` depends on `domain`. In a simple feature
   without `domain/`, `presentation → data` is allowed through that feature's repository contract
   (see §4).
6. **No cyclic imports.** Barrels export a curated public surface; they must not re-export
   internals that would let callers bypass these rules.

---

## 4. Simple vs. complex modules

Layering is a tool, not a tax. Choose the lightest structure that fits the module. **Do not create
empty layers "for later."**

**Simple module** — read-mostly, few screens, no offline needs (e.g. Local Heritage list/detail,
News feed):

```
features/heritage/
├─ heritage.dart              # barrel: routes + entry
├─ data/
│  ├─ heritage_dto.dart
│  └─ heritage_repository.dart   # concrete: talks to Dio, maps DTO → simple model
└─ presentation/
   ├─ heritage_list_screen.dart
   ├─ heritage_detail_screen.dart
   └─ heritage_controller.dart   # Riverpod notifier calls repository directly
```

No separate `domain/`, no use-case classes, DTO may double as the UI model when shapes match.

**Complex module** — rich business rules, multi-source data, offline/sync, transactions
(e.g. Shop with cart/checkout, Community/Chat, Villas booking):

```
features/shop/
├─ shop.dart
├─ domain/
│  ├─ entities/            # pure Dart, no serialization
│  ├─ repositories/        # abstract interfaces
│  └─ usecases/            # only where logic is non-trivial (e.g. PlaceOrder)
├─ data/
│  ├─ dto/                 # json_serializable
│  ├─ sources/             # remote (Dio) + local (Drift) data sources
│  ├─ mappers/             # dto ⇄ entity
│  └─ *_repository_impl.dart
└─ presentation/
   ├─ screens/ widgets/ controllers/
```

**Promotion rule:** start a module simple; introduce `domain/` (entities + interfaces) the moment
it has real business rules, more than one data source, or offline behavior. Add use-case classes
only when a controller would otherwise hold orchestration logic worth testing in isolation.

---

## 5. Bootstrap & environment configuration

**Frozen application identity.** The Dart project name is `laforika`; the organization namespace is
`com.primebuilds`; Android `namespace` and production `applicationId` are
`com.primebuilds.laforika`. The `staging` and `dev` flavors append `.staging` and `.dev`
respectively. iOS bundle identifiers mirror the same base and suffixes so future iOS support does
not require an identity migration. M0 creates the platform project with:

```bash
flutter create --project-name laforika --org com.primebuilds --platforms=android,ios .
```

No placeholder identity may be uploaded or published.

**Entry & bootstrap.** `main.dart` is intentionally trivial. `core/config/` owns the immutable
`AppConfig` contract and `appConfigProvider`; `app/config/env.dart` constructs the value from the
checked build inputs, and `bootstrap.dart` supplies it as a root override:

```dart
// main.dart
Future<void> main() => bootstrap();

// bootstrap.dart (shape)
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = loadAppConfig();
  await runZonedGuarded(() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details); // retain normal debug visibility
      reportSanitizedFlutterError(details); // remote sink remains absent until O4
    };
    runApp(ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const LaforikaApp(),
    ));
  }, reportSanitizedUncaughtError);
}
```

Bootstrap never silently swallows errors. Until O4 is resolved, the remote telemetry sink is a
no-op, but Flutter's default debug presentation and sanitized local diagnostics remain enabled.
Startup configuration failures render a deterministic fatal-startup surface rather than running
with partial or guessed values.

**Environments (flavors).** Three: `dev`, `staging`, `prod`. Runtime configuration is passed via
**`--dart-define-from-file`** and read into `AppConfig` (environment name, required API base URL
once networking exists, feature flags, log level). Android Gradle product flavors provide the
identity suffixes above; iOS schemes mirror them.

A single checked build entry accepts one flavor value and derives both the native flavor and the
same-named configuration file. It also supplies `APP_FLAVOR`; startup verifies that this value
matches the configuration's environment name. CI and project scripts use this form:

```bash
flutter run --flavor "$FLAVOR" --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
flutter build apk --debug --flavor "$FLAVOR" --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"
```

`config/*.json` contains only non-secret values. From M1, `API_BASE_URL` is required: `dev`
defaults to the Android-emulator loopback (`http://10.0.2.2:3000/v1`); `staging`/`prod` use
explicit HTTPS hosts (or documented non-routable `.invalid` placeholders until real hosts exist).
Configuration validates every field required by the current milestone and rejects unknown
environments; any configured non-development API URL must use HTTPS. Secrets and signing material
never live in the repository (see §12). Physical-device or iOS-simulator host overrides use an
ignored local config; do not commit machine-specific URLs.

---

## 6. State management & dependency ownership

**Use the latest stable Riverpod release compatible with the selected Flutter SDK as both the
state manager and the DI container.** Code generation (`riverpod_annotation` /
`riverpod_generator`) is used selectively where it materially improves maintainability; it is not
required for every provider. Using one tool for both roles is deliberate — it removes a second DI
package (e.g. `get_it`) and keeps wiring explicit and testable. See
[ADR-0002](./adr/0002-riverpod-state-and-di.md).

**Where state lives:**

- **Ephemeral UI state** (form fields, toggles, animation) → local widget state
  (`StatefulWidget` / `useState`-style). Do not put it in providers.
- **Feature/screen state** → a Notifier/AsyncNotifier provider in that feature's
  `presentation/`, generated or handwritten according to the rule above, exposing an immutable
  state object. Async results use `AsyncValue` so loading/error/data are handled uniformly.
- **App/session state** → providers in `core/` (for example the provider-neutral session contract
  and `appConfigProvider`). Connectivity is introduced only with a real retry/offline use case.

**Ownership rules:**

- A provider is **owned by the layer that defines the contract**: product-agnostic infrastructure
  and application-wide contracts live in `core/`; module state providers live in the feature.
  `AppConfig` and `appConfigProvider` live in `core/config/`, while `app/config/env.dart` constructs
  the value and bootstrap overrides it.
- Providers depend on other providers via `ref` — this *is* the dependency graph. No global
  singletons, no service locator.
- Keep providers small and single-purpose; auto-dispose by default, keep-alive only with a
  documented reason.
- **Never mutate state outside its notifier.** Side effects (navigation, snackbars) are triggered
  by the presentation layer listening to state, not performed inside repositories.

---

## 7. Navigation & module integration

**`go_router`** is the router. See [ADR-0003](./adr/0003-go-router-navigation.md).

**Module integration via a route registry.** Each feature exposes its routes from its public
barrel as a `List<RouteBase>`; `app/router/routes.dart` aggregates them into the single
`GoRouter`. Adding a module = add one import + spread its routes. Features never build their own
`Navigator`; they declare routes and navigate by name/path.

```dart
// features/home/home.dart
List<RouteBase> homeRoutes() => [ GoRoute(path: '/', builder: ...) ];

// app/router/routes.dart
List<RouteBase> appRoutes() => [ ...homeRoutes(), ...authRoutes(), ...shopRoutes() ];
```

**Conventions:** path-based routes and `const` route-name constants exported from each barrel (no
raw string paths at call sites). Data required to reconstruct a destination belongs in typed
path/query parameters. `extra` is permitted only for optional, ephemeral in-process data; no route
may depend on it to open correctly from a cold start or deep link. Deep links map to the same route
table (one source of truth), enabling future push-notification and web deep-linking without
rework.

**Redirect contract (guest-first — implemented in M03_WP03):**

| Session | Destination | Result |
|---|---|---|
| `unknown` | any | remain on the deterministic startup surface; do not guess or flash login |
| `unauthenticated` | public (including Home) | allow |
| `unauthenticated` | protected capability | redirect to **direct phone OTP** and preserve a validated internal destination |
| `authenticated` | auth-only OTP/login routes | return to the validated destination, otherwise Home |
| `authenticated` | public or protected | allow |

Home is public. Public modules/content are guest-explorable. Authentication is required only at
protected-capability boundaries (for example Account Security today; Chat and Notifications later).
A preserved destination must resolve to a registered internal **path only** (query parameters and
fragments are rejected). External, malformed, or unknown locations fall back to Home. Router tests
cover the guest/authenticated/public/protected matrix and loop prevention.

**Shell selection (implemented in M03_WP04; Profile added in M03_WP05):** Home is selected after session
restoration with no module and no module-internal tabs active. Selecting a module clears bottom-dock
selection, highlights the module strip item, and shows contextual internal tabs. Production currently
ships Profile and Home dock destinations and omits unavailable Chat/module destinations (no dead
placeholders). Feature route barrels remain the module-integration boundary. Full shell rules:
[`../design/APP_SHELL.md`](../design/APP_SHELL.md).

---

## 8. Authentication, session & route protection

Full Flutter session contract in [ADR-0006](./adr/0006-authentication-and-session.md). Concrete
backend and token model in [ADR-0007](./adr/0007-custom-authentication-backend-and-session-security.md).
Guest-first access and phone-only credentials in
[ADR-0008](./adr/0008-guest-first-access-and-phone-only-authentication.md). O1 is **resolved**:
Laforika owns a custom NestJS + PostgreSQL authentication API; ADR-0008 amends the user-facing
credential model to **phone OTP only**.

- **Session state:** `authControllerProvider` exposes
  `AuthState = { unknown, authenticated(principal), unauthenticated }`. The authenticated principal
  exposes an opaque, stable `accountId` for scoping only. `unknown` covers session hydration so the
  UI shows a startup surface rather than flashing login. Temporary transport failures during
  hydration are recoverable and must not destroy a potentially valid refresh secret.
- **Provider adapter:** `core/auth/` defines the provider-neutral session contract and overridable
  provider. The auth feature exports the custom API adapter through its public barrel, and `app/`
  composition supplies the override. `core/` never imports `features/`.
- **Credentials:** phone-number OTP is the **only** user-facing sign-in method.
  Email is optional profile/contact data and must not silently create a login credential. The
  verified phone number is the account's primary login identity. The auth-method chooser,
  email/password login, and password reset are removed (M03_WP03). Normalized phone
  identifiers remain globally unique.
- **Tokens:** short-lived RS256 access JWTs (in memory on the client) and opaque rotating refresh
  tokens (environment-scoped in `flutter_secure_storage`). Refresh uses token families with reuse
  detection and family revocation. Protected API requests enforce active session status server-side.
  No guest access token or anonymous backend principal is introduced.
- **Credential storage:** only Laforika-owned refresh/session secret material uses
  `flutter_secure_storage`. OTPs and form contents are never persisted. Credentials are never
  stored in preferences and never logged.
- **Refresh/recovery:** single-flight refresh; concurrent 401s await the same refresh; retry each
  original request once; never recursively refresh the refresh call. Definitive session invalidation
  clears secrets and becomes `unauthenticated`; temporary network failure does not.
- **Logout:** revokes the current session (or all sessions when requested), clears Laforika-owned
  secrets, disposes the current `{environment, accountId}` provider scope, and transitions to
  `unauthenticated`. Account deletion awaits O8.
- **Delivery:** phone OTP lifecycle is real; development uses fixture delivery; staging/prod fail
  closed until real adapters are configured.
- **Route protection:** a stable `GoRouter` reads the current auth state in `redirect`. An
  app-owned `Listenable` adapter, created with the router provider, subscribes to
  `authControllerProvider` through Riverpod and calls `notifyListeners()` when session state
  changes; it is supplied as `refreshListenable`. This re-runs redirects without reconstructing
  the router. Protected capabilities preserve the intended destination through phone OTP login.
- **Migration safety:** never reset or silently delete a database to drop email/password
  support; use committed forward Prisma migrations; stop for an owner decision if a non-test
  account has only email/password and no verified phone. Historical migrations remain immutable.
- **Authority:** client guards are UX; the NestJS API is authoritative for access control.

---

## 9. Networking, errors, DTOs, repositories & API ownership

Full model in [ADR-0004](./adr/0004-networking-and-error-model.md).

- **Client:** one configured **`dio`** instance behind `dioProvider` in `core/network/`
  (base URL from `AppConfig`, sane timeouts). Interceptors, in order: request authentication for
  eligible API calls, bounded retry with backoff for safe/idempotent requests, and sanitized
  logging in debug development builds only. Credential retrieval and refresh delegate to the
  custom auth adapter. HTTP logging is disabled in profile/release and must redact
  `Authorization`, `Cookie`, `Set-Cookie`, token-like fields, passwords, OTP/code fields, email,
  phone, and personal query/body values; the redactor is tested.
- **API contract:** the NestJS backend publishes a versioned `/v1` OpenAPI contract generated from
  source annotations. Flutter maps stable machine-readable error codes to ARB strings; backend
  messages are not the UI localization source.
- **DTOs:** `data/dto/*_dto.dart` with `json_serializable`. DTOs are the wire format and stay in
  `data/`. They never leak into `presentation/` of a complex module (mapped to entities); a simple
  module may use the DTO directly as its model when shapes match (§4).
- **Repositories own the API.** A feature's repository is the *only* place that knows endpoint
  paths, query params, and DTO shapes for that feature. Controllers/use cases call repositories,
  never Dio directly. This keeps API knowledge co-located with the module that owns it and out of
  the UI.
- **Errors are values, not exceptions, at boundaries.** Dio/`Exception`s are caught in the data
  layer and mapped to a sealed `Failure` (`NetworkFailure`, `TimeoutFailure`, `ServerFailure`,
  `AuthFailure`, `NotFoundFailure`, `ValidationFailure`, `UnknownFailure`). Repository methods
  return `Result<T>` (a sealed `Success`/`FailureResult`) — **no `dartz`**, plain Dart 3 sealed
  classes + pattern matching. Presentation maps `Failure` → localized user message via l10n; raw
  errors never reach the user or logs-as-PII.

---

## 10. Storage, caching & offline

Full model in [ADR-0005](./adr/0005-local-persistence-and-offline.md). **Nothing here is built
until a module needs it** — but the choices are pre-decided so no one improvises later.

- **Preferences** (non-sensitive, small key/values: last locale, onboarding-seen, UI flags) →
  `shared_preferences` behind a thin `PrefsFacade` in `core/storage/`.
- **Secure storage** (small credentials and cryptographic/session secrets owned by Laforika) →
  `flutter_secure_storage` behind `SecureStore`. Other personal data is not placed there by
  default; it requires an explicit retention, encryption, deletion, and database policy. Nothing
  sensitive goes to preferences or an unprotected disk cache.
- **Structured/relational data & offline** → **Drift (SQLite)** is the default when a module needs
  it (Shop catalog/cart, saved places, chat history, offline reads). Chosen over Hive/Isar for
  mature migrations, relational queries, and reactive streams. The application owns one Drift
  database connection and one schema-version/migration authority by default; each module owns its
  tables, DAOs, mappings, and repository logic inside its feature boundary. App composition owns
  a curated schema-contribution seam; modules never open independent connections by default. This
  avoids both a coupling-heavy god database and unnecessary independent SQLite connections/files.
- **Network/image caching** → `cached_network_image` only for public/non-sensitive media. Private
  media requires a user-scoped cache partitioned by `{environment, accountId}` with explicit purge
  behavior. Short-lived response caching is added only where a module proves it needs it.
- **Account isolation:** every persisted user-derived row, protected-media cache entry, and outbox
  item is partitioned by `{environment, accountId}` and is never read or replayed for another
  account.
- **Offline sync (future):** for sync-capable modules, the pattern is **local store as source of
  truth for reads** plus a **write outbox**. Each local mutation and its outbox row commit in the
  same Drift transaction. The outbox stores a stable idempotency key; replay assumes at-least-once
  delivery and marks/removes an item only after server acknowledgement. Connectivity changes are
  retry hints only, never proof of internet or server reachability. Replay uses request timeouts,
  bounded backoff, idempotency, and server-response handling. Conflict policy is defined per
  module; last-write-wins is only an explicit module choice, not a universal default. This pattern
  is implemented per module on demand, not speculatively.

---

## 11. Localization, RTL, typography, accessibility & responsive UI

- **Localization:** `flutter_localizations` + `intl` + ARB via `gen_l10n`. `pubspec.yaml` sets
  `flutter.generate: true`; `l10n.yaml` sets `arb-dir: lib/l10n`, `template-arb-file: app_fa.arb`,
  `output-localization-file: app_localizations.dart`, and a generated output directory under
  `lib/l10n/generated/`. `MaterialApp.router` uses the generated delegates and supported locales.
  **All user-facing strings come from l10n from day one.** Adding another locale requires ARB
  content, locale configuration, and tests, but no architecture change.
- **Locale & RTL:** `supportedLocales: [Locale('fa','IR')]`, `locale: const Locale('fa','IR')`.
  Flutter derives RTL from the locale; **complete RTL is achieved by using directional APIs
  everywhere** — `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end` (never `left/right`),
  directional icons, and mirrored back/chevron affordances. RTL correctness is a golden-test and
  review checklist item. M0 includes a widget test asserting `fa-IR` and `Directionality.rtl` at the application root.
- **Numerals & dates:** Persian (Eastern Arabic) digits via `intl` `NumberFormat` for display;
  store/compute in Latin digits. Calendar defaults to Gregorian for storage; if Jalali (Persian)
  calendar display is required product-wide, adopt `shamsi_date` (flagged in §15 as it affects
  product behavior).
- **Typography:** bundle **Vazirmatn** (open-source Persian font) in `assets/fonts/`, set as the
  default `fontFamily`. A type scale (display/title/body/label) lives in `core/theme/`; features
  use scale tokens, not ad-hoc `TextStyle`s.
- **Theme (implemented — M03_WP02):** Laforika-owned semantic light and dark palettes
  ([ADR-0009](./adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md);
  [`../design/UI_FOUNDATION.md`](../design/UI_FOUNDATION.md)). Appearance modes are `System`,
  `Light`, and `Dark` with **`System` default**, persisted through `PrefsFacade`. Material 3
  `ThemeData` and semantic tokens — not a Fluent UI framework dependency. Motion ~180–250ms;
  respect reduced motion where Flutter exposes it. Translucency cannot reduce contrast below
  accessibility targets; blur is progressive enhancement only. Broader visual hardening remains
  M03_WP07.
- **Adaptive shell (implemented in M03_WP04):** see
  [`../design/APP_SHELL.md`](../design/APP_SHELL.md) for module strip, search scoping, contextual
  tabs, floating dock, and Profile/Settings/Notifications rules. Unavailable destinations are
  omitted until real routes exist; fixture coverage exercises full shell chrome in tests only.
- **Accessibility:** minimum 48dp touch targets; `Semantics`/`semanticLabel` on icon-only
  controls and images; respect system text scaling (no fixed heights that clip scaled text);
  verify at **2.0** text scale; target WCAG AA contrast in theme tokens. Screen-reader pass on
  primary flows before release.
- **Responsive:** phone-first; verify at **320dp** width. A small set of width breakpoints in
  `core/theme/` (e.g. compact / medium / expanded) via `LayoutBuilder`/`MediaQuery`; no heavy
  responsive framework. Tablet polish is opportunistic, not a launch requirement.

> **Transition note:** Theme foundation (M03_WP02), guest-first / phone-only auth (M03_WP03),
> adaptive shell (M03_WP04), and Profile (M03_WP05) are implemented. Settings/Notifications
> (M03_WP06) and full visual hardening (M03_WP07) remain pending.

---

## 12. Security & privacy baseline

- **No secrets in the repo.** No API keys, tokens, or signing material committed. Runtime config
  via `--dart-define-from-file`; signing via CI secrets / local keystore outside VCS.
  `config/*.json` contains only non-sensitive values.
- **Credential storage:** small credentials and session/cryptographic secrets owned by Laforika
  use `flutter_secure_storage`. Other personal data follows an explicit retention, encryption,
  deletion, account-isolation, and database policy. Logs and crash reports scrub credentials and
  personal data; private authenticated data is excluded from Android backup unless encryption and
  the approved policy explicitly allow it.
- **Transport:** HTTPS only. **Certificate pinning is deferred** until backend certificates are
  known (revisit condition; needs owner/backend input) — the Dio layer is the single place to add
  it.
- **Release hardening:** R8/ProGuard shrink + resource shrink, `--obfuscate --split-debug-info`
  for release builds; least-privilege Android permissions requested at point of use, not upfront.
- **Privacy:** data collection is minimized; any analytics/crash SDK that transmits user data is
  an owner decision (§15) with a privacy-policy obligation. Until chosen, no third-party telemetry
  ships. Before any build using real accounts leaves controlled testing, O8 must define
  auth/account data collection, processors, retention, local deletion, account deletion, and
  applicable notice or consent. Until then, real authentication is test-only.
- **Auth boundaries:** protected capabilities are enforced by redirect (§8); the NestJS API remains
  authoritative for access control — client guards are UX, not security. Guests have no access
  token and no anonymous backend principal. Profile contact data remains subject to the O8
  account-data lifecycle policy before external distribution.
- **Backend secrets:** JWT signing keys, refresh/OTP peppers, database URLs, and fixture inbox
  keys never live in the Flutter tree or tracked config. Staging/prod reject fixture delivery.

---

## 13. Testing strategy & CI quality gates

**Testing (proportionate, not coverage theater):**

- **Unit** — repositories (with a mocked Dio client), mappers, use cases, controllers/notifiers,
  `Failure` mapping, config validation, HTTP redaction, and account scoping.
- **Widget** — key screens' loading/error/empty/data states, critical interactions, and the M0
  `fa-IR`/RTL application-root assertion.
- **Route matrix (from M03_WP03/M03_WP07):** guest/authenticated × public/protected destinations, including
  validated return destinations and loop prevention.
- **Shell / visual (from M03_WP04/M03_WP07):** dock swipe mapping; expanded/compact module-header states;
  light/dark RTL goldens; **320dp** width and **2.0** text-scale checks; semantics for icon-only
  shell controls.
- **Golden** — design-system components and at least one full screen **in RTL** (light and dark
  when the theme foundation exists) to lock layout direction.
- **Integration** (`integration_test`) — required from M1 for the real auth flow and then each
  module's primary happy path.
- **Mocking:** `mocktail` (no code generation). Test tree mirrors `lib/`.
- Riverpod dependencies are overridden with fakes in `ProviderContainer`/`ProviderScope`.

**Reproducibility.** CI pins Flutter 3.44.6 stable; `pubspec.lock` is committed for the application.
Generated Dart sources under `lib/` (l10n and, when introduced, Riverpod/JSON/Drift output) are
committed, never hand-edited, regenerated in CI, and checked for an empty diff. Toolchain or
generator-policy changes are reviewed changes.

**CI (GitHub Actions) — required gates on every PR:**

```bash
# Flutter (all milestones)
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart

# Backend (from M1)
npm ci --prefix backend
npm run format:check --prefix backend
npm run lint --prefix backend
npm run typecheck --prefix backend
npm run prisma:validate --prefix backend
npm run test --prefix backend
npm run test:e2e --prefix backend
npm run openapi:check --prefix backend

# Matrix: FLAVOR = dev, staging, prod
flutter build apk --debug --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"

# Required Android-emulator job from M1 (real backend + PostgreSQL)
flutter test integration_test --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json -d <emulator-id>
```

The import-boundary script rejects every §3 violation. Merges are blocked unless all gates
applicable to the milestone pass. CI artifacts are debug-signed and non-publishable; release
signing/publishing waits for O5. Coverage is reported, not gated by a hard percentage.
Backend generated OpenAPI output and Prisma schema/migrations are committed and checked for drift.

---

## 14. Roadmap — dependency-ordered

Each milestone is shippable/reviewable and unblocks the next. **No module directory is created
before its milestone.**

### Completed baseline (history)

- **M0 — Project bootstrap.** Frozen identity, flavors, RTL localization, theme placeholder,
  routing, CI, and boundary enforcement. ✅
- **M1 — Authentication vertical slice.** Custom NestJS API, provider-neutral session, dual
  credentials as originally shipped, secure refresh, Dio interceptors, protected redirects. ✅
- **M2 — Home / discovery shell.** Authenticated Persian RTL Home and feature route-registry
  pattern. ✅

### Approved transition packages (after M2)

These close the gap between the M2 code baseline and the v1.4 target.

- **M03_WP01 — Documentation and decision freeze.** ADR-0008, ADR-0009, architecture v1.4, UI
  foundation and shell specifications, contributor/README alignment. ✅
- **M03_WP02 — Light/dark theme foundation.** Semantic tokens, Material 3 light/dark, System/Light/Dark
  with System default and preferences persistence; typography/spacing/radius/elevation tokens;
  light/dark RTL visual tests. No routing/auth/shell redesign. ✅
- **M03_WP03 — Guest-first routing and phone-only authentication.** Public Home for guests; direct
  phone OTP; protected return destinations; remove method chooser, email/password login, and
  password reset; forward non-destructive backend/OpenAPI/Prisma migration as required; email
  becomes profile data. No shell redesign. ✅
- **M03_WP04 — Adaptive application shell.** Adaptive RTL module strip, search row, contextual internal
  tabs, floating bottom dock, selection and swipe rules; real registered destinations only; no
  dead Chat/module placeholder. ✅
- **M03_WP05 — Profile vertical slice.** Guest direct-phone-login Profile; authenticated profile fields;
  staged Settings/Notifications header contract; backend profile contract as required. ✅
- **M03_WP06 — Settings and Notifications.** Guest-accessible appearance settings; About/account
  sections; protected Notifications with real states; no push SDK while O3 is unresolved.
  ← **exact next package**
- **M03_WP07 — Integration and visual hardening.** Complete guest/auth/public/protected route matrix;
  return destinations; light/dark RTL goldens; 320dp; 2.0 text scale; semantics; dock swipe;
  expanded/compact module header; documentation reconciliation.

**Exact next package after M03_WP05:** **M03_WP06 — Settings and Notifications**.

### Later product milestones (after the M03_WP01–M03_WP07 transition)

Milestone **M03** is the guest-first / phone-only / UI-foundation transition program
(`M03_WP01`–`M03_WP07`). Later product milestones continue as **M04** and **M05** so they do not
collide with that program id.

- **M04 — First specialized module.** Pick **one** production module (owner chooses; recommended:
  a read-mostly module such as News/Events or Local Heritage) and introduce only the networking,
  errors, caching, storage, and shared UI it genuinely requires. _Exit:_ one specialized module
  works end-to-end and proves the simple-module architecture in production shape.
- **M05 — First complex/offline module, when justified.** A later module such as Shop, Chat, or
  Villas may introduce Drift and an outbox/synchronization policy after its real data and conflict
  requirements are known. Before implementation, define the app-level schema-contribution seam and
  backup eligibility. _Exit:_ migrations are tested from every supported schema version; account
  isolation, transaction/outbox crash recovery, replay idempotency, purge behavior, and Android
  backup policy are verified without creating a speculative app-wide sync framework.

M04's module choice depends on product priority and must not be invented during M03_WP01–M03_WP07.
Connectivity and shared UI infrastructure beyond proven need are added only through the first real
feature that requires them.

---

## 15. Decisions requiring owner input

These affect product behavior, legal/privacy, paid vendors, data ownership, or deployment, so the
architect should not decide them unilaterally. Each has a safe default so work is not blocked.

| # | Decision | Why it needs the owner | Interim default (unblocks work) |
|---|---|---|---|
| O1 | **Backend & identity provider** — **RESOLVED:** custom NestJS + PostgreSQL API; RS256 access + opaque rotating refresh; monorepo `backend/`. User-facing credential amended by [ADR-0008](./adr/0008-guest-first-access-and-phone-only-authentication.md) to **phone OTP only** (email is profile data). Backend ownership/token security remain [ADR-0007](./adr/0007-custom-authentication-backend-and-session-security.md). | — | Implemented in M1; phone-only / guest-first product change implemented in M03_WP03. |
| O2 | **Maps provider** — Google Maps vs. Iranian providers (Neshan / Balad) | Google services are often unreliable/restricted in Iran; affects a core module + vendor keys/cost. | Defer; maps module not before provider chosen. |
| O3 | **Push notifications** — FCM vs. local/regional service | FCM depends on Google Play services (unreliable in-market); vendor + privacy. | Defer; no push infra built yet. |
| O4 | **Crash/analytics vendor** — Sentry vs. Crashlytics vs. none | Sends user data (privacy policy), paid tiers, Google-service reliance. | No remote telemetry ships; default debug error presentation and sanitized local diagnostics remain active. |
| O5 | **Distribution channel** — Google Play vs. Cafe Bazaar / Myket vs. direct APK | Determines signing, update mechanism, store policies, CI publish step. | CI produces debug-signed, non-publishable APKs only. |
| O6 | **Jalali (Persian) calendar** for user-facing dates | Product/UX behavior for a Persian audience. | Gregorian storage; display calendar TBD. |
| O7 | **Branding** — **PARTIALLY RESOLVED:** in-app visual system, semantic palette, typography direction, and shell behavior via [ADR-0009](./adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md) and [`../design/`](../design/). **Still open:** logo, launch/store icons, marketing identity, illustrations. | External brand assets and store presence. | M03_WP02–M03_WP05 implement the approved in-app system; do not invent external brand assets. |
| O8 | **Legal/privacy** — privacy policy, terms, data retention, age policy | Legal obligation; gates telemetry and any real-account build leaving controlled testing. | Real auth remains test-only; no telemetry; account-data lifecycle must be approved before external distribution. |

---

## Freeze record

Version 1.4 records the approved guest-first, phone-only, Fluent-inspired adaptive-shell target via
ADR-0008 and ADR-0009 on top of the M2 baseline. ADR-0008 **partially supersedes** only the
dual-credential and authenticated-first product implications of ADR-0007; NestJS/PostgreSQL
ownership, token security, session revocation, fixture delivery, and server authority from ADR-0007
remain in force. ADR-0006 remains the provider-neutral Flutter session boundary. O7 is partially
resolved for the in-app visual foundation; external brand assets remain open. O2–O6 and O8 remain
unresolved. O8 continues to gate external distribution of real-account builds. M03_WP02,
M03_WP03, M03_WP04, and M03_WP05 are implemented; M03_WP06–M03_WP07 close the remaining
documented code-to-target gaps. M03_WP01 itself changed documentation only.

---

## Change control

Material changes to a load-bearing decision require a new or superseding **ADR**; this document
is then updated to point at it. Non-structural clarifications edit this document directly and bump
the version. ADRs are immutable once `Accepted` (supersede, don't rewrite). ADR-0008 supersedes
only the credential/access product choice in ADR-0007 without editing that accepted file.
