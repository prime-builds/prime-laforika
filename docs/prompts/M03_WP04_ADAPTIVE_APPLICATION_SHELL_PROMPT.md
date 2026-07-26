# Laforika M03_WP04 — Adaptive Application Shell Prompt

## TASK

Deliver **M03_WP04 — Adaptive application shell** for Laforika.

Implement the approved Persian RTL application-shell behavior from architecture v1.4, ADR-0009,
`docs/design/UI_FOUNDATION.md`, and `docs/design/APP_SHELL.md`:

1. a Home/module discovery shell with an adaptive horizontally scrollable module strip;
2. a search row below the module strip;
3. contextual horizontally scrollable internal tabs only when a real module is active;
4. a floating, centered, slightly translucent bottom dock using the approved Home / Chat / Profile
   ordering and selection rules;
5. direct icon taps and non-wrapping RTL horizontal swipe behavior;
6. scroll-driven expanded-to-compact module-strip behavior that preserves selection and horizontal
   position;
7. theme-aware, localized, accessible, responsive shell presentation using the implemented
   M03_WP02 semantic theme foundation;
8. production integration with **real currently registered destinations only**.

The repository currently has a real Home route and Account Security capability but no real Chat,
Profile, Settings, Notifications, or specialized module routes. Therefore this package must build
and verify the complete shell primitives and interaction contract without shipping dead actions,
dummy module cards, placeholder pages, or invented production modules.

Persist this exact task prompt in the repository as:

```text
docs/prompts/M03_WP04_ADAPTIVE_APPLICATION_SHELL_PROMPT.md
```

Do **not** implement Profile data/editing, Settings, Notifications, push delivery, Chat content, or
an M04 specialized module in this package.

---

## WHY

Laforika is expected to gain many independent modules. The application needs a stable shell that
can accept future real modules with minimal UI disruption while remaining Persian-first, RTL-safe,
accessible, and consistent across light and dark themes.

The current M03_WP03 Home is intentionally transitional. It still uses a conventional AppBar,
welcome content, and direct Account Security actions. It does not yet implement:

- the approved adaptive discovery header;
- module-expanded and module-compact presentation;
- app-wide/module-scoped search placement;
- contextual module tabs;
- the floating bottom dock;
- dock selection and RTL swipe rules;
- reusable shell geometry for future real feature routes.

M03_WP04 must close that shell gap without inventing future product content or weakening the route,
authentication, theme, module-boundary, and accessibility contracts already established.

The outcome that matters is a production-safe Home shell plus a focused, controlled shell API that
future real feature routes can supply with actual module/tab/destination data. The implementation
must demonstrate all approved states through tests and dedicated test fixtures while production
renders only capabilities that genuinely exist.

---

## MILESTONE

**M03_WP04 — Adaptive application shell.**

This package implements the shell portion of architecture v1.4 and ADR-0009. It does not change the
approved architecture direction and must not create a new ADR or architecture version unless an
actual conflict is discovered and explicitly approved.

Exact next package after successful review, inventory, and merge:

**M03_WP05 — Profile vertical slice.**

---

## REVIEWED BASELINE AND MANDATORY PRECONDITIONS

The final externally approved M03_WP03 implementation head is:

```text
ba8cd8fc404e1e5d6389de0697a37832bd70382f
```

PR #10 was reported green for Flutter/backend CI, all three Android debug flavors, backend tests,
and the real dev Android-emulator authentication integration flow. The final M03_WP03 inventory
update and merge were intentionally held until external approval.

Before creating the M03_WP04 branch:

1. Read `AGENTS.md` fully.
2. Finish the terminating M03_WP03 workflow on its existing PR/branch:
   - add exactly one M03_WP03 entry to `docs/project_inventory.md`;
   - record implementation SHA
     `ba8cd8fc404e1e5d6389de0697a37832bd70382f`;
   - record the exact next package as **M03_WP04 — Adaptive application shell**;
   - commit and push the inventory update;
   - rerun CI;
   - merge only after final green CI and owner approval.
3. Synchronize the local default branch with the remote and confirm it is clean.
4. Confirm the merged repository contains:
   - M03_WP01, M03_WP02, and M03_WP03 inventory entries;
   - the reviewed M03_WP03 guest-first/phone-only implementation and remediation;
   - the reviewed M03_WP02 theme/comparator implementation;
   - no unrecorded local source, generated, environment, Gradle, documentation, or golden changes.
5. Record the actual M03_WP04 base commit SHA in the plan and final report.
6. Preserve Composer's current runtime/build fixes. Do not restore older archive files over a newer
   synchronized repository.
