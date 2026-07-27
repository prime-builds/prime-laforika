# Laforika M03_WP06 — Settings and Notifications Prompt

## TASK

Deliver **M03_WP06 — Settings and Notifications** for Laforika.

Implement the two real Profile-context destinations approved by architecture v1.4:

1. a **guest-accessible Settings** destination with a functional `System` / `Light` / `Dark`
   appearance selector backed by the existing M03_WP02 appearance controller and preferences;
2. localized About content available to every user;
3. an authenticated-only account section in Settings with the existing Account Security and Logout
   actions;
4. a **protected Notifications** destination that preserves `/notifications` through the existing
   direct phone-OTP flow and resumes there after successful authentication;
5. honest Notifications loading / empty / error / data presentation states without inventing a
   backend notification contract, fake production notifications, a push provider, permissions, or
   persistence;
6. production Profile header actions for Settings at directional `start` / visual top-right and
   Notifications at directional `end` / visual top-left in Persian RTL;
7. Profile selected as the parent bottom-dock context on Settings and Notifications;
8. complete routing, state, localization, RTL, accessibility, golden, widget, router, and Android
   emulator integration coverage;
9. current-state documentation updated to mark M03_WP06 implemented and identify
   **M03_WP07 — Integration and visual hardening** as the exact next package.

Persist this exact task prompt in the repository as:

```text
docs/prompts/M03_WP06_SETTINGS_AND_NOTIFICATIONS_PROMPT.md
```

---

## WHY

M03_WP02 introduced the real persisted appearance model, but users still have no production screen
for changing it. M03_WP05 introduced Profile and deliberately staged Settings and Notifications
header actions until real destinations existed.

M03_WP06 closes those bounded architecture gaps without prematurely selecting a push provider or
inventing notification storage:

- guests can configure appearance before signing in;
- authenticated users can reach account security and logout from Settings as well as Profile;
- Notifications becomes a genuine protected route with correct phone-OTP return behavior;
- the Notifications surface is ready to represent honest asynchronous states while production
  truthfully shows an empty inbox until a real source is separately approved;
- the Profile header finally exposes only real, synchronized destinations;
- the application remains guest-first, Persian-first, RTL-safe, and accessible.

The outcome that matters is a complete, tested vertical slice using existing architecture—not a
placeholder page, speculative notification platform, or settings catalog.

---

## MILESTONE

**M03_WP06 — Settings and Notifications.**

This package implements the Settings/Notifications portion of architecture v1.4, ADR-0008,
ADR-0009, `docs/design/UI_FOUNDATION.md`, and `docs/design/APP_SHELL.md`.

It does not change the approved architecture direction and does not require an architecture-version
bump or new ADR unless inspection reveals a genuine conflict that cannot be resolved within this
prompt.

Exact next package after successful completion and merge:

**M03_WP07 — Integration and visual hardening.**

---

## REVIEWED BASELINE AND MANDATORY PRECONDITIONS

This prompt was prepared from the final externally approved M03_WP05 implementation archive at:

```text
b25ce702c7a8d3b0bb7b1c74be95c31f98917186
```

That archive is inspection evidence only. The clean synchronized default branch after the complete
M03_WP05 terminating workflow is the implementation source of truth. Preserve all later Composer,
runtime, build, integration, inventory, and merge fixes present on the synchronized default branch.

Before creating the M03_WP06 branch:

1. Read `AGENTS.md` fully.
2. Read `docs/architecture/ARCHITECTURE.md` fully.
3. Read at minimum:
   - `docs/architecture/adr/0002-riverpod-state-and-di.md`
   - `docs/architecture/adr/0003-go-router-navigation.md`
   - `docs/architecture/adr/0004-networking-and-error-model.md`
   - `docs/architecture/adr/0006-authentication-and-session.md`
   - `docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md`
   - `docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md`
   - `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`
   - `docs/design/UI_FOUNDATION.md`
   - `docs/design/APP_SHELL.md`
   - `docs/project_inventory.md`
   - `docs/prompts/M03_WP02_LIGHT_DARK_THEME_FOUNDATION_PROMPT.md`
   - `docs/prompts/M03_WP03_GUEST_FIRST_PHONE_ONLY_AUTH_PROMPT.md`
   - `docs/prompts/M03_WP04_ADAPTIVE_APPLICATION_SHELL_PROMPT.md`
   - `docs/prompts/M03_WP05_PROFILE_VERTICAL_SLICE_PROMPT.md`
4. Inspect the synchronized implementations and tests for:
   - `lib/core/theme/`
   - `lib/core/storage/`
   - `lib/core/auth/`
   - `lib/app/router/`
   - `lib/app/navigation/production_dock.dart`
   - `lib/features/auth/`
   - `lib/features/profile/`
   - `lib/features/shell/`
   - `integration_test/auth_flow_test.dart`
   - current shell/profile golden harnesses.
5. Confirm M03_WP05 completed its terminating workflow:
   - one terminating M03_WP05 inventory entry exists on the default branch;
   - the inventory records the final reviewed implementation SHA;
   - inventory CI is green;
   - PR #12 is merged;
   - local `main`/`master` is clean and synchronized with remote.
