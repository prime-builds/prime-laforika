# Laforika M03_WP07 — Integration and Visual Hardening Prompt

## CONTINUATION STATUS / IMPLEMENTATION STATUS

This work package is **implemented** and prepared for external review handoff.

| Item | Current value |
|---|---|
| Base branch | `main` at `5aa2ef8b2310e5fc49809ee6b839658ff3c4fe31` |
| Working branch | `test/m03-wp07-integration-visual-hardening` |
| Implementation status | M03_WP07 is implemented; the M03 transition is complete; architecture remains v1.4 |
| Decisions | O7 is implemented for the in-app visual system through M03_WP07; O7 external logo/store/marketing assets remain unresolved; O2–O6 and O8 remain unresolved as currently documented; O3 remains unresolved and Notifications remains presentation-only with no push provider |
| Next planning action | Owner chooses and specifies **M04 — First specialized production module** (do not name or scaffold a module by assumption) |
| Remote | `origin/test/m03-wp07-integration-visual-hardening` |
| Merge status | Not merged; held for external review |
| Inventory status | Not updated; do not update before external approval |
| Verification status | All local quality gates passed (Flutter format, analyze, 196 tests, boundaries, diff-check, backend format/lint/typecheck/prisma/unit/e2e/openapi, dev/staging/prod debug APK matrix, and Android emulator integration test) |

### Already present at the current HEAD

The partial implementation already contains focused work in:

- auth startup/session hydration and preserved-destination behavior;
- production dock interaction coverage;
- shell fixture harness and widget coverage;
- router/security, production dock, and shell tests;
- the committed test support file `test/tmp_repro_test.dart`.

Treat these files as existing work to inspect, validate, repair, or extend. Do not assume that their presence means the related acceptance criteria are complete. The remaining package still includes the full route matrix, responsive and text-scale coverage, accessibility and contrast audits, visual/golden review, emulator integration hardening, documentation reconciliation, local quality gates, and the external-review handoff described below.

### Required continuation sequence

1. Fetch `origin`, switch to `test/m03-wp07-integration-visual-hardening`, fast-forward to the latest remote HEAD, and verify that the worktree is clean before editing. The latest known HEAD is `320c9b35`; if the branch has advanced, inspect the newer commits and preserve them.
2. Read `AGENTS.md` and all authority/context files required by this prompt before changing code.
3. Inspect the current diff and run targeted tests first. Fix failures in the existing slice before adding another slice.
4. Continue implementation on this same branch with minimal, focused commits. Preserve the architecture, dependency, backend, platform, flavor, and CI constraints below.
5. Run and report every applicable local verification gate. Do not claim GitHub Actions passed while hosted runners are unavailable.
6. Push the completed implementation and stop for external review. Do not update `docs/project_inventory.md` and do not merge in this continuation phase.

The original task, acceptance criteria, required test plan, temporary Actions deviation, and delivery rules below remain authoritative. This handoff supplements the original baseline instructions; it does not reduce their scope.

### Google Studio kickoff prompt

Use the following prompt to resume this package in Google Studio:

```text
Import the latest state of the GitHub repository `prime-builds/prime-laforika` and continue the incomplete M03_WP07 work package.

1. Fetch the latest remote refs and open the branch `test/m03-wp07-integration-visual-hardening`.
2. Use the latest remote commit on that branch. Do not reset, discard, rebase away, or recreate the branch. Do not start from `main` unless the branch is missing and you report that blocker first.
3. Read `AGENTS.md` fully.
4. Read `docs/prompts/M03_WP07_INTEGRATION_AND_VISUAL_HARDENING_PROMPT.md` fully, including its continuation handoff, acceptance criteria, constraints, test plan, and delivery rules.
5. Inspect the current branch diff and run focused tests before adding new work. Treat the existing implementation as partial, not complete.
6. Continue M03_WP07 from the current HEAD with minimal, focused changes. Preserve all architecture, dependency, backend, platform, flavor, CI, localization, RTL, accessibility, and no-merge constraints in the repository instructions and WP07 prompt.
7. Do not invent a production module, Chat, route, backend contract, dependency, palette redesign, or M04 choice. Do not update `docs/project_inventory.md`.
8. Run every applicable local verification command and report actual results. Never claim GitHub Actions passed if hosted runners are unavailable.
9. Commit and push the completed implementation to the same branch using Conventional Commits. Do not merge. Stop for external review and report the branch, final commit, tests, remaining blockers, and archive/CI status.

Begin by reporting the imported branch name, exact HEAD SHA, worktree status, and the first targeted validation command. Then continue implementation; do not stop at a plan unless a repository guardrail or explicit owner decision blocks the work.
```

## TASK

Deliver **M03_WP07 — Integration and visual hardening**, the final work package in the M03 transition program.

Harden the already-implemented guest-first, phone-only, Fluent-inspired Laforika application across its real production routes and the approved shell test fixtures. Complete the route-state matrix, cold-start and preserved-destination behavior, full-screen visual coverage, narrow-width and large-text resilience, semantics, touch targets, dock navigation, module-header interaction coverage, and the real Android emulator flow.