7. Machine-local Android workarounds such as an alternate `GRADLE_USER_HOME` or temporary
   `kotlin.incremental=false` must remain uncommitted unless separately approved.

**Stop** if M03_WP03 is not inventoried, green, merged, and present on the synchronized default
branch. Work packages must remain isolated.

---

## AUTHORITATIVE DOCUMENTS

Read fully before planning or editing:

- `AGENTS.md`
- `README.md`
- `docs/project_inventory.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/adr/0001-modular-feature-first-architecture.md`
- `docs/architecture/adr/0002-riverpod-state-and-di.md`
- `docs/architecture/adr/0003-go-router-navigation.md`
- `docs/architecture/adr/0006-authentication-and-session.md`
- `docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md`
- `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`
- `docs/design/UI_FOUNDATION.md`
- `docs/design/APP_SHELL.md`
- `docs/prompts/M03_WP01_GUEST_FIRST_UI_FOUNDATION_DOCUMENTATION_PROMPT.md`
- `docs/prompts/M03_WP02_LIGHT_DARK_THEME_FOUNDATION_PROMPT.md`
- `docs/prompts/M03_WP03_GUEST_FIRST_PHONE_ONLY_AUTH_PROMPT.md`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `l10n.yaml`
- `.gitignore`
- `.github/workflows/*`

Inspect the current implementation and tests, especially:

- `lib/app/app.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/routes.dart`
- `lib/core/theme/`
- `lib/features/home/home.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/auth/auth.dart`
- `lib/features/auth/presentation/phone_auth_screen.dart`
- `lib/features/auth/presentation/account_security_screen.dart`
- `lib/l10n/app_fa.arb`
- generated localization files and the repository's generation command
- `test/app/app_test.dart`
- `test/app/auth_router_and_security_test.dart`
- `test/core/theme/`
- `test/features/home/home_screen_test.dart`
- `integration_test/auth_flow_test.dart`
- `tool/check_import_boundaries.dart`

Inspect the current route table before deciding shell integration. The synchronized repository wins
over path suggestions in this prompt when it has evolved without conflicting with architecture
v1.4 or accepted ADRs.

---

## OWNER DECISIONS

### Required resolved decisions

- O1 remains resolved by ADR-0007/ADR-0008: custom backend, guest-first access, phone OTP only.
- O7 is partially resolved for the in-app visual system and adaptive shell by ADR-0009.
- Persian `fa-IR`, RTL, Vazirmatn, Material 3, semantic light/dark palettes, and
  System/Light/Dark appearance are frozen.
- Home is public after deterministic session restoration.
- Home has no selected module and no internal tabs.
- A real active module clears bottom-dock selection and selects its first valid internal tab unless
  a reconstructable route selects another valid tab.
- Bottom-dock visual RTL order is Profile (visual left), Chat (center), Home (visual right).
- Dock swipes follow visual adjacency and never wrap.
- Production must ship real registered destinations only.

### Decisions that must remain untouched

- O2–O6 and O8 remain unresolved.
- O3 remains unresolved; do not add push SDKs, notification permissions, background handlers,
  device-token APIs, or vendor configuration.
- Do not create or choose the first specialized M04 module.
- Do not invent external branding assets, logos, launch/store icons, illustrations, or
  module-specific palettes.
- Do not change the phone-only authentication, return-destination, token/session, backend, OpenAPI,
  Prisma, or account-data contract.
- Do not implement Profile fields, profile API/schema, Settings, Notifications, Chat content,
  account deletion, change-phone behavior, or email verification.
- Do not create anonymous guest accounts, guest tokens, guest backend records, or fake production
  auth.

---

## SCOPE

### In scope

- A focused application-shell presentation layer owned by the `app/` composition area or another
  architecture-consistent product-specific location.
- Home integration with the approved shell geometry.
- Adaptive module-strip component and controlled shell input models needed by this package.
- Search row and current Home-search behavior over real currently rendered Home discovery entries.
- Contextual internal-tab component and selection behavior.
- Floating bottom-dock component, direct taps, selection treatment, and RTL swipe behavior.
- Scroll-driven expanded/compact module-strip states.
- Theme, localization, accessibility, RTL, motion, and responsive behavior.
- Unit/widget/golden/integration tests required below.
- Documentation/current-state updates after implementation.
- Exact prompt persistence under `docs/prompts/`.

### Out of scope / do not touch

- Backend source, Prisma schema/migrations, OpenAPI, backend dependencies, or auth endpoints.
- Auth/session semantics, protected-route policy, or return-destination canonicalization.
- Profile, Settings, Notifications, Chat, or specialized module features.
- New network search, search indexing, remote search endpoints, search history, recent searches, or
  search persistence.
