# Laforika — Architecture

**Status:** `FROZEN` · **Version:** 1.2 · **Owner:** Principal Architect · **Last updated:** 2026-07-21

This document is the **single source of truth** for how Laforika is built. Any code that
contradicts it is a bug in the code or a needed change to this document — not both silently.
Deep rationale for the most consequential choices lives in [`adr/`](./adr/README.md); this
document states the decisions and the rules that follow from them.

> The repository's `FLUTTER_ARCHITECTURE_TEMPLATE.md` is a topic checklist only. It is not
> authoritative and is superseded by this document.

### Assumptions (labeled)

Where a requirement was unstated, these reasonable assumptions were made. Correct any that are
wrong; several map to owner decisions in §15.

- **[A1]** Android minSdk 24 (Android 7.0+); Flutter 3.44.6 stable and Dart 3.12.2 are
  the frozen M0 toolchain baseline. Toolchain upgrades are explicit reviewed changes.
- **[A2]** Authentication is required, but the backend and identity-provider session model are
  undecided (see §8/O1). The client architecture remains provider-neutral until O1 is resolved.
- **[A3]** A single Persian locale (`fa-IR`) at launch; all strings are localized so another
  locale can be added without structural refactoring, but it still requires ARB content, locale
  configuration, and tests.
- **[A4]** Vazirmatn is the Persian UI font (open-source, no licensing cost) until branding (O7).
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
| Auth | Provider-neutral session state, secure credential handling, redirect guard; concrete token model deferred to O1 | [0006](./adr/0006-authentication-and-session.md) |

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
├─ assets/{fonts,images}/           # Vazirmatn font, static images
├─ test/                            # mirrors lib/ ; unit + widget + golden
├─ integration_test/                # end-to-end flows
├─ tool/check_import_boundaries.dart # executable §3 boundary gate
├─ l10n.yaml                         # explicit gen_l10n configuration
├─ config/{dev,staging,prod}.json   # --dart-define-from-file (NO secrets committed)
├─ docs/architecture/               # this document + ADRs
├─ .github/workflows/ci.yml         # format → analyze → test → build
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
**`--dart-define-from-file`** and read into `AppConfig` (environment name, optional API base URL
until networking exists, feature flags, log level). Android Gradle product flavors provide the
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

`config/*.json` contains only non-secret values. Configuration validates every field required by
the current milestone and rejects unknown environments; any configured non-development API URL
must use HTTPS. Secrets and signing material never live in the repository (see §12).

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

**Redirect contract (implemented with M1):**

| Session | Destination | Result |
|---|---|---|
| `unknown` | any | remain on the deterministic startup surface; do not guess or flash login |
| `unauthenticated` | public | allow |
| `unauthenticated` | protected | redirect to login and preserve a validated internal destination |
| `authenticated` | login/auth-only | return to the validated destination, otherwise Home |
| `authenticated` | public or protected | allow |

A preserved destination must resolve to a registered internal route; external, malformed, or
unknown locations are discarded. Router tests cover the matrix and loop prevention.

---

## 8. Authentication, session & route protection

Full model in [ADR-0006](./adr/0006-authentication-and-session.md). Auth is **required**; the
backend and identity provider are an **owner decision** (§15). Until O1 is resolved, the accepted
architecture defines provider-neutral session behavior rather than assuming that Laforika owns
JWT access and refresh tokens.

- **Session state:** `authControllerProvider` exposes
  `AuthState = { unknown, authenticated(principal), unauthenticated }`. The authenticated principal
  exposes an opaque, stable `accountId` for scoping only. `unknown` covers provider/session
  hydration so the UI shows a startup surface rather than flashing login.
- **Provider adapter:** `core/auth/` defines the provider-neutral session contract and overridable
  provider. The auth feature exports the selected adapter through its public barrel, and `app/`
  composition supplies the override. The provider may manage tokens itself (for example Firebase
  Auth), or Laforika may own credentials for a custom API; that choice is made with O1.
- **Credential storage:** only small credentials or session secrets that Laforika itself owns are
  stored in `flutter_secure_storage`. Provider-managed SDK sessions remain provider-managed.
  Credentials are never stored in preferences and never logged.