Apply only minimal production fixes that are directly proven necessary by the hardening tests. Do not introduce a new product feature, module, backend contract, dependency, architecture direction, or speculative design-system layer.

Persist this exact task prompt in the repository as:

```text
docs/prompts/M03_WP07_INTEGRATION_AND_VISUAL_HARDENING_PROMPT.md
```

---

## WHY

M03_WP02 through M03_WP06 delivered the approved target in bounded vertical slices:

- semantic System / Light / Dark theming;
- guest-first routing and phone-only OTP authentication;
- adaptive shell primitives and the production Profile + Home dock;
- guest and authenticated Profile states;
- public Settings and protected Notifications.

The remaining risk is not missing product scope. It is cross-slice behavior:

- route behavior can differ between warm navigation and true cold start;
- auth hydration, errors, retries, and preserved destinations can expose redirect gaps;
- full screens can clip or overflow at 320dp and text scale 2.0;
- selected and disabled states can become color-only or lose semantics;
- the translucent dock can look correct in one theme but fail contrast or interaction requirements in another;
- shell module fixtures can pass unit tests while failing realistic scroll, selection, and swipe interaction;
- the emulator happy path must prove that the composed application still works end to end.

The outcome that matters is a stable, accessible, visually reviewed M03 baseline ready for the owner to choose the first real M04 specialized module.

---

## MILESTONE

**M03_WP07 — Integration and visual hardening.**

This is the final implementation package of the architecture v1.4 transition documented by ADR-0008, ADR-0009, `docs/design/UI_FOUNDATION.md`, and `docs/design/APP_SHELL.md`.

Expected architecture impact:

- no new ADR;
- no architecture-version bump;
- current-state documentation reconciliation only;
- minimal compatible fixes where hardening exposes an implementation defect.

After successful completion, external approval, inventory, and merge:

- M03 is complete;
- do **not** begin a specialized module by assumption;
- the exact next planning action is **owner selection and specification of M04 — First specialized production module**.

---

## REVIEWED BASELINE AND MANDATORY PRECONDITIONS

Start from the clean synchronized default branch at exactly:

```text
5aa2ef8b2310e5fc49809ee6b839658ff3c4fe31
```

This SHA is the locally merged and pushed M03_WP06 baseline.

Before creating the M03_WP07 branch:

1. Read `AGENTS.md` fully.
2. Read `README.md` fully.
3. Read `docs/project_inventory.md` fully.
4. Read `docs/architecture/ARCHITECTURE.md` fully.
5. Read at minimum:
   - `docs/architecture/adr/0002-riverpod-state-and-di.md`
   - `docs/architecture/adr/0003-go-router-navigation.md`
   - `docs/architecture/adr/0006-authentication-and-session.md`
   - `docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md`
   - `docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md`
   - `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`
   - `docs/design/UI_FOUNDATION.md`
   - `docs/design/APP_SHELL.md`
   - every prior M03 prompt under `docs/prompts/`.
6. Confirm the default branch contains the single terminating M03_WP06 inventory entry.
7. Confirm local default branch equals `origin/main` at the baseline SHA above.
8. Confirm the working tree is clean and there are no untracked runtime fixes.
9. Confirm PR #13 history remains intact and M03_WP06 is merged.
10. Confirm current documentation identifies M03_WP07 as the exact next package.
11. If `origin/main` differs from the baseline SHA, stop and report the newer SHA and diff before proceeding. Do not silently build from a stale base.
12. Do not start from an extracted archive, an earlier PR branch, or a dirty working tree.

Create a dedicated branch only after all preconditions pass.

Suggested branch:

```text
fix/m03-wp07-integration-visual-hardening
```

---

## OWNER DECISIONS — AUTHORITATIVE FOR THIS PACKAGE

### A. This is hardening, not a new feature package

M03_WP07 may:

- add route-matrix, widget, golden, semantics, responsive, controller, and integration tests;
- add focused test harnesses and test-only fixtures;
- correct directly proven route, accessibility, layout, state, or integration defects;
- reconcile current-state documentation;
- add localization only when a real missing semantic/tooltip/error label is discovered.

M03_WP07 must not:

- create Chat;
- create a real module or module registry;
- add fake production module cards, tabs, messages, or notifications;
- add a push provider, analytics, maps, Jalali display, offline storage, Drift, or networking beyond existing auth/profile behavior;
- add backend endpoints, OpenAPI shapes, Prisma schema, migrations, or authentication behavior unless a blocking regression in an existing approved contract is first reported and explicitly approved;
- add a new package dependency;
- redesign the approved palette or navigation model;
- create external brand assets, illustrations, logos, store icons, or marketing UI;
- choose the M04 module.

### B. Current production route contract

The current registered production destinations are:

| Route | Access | Expected guest behavior |
|---|---|---|
| `/` | public | show Home after hydration |
| `/profile` | public Profile context | show direct phone-OTP Profile state |
| `/settings` | public Profile context | show guest Settings |
| `/notifications` | protected Profile context | redirect to phone OTP with canonical `from=/notifications` |
| `/account/security` | protected | redirect to phone OTP with canonical `from=/account/security` |
| `/auth` | auth-only | guests may use phone OTP; authenticated users leave auth |
| `/startup` | internal startup | deterministic hydration/error surface only |

Do not add routes in this package.

### C. Complete route-state matrix

Test and harden the actual composition for all relevant combinations.

#### Hydration states

For `AuthUnknown` and `AuthHydrationError`:

- show deterministic startup/loading or startup/error UI;
- never flash Home, Profile, Settings, Notifications, Account Security, or login incorrectly;
- preserve a safe registered pending destination through startup;
- preserve the pending destination through hydration failure and Retry;
- reject unsafe, malformed, external, query-bearing, fragment-bearing, protocol-relative, auth-loop, startup-loop, and unknown destinations;
- do not lose the pending route when the gateway completes after a real delay.

#### Unauthenticated state

- `/`, `/profile`, and `/settings` are allowed.
- `/notifications` and `/account/security` redirect to `/auth` with a canonical path-only `from`.
- direct `/auth` remains usable after hydration.
- `/startup` resolves safely.
- unknown or unsafe locations fall back to Home.
- Profile remains the selected parent dock context on Profile, Settings, and Notifications-related surfaces where the shell is present.

#### Authenticated state

- public and protected routes are allowed.
- direct `/auth` and `/startup` leave auth/startup and resolve a validated destination when one exists; otherwise Home.
- authenticated cold starts at `/notifications` and `/account/security` resume those routes after hydration.
- invalid preserved destinations are discarded.
- no redirect loop or transient login flash occurs.

#### Auth route with `from`

A cold or warm auth route containing `from` must use the existing path-only validation policy:

- accept only canonical registered internal paths;
- reject query or fragment state inside `from`;
- reject absolute, authority, protocol-relative, auth-only, startup, malformed, and unknown values;
- never navigate using the unvalidated original value;
- normalize or discard unsafe `from` values so they do not remain active navigation state.

If the current router loses a valid direct `/auth` cold start or valid protected `from` during hydration, implement the narrowest router correction and add regression tests. Do not weaken the path-only policy.

### D. Production dock and navigation context

Production remains **Profile + Home only**.

Visual left-to-right order in Persian RTL:

```text
Profile · Home
```

Required rules:

- Home selected on Home.
- Profile selected on Profile.
- Profile selected as parent context on Settings and Notifications.
- No Chat destination.
- No dead or disabled future destination.
- Tap navigation uses registered routes.
- Swipe follows visible adjacency and never wraps.
- Swiping with fewer than two destinations or no selected item is a no-op.
- Selected state is not color-only: it combines semantics, icon treatment, and selected surface/shape.
- Every dock action has localized semantics and a minimum 48dp target.

Retain the approved three-item Profile · Chat · Home model only in test fixtures for adjacency coverage. It must not enter production composition.

### E. Module strip and contextual tabs remain test-fixture only

Production has no real module yet. Do not invent one.

Harden the existing shell fixture behavior using generic test labels only:

- expanded icon + label module state;
- compact text-only state driven by real body scrolling;
- enough modules to create a real horizontal scroll extent;
- preserved horizontal strip offset across expanded/compact transition;
- module selection remains stable;
- entering a module selects its first contextual tab;
- contextual tabs appear only while a module is active;
- no dock destination is selected while a module is active;
- body scrolling continues correctly;
- search placeholder/scope reflects Home versus active-module fixture context where the existing contract exposes it;
- module and tab actions have selected semantics and 48dp targets;
- visual RTL order and directional scrolling are correct;
- dock swipe and module-strip gestures do not interfere with vertical body scroll;
- no wrap or accidental selection occurs from sub-threshold gestures;
- reduced-motion behavior uses an immediate or appropriately reduced transition where Flutter exposes `disableAnimations`.

The controlled shell API may remain controlled. Do not add a speculative production module controller, registry, persistence layer, or route model.

### F. Visual hardening matrix

Use the approved Windows 11/Fluent-inspired Laforika semantic tokens. Do not replace the palette.

Cover the real production UI in light and dark Persian RTL, with meaningful full-screen goldens and widget tests.

At minimum, retain or add reviewed coverage for:

- guest Home;
- guest Profile phone-login state;
- authenticated Profile;
- guest Settings;
- authenticated Settings;
- Notifications loading/empty/error/data through provider overrides, with production empty truth preserved;
- direct phone OTP screen;
- Account Security representative authenticated state;
- startup loading and hydration-error states where a golden adds real value;
- expanded and compact module shell fixtures.

Do not create a combinatorial golden explosion. Use goldens for representative visual baselines and widget tests for the broader state matrix.