- Module ordering, pinning, recents, personalization, persistence, feature flags, or a general
  module-registry service.
- New state-management, routing, UI-framework, blur, icon, responsive, or animation dependencies.
- Existing theme palette values or existing theme golden baselines.
- CI/CD, platform identifiers, flavors, SDK levels, signing, release, distribution, or telemetry.

---

## CRITICAL STAGED-AVAILABILITY RULE

The approved final shell names Home, Chat, and Profile, but the M03_WP03 baseline does not contain
real Chat or Profile routes. The baseline also contains no specialized production modules.

Apply this rule exactly:

1. **Never ship a dead action.**
2. Production bottom-dock entries are created only from real currently registered destinations.
3. At the current baseline, Home is the only valid production dock destination unless the
   synchronized default branch contains another fully implemented, architecture-approved real
   destination.
4. Do not add disabled Chat/Profile icons, “coming soon” routes, empty placeholder pages, fake
   modules, or redirects that misrepresent Account Security as Profile.
5. The dock component must still support the approved three-destination contract. Verify full
   Profile–Chat–Home order, selection, taps, and swipes using **test-only fixtures/harnesses** that
   never enter production route registries or user-facing builds.
6. The production dock must size and center itself gracefully for the real available entries; it
   must not reserve blank slots for unavailable destinations.
7. The module strip and internal tabs are hidden in production while no real module supplies them.
   Their complete expanded/compact/selected behavior is verified through controlled test-only
   fixtures.
8. This staged availability is already permitted by `APP_SHELL.md`; it is not a reason to invent
   future features and does not require a new owner decision.

If the synchronized repository unexpectedly contains a real Chat/Profile/module route, inspect its
public contract and include it only when it is complete, architecture-approved, and not a
placeholder. Report any conflict before implementation.

---

## APPROVED TARGET CONTRACT

### 1. Shell ownership and dependency direction

- Keep one `GoRouter` under `app/router/`.
- Preserve `app → features → core` dependency direction.
- The application shell is product-specific; do not place feature-aware shell orchestration in
  `core/`.
- `core/ui` may contain only genuinely product-agnostic primitives. Do not move Laforika-specific
  module/dock semantics there merely to make imports convenient.
- Feature routes remain exposed through curated feature public barrels.
- Do not import feature internals from the app shell.
- Do not create a service locator, second router, nested ad-hoc `Navigator`, or speculative module
  registry.
- Prefer a small controlled presentation contract: callers supply visible items, selected IDs,
  semantic labels, and callbacks. The shell must not own future feature business state.

### 2. Home/module hierarchy

On Home and module surfaces, top-to-bottom:

1. adaptive module strip when real module items exist;
2. search field;
3. contextual internal tabs only when a real module is active;
4. main body;
5. floating bottom dock above the bottom safe area.

Chat/Profile/Settings/Notifications will use focused headers in later packages and must not be
created here.

### 3. Production Home integration

- Home remains public and guest-safe.
- Home is selected in the bottom dock.
- No module is selected on Home.
- No internal tabs appear on Home.
- Replace the transitional conventional AppBar presentation with the approved Home/discovery shell
  unless a focused status/title treatment is required for accessibility; do not retain duplicate
  top chrome.
- Preserve the real Account Security discovery action as a protected capability.
- Preserve a user-accessible logout action for authenticated users until M03_WP05 relocates account
  actions into Profile. It may remain in the Home body, but must not become a fourth dock item.
- Keep the Home body simple and localized. Do not invent news, calendars, events, quotes, cards, or
  future module content.
- Preserve stable integration-test keys where reasonable, especially:
  - `home_discovery_shell`
  - `home_account_security_action`
  - `home_account_security`
  - `home_logout`
- If markup changes require key movement, update tests atomically without weakening assertions.

### 4. Home search behavior

The current app has no search backend or specialized modules. Implement a real, bounded search
interaction without speculative infrastructure:

- Render the approved search field below the module-strip region on Home.
- Scope it only to real Home discovery entries currently rendered by Home (at minimum Account
  Security and any other actual synchronized Home entries).
- Filtering is local, immediate, case/whitespace tolerant, and Persian-safe for current labels.
- An empty query restores all entries.
- No-result state is localized and accessible.
- Do not add networking, indexing, history, persistence, suggestions, analytics, or a generic search
  service.
- The controlled shell/search API must allow a future real module to provide a module-scoped query
  callback, but do not implement future module search logic now.
- Use a real editable text field with a localized label/hint and search semantics; do not render a
  decorative non-functional search box.

