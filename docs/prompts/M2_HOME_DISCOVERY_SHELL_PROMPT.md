# M2 Home / Discovery Shell Prompt

## TASK

Deliver **M2 — Home / discovery shell** on top of the completed M1 authentication baseline.

Replace the M0 placeholder Home with a production-shaped, authenticated, Persian RTL landing screen; establish the minimal route-registry integration contract that future feature modules must follow; preserve all M1 authentication behavior; and prove the Home happy path with focused widget, router, boundary, and real-backend integration coverage.

This task must remain a Home/application-shell work package. Do not begin M3 or create speculative product modules.

## WHY

M1 proves that real users can authenticate securely. M2 must give authenticated users a useful, navigable landing surface and leave the repository with a clear, tested method for integrating the first production module in M3.

The outcome that matters:

- an authenticated user consistently lands on a real Persian RTL Home;
- the Home exposes only real, currently available actions;
- account security remains reachable;
- logout remains correct;
- future modules integrate through their public route registries rather than internal imports or ad-hoc router edits;
- no unused feature, networking, storage, or shared-UI infrastructure is created early.

## MILESTONE

**M2 — Home / discovery shell**

Architecture exit condition:

> Authenticated users land on a navigable Persian RTL Home and adding a module follows the documented route-registry boundary.

## REVIEWED BASELINE

The final reviewed M1 implementation archive is:

- Archive: `laforika-m1-auth-final-247c98f6-src.zip`
- Final reviewed implementation commit:
  `247c98f606d57455b596e7624aea2ccb23f31924`

The final M1 review confirmed:

- the unsafe email-verification backfill was removed;
- challenge-authorized mutations are atomic with challenge consumption;
- destination rate-limit keys use domain-separated HMAC fingerprints;
- OpenAPI error contracts are generated and tested;
- prior OTP, refresh rotation/replay, secure fixture, logging, test-database, Dio, and resend fixes remain present.

### Mandatory precondition

Do not start M2 from the M1 implementation branch.

Before creating the M2 branch, confirm that the terminating M1 workflow has completed:

1. M1 final green applicable CI;
2. one terminating M1 entry added to `docs/project_inventory.md`;
3. inventory commit pushed and its applicable CI green;
4. M1 PR merged after approval;
5. local `main` is clean and synchronized with `origin/main`;
6. the merged M1 implementation is the reviewed commit above, followed only by the terminating inventory commit and merge mechanics.

If M1 is not merged or the M1 inventory entry is absent, stop and report that M1 check-in must be completed. Do not mix M1 closure and M2 implementation in one branch.

## OWNER DECISIONS

### Resolved and authoritative

- **O1:** custom NestJS + PostgreSQL authentication backend;
- phone OTP and email/password credentials on one stable account;
- short-lived RS256 access tokens;
- opaque rotating refresh tokens with replay detection and revocation;
- secure Flutter refresh-token storage;
- real auth remains controlled-test-only until O8.

### Must remain untouched

- **O2:** maps provider;
- **O3:** push provider;
- **O4:** crash/analytics vendor;
- **O5:** distribution channel;
- **O6:** Jalali display;
- **O7:** final branding;
- **O8:** privacy/legal/account-data lifecycle.

### Safe defaults for M2

- No maps, push, remote telemetry, publishing, or account deletion.
- Keep Gregorian/UTC behavior; M2 introduces no dates.
- Keep the neutral placeholder Material 3 theme because O7 is unresolved.
- Real-account builds remain controlled-test-only because O8 is unresolved.
- Keep the owner-approved CI arrangement:
  - long-running Android flavor builds run locally;
  - Android-emulator auth integration runs locally;
  - do not restore those as GitHub Actions jobs.

## CHECK-IN MODE

**New branch + atomic commits + PR + reviewed archive**

- Branch: `feat/home-discovery-shell`
- Base: clean, synchronized `main` after M1 merge
- Commits: Conventional Commits, atomic by logical change
- PR: use the `AGENTS.md` PR body
- Stop for owner/external review before inventory update or merge
- Never commit directly to `main`/`master`

## SCOPE

### In scope

#### Flutter Home feature

- `lib/features/home/home.dart`
- `lib/features/home/presentation/home_screen.dart`
- focused Home-private widgets under `lib/features/home/presentation/` only when extraction materially improves readability
- Home widget tests under `test/features/home/`