6. Confirm current documentation identifies M03_WP06 as the exact next package.
7. Confirm no unrecorded working-tree changes exist.
8. Record the actual synchronized base SHA in the plan and final report. Do not reuse the reviewed
   M03_WP05 SHA above as branch base by assumption.
9. If M03_WP05 is not inventoried and merged, stop. Do not combine M03_WP05 closure with M03_WP06.
10. Do not start from an extracted source archive without Git history, from PR #12's branch, or from
    a dirty working tree.

---

## OWNER DECISIONS — AUTHORITATIVE FOR THIS PACKAGE

### A. Access model

- Home remains public and guest-safe.
- Profile remains guest-accessible.
- Settings is **public / guest-accessible**.
- Notifications is **protected**.
- Phone OTP remains the only user-facing sign-in method.
- A guest opening Notifications is redirected through the existing direct phone-OTP route with a
  validated path-only return destination of `/notifications`.
- After successful authentication, the user resumes Notifications.
- Do not add an auth-method chooser, email/password login, password reset, social login, anonymous
  guest identity, guest token, or fake account.
- Client redirects are UX; backend authorization remains authoritative for any future protected
  notification source.

### B. Settings scope

Settings initially contains exactly these product areas:

1. **Appearance**
   - `System`
   - `Light`
   - `Dark`
   - `System` remains the default when no preference exists.
   - Use the existing `AppAppearance`, `AppAppearanceController`, `PrefsFacade`, codec, and app theme
     wiring. Do not create a second settings store or duplicate theme state.
   - Selecting a mode applies immediately and persists through the existing non-sensitive
     preferences path.
   - A preferences write failure retains the in-memory mode according to the existing controller
     contract; do not expose raw storage errors or personal data.

2. **About**
   - localized application name;
   - a concise localized description of Laforika;
   - no external brand artwork, logo, marketing illustration, store link, privacy URL, support URL,
     legal catalog, or app-version dependency unless an already-present approved source provides it.
   - Do not add `package_info_plus` or another dependency solely to display a version.

3. **Account** — authenticated users only
   - Account Security action using the existing registered route constant;
   - Logout using the existing auth controller/session behavior;
   - guest Settings omits the account section entirely—do not show disabled controls, fake account
     values, or an email/password sign-in option.

No language selector, notification preferences, sounds, vibration, reminders, analytics toggle,
privacy controls, account deletion, change-phone flow, email verification, password controls, module
preferences, or speculative settings catalog.

### C. Settings logout behavior

- Settings remains public after logout.
- Logging out from Settings leaves the user on `/settings`.
- The appearance and About sections remain visible.
- The authenticated account section disappears when the auth state becomes unauthenticated.
- Profile remains the selected parent dock context.
- Disable duplicate Logout and Account Security actions while logout is pending.
- Preserve existing secure-session cleanup, refresh-token behavior, account-scoped disposal, and
  error sanitization.
- Do not add a confirmation dialog unless current repository convention already requires one; do
  not invent a new confirmation pattern in this package.

### D. Notifications source boundary

O3 remains unresolved. Therefore this package must **not** add:

- Firebase Cloud Messaging;
- a regional push provider;
- notification permissions;
- device-token registration;
- background handlers;
- platform notification channels;
- local-notification scheduling;
- backend notification endpoints;
- Prisma notification tables or migrations;
- notification persistence, polling, sockets, or networking;
- fake production notifications;
- fake unread counts or badges.

Implement the narrowest feature-owned asynchronous presentation seam that can honestly render:

- loading;
- empty;
- error with retry;
- data.

Production currently has no approved notification source, so production must settle to an honest
localized **empty state**. Loading, error, and representative data states must be fully implemented
and tested through Riverpod/provider overrides or explicit test fixtures. Do not claim a backend,
domain, storage, or delivery contract that has not been approved.

Prefer a simple presentation-only feature. Do not create speculative `data/` or `domain/` layers,
repository abstractions, DTOs, networking, persistence, or notification schema merely to return an
empty list.

If inspection reveals a complete real notification source already merged on the synchronized default
branch, stop and report the conflict before integrating it; this prompt is intentionally based on no
approved source.

### E. Notifications visual/data rules

- The production Notifications screen displays a localized empty state, not dummy rows.
- Loading uses a meaningful progress surface.
- Error uses a localized safe message and a real Retry action.
- A test-only data state may use minimal presentation items solely to verify list rendering,
  semantics, scrolling, and unread/read styling.
- Do not define business-critical notification categories, deep-link payloads, timestamps,
  retention, read receipts, mark-all-read behavior, deletion, pagination, badges, or sorting rules.
- Do not show an unread badge on the Profile header because no real unread source exists.
- All test fixture labels must remain test-only and must not ship as production dummy content.

### F. Profile header integration

M03_WP05 already provides the reusable directional Profile header contract. M03_WP06 activates it
with real routes:

- Settings at directional `start` / visual top-right in RTL;
- Notifications at directional `end` / visual top-left in RTL;
- both controls are icon-only with localized tooltip/semantics and minimum 48dp targets;
- Settings is visible for both guest and authenticated Profile states;
- Notifications is visible for both guest and authenticated Profile states because the destination
  is real; guest navigation relies on centralized route protection;
- no unread badge without real notification data;
- Profile must not import Settings or Notifications feature internals.