All changed/new goldens must:

- render Material Icons and Vazirmatn correctly;
- use Persian RTL;
- use deterministic fonts, clocks, data, and surfaces;
- have no missing-glyph squares;
- have no clipped text or controls;
- be visually inspected in both themes;
- use the existing bounded golden comparator correctly.

WP02 theme specimen goldens are frozen and must remain byte-for-byte unchanged unless a directly proven theme-token defect requires an owner-approved baseline change. M03_WP04–M03_WP06 shell/profile/settings/notifications goldens may change only when a focused hardening fix changes their real output, and every change must be listed and visually reviewed.

Never run `flutter test --update-goldens` broadly. Update only explicitly named WP07 or directly affected M03 shell goldens after inspecting the rendered failure.

### G. Narrow-width and large-text resilience

Verify every real route-level surface at:

```text
logical width: 320dp
text scale: 2.0
locale: fa-IR
text direction: RTL
```

Required surfaces:

- startup loading/error;
- direct phone OTP;
- guest Home;
- guest and authenticated Profile;
- guest and authenticated Settings;
- Notifications loading/empty/error/scrollable data;
- Account Security with representative session rows;
- expanded/compact module fixture.

Assertions must prove:

- no Flutter overflow/layout exception;
- primary content remains reachable by scrolling;
- buttons do not clip labels;
- icon-only actions remain at least 48dp;
- long Persian labels wrap or ellipsize according to an explicit, readable policy;
- floating dock does not cover unreachable final content;
- safe-area and keyboard insets do not hide required actions;
- focused text fields and save controls can be made visible and tapped;
- loading, success, error, and empty messages remain discoverable.

Avoid fixed-height fixes that merely hide overflow at normal text scale.

### H. Accessibility and semantics

Audit and test the real production surfaces.

At minimum:

- all icon-only controls have localized tooltip and semantic label;
- selected dock/module/tab/appearance state is exposed semantically;
- disabled and loading controls expose correct enabled state and cannot double-submit;
- back controls have localized semantics and 48dp targets;
- search field and clear action have labels, hints/tooltips, and valid focus behavior;
- verified phone state is not communicated only through color;
- Notifications loading/empty/error/data states are announced meaningfully;
- error and success messages remain safe and localized;
- decorative icons are excluded from redundant semantics where appropriate;
- traversal order follows the visual RTL reading order;
- keyboard dismissal does not make integration assertions depend on offstage defaults.

Use `SemanticsTester` or focused widget assertions where it provides real coverage. Do not add accessibility wrappers mechanically without understanding the resulting semantics tree.

### I. Contrast and translucent surfaces

Keep the approved palette values.

Add or strengthen tests for actual semantic pairings used by production components:

- primary and secondary text on app, primary, secondary, and elevated surfaces;
- accent/on-accent controls;
- error and success on their real surfaces;
- selected dock icon on subtle selection;
- inactive dock icon on the composited translucent dock surface;
- focus/selection indicators against both light and dark surfaces;
- essential borders/indicators where they communicate state.

Use WCAG AA as documented:

- 4.5:1 for normal text;
- 3:1 for large text and essential graphical controls where applicable.

For alpha surfaces, test the actual composited color over the documented background rather than comparing an uncomposited alpha value.

If an approved palette pair itself fails the documented target, stop and report the exact pair and ratio before changing token values. Prefer a component treatment fix over a global palette change.

### J. Integration hardening

Run the real Android emulator integration flow against the dev backend and fixture inbox without exposing secrets.

The committed integration suite must cover a stable end-to-end path including:

1. clean app data / cold start;
2. guest Home;
3. public Settings as guest;
4. appearance interaction and persistence behavior appropriate for the existing test scope;
5. guest Profile direct phone OTP;
6. protected Notifications or Account Security with preserved return destination;
7. phone challenge and OTP verification;
8. successful resume to the protected destination;
9. authenticated Profile load;
10. profile edit/save success;
11. Account Security session load;
12. refresh-token/protected-call validation already present;
13. Notifications honest empty state;
14. authenticated Settings account actions;
15. logout from a documented surface with correct guest destination;
16. final guest Home/Profile/Settings behavior.

The test must be robust against:

- soft keyboard and offstage widgets;
- asynchronous session hydration;
- route transitions;
- loading indicators;
- fixture inbox polling;
- focus state;
- stale cached app data;
- retry timing.

Do not hide product defects with arbitrary long sleeps. Prefer deterministic keys, `ensureVisible`, focused pumps, explicit state assertions, and bounded polling.

Do not log fixture keys, OTP values, phone numbers, account IDs, tokens, or personal/test credentials.

### K. Documentation reconciliation

After implementation and tests are real, update current-state documentation:

- `README.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/design/UI_FOUNDATION.md`
- `docs/design/APP_SHELL.md`
- this prompt under `docs/prompts/`

Required final wording:

- M03_WP07 is implemented;
- the M03 transition is complete;
- architecture remains v1.4 unless a separately approved architectural conflict required otherwise;
- O7 is implemented for the in-app visual system through M03_WP07;
- O7 external logo/store/marketing assets remain unresolved;
- O2–O6 and O8 remain unresolved as currently documented;
- O3 remains unresolved and Notifications remains presentation-only with no push provider;
- exact next planning action: owner chooses and specifies **M04 — First specialized production module**;
- do not name or scaffold a module by assumption.

Do not add the terminating M03_WP07 inventory entry before external approval.

---

## IN SCOPE

- Route-state matrix tests and minimal route corrections.
- Return-destination/cold-start/hydration hardening.
- Production dock order, swipe, selection, semantics, and target coverage.
- Existing shell fixture hardening for expanded/compact modules and contextual tabs.
- Light/dark RTL full-screen golden coverage.
- 320dp and text-scale 2.0 coverage.
- Contrast tests for actual semantic component pairings.
- Accessibility semantics and focus hardening.
- Existing integration suite expansion/stabilization.
- Focused localization additions when required for semantics.
- Current-state documentation reconciliation.
- Test-only fixtures and support utilities that remain narrow and clearly named.

---

## OUT OF SCOPE / DO NOT TOUCH

- New production features or routes.
- Chat.
- Any real module, module registry, module persistence, or dummy production module content.
- Backend endpoint, DTO, OpenAPI, Prisma, migration, or auth-policy changes.
- Push notifications, permissions, FCM, regional providers, local notifications, background handlers, or device tokens.
- Maps, analytics/crash vendor, Jalali display, offline database, outbox, cache infrastructure, or telemetry.
- Theme palette redesign.
- External branding assets.
- Toolchain, Flutter/Dart versions, min SDK, iOS deployment target, flavors, application IDs, signing, release/publishing, or CI workflow changes.
- New dependency.
- Broad refactors or speculative shared UI catalogs.
- M04 module selection or implementation.

---

## RELEVANT CONTEXT TO INSPECT

At minimum inspect:

```text
lib/app/app.dart
lib/app/router/app_router.dart
lib/app/router/routes.dart
lib/app/navigation/production_dock.dart
lib/bootstrap.dart
lib/core/auth/
lib/core/theme/
lib/core/utils/auth_utils.dart
lib/features/auth/
lib/features/home/
lib/features/profile/
lib/features/settings/
lib/features/notifications/
lib/features/shell/
lib/l10n/app_fa.arb
integration_test/auth_flow_test.dart

test/app/auth_router_and_security_test.dart
test/app/navigation/production_dock_test.dart
test/app/shell/
test/core/theme/
test/features/auth/
test/features/home/
test/features/profile/
test/features/settings/
test/features/notifications/
test/support/

tool/check_import_boundaries.dart
pubspec.yaml
analysis_options.yaml
l10n.yaml
.github/workflows/
backend/package.json
backend/src/auth/
backend/src/profile/
```

Inspect all current golden files visually before deciding which must change.

---

## REQUIRED TEST PLAN

### Unit tests

- Return-destination canonicalization table, including every registered path and unsafe classes.
- Dock visual-neighbor mapping, thresholds, no-wrap, no-selection, one-item/two-item/three-item behavior.
- Contrast/compositing utilities and actual semantic pairings.
- Any minimal new pure logic introduced by hardening.

### Router/widget tests

Create a table-driven or otherwise maintainable route matrix covering:

- delayed guest hydration from every public/protected/auth-only representative route;
- delayed authenticated hydration from every public/protected representative route;
- hydration error followed by Retry while preserving a public route;
- hydration error followed by Retry while preserving a protected route;
- direct `/auth` cold start for guest and authenticated states;
- valid and invalid `from` on cold and warm auth navigation;
- no login flash;
- no redirect loop;
- correct final route and page key;
- correct parent dock selection where a dock is present.

Avoid a giant duplicated test file. Extract narrowly scoped test harnesses only when they make the matrix clearer.

### Shell/widget tests

- Production Profile + Home order and position assertions.
- Production tap and swipe navigation.
- No Chat or module production chrome.
- Three-item fixture adjacency and no-wrap.
- Real body drag causing expanded → compact transition.
- Horizontal offset preservation.
- Module selection + first tab + tabs visibility.
- No dock selection during active module.
- 48dp and selected semantics.
- Sub-threshold gestures do nothing.
- Reduced-motion behavior.
- 320dp / 2.0 text scale.

### Route-level responsive/accessibility tests

For all real surfaces listed above:

- 320dp width;
- text scale 2.0;
- Persian RTL;
- no overflow exception;
- required actions reachable;
- semantics/tooltips/selected/disabled states;
- 48dp controls;
- long text behavior.

### Golden tests

- Representative light/dark production route goldens.
- Representative startup/auth/security goldens where missing.
- Expanded and compact shell fixture goldens.
- Material Icons/Vazirmatn loaded.
- Existing WP02 theme goldens unchanged.
- Golden comparator remains bounded and tested.