#### Application routing

- `lib/app/router/routes.dart`
- minimal `lib/app/router/app_router.dart` changes needed to consume the aggregated registered-path contract
- router/registry tests under `test/app/`

#### Localization and theme

- `lib/l10n/app_fa.arb`
- generated localization output through `gen_l10n`
- existing theme/token files only when a Home requirement proves a reusable token is needed
- no branding redesign

#### Integration and documentation

- update `integration_test/auth_flow_test.dart` only as required for the M2 Home contract
- `README.md`:
  - current work package;
  - roadmap status;
  - concise feature-route integration instructions
- commit this exact task prompt at:
  `docs/prompts/M2_HOME_DISCOVERY_SHELL_PROMPT.md`
- `docs/project_inventory.md` only at the terminating inventory step after review and final green CI

### Out of scope / do not touch

- New specialized feature directories such as News, Events, Heritage, Shop, Chat, Villas, Maps, Notifications, Profile, or Search
- Fake module cards, disabled destinations, “coming soon” module placeholders, or invented product content
- Backend source, Prisma schema/migrations, auth endpoints, OpenAPI behavior, or backend dependencies
- New remote Home/discovery endpoints
- Dio repositories or network calls for Home
- Local persistence, Drift, caches, connectivity services, outboxes, or sync
- Push notifications, maps, analytics, crash vendors, or telemetry
- Account deletion or O8 policy work
- App identity, flavors, toolchain, Android/iOS deployment configuration
- Final palette, logo, icon, illustrations, or brand assets
- Heavy responsive packages or navigation-shell dependencies
- A generic app-wide component library
- A generic “module registry framework”
- Empty `data/` or `domain/` directories for Home
- Changes to M1 security semantics
- Release/version changes, signing, publishing, or store setup
- Unrelated cleanup or drive-by refactors

## REQUIRED CONTEXT

Read fully before editing:

- `AGENTS.md`
- `README.md`
- `docs/project_inventory.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/adr/0001-modular-feature-first-architecture.md`
- `docs/architecture/adr/0002-riverpod-state-and-di.md`
- `docs/architecture/adr/0003-go-router-navigation.md`
- `docs/architecture/adr/0006-authentication-and-session.md`
- `docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md`
- `docs/prompts/M1_AUTHENTICATION_VERTICAL_SLICE_PROMPT.md`
- `pubspec.yaml`
- `analysis_options.yaml`
- `l10n.yaml`
- `.github/workflows/ci.yml`

Inspect fully:

- `lib/app/app.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/routes.dart`
- `lib/core/auth/`
- `lib/core/theme/`
- `lib/features/auth/auth.dart`
- `lib/features/home/home.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/l10n/app_fa.arb`
- generated l10n files
- `test/app/app_test.dart`
- `test/app/auth_router_and_security_test.dart`
- all existing Home tests, if present
- `integration_test/auth_flow_test.dart`
- `tool/check_import_boundaries.dart`
- closest established M1 screen/widget patterns

Confirm actual package versions before importing anything. No new dependency is expected or approved.

---

# REQUIRED PRODUCT AND UI CONTRACT

## 1. Home remains the authenticated root destination

Preserve:

```dart
const String homeRouteName = 'home';
const String homeRoutePath = '/';
```

Requirements:

- `/` remains reconstructable from cold start and deep link.
- It requires authentication through the centralized `GoRouter.redirect`.
- Unknown/hydration-error state still shows the deterministic startup route.
- Unauthenticated access to `/` still redirects to the auth-method route with a validated return destination.
- Successful login without a valid preserved destination lands on `/`.
- Authenticated navigation to an auth-only route redirects to `/` unless a valid internal return destination exists.
- Home must not construct its own `Navigator`, `MaterialApp`, or router.
- Do not move route protection into Home widgets.

## 2. Replace the M0 placeholder with one real Home screen

The Home screen is the single real screen required by M2.

It must be useful using data that already exists in the authenticated principal. It must not depend on an invented backend Home API.

### Required screen structure

Use a `Scaffold` with:

1. **App bar**
   - localized Laforika title;
   - account-security icon action;
   - logout icon action;
   - localized tooltips;
   - icon-only controls meet the 48dp touch target and have semantics;
   - preserve normal Material directional behavior.