### 5. Adaptive module strip

Implement a controlled, reusable shell component with these states:

#### Expanded

- Larger rounded items.
- Localized title plus icon.
- At least 48dp interactive target.
- Horizontally scrollable and RTL-aware.

#### Compact

- Smaller rounded chips.
- Localized title only; icons are removed.
- At least 48dp interactive target even when visually compact.
- Horizontally scrollable and RTL-aware.

#### Transition

- Main vertical content scrolling drives expanded → compact.
- Use a calm approximately 180–250ms transition where an explicit animation is needed.
- Respect reduced motion/system accessibility behavior where Flutter exposes it.
- Preserve selected module identity.
- Preserve horizontal scroll position by retaining the same horizontal controller/state.
- Do not jump the module row back to its start when compacting.
- Do not persist strip position across process restarts.
- Use directional padding/alignment APIs.

The production strip is omitted when the visible real module list is empty. Test-only fixtures may
use generic Persian labels such as `ماژول ۱` / `ماژول ۲`; those fixtures must not ship as production
content.

### 6. Contextual internal tabs

- Hidden on Home.
- Visible only when a module is active and supplies real tabs.
- Horizontally scrollable in RTL.
- First tab is selected when entering a module unless route-reconstructable state selects another
  valid tab.
- Selected tab uses more than color: accent plus shape/indicator/text treatment.
- Selecting a tab invokes the caller-provided controlled callback; the shell must not invent a
  module navigation model.
- Invalid/missing selected tab input fails safely to the first valid tab in test harness behavior,
  or is rejected by an explicit assertion/contract; document the chosen controlled-widget policy.
- Test-only fixtures verify tab selection and body switching. No production dummy tab names.

### 7. Floating bottom dock

#### Geometry and materials

- Fixed above the bottom safe area.
- Centered rounded capsule, approximately 24–28dp radius using existing semantic radius tokens.
- Slightly translucent semantic surface.
- Thin semantic border.
- Restrained elevation/shadow.
- Optional SDK-only `BackdropFilter` blur may be used as progressive enhancement, but readability
  must remain correct without blur.
- Do not hardcode white/black surfaces; consume `AppSemanticColors` and existing theme tokens.
- Main scrollable bodies receive sufficient bottom padding so content is not obscured by the dock.

#### Items

- Icon-only visual controls.
- Localized semantic label supplied for every item.
- Minimum 48dp target.
- Direct tap navigation callback.
- Production uses only real registered destinations.
- Approved visual RTL order when all exist:

```text
[ Profile ]  [ Chat ]  [ Home ]
 visual left             visual right
```

#### Selection

| Active context | Required selection |
|---|---|
| Home | Home |
| Chat, including protected login context | Chat |
| Profile, including guest login context | Profile |
| Settings/Notifications under Profile | Profile |
| Active module | none |

M03_WP04 production can currently exercise Home selection only. Test fixtures must prove all rules
that do not require future real features.

Selected state must combine:

- accent color;
- a shape/background or indicator;
- stronger/filled icon treatment where the chosen Material icon family supports it;
- semantic `selected` state.

Do not rely on color alone.

### 8. Dock swipe behavior

Horizontal gestures are recognized on the dock itself, not across the entire page.

Approved RTL visual adjacency:

| Swipe toward | Sequence |
|---|---|
| Visual left | `Home → Chat → Profile` |
| Visual right | `Profile → Chat → Home` |

Rules:

- Do not wrap.
- At an edge, a further outward swipe is a no-op.
- A tap always navigates directly to that item.
- Use a deliberate drag-distance/velocity threshold so incidental taps do not switch destination.
- Preserve native accessibility and tap behavior.
- With fewer than two production entries, swipe is a no-op.
- Put adjacency calculation in a small independently testable function/model when that reduces
  widget complexity; do not create an application-wide navigation state framework.

### 9. Route integration and selected context

- Preserve all M03_WP03 public/protected/auth redirects exactly.
- Home route remains reconstructable from `/`.
- Do not add raw route strings at shell call sites; use exported route constants.
- Do not make shell state required through `extra`.
- Do not add Chat/Profile/module paths solely for shell tests.
- Test-only dock/module/tab harnesses must not alter `appRegisteredPaths`, `appPublicPaths`, or
  `appProtectedPaths`.
- Account Security remains its current protected focused screen and must continue to resume after
  OTP.
- Do not misclassify Account Security as a dock destination or Profile page.
- If a `ShellRoute` is introduced, keep route ownership and redirect behavior simple, preserve cold
  starts/deep links, and test the route tree. A `ShellRoute` is not mandatory if focused composition
  satisfies the approved behavior more safely.