### Integration test

- Extend/stabilize the real dev emulator flow as described above.
- Run from clean app data.
- Use existing fixture delivery contract.
- Assert actual route, protected call/account identity where already supported, state visibility, and final logout destination.

### Backend regression

No backend code is expected to change. Run the existing backend verification matrix to prove no regression. If an existing pre-existing formatting issue remains unchanged from main, report exact baseline comparison; do not perform unrelated backend formatting churn.

---

## ACCEPTANCE CRITERIA

### Workflow and baseline

- [ ] Branch starts from clean synchronized `5aa2ef8b2310e5fc49809ee6b839658ff3c4fe31`.
- [ ] M03_WP06 inventory entry is present on main.
- [ ] Prompt is committed under the required `docs/prompts/` path.
- [ ] Diff remains bounded to hardening and documentation.

### Route matrix

- [ ] Every current public/protected/auth-only route has guest/authenticated behavior coverage.
- [ ] Delayed hydration coverage begins from real initial locations.
- [ ] Hydration error + Retry preserves safe pending routes.
- [ ] Valid protected destinations resume correctly after OTP.
- [ ] Direct auth cold start behaves correctly for guest/authenticated users.
- [ ] Unsafe/unknown/query/fragment/external destinations are discarded.
- [ ] Redirects use canonical validated paths only.
- [ ] No route loop or auth flash exists.

### Shell/navigation

- [ ] Production dock is Profile + Home only.
- [ ] Visual order and horizontal center assertions are correct in RTL.
- [ ] Home/Profile/parent-context selection rules are correct.
- [ ] Tap/swipe adjacency is correct and non-wrapping.
- [ ] One/no-selection swipe is a no-op.
- [ ] Three-item model remains test-only.
- [ ] Active-module fixture clears dock selection.
- [ ] Expanded/compact transition is driven by real vertical scroll.
- [ ] Module horizontal offset and selection are preserved.
- [ ] Contextual tabs appear only for selected module and first tab is selected.
- [ ] No production module/tab/Chat placeholder ships.

### Responsive/accessibility

- [ ] All real route surfaces pass at 320dp and text scale 2.0.
- [ ] No clipping/overflow/layout exception.
- [ ] Required content remains scroll-reachable above the floating dock.
- [ ] Icon-only controls have localized tooltips/semantics.
- [ ] 48dp targets are verified.
- [ ] Selected/verified/error/loading state is not color-only.
- [ ] Disabled/loading actions cannot double-submit.
- [ ] RTL traversal and directional placement are correct.
- [ ] Reduced-motion behavior is respected where applicable.

### Theme/visual

- [ ] Representative production screens have reviewed light/dark RTL goldens.
- [ ] Startup/auth/security gaps are covered appropriately.
- [ ] Material Icons and Vazirmatn render correctly.
- [ ] No missing glyph squares.
- [ ] Actual component contrast pairings meet documented targets.
- [ ] Alpha surfaces are tested after compositing.
- [ ] Approved palette remains unchanged unless owner explicitly approves a proven exception.
- [ ] WP02 theme goldens remain byte-for-byte unchanged.
- [ ] Every changed/new golden is listed and visually inspected.

### Integration/regression

- [ ] Real emulator flow passes from clean app data.
- [ ] Guest Settings, protected resume, profile save, sessions/refresh, Notifications empty, and logout are exercised.
- [ ] Harness is robust to keyboard/offstage/loading timing.
- [ ] Flutter format/analyze/tests/import boundaries pass.
- [ ] Backend regression gates pass or exact unchanged baseline limitation is reported.
- [ ] dev/staging/prod debug APK matrix passes.
- [ ] No secrets or personal/test credentials appear in logs/report/archive.

### Architecture/docs/delivery

- [ ] No new dependency, backend contract, migration, platform, flavor, or CI workflow change.
- [ ] Architecture remains v1.4; no ADR added.
- [ ] README/architecture/design docs mark M03_WP07 and M03 complete.
- [ ] O7 in-app system is recorded complete; external assets remain open.
- [ ] Next action is owner selection/specification of M04; no module is invented.
- [ ] Full clean source archive is created from exact reviewed PR head.
- [ ] No inventory update or merge occurs before external review.

---

## TEMPORARY GITHUB ACTIONS DEVIATION

The owner has explicitly approved a temporary local-verification workflow because the free GitHub-hosted Actions allowance is exhausted and jobs fail before runner assignment with zero executed steps.

For this package:

- do not ask the owner to pay or increase the budget;
- do not modify GitHub Actions workflows to work around billing/runner capacity;
- do not treat zero-step Actions failures as an implementation failure;
- do not claim GitHub CI passed;
- run every applicable local gate, backend gate, APK build, and emulator integration test;
- report GitHub Actions as **not executed — hosted runner unavailable under owner-approved temporary deviation**;
- continue to PR/archive/external review based on complete local verification;
- if runner capacity becomes available during the package, immediately resume the normal `AGENTS.md` green-CI workflow.