2. **Scrollable body**
   - `SafeArea`;
   - directional outer padding;
   - vertically scrollable at narrow heights and large text scales;
   - centered width constraint on tablets/wide layouts;
   - no fixed body height;
   - no clipping at text scale 2.0;
   - no horizontal overflow at 320 logical pixels.

3. **Welcome section**
   - clear Persian welcome title;
   - short Persian explanation that this screen exposes the currently available Laforika areas;
   - no technical text;
   - no environment name;
   - no backend/API status;
   - no raw error details.

4. **Account-status summary**
   - driven only by the current `AuthAuthenticated.principal`;
   - show whether phone login is attached;
   - show whether email/password login is attached;
   - show masked phone/email only when provided;
   - use localized labels;
   - do not make a Home repository/network request;
   - do not mutate authentication state from `build()`.

5. **Available-destination / quick-action section**
   - contain exactly one current real navigable destination:
     **Account security**;
   - whole item/card is tappable;
   - use the public `accountSecurityRoutePath` from the auth feature barrel;
   - navigate with `context.push(accountSecurityRoutePath)`;
   - include a leading security icon, localized title, localized description, and directional navigation affordance;
   - do not include future module placeholders.

6. **Logout**
   - invokes only `authControllerProvider.notifier.logout()`;
   - do not call `AuthRepository` or Dio directly;
   - do not manipulate secure storage from Home;
   - the router must react to the resulting unauthenticated state;
   - prevent duplicate invocation while the same logout action is pending if the UI can be tapped repeatedly;
   - failures remain governed by the existing M1 session behavior; do not redesign authentication in M2.

### Account ID privacy

The opaque `accountId` exists for scoping and test identity continuity, not as primary user-facing Home content.

- Remove the raw account ID from the Home presentation.
- Do not render `principal.accountId` in Home text, semantics, tooltips, keys, or logs.
- Do not delete the account ID from `AuthPrincipal`.
- Do not change backend account IDs.
- Existing account-security behavior may remain unless a small test-only adjustment is required.
- Update the integration test so it verifies stable account identity through provider/repository state rather than parsing the account ID from visible Home text.

## 3. Required Persian source strings

All new user-facing strings must be added to `lib/l10n/app_fa.arb` with clear descriptions where useful. Do not hand-edit generated localization output.

Use these exact Persian source values unless an existing key already expresses the same meaning precisely:

```json
{
  "homeWelcomeTitle": "به لفوریکا خوش آمدید",
  "homeWelcomeSubtitle": "از اینجا به بخش‌های در دسترس لفوریکا دسترسی دارید.",
  "homeAccountStatusTitle": "وضعیت حساب",
  "homePhoneReady": "شماره موبایل تأیید شده است",
  "homePhoneMissing": "شماره موبایل به حساب متصل نیست",
  "homeEmailReady": "ایمیل تأیید شده است",
  "homeEmailMissing": "ایمیل به حساب متصل نیست",
  "homeAvailableSectionsTitle": "دسترسی سریع",
  "homeAccountSecurityTitle": "امنیت حساب",
  "homeAccountSecurityDescription": "روش‌های ورود، رمز عبور و نشست‌های فعال را مدیریت کنید.",
  "homeOpenAccountSecurity": "باز کردن امنیت حساب",
  "homeLogoutTooltip": "خروج از حساب"
}
```

Rules:

- Reuse existing auth/account strings where they are semantically identical.
- Remove or repurpose `homeWelcomeMessage` only if every reference is updated.
- Do not leave obsolete generated references.
- Do not concatenate Persian sentences in widgets.
- Masked identifiers are interpolation values, not separate hardcoded strings.
- Displayed numerals, if any, go through existing localization/`intl` conventions.

## 4. Responsive behavior

Use Flutter framework primitives only.

Required behavior:

- narrow layouts: cards/sections stack vertically;
- wide layouts: account-status and quick-action areas may use a balanced `Wrap`, `Row`, or constrained multi-column arrangement;
- content remains centered with a sensible maximum width;
- layout remains RTL-correct;
- do not add a responsive package;
- do not add speculative global breakpoints.

Prefer private Home-local constants for a breakpoint or max width if only Home uses them. Promote them to `AppTokens` only when at least one other current app surface genuinely reuses the same value in this task.

## 5. Accessibility