Use a narrow app-owned composition seam—such as route callbacks supplied by `app/router/routes.dart`
through public feature contracts—to avoid circular feature imports and preserve
`app → features → core`. Do not create a service locator, global navigation singleton, or speculative
navigation framework.

### G. Navigation and dock context

Approved routes:

```text
/settings       public
/notifications  protected
```

Required behavior:

- both routes are reconstructable from cold start/deep link and require no `extra`;
- route names and paths are exported through each feature's public barrel;
- `appRegisteredPaths` includes both;
- `appPublicPaths` includes Settings only;
- `appProtectedPaths` includes Notifications;
- direct guest `/settings` is allowed after hydration;
- direct guest `/notifications` redirects to `/auth?from=%2Fnotifications` under the existing
  canonical path-only policy;
- authenticated `/auth?from=/notifications` resumes `/notifications`;
- malformed/external/query/fragment return destinations remain rejected by the existing policy;
- Settings and Notifications use focused page headers, not Home/module discovery chrome;
- Profile is selected in the production dock on Settings and Notifications;
- Home remains the other real production dock destination;
- Chat remains absent;
- Settings and Notifications are not new dock items;
- dock tap and RTL swipe behavior remains the reviewed Profile + Home behavior;
- no module strip, search field, or contextual module tabs appear on Settings/Notifications.

The existing focused `/auth` route may remain the authentication surface during the protected
Notifications redirect. Do not invent a second auth shell or duplicate `PhoneAuthPanel` solely to
keep the dock visible during `/auth`. The critical contract is validated return to Notifications and
Profile selection on the real Settings/Notifications destinations.

### H. Focused page headers

Settings and Notifications should use a consistent focused-page header appropriate to the existing
Fluent-inspired Material 3 system:

- localized title;
- directional back/up affordance returning to Profile;
- semantics and 48dp target;
- RTL-safe icon direction;
- no Home discovery header;
- no decorative or dead actions.

Reuse an existing proven focused-header component only if it is genuinely reusable. Add a shared UI
primitive only when repeated app-wide use is already proven by Profile + Settings + Notifications.
Otherwise keep focused widgets feature-owned and small.

### I. Architecture and dependency boundaries

- Settings and Notifications are simple features.
- Use Riverpod for state and dependency ownership.
- Use existing `go_router`, theme, appearance, auth, shell, and localization contracts.
- No new dependency is approved.
- No backend, OpenAPI, Prisma, migration, platform, push, CI, flavor, signing, or environment change
  is approved.
- No architecture version bump or new ADR is expected.
- O3 remains unresolved.
- O7 external brand assets remain deferred.
- O8 privacy/account-data lifecycle remains unresolved; do not add account deletion.

---

## SCOPE

### In scope

#### Flutter — Settings

- New `lib/features/settings/` feature with curated public barrel.
- Public route constants and route registry for `/settings`.
- Settings screen composed with the existing production shell/dock contract.
- Profile-selected parent dock context.
- Functional System/Light/Dark selector using the existing appearance provider.
- Guest-visible Appearance and About sections.
- Authenticated-only Account Security and Logout section.
- Logout-pending behavior and safe auth-state transition.
- Localized strings, semantics, RTL, responsive layout, tests, and goldens.

#### Flutter — Notifications

- New `lib/features/notifications/` feature with curated public barrel.
- Protected route constants and route registry for `/notifications`.
- Narrow Riverpod-owned async presentation state.
- Production loading-to-empty behavior without external source or fake content.
- Loading, empty, error/retry, and test-only data rendering.
- Profile-selected parent dock context.
- Localized strings, semantics, RTL, responsive layout, tests, and goldens.

#### Flutter — Profile/app composition

- Wire real Settings and Notifications callbacks into the production Profile header.
- Preserve guest/authenticated Profile behavior from M03_WP05.
- Aggregate Settings and Notifications routes/path sets in `app/router`.
- Preserve the real Profile + Home production dock and reviewed swipe adjacency.
- Extend the existing Android emulator integration flow.

#### Documentation

- Persist this exact prompt under `docs/prompts/`.
- Update current-state wording in:
  - `README.md`;
  - `docs/architecture/ARCHITECTURE.md`;
  - `docs/design/APP_SHELL.md`;
  - `docs/design/UI_FOUNDATION.md` where it still says the production selector is pending;
  - `AGENTS.md` only if synchronized current-state instructions require a factual correction.
- Mark M03_WP06 implemented only after implementation and verification are complete on the branch.
- Identify **M03_WP07 — Integration and visual hardening** as exact next.
- Preserve architecture version 1.4 and accepted ADRs.

### Out of scope / do not touch

- Chat route, screen, dock action, or backend.
- Production modules, module registry, module personalization, module persistence.
- Any notification backend/API/OpenAPI/Prisma schema or migration.
- FCM, regional push SDK, local notification package, permissions, tokens, background handlers,
  notification channels, platform setup, or provider configuration.
- Notification preferences, read receipts, unread counters, badges, deletion, pagination, deep-link
  payloads, scheduling, or retention policy.
- Language switching or additional locales.
- Privacy/account deletion/retention controls.
- Change-phone, email verification, password, social login, or authentication changes.
- New About links, legal/privacy content, external brand assets, logo, store icon, or marketing UI.
- App-version dependency or package solely for About.
- Theme palette/token changes except a narrowly necessary bug fix that must be reported before
  editing.