This deviation does not permit skipping tests, merging before review, committing directly to main, omitting inventory, or accepting failing local gates.

Do not permanently edit `AGENTS.md` or CI policy solely for this temporary billing condition unless the owner separately requests a durable workflow change.

---

## CONSTRAINTS

- No architecture or owner-decision changes without explicit approval.
- No new dependency.
- No production route or feature addition.
- No backend/OpenAPI/Prisma/migration changes.
- No CI workflow changes.
- No platform/flavor/signing/toolchain changes.
- No broad palette change.
- No future-module scaffolding.
- No Chat.
- No fake production notifications or unread badges.
- No drive-by refactor.
- Preserve all Composer/runtime/build/integration fixes already merged on main.
- Never hand-edit generated localization or serializer files.
- Never broadly update goldens.
- Never commit secrets, fixture keys, OTP values, phone numbers, tokens, account IDs, `.env`, build outputs, caches, or local Gradle workarounds.
- Temporary `kotlin.incremental=false`, Gradle mirror, TUN, JDK, or cross-drive workarounds must be restored and remain uncommitted.
- Never commit directly to `main`/`master`.
- Never inventory or merge before external archive approval.

Check-in mode:

```text
branch + atomic commits + PR + complete local verification + full clean source archive + stop for external review
```

---

## STEP 0 — INSPECT

Before editing:

1. Complete all baseline/precondition checks.
2. Read all authority files listed above.
3. Inspect the router redirect as a state machine, not isolated branches.
4. Enumerate all registered, public, protected, auth-only, and startup paths from actual code.
5. Inspect every current route-level screen and test key.
6. Inspect the production dock and shell fixture APIs.
7. Inspect every current golden and its harness/font loading.
8. Inspect current narrow-width, text-scale, semantics, contrast, and reduced-motion coverage.
9. Inspect the full emulator integration flow and recent keyboard/offstage stabilization.
10. Inspect backend regression commands and current main behavior before deciding a failure is new.
11. Identify the smallest set of production fixes needed; prefer tests/harness improvements where behavior is already correct.
12. Stop for owner approval if the task would require a new dependency, new route, backend contract, palette change, architecture change, or M04 product choice.

---

## STEP 1 — PLAN

Before editing, provide a concise implementation plan containing:

- verified base SHA and clean/synchronized status;
- branch name;
- actual route-state matrix;
- expected production file changes versus test-only changes;
- golden plan listing existing goldens to retain, new goldens, and any approved expected updates;
- 320dp / 2.0 test matrix;
- semantics/contrast audit plan;
- shell fixture hardening plan;
- emulator integration extension/stabilization plan;
- documentation updates;
- exact local verification commands;
- confirmation that dependencies/backend/platform/CI remain untouched;
- explicit use of the temporary GitHub Actions deviation.

Proceed without waiting unless an `AGENTS.md` guardrail, architecture conflict, or unresolved owner decision blocks implementation.

---

## STEP 2 — IMPLEMENT

1. Commit this exact prompt under `docs/prompts/`.
2. Add route-matrix tests first and fix only proven redirect/canonicalization defects.
3. Harden production dock and shell fixture tests.
4. Add route-level 320dp / 2.0 / semantics coverage.
5. Add or update narrowly approved goldens with deterministic fonts/data.
6. Strengthen actual semantic contrast tests.
7. Extend and stabilize the emulator integration flow.
8. Keep all user-facing additions localized through ARB and regenerate; never hand-edit generated output.
9. Reconcile current-state documentation only after implementation is real.
10. Keep the production diff minimal; avoid introducing abstractions solely to satisfy tests.
11. Inspect each changed golden before accepting it.

---

## STEP 3 — VERIFY

Run and report actual results for every applicable command.

### Flutter

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
git diff --check
```

Run targeted suites during development, then the full suite.

### Generated output

Run the repository-approved localization/code-generation command where source inputs changed. Confirm regeneration leaves no unexplained diff and no generated file was hand-edited.

### Backend regression

Run the repository's documented backend gates, including applicable formatting, Prisma format, lint/typecheck, unit, e2e, OpenAPI, and build checks. Report exact commands/results. Do not edit backend files merely to clean unrelated pre-existing formatting.

### Flavor APK matrix

```bash
for FLAVOR in dev staging prod; do
  flutter build apk --debug --flavor "$FLAVOR" \
    --dart-define=APP_FLAVOR="$FLAVOR" \
    --dart-define-from-file="config/$FLAVOR.json"