- Every icon-only action has a localized tooltip and semantic label.
- The account-security destination exposes one coherent tappable semantic action; avoid nested competing taps.
- Status indicators must not rely on color alone.
- Use text plus icon/shape.
- Maintain Material contrast through the existing theme.
- Minimum interactive size: 48dp.
- Respect text scaling.
- Do not hide essential information from screen readers.
- Decorative icons are excluded from redundant semantics where appropriate.

## 6. Styling

- Use the existing Material 3 theme and Vazirmatn.
- Use existing `AppTokens` spacing.
- Use `Theme.of(context).colorScheme` and `textTheme`.
- No hardcoded final brand palette.
- No custom shadows, gradients, or visual system unless directly justified by the existing theme.
- Prefer Material `Card`, `ListTile`, `Chip`, `Badge`, `Wrap`, and standard layout widgets.
- Do not build a custom design-system catalog in `core/ui`.
- Extract a shared primitive only if this task proves repeated app-wide use in at least two independent current features. Home-private widgets do not count as app-wide shared primitives.

---

# ROUTE-REGISTRY INTEGRATION CONTRACT

M2 must leave a small, explicit route-registration pattern for M3.

## 1. Feature barrel contract

`lib/features/home/home.dart` remains Home’s curated public barrel.

It should expose only the intended public contract:

- `homeRouteName`;
- `homeRoutePath`;
- `homeRoutes()`;
- `homeRegisteredPaths`;
- the route-level Home entry widget only if external tests or composition genuinely need it.

Do not expose private Home subwidgets.

If `HomeScreen` is needed outside the feature, export it intentionally from the barrel. Remove external imports of:

```text
features/home/presentation/...
```

Other features and app-level tests must use the Home public barrel.

## 2. Registered-path aggregation

Add a minimal aggregation contract in `lib/app/router/routes.dart`, for example:

```dart
List<RouteBase> appRoutes() => <RouteBase>[
  ...authRoutes(),
  ...homeRoutes(),
];

Set<String> get appRegisteredPaths => <String>{
  ...authRegisteredPaths,
  ...homeRegisteredPaths,
};
```

Exact syntax may follow repository conventions, but behavior must be equivalent.

Requirements:

- `app_router.dart` uses the aggregated registered-path set when validating preserved return destinations.
- Do not maintain an additional manual `{homeRoutePath, ...authRegisteredPaths}` set inside `app_router.dart`.
- Each future feature should need:
  1. its own public route constants/registry/path set;
  2. one aggregation edit in `app/router/routes.dart`;
  3. tests.
- Do not build a dynamic plugin registry, reflection system, code generator, service locator, or route annotation framework.
- Route names and paths remain unique.
- No raw feature path string is scattered outside the owning feature barrel, except test expectations that intentionally verify the public contract.

## 3. README documentation

Add a concise **Feature route integration** section to `README.md` that says:

1. create the feature only in its roadmap milestone;
2. expose route name/path constants, `List<RouteBase>`, and registered paths from the feature public barrel;
3. aggregate only the public barrel in `app/router/routes.dart`;
4. never import another feature’s `presentation/`, `data/`, or `domain/` internals;
5. include the new internal path in the aggregated set used for validated return destinations;
6. add route/redirect/boundary tests;
7. do not introduce future modules early.

Reference architecture §3 and §7 rather than duplicating the entire architecture.

## 4. No route architecture change

This is implementation/documentation of the already frozen route-registry direction.

Expected architecture impact:

- no ADR;
- no architecture version change;
- no router replacement;
- no navigation-shell package;
- no bottom navigation with nonexistent destinations.

---

# STATE AND DEPENDENCY RULES

- Home reads `authControllerProvider`.
- Home does not own session state.
- Home does not call Dio.
- Home does not call secure storage.
- Home does not create a repository.
- Home does not introduce a controller unless there is actual non-ephemeral screen state.
- A local pending-logout boolean may remain widget-local.
- No Riverpod code generation is required.
- No keep-alive provider is expected.
- Do not create Home `data/` or `domain/` layers.
- Do not put product-specific Home/discovery content in `core/`.

---

# ACCEPTANCE CRITERIA

## Baseline and scope