- **Refresh/recovery:** refresh semantics belong to the selected provider adapter. If O1 chooses a
  bearer + refresh-token API, use single-flight refresh and retry the failed request once. Do not
  implement token refresh before that model is confirmed.
- **Logout:** invokes the provider's sign-out/revocation behavior when available, stops outbox
  replay, clears Laforika-owned session secrets, disposes the current `{environment, accountId}`
  provider scope, and transitions to `unauthenticated`. Retention/purge follows the approved module
  policy; account deletion purges all data in that scope.
- **Route protection:** a stable `GoRouter` reads the current auth state in `redirect`. An
  app-owned `Listenable` adapter, created with the router provider, subscribes to
  `authControllerProvider` through Riverpod and calls `notifyListeners()` when session state
  changes; it is supplied as `refreshListenable`. This re-runs redirects without reconstructing
  the router. Public and protected routes preserve the intended destination through login.

---

## 9. Networking, errors, DTOs, repositories & API ownership

Full model in [ADR-0004](./adr/0004-networking-and-error-model.md).

- **Client:** one configured **`dio`** instance behind `dioProvider` in `core/network/`
  (base URL from `AppConfig`, sane timeouts). Interceptors, in order: request authentication
  whenever the selected backend requires authenticated Dio calls, retry with backoff for
  safe/idempotent requests, and sanitized logging in debug development builds only. Credential
  retrieval and refresh delegate to the selected auth adapter whether the session is SDK-managed
  or Laforika-owned. HTTP logging is disabled in profile/release and must redact `Authorization`,
  `Cookie`, `Set-Cookie`, token-like fields, and personal query/body values; the redactor is tested.
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
- **Accessibility:** minimum 48dp touch targets; `Semantics`/`semanticLabel` on icon-only
  controls and images; respect system text scaling (no fixed heights that clip scaled text);
  target WCAG AA contrast in theme tokens. Screen-reader pass on primary flows before release.
- **Responsive:** phone-first. A small set of width breakpoints in `core/theme/` (e.g. compact /
  medium / expanded) via `LayoutBuilder`/`MediaQuery`; no heavy responsive framework. Tablet
  polish is opportunistic, not a launch requirement.

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
- **Auth boundaries:** protected routes are enforced by redirect (§8); the backend or selected
  identity provider remains authoritative for access control — client guards are UX, not security.

---

## 13. Testing strategy & CI quality gates

**Testing (proportionate, not coverage theater):**

- **Unit** — repositories (with a mocked Dio client), mappers, use cases, controllers/notifiers,
  `Failure` mapping, config validation, HTTP redaction, and account scoping.
- **Widget** — key screens' loading/error/empty/data states, critical interactions, and the M0
  `fa-IR`/RTL application-root assertion.
- **Golden** — design-system components and at least one full screen **in RTL** to lock layout
  direction.
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
# All milestones
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart

# Matrix: FLAVOR = dev, staging, prod
flutter build apk --debug --flavor "$FLAVOR" \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  --dart-define-from-file="config/$FLAVOR.json"