- M03_WP07 broad visual hardening beyond representative WP06 states.
- Backend source, backend dependencies, OpenAPI, Prisma, migrations, `.env`, platform code, CI,
  flavors, signing, release configuration, or toolchain.
- `docs/project_inventory.md` before external implementation approval.
- Historical completed prompts, immutable ADRs, or previous inventory entries.

---

## EXPECTED REPOSITORY SHAPE

Use actual inspected naming and avoid empty layers. A reasonable shape is:

```text
lib/
├─ app/
│  ├─ router/
│  │  ├─ app_router.dart
│  │  └─ routes.dart
│  └─ navigation/
│     └─ production_dock.dart               # preserve Profile + Home
├─ features/
│  ├─ profile/
│  │  ├─ profile.dart                       # public contract extended minimally
│  │  └─ presentation/
│  │     ├─ profile_header.dart
│  │     └─ profile_screen.dart
│  ├─ settings/
│  │  ├─ settings.dart                      # route/public barrel
│  │  └─ presentation/
│  │     └─ settings_screen.dart
│  └─ notifications/
│     ├─ notifications.dart                 # route/public barrel
│     └─ presentation/
│        ├─ notifications_screen.dart
│        └─ notifications_controller.dart   # only if genuinely useful
└─ l10n/
   ├─ app_fa.arb
   └─ generated/                            # regenerated, never hand-edited

test/
├─ app/
│  ├─ router/settings_notifications_router_test.dart  # or closest existing file
│  └─ shell/
│     ├─ shell_golden_test.dart             # extend carefully
│     └─ goldens/
├─ features/
│  ├─ profile/
│  ├─ settings/
│  └─ notifications/
└─ support/

integration_test/
└─ auth_flow_test.dart                      # extend or split without losing coverage
```

Do not create `data/` or `domain/` directories for Settings/Notifications unless inspection proves
real logic requires them. Do not create empty abstractions.

---

## ROUTING CONTRACT

### Feature barrels

Each new feature public barrel owns:

- route name;
- route path;
- registered path set;
- public or protected path set as appropriate;
- route registry entry points;
- intentionally shared screen/composition callback types only.

No raw `/settings` or `/notifications` strings at screen call sites.

### App aggregation

`app/router/routes.dart` must aggregate:

```text
appRegisteredPaths = auth + home + profile + settings + notifications
appPublicPaths     = home + profile + settings
appProtectedPaths  = account security + notifications
```

Preserve existing return-destination canonicalization and loop prevention.

### Route tests

Cover at minimum:

- hydration still shows deterministic startup state;
- guest Home remains public;
- guest `/profile` remains public;
- guest `/settings` allowed;
- authenticated `/settings` allowed;
- guest `/notifications` redirects to direct phone OTP with canonical `/notifications` return;
- authenticated `/notifications` allowed;
- successful authentication resumes `/notifications`;
- `/auth?from=/notifications` for an already authenticated user resumes Notifications;
- query/fragment/external/malformed/unknown returns remain rejected;
- Settings is registered/public;
- Notifications is registered/protected;
- Account Security remains protected;
- no Chat route is added;
- deep links work without `extra`;
- no redirect loops.

---

## SETTINGS CONTRACT

### Screen structure

Use a focused, scrollable page with safe-area and dock bottom inset. Suggested hierarchy:

```text
Focused header: Settings + back to Profile

Appearance
  ○ System
  ○ Light
  ○ Dark

About
  Laforika
  concise localized description

Account (authenticated only)
  Account Security
  Logout

Floating production dock: Profile selected · Home available
```

Use semantic Material components and existing theme/tokens. Do not copy Windows chrome literally.

### Appearance behavior

- The selected control reflects `appAppearanceControllerProvider`.
- Tapping a different mode calls the existing controller.
- Theme changes immediately through `MaterialApp.router`.
- Stable persisted values continue to use the existing codec.
- Repeated selection is safe.
- System mode follows platform brightness through existing Flutter theme behavior.
- Do not duplicate `ThemeMode` conversion or preference keys in Settings.
- Do not add a Save button; appearance changes are immediate.
- Do not create a per-account preference. Appearance remains installation-level non-sensitive state.

### Auth-reactive account section

- Observe existing auth state through Riverpod.
- `AuthAuthenticated`: show Account Security + Logout.
- `AuthUnauthenticated`: omit account section.
- Unknown/hydration should not normally reach Settings due router startup handling; if it occurs in a
  focused widget test, render safely without login flash or crash.
- Logout invokes the existing auth controller exactly once.
- While logout is pending, disable Account Security and Logout.
- After logout, remain on Settings and remove the account section.
- Never display raw `accountId`, tokens, phone, email, or internal session identifiers in Settings.

### About content

- Localized through ARB/gen_l10n.
- No hardcoded Persian strings in widgets.
- Keep concise and static.
- Do not use package metadata or external URLs unless already available through approved contracts.

---

## NOTIFICATIONS CONTRACT

### Screen structure

Use a focused page with safe-area and production dock bottom inset:

```text
Focused header: Notifications + back to Profile

Async body:
  loading → progress
  empty   → localized icon/title/body
  error   → localized safe message + Retry
  data    → accessible scrollable list (test/provider state only today)

Floating production dock: Profile selected · Home available
```

### State ownership

- State is Riverpod-owned and auto-disposed unless inspection justifies keep-alive.
- No network request in widget `build()`.
- Production state must settle to empty without fake items.
- Retry must re-execute the feature-owned load operation/state transition.
- A test override can produce error/data states.
- Avoid a repository abstraction when a focused provider/controller is enough.
- If a controller is introduced, every transition must be tested.

### Failure presentation

- Do not expose raw exceptions.
- Use a localized generic notification-load failure message.
- Retry must be actionable and semantic.
- No telemetry or logging of personal content.

### Data-state fixture rules

Representative data-state tests may use minimal test-only items to verify:

- list rendering;
- title/body wrapping;
- read/unread visual distinction if implemented;
- semantics;
- 320dp and text scale 2.0;
- RTL layout;
- scrolling.

Do not let test fixture data enter the production provider, ARB, app route, or release UI. Do not
freeze unapproved server/domain schemas from fixture fields.

---

## PROFILE INTEGRATION CONTRACT

### Header actions

Wire production callbacks through app composition:

```text
Settings action      → settingsRoutePath
Notifications action → notificationsRoutePath
```

Required in both guest and authenticated Profile states.

Verify:

- Settings visual x-position is to the right of Notifications in RTL;
- tooltips/semantics are localized;
- targets are at least 48dp;
- tapping Settings opens the public Settings route;
- tapping Notifications as guest enters protected phone OTP with return preserved;
- tapping Notifications authenticated opens Notifications directly;
- no badge appears;
- no circular imports or feature-internal imports.

### Profile regression constraints

Preserve:

- guest direct phone OTP inside Profile;
- Profile selected on Profile;
- authenticated profile load/edit/save states;
- stale-save/account-transition protection;
- read-only verified phone;
- optional names/contact email;
- Account Security and Logout lower in Profile;
- Home/Profile dock order and swipe adjacency;
- Profile goldens except intentional header-action baseline updates.

---

## LOCALIZATION, RTL, ACCESSIBILITY, AND RESPONSIVENESS

### Localization

Add all production strings to `lib/l10n/app_fa.arb`, including at minimum concepts for:

- Settings title;
- Notifications title;
- back/up semantics where not already available;
- Appearance section;
- System / Light / Dark labels and supporting descriptions if used;
- About section, app name, concise description;
- Account section;
- Notifications loading/empty/error/retry;
- notification item semantics only if genuinely needed by the presentation model.

Regenerate localization output. Never hand-edit generated files.

### RTL

- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`, and `end`.
- Directional back/up affordance must be correct in RTL.
- Settings remains visual top-right in Profile header; Notifications visual top-left.
- Profile remains visual left and Home visual right in the production dock.
- Do not hardcode left/right positioning in implementation logic.

### Accessibility

- Every icon-only action has localized tooltip and semantics.
- Every interactive control has a minimum 48dp target.
- Appearance selection is announced as selected, not conveyed by color alone.
- Empty/error/loading states have meaningful semantics.
- Retry is keyboard/screen-reader actionable.
- Notification fixture rows have coherent reading order and labels.
- No fixed heights that clip Persian text.

### Responsive behavior

Verify Settings and Notifications at:

- 320dp width;
- normal phone width;
- text scale `2.0`;
- light theme;
- dark theme;
- Persian RTL.

Use existing tokens/breakpoints. Do not add a responsive framework.

---

## TEST REQUIREMENTS

Every new unit of logic requires matching tests in the same task.

### Flutter unit/controller tests

Cover:

- Settings appearance selection delegates to existing controller;
- System/Light/Dark state reflection;
- appearance persistence remains covered without duplicating codec logic;
- Notifications production load settles to empty;
- Notifications loading/error/retry/data transitions through the chosen provider/controller seam;
- retry executes once per action;
- disposal/navigation away causes no uncaught state update;
- Settings logout invokes auth once and reacts to unauthenticated state;
- account section visibility follows auth state.

### Settings widget tests

Cover:

- guest Settings route renders Appearance + About;
- guest account section absent;
- authenticated account section present;
- current appearance is selected;
- tapping System/Light/Dark updates provider and visual theme state;
- repeated selection safe;
- Account Security navigates correctly;
- Logout pending disables account actions;
- logout leaves Settings visible and removes account section;
- Profile dock selected;
- Home dock available;
- no Chat;
- no module strip/search/contextual tabs;
- focused header and back-to-Profile action;
- localization/semantics/48dp targets;
- 320dp and text scale 2.0.

### Notifications widget tests

Cover:

- loading;
- empty production state;
- error + retry;
- representative test-only data state;
- long Persian text wrapping;
- list scrolling;
- Profile dock selected;
- Home dock available;
- no Chat;
- no module strip/search/contextual tabs;
- focused header and back-to-Profile action;
- semantics/48dp targets;
- 320dp and text scale 2.0;
- no unread badge or fake production data.

### Profile/header tests

Update/extend coverage for:

- both real actions present in guest Profile;
- both real actions present in authenticated Profile;
- Settings visual right/top start;
- Notifications visual left/end;
- x-position assertion;
- callbacks navigate to exported routes;
- guest Notifications tap enters protected auth flow;
- tooltips, semantics, 48dp targets;
- no fake unread badge;
- existing Profile editing/auth behavior remains green.

### Router tests

Implement the route matrix listed earlier. Test actual router behavior, not only path-set contents.

### Shell/dock tests

Verify:

- production dock remains Profile + Home only;
- Profile is selected on Profile, Settings, and Notifications;
- Home selected on Home;
- Settings/Notifications do not become dock items;
- visual order and RTL swipe adjacency remain unchanged;
- taps/no-wrap remain correct;
- Chat absent.

### Golden tests

This task explicitly approves visual baseline changes only for:

- new Settings goldens;
- new Notifications goldens;
- existing M03_WP05 Profile goldens where the newly real header actions legitimately change the
  production Profile header.

Required representative goldens:

- guest Settings — light RTL;
- authenticated Settings — dark RTL;
- Notifications empty — light RTL;
- Notifications empty — dark RTL;
- a representative Notifications data/error specimen may be added only if it materially improves
  coverage and remains clearly test-only;
- updated production Profile light/dark RTL goldens showing real Settings/Notifications actions.

Load Material Icons and Vazirmatn correctly. Render real production screens through realistic
provider overrides rather than simplified misleading replicas.

Do **not** modify:

- M03_WP02 theme specimen goldens;
- M03_WP04 Home/module goldens unless a real shared-shell bug fix necessarily changes them and is
  separately explained;
- unrelated baselines.

Never run `flutter test --update-goldens` blindly. Inspect every changed image visually and report the
exact changed/new golden list.

### Backend regression tests

No backend changes are approved. Run the current backend unit/e2e/OpenAPI/build gates to prove the
Flutter-only feature does not alter backend contracts. Any proposed backend edit is an approval
blocker.

### Android emulator integration

Extend the real dev integration flow against the local backend/PostgreSQL. Preserve all existing
M03_WP03–M03_WP05 auth/profile/session coverage.

At minimum verify:

```text
clear app data
→ guest Home
→ Profile
→ open Settings from Profile header without authentication
→ Appearance selector works
→ return to Profile
→ open Notifications from Profile header as guest
→ direct phone OTP
→ authenticate
→ resume Notifications
→ Notifications empty state visible
→ Profile dock selected
→ open Settings
→ authenticated Account section visible
→ Account Security remains reachable and me()/refresh/session checks pass
→ return to Settings
→ logout from Settings
→ remain on guest Settings
→ Account section absent; Appearance/About remain
→ Profile and Home remain reachable
→ Notifications remains protected after logout
```

Also rerun the existing Profile edit/save/persistence path. If split into separate integration files,
run every relevant file. Do not reduce existing coverage to make the new flow pass.

Keep `FIXTURE_INBOX_KEY` secret. Never print it, commit it, include it in the archive, or expose it in
test failure text.

Suggested stable keys, adapted to inspected conventions:

```text
profile_header_settings
profile_header_notifications
settings_screen
settings_back
settings_appearance_system
settings_appearance_light
settings_appearance_dark
settings_about
settings_account_section
settings_account_security
settings_logout
notifications_screen
notifications_back
notifications_loading
notifications_empty
notifications_error
notifications_retry
notifications_list
shell_dock_profile
shell_dock_home
```

Do not rename existing integration selectors unless unavoidable and atomically updated everywhere.

---

## REQUIRED VERIFICATION

Run and report actual results for every applicable command.

### Flutter

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Run repository-approved localization/code generation, commit generated outputs, and prove a second
run leaves a clean diff.

### Backend regression gates

Run the actual scripts from `backend/package.json`, including at minimum:

```bash
cd backend
npm run format:check
npm run lint
npm run typecheck
npm test -- --runInBand
npm run test:e2e
npm run openapi:check
npm run build
```

Adapt exact invocation only to current repository scripts. Report exact command/results. Do not
silently accept lint fixes outside scope; inspect any formatter/linter edits.

### Flavor APK matrix

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

### Android emulator integration

```bash
flutter test integration_test/auth_flow_test.dart --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json \
  --dart-define=FIXTURE_INBOX_KEY=<secret> \
  -d <emulator-id>