- [ ] M1 is merged and recorded before the M2 branch is created.
- [ ] Branch is `feat/home-discovery-shell` from clean synchronized `main`.
- [ ] This prompt is committed as `docs/prompts/M2_HOME_DISCOVERY_SHELL_PROMPT.md`.
- [ ] Diff contains no backend implementation change.
- [ ] No future module directory or placeholder destination is added.
- [ ] No new dependency is added.
- [ ] O2–O8 remain untouched.
- [ ] O8 controlled-test-only restriction remains documented.

## Home behavior

- [ ] Authenticated users land on `/`.
- [ ] Home is a real Persian RTL discovery/landing screen, not the M0 placeholder.
- [ ] Home uses the authenticated principal only.
- [ ] Home makes no network/repository call.
- [ ] Phone/email credential status renders correctly.
- [ ] Masked values render only when available.
- [ ] Raw account ID is not visible on Home.
- [ ] Account security is the only current discovery destination.
- [ ] Account-security navigation uses the auth public barrel.
- [ ] Logout uses the auth controller and redirects to auth.
- [ ] No future-module or “coming soon” cards exist.
- [ ] Screen scrolls and does not overflow on narrow/short/large-text layouts.
- [ ] Interactive controls meet accessibility requirements.

## Route integration

- [ ] Home barrel exposes a curated route contract.
- [ ] Home registered paths are aggregated in `app/router/routes.dart`.
- [ ] `app_router.dart` uses the aggregate path contract.
- [ ] No Home internal presentation import exists outside Home.
- [ ] Route names are unique.
- [ ] Route paths are unique.
- [ ] Valid internal return destinations remain accepted.
- [ ] Auth-only/startup/external/malformed destinations remain rejected.
- [ ] README documents the integration pattern.

## Localization and generated output

- [ ] All new text comes from ARB.
- [ ] Persian source text is correct.
- [ ] Directional APIs are used.
- [ ] Generated localization files are regenerated, committed, and clean on second generation.
- [ ] No generated file is hand-edited.

## Regression safety

- [ ] M1 startup hydration still does not flash login.
- [ ] Protected-route redirects remain correct.
- [ ] Account-security screen remains reachable.
- [ ] Logout and auth refresh remain correct.
- [ ] Root `fa-IR` and RTL assertion remains.
- [ ] Existing auth unit/widget/integration tests remain green.
- [ ] Boundary checker remains green.
- [ ] No secrets, PII logs, debug-only user content, or unexplained TODOs are introduced.

---

# REQUIRED TESTS

## 1. Home widget tests

Create focused tests under:

```text
test/features/home/
```

At minimum:

### Authenticated account with phone and email

- pump Home with `AuthAuthenticated`;
- verify `TextDirection.rtl`;
- verify localized welcome and sections;
- verify phone-ready and email-ready states;
- verify masked phone/email when provided;
- verify raw `accountId` is absent from rendered text;
- verify account-security action exists;
- verify logout action exists.

### Missing credential variants

- phone-only principal:
  - phone ready;
  - email missing.
- email-only principal:
  - email ready;
  - phone missing.
- optional masked values absent:
  - no literal `null`;
  - no empty punctuation artifact;
  - accessible status text remains.

### Account-security navigation

- use a small test `GoRouter` or the real app router with provider overrides;
- tap the full account-security destination;
- verify navigation to `accountSecurityRoutePath`;
- do not import auth internals.

### Logout

- fake/recording `AuthSessionGateway`;
- tap logout;
- verify exactly one current-session logout request;
- verify controller becomes unauthenticated;
- verify router presents the auth entry;
- repeated rapid taps do not produce duplicate logout calls if the first is pending.

### Responsive and text scaling

Test at minimum:

- 320×568 logical size;
- a tablet/wide size such as 900×800;
- text scale 2.0;
- no Flutter exception;
- no overflow indicators;
- content remains scrollable;
- key actions remain reachable.

Use `addTearDown` to restore tester view metrics.

### Semantics

- account-security action has an understandable localized semantic label;
- logout action has an understandable localized semantic label;
- status text is available without relying on icon color.

## 2. Router and registry tests

Extend/create app router tests to cover:

- `appRoutes()` includes auth and Home registries;
- `appRegisteredPaths` includes every current internal route;
- no duplicate route name;
- no duplicate route path;
- Home is protected;
- authenticated auth-route redirect lands on Home;
- validated return to account security still works;
- `/` remains a valid return destination;
- auth-only paths cannot become authenticated return destinations;
- startup path cannot become a return destination;
- external URLs, protocol-relative URLs, encoded external URLs, malformed paths, and unknown internal paths are rejected;
- app router no longer maintains a separate manual Home/auth registered set.