### 10. Responsive layout

- Phone-first.
- Use existing shared tokens/breakpoints and `LayoutBuilder`/`MediaQuery` only.
- No heavy responsive framework.
- Keep main content centered with the existing reasonable wide-screen max width or an
  architecture-consistent equivalent.
- At 320dp width:
  - no horizontal overflow outside intentional horizontal scrollers;
  - dock remains usable;
  - search remains full-width and readable;
  - shell header does not clip.
- At 2.0 text scale:
  - no fixed-height text clipping;
  - module/tab labels follow a documented wrap/ellipsis policy;
  - icon-only controls remain semantic.

Full cross-product hardening remains M03_WP07, but this package must not introduce known overflow
or accessibility defects.

### 11. Theme and motion

- Consume M03_WP02 `ThemeData`, `AppSemanticColors`, and `AppTokens`.
- Do not change approved palette hex values.
- Do not add ad-hoc feature colors or duplicate theme constants.
- Support both light and dark themes.
- Translucency must preserve WCAG AA contrast for essential icons and indicators.
- Standard transitions approximately 180–250ms.
- Avoid bounce, decorative parallax, oversized hero motion, or long animations.
- Avoid state changes that depend on a frame-perfect animation completing.

### 12. Localization and RTL

- All production user-facing strings come from `lib/l10n/app_fa.arb` and generated localizations.
- Never hand-edit generated l10n output.
- Regenerate through the repository's approved Flutter localization command.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`, and `end`.
- Do not hardcode left/right layout behavior.
- Mirror directional affordances when needed.
- Generic fixture labels may be literal test data only.

Likely production strings include, as needed:

- Home navigation semantic label;
- Home search label/hint;
- clear-search semantic label;
- no-search-results message;
- shell accessibility descriptions.

Do not add unused Chat/Profile production strings merely to populate unavailable actions; labels for
test-only dock entries can be supplied by tests.

### 13. Accessibility

- Every icon-only dock/search control has a localized semantic label.
- Selected dock/tab/module state is exposed to semantics.
- Minimum 48dp target.
- Logical traversal follows RTL visual/reading order.
- Search no-result state is announced appropriately.
- Decorative blur/shadow layers are excluded from semantics.
- Avoid nested duplicate semantic labels.
- Add focused tests that inspect semantics for the production Home dock/search and fixture-selected
  states.

### 14. Error/empty/disabled behavior

- Empty real module list: omit module strip cleanly.
- No active module: omit internal tabs.
- Empty real dock list is an invalid shell configuration; fail fast in debug/assertions or omit the
  dock through an explicit caller choice. Production Home must supply Home.
- One dock item: centered, usable, swipe no-op.
- Empty Home search result: localized empty state, no crash.
- Disabled actions during logout or other pending state remain disabled and preserve semantics.
- Long module/tab labels do not overflow or force the entire page horizontally.

---

## EXPECTED FILE SURFACE

The exact design is up to the coding agent after inspection, but a reasonable focused surface may
include:

```text
lib/app/shell/
  app_shell_scaffold.dart
  adaptive_module_strip.dart
  contextual_tab_strip.dart
  floating_bottom_dock.dart
  shell_models.dart                 # only minimal controlled view contracts if needed
  shell_navigation.dart             # only small pure swipe/adjacency logic if needed

lib/features/home/presentation/home_screen.dart
lib/l10n/app_fa.arb
lib/l10n/generated/*                # regenerated, never hand-edited

test/app/shell/
test/features/home/
integration_test/auth_flow_test.dart

docs/prompts/M03_WP04_ADAPTIVE_APPLICATION_SHELL_PROMPT.md
README.md
AGENTS.md                            # current-state wording only if required
docs/architecture/ARCHITECTURE.md   # current-state/roadmap wording only
docs/design/APP_SHELL.md            # implementation-status clarification only
```

This list is not permission to create every file. Keep the implementation small, cohesive, and
free of empty abstractions. Do not place product-specific shell semantics in `core/` merely to match
this example.

---

## ACCEPTANCE CRITERIA

### Repository/workflow

- [ ] M03_WP03 is inventoried once, green, merged, and present on the synchronized clean default
      branch before WP04 starts.
- [ ] WP04 uses a new branch named `feat/m03-wp04-adaptive-shell` or an equally precise approved
      Conventional Git branch name.
- [ ] This exact prompt is committed under the required `docs/prompts/` path.
- [ ] No backend, Prisma, OpenAPI, platform, CI, flavor, identity, or dependency changes.

### Production behavior