```

Run additional integration files if the flow is split.

### Additional checks

```bash
git diff --check
git status --short
git diff --stat
```

Inspect:

- full diff;
- generated localization files;
- route/path aggregation;
- dependency files;
- backend diff (must be empty unless an explicit blocker was approved);
- platform/CI diff (must be empty);
- all changed/new goldens;
- final clean source archive contents.

A missing emulator, fixture-key access, backend/PostgreSQL, JDK/Gradle setup, or platform tool is an
environment limitation—not automatic approval to skip a required gate. Resolve it where possible.
If genuinely blocked, report the exact limitation and obtain explicit owner-approved deviation before
claiming completion.

Temporary local Gradle/Kotlin/TUN/mirror workarounds must be restored and uncommitted.

---

## ACCEPTANCE CRITERIA

### Preconditions/workflow

- [ ] M03_WP05 has its single inventory entry and is merged before branch creation.
- [ ] Branch starts from clean synchronized default branch.
- [ ] Actual base SHA is reported.
- [ ] Exact prompt is committed under `docs/prompts/`.

### Settings product behavior

- [ ] `/settings` is real, public, reconstructable, and deep-link safe.
- [ ] Guest Settings shows Appearance + About.
- [ ] System/Light/Dark are functional and use existing controller/persistence.
- [ ] System remains default.
- [ ] Theme applies immediately.
- [ ] No duplicate theme store/preferences are introduced.
- [ ] Authenticated Settings shows Account Security + Logout.
- [ ] Guest Settings omits account controls.
- [ ] Logout remains on Settings and removes account section.
- [ ] No language switcher or speculative settings catalog ships.

### Notifications product behavior

- [ ] `/notifications` is real, protected, reconstructable, and deep-link safe.
- [ ] Guest access enters direct phone OTP with canonical return destination.
- [ ] Successful auth resumes Notifications.
- [ ] Production shows honest empty state with no fake rows.
- [ ] Loading, empty, error/retry, and data UI states are implemented/tested.
- [ ] No push SDK/provider, backend, persistence, permissions, token, badge, or fake data ships.
- [ ] O3 remains unresolved and documented.

### Profile/shell/navigation

- [ ] Profile header wires real Settings and Notifications actions.
- [ ] Settings is visual top-right/start; Notifications visual top-left/end in RTL.
- [ ] Actions exist for guest and authenticated Profile.
- [ ] No unread badge without data.
- [ ] Profile selected on Profile, Settings, Notifications.
- [ ] Home remains selected on Home.
- [ ] Dock remains Profile + Home only; Chat absent.
- [ ] Settings/Notifications have focused headers and no Home/module chrome.
- [ ] Route aggregation/path protection is correct.
- [ ] Existing Profile editor/auth/session behavior remains green.

### Architecture/code quality

- [ ] `app → features → core` boundaries pass.
- [ ] Features expose curated public barrels.
- [ ] No circular feature imports.
- [ ] Riverpod owns feature state.
- [ ] No network call in widget `build()`.
- [ ] No empty layers/speculative repositories.
- [ ] No new dependency.
- [ ] No backend/OpenAPI/Prisma/migration/platform/CI change.
- [ ] Architecture remains v1.4; no ADR added.

### Localization/accessibility/visual

- [ ] All production strings are generated from ARB.
- [ ] Persian RTL directional APIs used throughout.
- [ ] Icon-only controls have localized semantics/tooltips.
- [ ] Interactive targets are at least 48dp.
- [ ] Selected appearance is not color-only.
- [ ] 320dp and text scale 2.0 tests pass.
- [ ] Light/dark representative goldens pass.
- [ ] Material Icons/Vazirmatn render correctly.
- [ ] WP02 theme goldens remain unchanged.
- [ ] Unrelated Home/module goldens remain unchanged.

### Verification/delivery

- [ ] Flutter format/analyze/tests/boundaries pass.
- [ ] Backend regression gates pass.
- [ ] dev/staging/prod debug APK builds pass.
- [ ] Real emulator integration passes without exposing fixture key.
- [ ] CI is green.
- [ ] Full clean source archive is created from exact PR-head commit.
- [ ] No inventory entry or merge occurs before external approval.
- [ ] Documentation marks M03_WP06 implemented and M03_WP07 next only after implementation is real.

---

## CONSTRAINTS

- No architecture or owner-decision changes without explicit approval.
- No new dependency.
- No backend, OpenAPI, Prisma, migration, platform, push, CI, flavor, signing, or environment edits.
- No fake production notification data or unread badges.
- No Chat or module implementation.
- No language switching.
- No account deletion, privacy lifecycle, change-phone, email verification, or auth-method changes.
- No external brand assets or marketing UI.
- Preserve public auth/profile/theme/shell contracts unless a minimal compatible extension is
  required by this prompt.
- Preserve all Composer/runtime/build/integration fixes on synchronized main.
- Never hand-edit generated files.
- Never update unrelated goldens.
- Never commit secrets, fixture keys, build outputs, caches, local Gradle workarounds, or `.env`.
- Never commit directly to `main`/`master`.
- Never merge before external review, terminating inventory update, final green CI, and explicit
  approval.

Check-in mode:

```text
branch + atomic commits + PR + clean full-source archive + stop for external review
```

Suggested branch:

```text
feat/m03-wp06-settings-notifications
```

---

## STEP 0 — INSPECT

Before editing:

1. Complete every precondition above.
2. Read the authoritative files fully.
3. Inspect actual route factories, path sets, auth redirect, production dock, Profile route/screen,
   Profile header, appearance controller, prefs facade, shell scaffold, localization, tests, goldens,
   and integration flow.
4. Confirm the current dependency list and generated-code commands.
5. Confirm no real notification source exists.
6. Confirm current backend/OpenAPI/Prisma tree should remain unchanged.
7. Identify the narrow app-owned callback/composition seam for Profile header actions without
   cross-feature internals or cycles.
8. Identify the simplest Notifications async state seam that supports honest production empty plus
   tested loading/error/data states without speculative layers.
9. Identify exactly which existing Profile goldens must change and which goldens must remain
   byte-for-byte unchanged.
10. Record blockers before editing. Stop for owner approval if implementation would require a new
    dependency, backend contract, push provider, architecture change, or platform permission.

---

## STEP 1 — PLAN

Provide a concise plan before editing that includes:

- actual base SHA;
- branch name;
- expected file surface;
- route/public/protected path changes;
- Profile callback/composition approach;
- Settings appearance/account state approach;
- Notifications async-state approach and why it is not speculative infrastructure;
- localization generation;
- tests and approved golden changes;
- integration-flow extension;
- exact verification commands;
- confirmation that backend/platform/CI/dependencies remain untouched.

Proceed without waiting unless an explicit guardrail or unresolved decision blocks the work.

---

## STEP 2 — IMPLEMENT

- Keep the diff strictly within M03_WP06.
- Implement Settings first using existing appearance/auth contracts.
- Implement Notifications as a protected feature with honest production empty state.
- Register/aggregate routes and path sets through public barrels.
- Wire Profile header actions through app composition without circular imports.
- Keep Profile selected on Settings/Notifications.
- Preserve production Profile + Home dock and all prior auth/profile behavior.
- Add localization and regenerate generated files.
- Add tests with each logic/UI change.
- Add/review only approved goldens.
- Update current-state docs and commit this prompt.
- Never hand-edit generated code.
- Do not add backend or platform work.

---

## STEP 3 — VERIFY

Run every applicable gate and report exact pass/fail/not-run results.

1. Flutter format.
2. Flutter analyze with fatal infos.
3. Full Flutter tests.
4. Import-boundary checker.
5. Localization/code-generation clean-diff check.
6. Backend format/lint/typecheck/unit/e2e/OpenAPI/build regression gates.
7. Debug APK matrix for dev/staging/prod.
8. Real Android emulator integration including the new Settings/Notifications flow and existing
   Profile flow.
9. `git diff --check`.
10. Full diff and generated-file inspection.
11. Visual inspection of every changed/new golden.
12. Confirm WP02 theme goldens and unrelated shell goldens are unchanged.
13. Confirm no secret/local workaround/build output is tracked.

Do not claim success for a command not run.

---

## STEP 4 — CHECK IN AND EXTERNAL REVIEW

Follow `AGENTS.md` exactly.

1. Use the dedicated task branch.
2. Commit atomically with Conventional Commits, for example:

```text
feat(settings): add guest appearance and account settings
feat(notifications): add protected notification states
feat(profile): wire settings and notifications header actions
test(settings): cover appearance and account behavior
test(notifications): cover protected routes and visual states
docs(m03-wp06): record settings and notifications implementation
```

Use actual logical grouping; do not force this exact commit list.

3. Push and open/update one PR.
4. Use the repository PR template/body requirements.
5. Wait for CI.
6. Create a **full clean source archive** from the exact PR-head commit using the repository's
   mandatory archive workflow:
   - tracked source/documentation only;
   - no `.git`;
   - no build output/cache;
   - no secrets or local config;
   - no patch-only or changeset-only substitute.
7. Report:
   - PR URL;
   - branch;
   - base SHA;
   - exact PR-head implementation SHA;
   - archive filename;
   - command results;
   - changed/new golden list;
   - architecture/ADR impact;
   - deviations/blockers.
8. Stop for external review.
9. Do not update inventory.
10. Do not merge.

---

## TERMINATING INVENTORY WORKFLOW — ONLY AFTER EXTERNAL APPROVAL

After the archive is externally reviewed and the implementation is explicitly approved:

1. Apply any requested fixes on the same branch.
2. Rerun applicable verification and obtain green CI.
3. Update `docs/project_inventory.md` exactly once for M03_WP06.
4. Record only:
   - Work package: `M03_WP06 — Settings and Notifications`;
   - delivery PR;
   - final reviewed implementation SHA from before the inventory commit;
   - completed scope;
   - actual verification results;
   - remaining decisions/limitations, including unresolved O3 and O7 external assets/O8 as
     applicable;
   - exact next package: `M03_WP07 — Integration and visual hardening`.
5. Do not record the inventory commit SHA, merge SHA, branch status, or pending-merge wording.
6. Commit/push inventory update.
7. Rerun CI.
8. Merge only after CI is green and explicit approval is given.
9. Do not create a post-merge inventory revision.

---

## REPORT BACK

Return a concise final implementation report containing:

- **Status:** done / partial / blocked.
- **Base commit SHA.**
- **Branch.**
- **Final implementation commit SHA.**
- **PR URL.**
- **Full source archive filename.**
- **Summary.**
- **Files changed.**
- **Routes/path sets added.**
- **Settings behavior delivered.**
- **Notifications state/source boundary delivered.**
- **Profile/header/dock integration.**
- **Tests added/updated.**
- **Changed/new golden files; confirm WP02 theme goldens unchanged.**
- **Commands with pass/fail/not-run.**
- **Emulator/device and integration result.**
- **Architecture/ADR impact.**
- **Dependency/backend/platform/CI impact.**
- **Approved deviations.**
- **Remaining blockers/owner decisions.**
- **Inventory/merge status:** held for external approval.
- **Exact next package after completion:** M03_WP07 — Integration and visual hardening.

Do not report a gate as passed unless it actually ran. Do not expose fixture keys, tokens, phone
numbers, email addresses, account IDs, or other personal/test credentials.