Use the closest existing `auth_router_and_security_test.dart` patterns.

## 3. Boundary tests

Update `test/tool/` or the boundary checker’s tests only if needed to assert:

- external Home callers do not import `features/home/presentation/...`;
- app imports the Home public barrel;
- Home may import auth only through `features/auth/auth.dart`;
- no feature imports `app/`;
- no cycle is introduced.

Do not weaken existing boundary rules.

## 4. Integration test

Update the existing real-backend Android flow rather than creating a fake M2 flow.

Required M2 assertions after successful real phone login:

1. Home route/screen is visible.
2. Persian Home welcome/title is visible.
3. account-status section reflects the current principal.
4. raw account ID is not scraped from visible Home text.
5. read stable account identity from `authControllerProvider` or the existing repository response for continuity assertions.
6. open Account security through the Home destination.
7. return to Home through normal router navigation.
8. force access-token expiry and verify the existing protected request refresh behavior remains authenticated.
9. logout from Home and verify auth entry is shown.

Preserve the existing real Nest + PostgreSQL + fixture-delivery setup. Do not inject fake auth.

## 5. Existing tests

Run all existing Flutter and backend tests. Do not delete or weaken M1 tests to accommodate M2.

## 6. Golden testing

No golden baseline currently exists.

- Do not introduce or update goldens unless this task explicitly receives visual-baseline approval.
- Manual RTL verification and widget coverage are required.
- If the repository already contains a golden harness at implementation time, follow the frozen architecture and add one approved Home RTL golden without updating unrelated goldens.

---

# MANUAL UI VERIFICATION

Verify on an Android emulator in `dev` flavor:

- Persian RTL layout;
- narrow phone layout;
- rotation or wide emulator layout if practical;
- text scaling at 1.0 and 2.0;
- account-security navigation;
- system back returns to Home;
- logout returns to auth;
- no raw account ID on Home;
- no clipped Persian text;
- no left/right hardcoding;
- no hidden action under keyboard or system insets;
- tap targets are comfortable.

Capture PR screenshots for the Home UI:

- narrow authenticated Home;
- wide/tablet or landscape Home if materially different;
- account-security navigation target only if useful for reviewer context.

Do not include real phone numbers, real email addresses, access tokens, account IDs, or fixture keys in screenshots.

---

# IMPLEMENTATION GUIDANCE

## Expected file surface

Likely:

```text
lib/features/home/home.dart
lib/features/home/presentation/home_screen.dart
lib/features/home/presentation/<focused_private_widget>.dart   # only if needed
lib/app/router/routes.dart
lib/app/router/app_router.dart                                 # minimal
lib/l10n/app_fa.arb
lib/l10n/generated/*                                           # generated
test/features/home/home_screen_test.dart
test/app/auth_router_and_security_test.dart                    # extend
test/tool/*                                                    # only if needed
integration_test/auth_flow_test.dart
README.md
docs/prompts/M2_HOME_DISCOVERY_SHELL_PROMPT.md
```

Do not create files merely to match this list. Keep the smallest clear surface.

## Suggested screen composition

A proportionate structure may be:

```text
HomeScreen
├─ AppBar
├─ _HomeWelcome
├─ _AccountStatusCard
│  ├─ phone status row
│  └─ email status row
└─ _HomeDestinationCard
   └─ Account security
```

These may remain private widgets. Do not promote them to `core/ui`.

## Keys

Use stable keys only for meaningful integration/widget interactions. Suggested keys:

```text
home_discovery_shell
home_account_status
home_phone_status
home_email_status
home_account_security
home_logout
```

Do not encode account IDs, emails, or phone numbers in keys.

## Error handling

Home has no new async data dependency.

- Do not add loading/error/empty states for nonexistent Home fetching.
- Authentication hydration/error remains owned by M1 startup.
- Logout behavior remains owned by the auth controller/gateway.
- No raw exception reaches the UI.

## Performance

- Use `const` where valid.
- Avoid watching broader providers than needed.
- Do not create lists/controllers on every build unnecessarily.
- One screen does not justify performance infrastructure or caching.

---