- [ ] Guest and authenticated startup still land on public Home after hydration.
- [ ] Home uses the new adaptive application-shell layout.
- [ ] Home dock selection is visible, non-color-only, and semantic.
- [ ] Production dock contains only real currently registered destinations.
- [ ] No dead Chat/Profile/module actions or placeholder pages are shipped.
- [ ] Home search is a real local filter over currently rendered Home discovery entries.
- [ ] Search clear/no-result behavior is localized and tested.
- [ ] Home has no contextual internal tabs.
- [ ] Account Security remains reachable and protected.
- [ ] Authenticated logout remains reachable until Profile lands.
- [ ] Scrollable content is not obscured by the floating dock.

### Shell component behavior

- [ ] Module strip supports expanded icon+title state.
- [ ] Module strip supports compact title-only state.
- [ ] Vertical scroll drives the transition.
- [ ] Selected module and horizontal strip position survive compaction.
- [ ] Empty module list omits the strip.
- [ ] Internal tabs appear only for active module fixtures.
- [ ] First valid internal tab selection behavior is defined and tested.
- [ ] Active module fixture clears dock selection.
- [ ] Dock supports the approved Profile–Chat–Home RTL visual order.
- [ ] Dock taps choose the intended item.
- [ ] Visual-left and visual-right swipes follow the approved adjacency.
- [ ] Swipe never wraps and edge swipes are no-ops.
- [ ] One-item production dock handles swipe as a no-op.

### Visual/accessibility

- [ ] Uses semantic light/dark theme colors and existing tokens.
- [ ] Floating dock is centered, rounded, slightly translucent, bordered, and restrained in
      elevation.
- [ ] Every icon-only production control has localized semantics and a 48dp target.
- [ ] Selected states are not color-only.
- [ ] RTL order and directional spacing are correct.
- [ ] Targeted 320dp and 2.0 text-scale tests show no shell overflow/clipping.
- [ ] Light and dark dedicated shell goldens are added/verified as specified below.
- [ ] Existing M03_WP02 theme goldens remain byte-for-byte unchanged.

### Documentation

- [ ] README and architecture current-state wording mark M03_WP04 implemented only after code/tests
      are complete.
- [ ] Exact next package becomes **M03_WP05 — Profile vertical slice**.
- [ ] Architecture remains version 1.4 and accepted ADRs remain unchanged.
- [ ] `APP_SHELL.md` clearly records staged production availability: full shell primitives are
      implemented, but unavailable real destinations/modules are omitted rather than faked.
- [ ] No M03_WP04 project-inventory entry is added before external approval.

---

## REQUIRED TESTS

### Unit / pure logic

Add focused tests for any extracted shell logic, including:

- RTL dock adjacency for Profile–Chat–Home;
- visual-left sequence Home → Chat → Profile;
- visual-right sequence Profile → Chat → Home;
- no wrap at Home/Profile edges;
- no-op with zero/one available adjacent destination as applicable;
- drag threshold behavior if separated from the widget;
- Home search normalization/filter behavior if extracted.

Do not create logic classes solely to satisfy a unit-test category; widget tests are acceptable when
logic is inherently visual.

### Widget tests

At minimum cover:

1. **Production Home / guest**
   - Home shell renders after hydration;
   - Home dock selected;
   - only real dock entries appear;
   - no module strip when no real modules;
   - no internal tabs;
   - Account Security action remains available;
   - logout absent.

2. **Production Home / authenticated**
   - Home dock selected;
   - Account Security remains available;
   - logout available and pending state is safe.

3. **Home search**
   - typing a matching Persian query keeps the real item;
   - nonmatching query shows localized no-results state;
   - clearing restores entries;
   - search semantics and clear action are correct.

4. **Module fixture / expanded**
   - generic test-only modules render icon+title;
   - selected module is non-color-only;
   - first tab selected;
   - dock has no selected destination.

5. **Module fixture / compact**
   - vertical scroll compacts strip to text-only chips;
   - selected module remains selected;
   - horizontal strip offset is preserved;
   - tabs remain visible;
   - body scroll remains usable.

6. **Dock fixture with three destinations**
   - RTL visual order Profile, Chat, Home;
   - direct taps invoke correct destination;
   - visual-left swipes Home → Chat → Profile;
   - visual-right swipes Profile → Chat → Home;
   - edges do not wrap;
   - semantic selected state changes correctly.

7. **Responsive/accessibility**
   - 320dp width no overflow;
   - 2.0 text scale no clipping/overflow in representative Home and module fixtures;
   - 48dp targets;
   - light and dark rendering.

8. **Router regression**
   - startup/public/protected/auth redirect tests remain green;
   - shell/test fixtures do not change registered production paths;
   - Account Security resume after OTP remains green.