done
```

Equivalent PowerShell commands are acceptable on Windows. Restore all temporary local Gradle/Kotlin changes before diff/archive.

### Emulator integration

Run the committed integration test on a real Android emulator against the dev backend and fixture inbox. Keep fixture values secret. Report only device id, command shape with redacted secret argument, exit result, and high-level flow.

### Visual verification

- inspect every changed/new golden;
- confirm Material Icons and Vazirmatn render;
- confirm no clipping/missing glyphs;
- compare WP02 theme golden hashes before/after;
- list every intentionally changed golden;
- never accept an unexplained golden diff.

### GitHub Actions

Attempt or observe the PR checks, but while hosted runners remain unavailable report:

```text
not executed — zero-step hosted-runner allocation failure; owner-approved temporary deviation
```

Do not claim green CI.

A missing local emulator, backend, fixture key, JDK, Gradle setup, or required platform tool is not automatically approved. Resolve it where possible or request a specific owner deviation.

---

## STEP 4 — CHECK IN AND EXTERNAL REVIEW

1. Work only on the dedicated branch.
2. Use atomic Conventional Commits. Example logical groups:

```text
test(router): complete guest and authenticated route matrix
fix(router): preserve validated auth cold-start destinations
test(shell): harden rtl dock and module interactions
test(ui): cover narrow large-text accessible route states
test(golden): add m03 visual hardening baselines
test(integration): harden composed guest and authenticated flow
docs(m03-wp07): close integration and visual transition
```

Use only the commits actually justified by the diff.

3. Push and open/update one PR.
4. Do not change CI workflows because runners are unavailable.
5. Create a full clean source archive from the exact PR-head commit:
   - tracked source/documentation only;
   - no `.git`;
   - no build output/cache;
   - no secrets/local config;
   - no patch-only or changeset-only substitute;
   - archive comment/manifest identifies the exact SHA according to current repository convention.
6. Report:
   - PR URL;
   - branch;
   - base SHA;
   - exact PR-head implementation SHA;
   - archive filename;
   - local command results;
   - emulator/device result;
   - GitHub Actions zero-step status without claiming pass;
   - changed/new golden list and visual inspection result;
   - production files changed;
   - architecture/ADR/dependency/backend/platform impact;
   - deviations/blockers.
7. Stop for external review.
8. Do not update inventory.
9. Do not merge.

---

## TERMINATING INVENTORY AND LOCAL-MERGE WORKFLOW — ONLY AFTER EXTERNAL APPROVAL

While hosted Actions remain unavailable, use the owner-approved local workflow.

After the exact archive/PR head is externally approved:

1. Apply requested review fixes on the same branch, if any.
2. Rerun all applicable local Flutter/backend gates, APK matrix, and emulator integration.
3. Update `docs/project_inventory.md` exactly once for:

```text
M03_WP07 — Integration and visual hardening
```

4. Record only:
   - PR number;
   - final externally reviewed implementation SHA from before the inventory commit;
   - completed route/visual/accessibility/integration scope;
   - actual local verification results;
   - temporary deviation: GitHub Actions unavailable because free hosted-runner capacity was exhausted; owner approved complete local verification;
   - remaining O2–O6, O7 external-assets remainder, and O8 decisions as applicable;
   - M03 transition complete;
   - exact next planning action: owner selects/specifies **M04 — First specialized production module**.
5. Do not record the inventory commit SHA, merge SHA, branch status, or pending-merge wording.
6. Commit the inventory update using a Conventional Commit.
7. Rerun applicable local gates after the inventory commit.
8. Merge locally into updated `main` with a normal no-fast-forward merge commit:

```bash
git switch main
git pull --ff-only origin main
git merge --no-ff <m03-wp07-branch>
```

9. Push `main`; keep PR/history intact.
10. Confirm local main equals `origin/main` and the working tree is clean.
11. Do not create a post-merge inventory revision.
12. When GitHub-hosted runner capacity later resets, run repository-wide `backend` and `quality` CI on current main; do not rewrite completed inventory entries.

If hosted runners become available before completion, return to the standard `AGENTS.md` CI/inventory/merge workflow instead.

---

## REPORT BACK

Return a concise report containing:

- **Status:** done / partial / blocked.
- **Base commit SHA.**
- **Branch.**
- **Final implementation commit SHA.**
- **PR URL.**
- **Full source archive filename.**
- **Summary of hardening delivered.**
- **Production files changed and why.**
- **Test-only files/harnesses changed.**
- **Route-state matrix result.**
- **Return-destination policy result.**
- **Dock/module fixture result.**
- **320dp / 2.0 / semantics result.**
- **Contrast result, including any measured failing pair.**
- **Changed/new golden files and confirmation WP02 theme goldens are unchanged.**
- **Integration flow/device/result.**
- **Every command with pass/fail/not-run.**
- **GitHub Actions:** explicitly not executed/zero-step under approved temporary deviation unless runners actually returned.
- **Architecture/ADR impact.**
- **Dependency/backend/platform/CI workflow impact.**
- **Approved deviations.**
- **Remaining blockers or owner decisions.**
- **Inventory/merge status:** held for external approval.
- **After completion:** M03 complete; owner must select/specify M04 module before implementation.

Never report a gate as passed unless it actually ran. Never expose secrets, fixture keys, OTPs, phone numbers, emails, account IDs, tokens, or personal/test credentials.