# DOCUMENTATION REQUIREMENTS

## README

Update:

- current work package to M2 while the branch is active;
- roadmap:
  - M0 complete;
  - M1 complete;
  - M2 in progress;
- route integration section described above;
- local commands only when they changed.

Do not claim M2 complete before review and terminating inventory.

## Architecture / ADR

Expected: no changes.

Only edit architecture or add an ADR if implementation reveals a real contradiction that cannot be resolved within the frozen M2 direction. Stop and report before making a material architecture change.

## Project inventory

Do not edit during initial implementation or review-fix iterations.

After:

1. external implementation review approves the exact PR-head commit;
2. applicable local checks pass;
3. existing CI is green;

then update `docs/project_inventory.md` exactly once with:

- **Work package:** M2 — Home / discovery shell
- PR number/link
- final reviewed implementation commit SHA
- completed scope
- actual verification results
- remaining decisions/limitations:
  - O2–O8 unresolved;
  - O8 continues to gate external real-account distribution;
  - any exact host limitation
- exact next work package:
  - **M3 — choose and implement one specialized production module**
  - do not choose the M3 module by assumption in the inventory entry unless the owner has approved it

Do not record the inventory commit SHA, merge SHA, temporary branch status, or “pending merge.”

---

# STEP 0 — INSPECT

1. Confirm the M1 precondition and clean synchronized `main`.
2. Read every required context file fully.
3. Inspect current Home, router, auth public contract, localization, tests, and integration flow.
4. Confirm Home is still the M0-style placeholder.
5. Confirm no M2/future module already exists.
6. Confirm the exact current route names/paths and return-destination validator.
7. Confirm no Home network/data layer is needed.
8. Confirm no new dependency is needed.
9. Confirm the prompt is tracked at the required path.
10. Identify any guardrail conflict before editing.

## STEP 1 — PLAN

Provide a concise plan containing:

- exact Home layout and responsive behavior;
- public Home barrel changes;
- registered-path aggregation change;
- localization keys;
- expected files;
- widget/router/boundary/integration tests;
- documentation changes;
- verification commands;
- explicit confirmation that backend and M3 modules remain untouched.

Proceed without waiting unless an `AGENTS.md` guardrail or unresolved owner decision blocks the work.

## STEP 2 — IMPLEMENT

Recommended order:

1. Add/track this M2 prompt under `docs/prompts/`.
2. Update Home public route contract and app route/path aggregation.
3. Implement the Home screen with localized RTL-safe responsive UI.
4. Remove raw account ID from Home.
5. Add Home widget tests.
6. Extend router/registry/boundary tests.
7. Update real-backend integration assertions.
8. Regenerate localization.
9. Update README.
10. Run targeted tests.
11. Run complete gates.
12. Inspect full diff and generated-file cleanliness.
13. Commit and push.

Keep changes atomic and within scope.

---

# STEP 3 — VERIFY

Run and report actual results. Do not claim success for commands not run.

## Flutter formatting, analysis, tests, boundaries

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Run targeted tests during implementation as well, for example:

```powershell
flutter test test/features/home
flutter test test/app/auth_router_and_security_test.dart
```

## Localization generation and clean diff

Use the repository’s established command:

```powershell
flutter gen-l10n
git diff --exit-code -- lib/l10n/generated
```

If JSON serialization generation is unaffected, do not run speculative generators. If the repository’s normal full generation command includes it, run that command and verify a second generation is clean.

## Backend regression gates

M2 should not change backend code, but the monorepo M1 baseline must remain healthy:

```powershell
npm ci --prefix backend
npm run format:check --prefix backend
npm run lint --prefix backend
npm run typecheck --prefix backend
npm run prisma:format:check --prefix backend
npm run prisma:validate --prefix backend
npm run prisma:generate --prefix backend
npm run test --prefix backend
npm run test:e2e --prefix backend
npm run openapi:check --prefix backend
npm run build --prefix backend
```

Use only the explicitly dedicated `_test` PostgreSQL database for e2e cleanup.

## Local Android flavor build matrix

Run locally, not as GitHub Actions artifacts:

```powershell
$flavors = @("dev", "staging", "prod")
foreach ($flavor in $flavors) {
  flutter build apk --debug `
    --flavor $flavor `
    --dart-define=APP_FLAVOR=$flavor `
    --dart-define-from-file="config/$flavor.json"
}
```

All three must pass before PR review unless an exact environment failure is reported.

## Real-backend Android integration

Start the dedicated local PostgreSQL test/development database and Nest backend with development fixture delivery, then run:

```powershell
flutter test integration_test/auth_flow_test.dart `
  --flavor dev `
  --dart-define=APP_FLAVOR=dev `
  --dart-define-from-file=config/dev.json `
  --dart-define=FIXTURE_INBOX_KEY=<from-backend-env> `
  -d <emulator-id>
```

The test must hit the real backend. Do not replace it with a fake provider.

## Repository integrity

```powershell
git status --short
git diff --check
git diff --stat
git diff
```

Also inspect:

- generated files;
- public barrel exports;
- route names/paths;
- imports;
- secrets;
- PII;
- screenshots;
- prompt tracking;
- README claims.

## CI

Push and wait for the repository’s existing applicable GitHub Actions checks.

The owner-approved CI exception remains:

- do not restore Android emulator CI;
- do not restore the long-running flavor-build artifact matrix;
- report local results in the PR.

---

# STEP 4 — CHECK IN AND REVIEW

## Branch and commits

Branch:

```text
feat/home-discovery-shell
```

Suggested atomic commits:

```text
feat(home): build authenticated discovery shell
test(home): cover rtl layout and route integration
docs(home): document m2 module routing pattern
```

Combine commits when a smaller atomic history is clearer. Do not create artificial commits.

## PR

Use the `AGENTS.md` PR body.

PR summary must state:

- M2 Home/discovery shell;
- route/path aggregation contract;
- no backend or future-module work;
- no raw account ID on Home;
- Persian RTL/responsive/accessibility coverage;
- local flavor and emulator results;
- owner-approved CI exception;
- O8 distribution restriction.

Include UI screenshots without real personal data.

## Review archive

After local checks, push, and green applicable CI:

1. create a clean source archive from the exact PR-head implementation commit;
2. include tracked source and documentation only;
3. exclude:
   - `.git`;
   - build outputs;
   - `.dart_tool`;
   - `node_modules`;
   - backend `dist`;
   - coverage;
   - secrets;
   - keys;
   - `.env`;
   - signing files;
   - local database files;
4. put the exact full commit SHA in the ZIP comment;
5. name it:

```text
laforika-m2-home-<short-sha>-src.zip
```

6. report archive filename and exact SHA;
7. stop for external review;
8. do not update inventory;
9. do not merge.

## After external approval

1. apply review fixes on the same branch if any;
2. push and obtain final green applicable CI;
3. update inventory exactly once;
4. commit/push inventory;
5. rerun applicable CI;
6. merge only after explicit approval.

---

# DEFINITION OF DONE

M2 is done only when:

- M1 was fully closed and merged first;
- authenticated users land on a meaningful Home;
- Home is Persian `fa-IR`, RTL-safe, responsive, and accessible;
- only real current actions are shown;
- account security is navigable;
- logout remains correct;
- raw account ID is absent from Home;
- Home uses no network/data/storage layer;
- feature route registry/path aggregation is explicit and tested;
- external callers use the Home public barrel;
- no future module or shared UI catalog was introduced;
- localization is generated and reproducible;
- tests cover principal variants, navigation, logout, RTL, accessibility, responsive layouts, and route validation;
- the real-backend integration flow covers the new Home contract;
- Flutter and backend regression gates pass;
- all three debug flavor builds pass locally;
- applicable CI is green;
- no secrets, PII leaks, debug prints, unexplained TODOs, or hand-edited generated files exist;
- README documents the M2 integration pattern;
- no architecture/ADR change was needed;
- the reviewed source archive is produced from the exact PR-head commit;
- inventory is updated only after external approval and final green CI.

## REPORT BACK

Return:

- Status: done / partial / blocked
- Branch
- PR
- Exact implementation commit SHA
- Summary
- Home behavior delivered
- Route-registry contract delivered
- Files changed
- Localization keys added/removed
- Tests added/updated
- Commands with pass/fail/not-run status
- Local dev/staging/prod APK results
- Real-backend emulator integration result
- CI result
- Manual RTL/accessibility/responsive verification
- Architecture/ADR impact
- Approved deviations
- O2–O8 status
- Archive filename/path
- Remaining blockers or follow-ups