Use targeted pumps. Do not use `pumpAndSettle()` where an intentionally persistent animation or
scroll physics could make it unreliable.

### Golden / RTL tests

This task explicitly approves **new dedicated shell golden baselines**. It does not approve changes
to existing theme goldens.

Add a focused RTL golden set using the existing comparator/infrastructure, for example:

- production Home shell — light;
- production Home shell — dark;
- test-only module fixture expanded — one theme;
- test-only module fixture compact — one theme.

Keep the set proportionate. The minimum acceptable set is Home light + Home dark plus one fixture
that clearly proves module/header geometry.

Rules:

- Existing files under `test/core/theme/goldens/` must remain unchanged.
- Do not change `TolerantGoldenComparator` or its tolerance.
- Run targeted `--update-goldens` only for the newly added shell golden test after visually
  inspecting output.
- Record exactly which new golden files were created.
- Do not mass-update unrelated goldens.

### Integration

Update and run the existing real dev Android-emulator flow:

```text
guest Home
→ protected Account Security
→ direct phone OTP
→ resume Account Security
→ protected me()/refresh validation
→ logout
→ guest Home
```

The flow must continue to assert real behavior, not merely widget presence. Preserve fixture-key
secrecy. Adapt selectors only as needed for the new Home shell without weakening the test.

Do not add fake Chat/Profile/module integration flows.

---

## IMPLEMENTATION GUIDANCE

### Step 0 — Inspect and report blockers

Before editing:

1. Complete the preconditions.
2. Read every authoritative document and relevant file.
3. Inspect current route ownership, Home body, theme APIs, localization generation, tests, and
   integration keys.
4. Confirm the real production destination/module inventory.
5. State explicitly in the plan which dock entries and module items exist in production.
6. Identify any architecture conflict before editing.

Proceed without waiting unless an actual `AGENTS.md` guardrail or frozen-document conflict blocks
work. The known absence of Chat/Profile/modules is handled by the staged-availability rule and is
not itself a blocker.

### Step 1 — Plan

Provide a concise implementation plan containing:

- actual WP04 base SHA;
- expected file surface;
- shell ownership/location rationale;
- production destination/module inventory;
- Home search strategy;
- expanded/compact implementation approach;
- dock tap/swipe approach;
- test and golden plan;
- exact verification commands;
- documentation updates.

### Step 2 — Implement incrementally

Recommended logical sequence:

1. Add minimal controlled shell view contracts and dock adjacency logic.
2. Implement floating bottom dock and tests.
3. Implement adaptive module strip and contextual tabs with tests.
4. Implement shell scaffold/header scroll geometry.
5. Integrate production Home using real destinations only.
6. Add real Home local search/filter behavior.
7. Regenerate localization output.
8. Update router/home/integration tests.
9. Add and inspect dedicated shell goldens.
10. Reconcile current-state documentation.

Keep commits atomic by logical change. Do not mix unrelated auth/backend cleanup into this package.

### Step 3 — Verify

Run and report actual results for all applicable commands.

#### Flutter quality

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
git diff --check
```

#### Localization generation / generated clean-diff

Use the repository-approved generation command, normally:

```bash
flutter gen-l10n
```

Then verify generated files are committed and regeneration leaves no unexpected diff.

#### Targeted shell goldens

Run the dedicated shell golden test normally after baselines exist. Use targeted
`--update-goldens` only once to create the explicitly approved new shell files, then inspect and
rerun without update mode.

#### Backend regression gates

No backend files should change, but run the standard repository backend gates because the PR CI
requires them:

```bash
npm ci --prefix backend
npm run format:check --prefix backend
npm run lint --prefix backend
npm run typecheck --prefix backend
npm run prisma:validate --prefix backend
npm test --prefix backend
npm run test:e2e --prefix backend
npm run openapi:check --prefix backend
npm run build --prefix backend
```

Use the exact current package-script names if they differ after inspection. Do not invent commands.

#### Three-flavor Android debug build matrix

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

On Windows/PowerShell, use an equivalent loop and report each flavor separately.

#### Real dev emulator integration

```bash
flutter test integration_test/auth_flow_test.dart --flavor dev \
  --dart-define=APP_FLAVOR=dev \
  --dart-define-from-file=config/dev.json \
  --dart-define=FIXTURE_INBOX_KEY=<owner-approved-local-secret> \
  -d <emulator-id>