# Required Android-emulator job from M1
flutter test integration_test --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json -d <emulator-id>
```

The import-boundary script rejects every §3 violation. Merges are blocked unless all gates
applicable to the milestone pass. CI artifacts are debug-signed and non-publishable; release
signing/publishing waits for O5. Coverage is reported, not gated by a hard percentage.

---

## 14. Roadmap — dependency-ordered

Each milestone is shippable/reviewable and unblocks the next. **No module directory is created
before its milestone.**

- **M0 — Project bootstrap.** Create the project with the frozen identity in §5; add
  `analysis_options.yaml` (`flutter_lints`), the minimal `app/` and `core/` skeleton, explicit l10n
  wiring with `app_fa.arb`, Vazirmatn and theme tokens, checked `AppConfig`/flavor binding,
  `ProviderScope`/bootstrap, `go_router` with one minimal Home route, the executable boundary
  checker, and the CI matrix in §13. _Exit:_ the app runs in `fa-IR` RTL, the root widget test
  passes, all three debug flavor builds succeed, generated files are reproducible, and CI is green.
- **M1 — Authentication decision and real vertical slice.** Resolve O1, then implement the
  selected provider adapter, session controller, login/logout, secure handling required by that
  provider, and protected-route redirects. Introduce Dio interceptors or token refresh only if the
  chosen model requires them. _Exit:_ real authentication works against the selected backend or
  identity provider in controlled testing; no fake session or stubbed auth flow remains. Before
  that real-auth build leaves controlled testing, the O8 distribution gate in §12 is satisfied.
- **M2 — Home / discovery shell.** Build the authenticated landing surface and establish the
  module-integration pattern with one real screen. Extract shared UI primitives only when the Home
  implementation proves repeated use. _Exit:_ authenticated users land on a navigable Persian RTL
  Home and adding a module follows the documented route-registry boundary.
- **M3 — First specialized module.** Pick **one** production module (recommended: a read-mostly
  module such as News/Events or Local Heritage) and introduce only the networking, errors, caching,
  storage, and shared UI it genuinely requires. _Exit:_ one specialized module works end-to-end and
  proves the simple-module architecture in production shape.
- **M4 — First complex/offline module, when justified.** A later module such as Shop, Chat, or
  Villas may introduce Drift and an outbox/synchronization policy after its real data and conflict
  requirements are known. Before implementation, define the app-level schema-contribution seam and
  backup eligibility. _Exit:_ migrations are tested from every supported schema version; account
  isolation, transaction/outbox crash recovery, replay idempotency, purge behavior, and Android
  backup policy are verified without creating a speculative app-wide sync framework.

M1 depends on O1; M3's module choice depends on product priority. M0 can proceed immediately, but
networking, storage, connectivity, and shared UI infrastructure are added only through the first
real feature that requires them.

---

## 15. Decisions requiring owner input

These affect product behavior, legal/privacy, paid vendors, data ownership, or deployment, so the
architect should not decide them unilaterally. Each has a safe default so work is not blocked.

| # | Decision | Why it needs the owner | Interim default (unblocks work) |
|---|---|---|---|
| O1 | **Backend & identity provider** (custom API? Firebase Auth? OTP/SMS? OAuth?) | Data ownership, cost, session ownership, and Iran-market availability; drives M1. | Keep the session contract provider-neutral; do not implement fake auth or assume JWT/token ownership. |
| O2 | **Maps provider** — Google Maps vs. Iranian providers (Neshan / Balad) | Google services are often unreliable/restricted in Iran; affects a core module + vendor keys/cost. | Defer; maps module not before provider chosen. |
| O3 | **Push notifications** — FCM vs. local/regional service | FCM depends on Google Play services (unreliable in-market); vendor + privacy. | Defer; no push infra built yet. |
| O4 | **Crash/analytics vendor** — Sentry vs. Crashlytics vs. none | Sends user data (privacy policy), paid tiers, Google-service reliance. | No remote telemetry ships; default debug error presentation and sanitized local diagnostics remain active. |
| O5 | **Distribution channel** — Google Play vs. Cafe Bazaar / Myket vs. direct APK | Determines signing, update mechanism, store policies, CI publish step. | CI produces debug-signed, non-publishable APKs only. |
| O6 | **Jalali (Persian) calendar** for user-facing dates | Product/UX behavior for a Persian audience. | Gregorian storage; display calendar TBD. |
| O7 | **Branding** — app name display, palette, logo, launch icon | Design-system tokens and store assets. | Neutral placeholder theme tokens. |
| O8 | **Legal/privacy** — privacy policy, terms, data retention, age policy | Legal obligation; gates telemetry and any real-account build leaving controlled testing. | Real auth remains test-only; no telemetry; account-data lifecycle must be approved before external distribution. |

---

## Freeze record

Version 1.2 incorporates the final independent freeze review. The architecture pattern, framework,
state/DI choice, router, HTTP client, storage defaults, localization direction, and roadmap intent
are unchanged; the revision freezes missing ownership, account-isolation, outbox, identity/flavor,
CI, auth-neutrality, and privacy contracts.

---

## Change control

Material changes to a load-bearing decision require a new or superseding **ADR**; this document
is then updated to point at it. Non-structural clarifications edit this document directly and bump
the version. ADRs are immutable once `Accepted` (supersede, don't rewrite).