```

Never print or commit the fixture key.

#### Manual visual verification

Manually inspect at minimum:

- Persian RTL Home in light theme;
- Persian RTL Home in dark theme;
- Home at 320dp width;
- representative shell fixture at 2.0 text scale;
- dock content clearance above system safe area;
- selected state and semantics;
- expanded/compact transition and preserved horizontal position;
- dock tap/swipe/no-wrap behavior in the test harness.

Report exact device/emulator and environment limitations. Do not claim commands passed when not run.
An applicable gate that cannot run requires a precise blocker and explicit approved deviation before
completion.

### Step 4 — Check in and external review

Use:

```text
Branch: feat/m03-wp04-adaptive-shell
```

Use Conventional Commits, for example:

```text
feat(shell): add adaptive RTL application shell
feat(home): integrate discovery search and floating dock
test(shell): cover adaptive states and RTL navigation
docs(shell): mark M03_WP04 implemented
```

Adjust commit grouping to the real diff; keep commits atomic.

Before PR:

- inspect `git status`;
- inspect `git diff --stat`;
- inspect the complete diff;
- confirm no secret, local Gradle workaround, build output, fixture data, or unrelated file is
  staged;
- confirm existing theme goldens are unchanged;
- confirm no production dummy destinations/modules exist.

Open/update one PR using the `AGENTS.md` PR template. Include screenshots/golden previews for visual
changes.

After implementation CI is green:

1. create a **complete clean source archive** from the exact PR-head commit, preferably using
   `git archive`;
2. name it:

```text
laforika-m03-wp04-adaptive-shell-<short-sha>-src.zip
```

3. report the full PR-head SHA and archive path;
4. stop for owner/external review;
5. do not update inventory or merge yet.

After external approval only:

1. add exactly one terminating M03_WP04 entry to `docs/project_inventory.md`;
2. record the externally approved implementation SHA, not the inventory commit SHA;
3. record exact next package **M03_WP05 — Profile vertical slice**;
4. commit/push inventory once;
5. rerun CI;
6. merge only after final green CI and owner approval.

The inventory entry must not record its own inventory commit, merge commit, branch status, or
“pending merge” wording.

---

## DOCUMENTATION UPDATES

After implementation and tests are complete, update only current-state wording needed to reflect
reality:

- `README.md`
  - mark M03_WP04 implemented;
  - identify M03_WP05 as exact next;
  - explain that unavailable Chat/Profile/module actions are not shipped.
- `docs/architecture/ARCHITECTURE.md`
  - mark M03_WP04 implemented;
  - update transition/freeze/roadmap wording;
  - preserve version 1.4;
  - do not alter accepted decisions.
- `docs/design/APP_SHELL.md`
  - update implementation status;
  - state that shell primitives are implemented and production availability remains route-driven;
  - preserve deferred Profile/Settings/Notifications and real Chat/module boundaries.
- `AGENTS.md`
  - update exact current package/next-package wording only when such wording exists;
  - do not rewrite architecture rules.
- Persist this prompt under the required path.

Do not edit accepted ADR-0009 to mark implementation. Accepted ADRs are immutable.

Do not add the M03_WP04 project-inventory entry before external approval.

---

## CONSTRAINTS

- No architecture or owner-decision changes without explicit approval.
- No new dependency.
- No backend/OpenAPI/Prisma change.
- No real Chat/Profile/Settings/Notifications/module implementation.
- No fake production routes or content.
- No module registry service, ordering/pinning persistence, or personalization.
- No raw color palette in shell widgets.
- No hardcoded left/right layout.
- No hand-editing generated l10n files.
- No existing theme-golden updates.
- No CI/platform/flavor/toolchain changes.
- Preserve public auth/session/route contracts.
- Preserve secure fixture handling and controlled-test-only real auth.
- Check-in mode: branch + atomic commits + PR + exact-head full source archive + external-review stop.

---

## REPORT BACK

Return a concise final report with:

- **Status:** done / partial / blocked
- **Base commit SHA:**
- **Branch:**
- **Final implementation commit SHA:**
- **PR:**
- **Full source archive path:**
- **Summary:**
- **Production destination/module inventory:**
- **Files changed:**
- **Tests added/updated:**
- **New golden files:**
- **Existing golden files changed:** must be `No`
- **Commands and actual results:**
  - format
  - analyze
  - Flutter tests
  - import boundaries
  - generated clean-diff
  - backend gates
  - dev/staging/prod APKs
  - real emulator integration
  - CI
- **Manual verification device/state:**
- **Architecture/ADR impact:** expected `none`; architecture remains v1.4
- **Approved deviations:** expected `none`
- **Blockers/follow-ups:**
- **Inventory/merge:** held for external approval
- **Exact next package:** **M03_WP05 — Profile vertical slice**
