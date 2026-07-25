# Laforika M03_WP01 — Guest-First Access and UI Foundation Documentation Prompt

## TASK

Deliver **M03_WP01 — Documentation and decision freeze** for Laforika.

Record the owner-approved direction established in the UI-design discussion before any implementation work begins:

1. Laforika launches into a guest-accessible Home after session restoration; authentication is required only for protected capabilities.
2. Phone-number OTP is the only user-facing sign-in method.
3. Email is optional profile/contact data, not an authentication credential.
4. The application adopts a Windows 11 / Fluent-inspired—but Laforika-owned—semantic light and dark visual system, with the system appearance as the default.
5. The adaptive RTL application shell, module-selection rules, search behavior, internal tabs, floating bottom dock, Profile, Settings, and Notifications behavior are frozen as documented product contracts.
6. The approved implementation sequence is split into M03_WP02–M03_WP07 and recorded without implementing any of them in this package.

This is a **documentation-only architecture-change package**. Do not modify production code, tests, generated files, dependencies, backend schema, API contracts, CI, or platform configuration.

---

## WHY

The current repository architecture and M1/M2 behavior were designed around:

- an authentication-gated Home;
- phone OTP plus email/password credentials;
- an unresolved placeholder visual identity;
- an earlier Home/discovery-shell contract that does not yet capture the final navigation states agreed by the owner.

Those assumptions are now intentionally changed. The repository needs one coherent and reviewable source of truth before Cursor implements the changes across separate work packages.

The outcome that matters is that future coding agents can implement M03_WP02–M03_WP07 without reconstructing decisions from conversation history, inventing missing behavior, silently preserving deprecated email/password flows, or creating speculative infrastructure.

---

## MILESTONE

**M03_WP01 — Documentation and decision freeze.**

This package documents a controlled transition from the current implementation into the approved guest-first, phone-only, adaptive-shell product direction.

It does **not** itself satisfy the implementation work in M03_WP02–M03_WP07.

---

## REVIEWED BASELINE AND MANDATORY PRECONDITION

The supplied source archive is evidence for inspection, not permission to skip repository verification. At the time this prompt was prepared, the inspected archive contained:

- architecture v1.3;
- accepted ADRs 0001–0007;
- custom NestJS/PostgreSQL authentication;
- phone OTP and email/password flows;
- an authenticated M2 Home/discovery implementation;
- a project inventory whose visible current baseline may not yet contain the terminating M2 entry.

Do not assume that archive state is the current Git baseline.

Before creating the M03_WP01 branch:

1. Read `AGENTS.md` fully, especially its terminating milestone workflow.
2. Confirm the current branch is `main`/`master`, clean, and synchronized with the remote.
3. Confirm the preceding M2 work package has completed its terminating workflow:
   - final reviewed implementation commit exists;
   - applicable CI is green;
   - one terminating M2 entry exists in `docs/project_inventory.md`;
   - the M2 PR is merged;
   - the local default branch includes that merged result.
4. Confirm there are no unrecorded source or documentation changes.
5. If M2 is not fully merged and inventoried, **stop**. Report that M2 closure must be completed first. Do not combine M2 closure with M03_WP01.
6. Do not start this package from an old M1 branch, the M2 implementation branch, an extracted archive without Git history, or a dirty working tree.

Record the actual base commit SHA in the plan/report. Do not invent or reuse a SHA from this prompt.

---

## OWNER DECISIONS — AUTHORITATIVE FOR THIS PACKAGE

### A. Guest-first access

- The app must not require login on first launch.
- Startup still restores any existing session using the existing deterministic `unknown`/hydration state.
- When restoration completes:
  - an authenticated user enters Home as authenticated;
  - an unauthenticated user enters the same public Home as a guest.
- Home is public.
- Public modules and public content are explorable without authentication.
- Authentication is required only at the boundary of a protected capability.
- Protected destinations preserve a validated internal return destination and continue there after successful login.
- Client route guards remain UX only; backend authorization remains authoritative.
- No fake guest account, anonymous backend principal, guest access token, or guest database scope is introduced by this decision.

### B. Phone-only authentication

- The custom NestJS + PostgreSQL backend direction remains approved.
- The provider-neutral Flutter `AuthState` and secure session boundary remain approved.
- Phone-number OTP is the **only user-facing sign-in credential**.
- The auth-method chooser is deprecated and must be removed in M03_WP03.
- Email/password login is deprecated and must be removed in M03_WP03.
- Password reset is deprecated and must be removed in M03_WP03.
- Email becomes optional profile/contact data only.
- Email must not silently create a login credential.
- The verified phone number is the account's primary login identity.
- Phone number is read-only in the ordinary profile-edit form. A future change-phone security flow is separate and not approved here.
- Existing RS256 access-token, opaque rotating refresh-token, session-revocation, replay-detection, secure-storage, redaction, and backend-authority decisions remain unchanged.
- Real-account builds remain controlled-test-only until O8 is resolved.

### C. Data-migration safety

M03_WP01 changes documentation only; it must not design a destructive shortcut.

Document these constraints for M03_WP03:

- Never reset or silently delete a database to remove email/password support.
- Use committed forward Prisma migrations when schema changes are required.
- Inspect the actual data model and test fixtures before deciding which credential fields/tables can be removed.
- The project has not been approved for external real-account distribution, but that does not authorize silent data loss.
- If any non-test account exists with only an email/password credential and no verified phone, M03_WP03 must stop for an explicit owner migration decision rather than orphaning the account.
- Historical migrations remain immutable.

### D. Windows 11 / Fluent-inspired Laforika visual direction

- Use Microsoft Windows 11 / Fluent as visual inspiration: restrained accent usage, calm neutral surfaces, rounded geometry, subtle depth, and separate light/dark neutral ramps.
- Do not reproduce Windows literally.
- Do not add Microsoft assets, proprietary icons, copied artwork, or a Fluent UI framework dependency.
- Implement the future UI through Laforika-owned semantic tokens and Flutter Material 3 `ThemeData`.
- Appearance options are `System`, `Light`, and `Dark`.
- Default appearance is `System`.
- Vazirmatn remains the Persian UI typeface.
- Persian `fa-IR` and RTL remain first-class from the application root.

Freeze this Laforika semantic palette in the design documentation:

| Semantic role | Light theme | Dark theme |
|---|---:|---:|
| App background | `#F3F3F3` | `#202020` |
| Primary surface | `#FFFFFF` | `#2C2C2C` |
| Secondary surface | `#F9F9F9` | `#252525` |
| Elevated surface | `#FFFFFF` | `#323232` |
| Primary text | `#242424` | `#FFFFFF` |
| Secondary text | `#616161` | `#C7C7C7` |
| Border / divider | `#E5E5E5` | `#454545` |
| Brand accent | `#0067C0` | `#60CDFF` |
| Content on brand accent | `#FFFFFF` | `#003E5A` |
| Subtle selection | `#E5F1FB` | `#0F3A4F` |
| Error | `#C42B1C` | `#FF99A4` |
| Success | `#107C10` | `#6CCB5F` |

These are semantic design values, not permission to hardcode colors in feature widgets.

### E. Application-shell behavior

#### Home state

- Home is selected on first app load after session restoration.
- No module is selected while Home is active.
- No module-internal tabs appear while Home is active.
- The Home body owns Home content; documentation examples may use a generic `Home` label, but production must not ship dummy content.
- Home search is application-wide across content that the current user is allowed to access.

#### Module state

- Selecting a module clears the selected state from the bottom dock.
- The selected module is highlighted in the top module strip.
- Module-internal tabs appear only when a module is active.
- The first internal tab is selected when entering a module unless a reconstructable deep link selects another valid tab.
- Search within an active module is scoped to that module.
- The main body renders the selected module tab/page.
- Documentation diagrams and state examples must use generic labels such as `Module 1` and `Item 1`; do not invent production modules or product content.

#### Adaptive module strip

- The top module strip is horizontally scrollable and RTL-aware.
- Expanded state displays each module icon and localized title in a larger rounded item.
- As the main content scrolls upward, module items transition into a compact state and remove their icons.
- Compact state keeps localized module titles in smaller rounded chips.
- The transition must preserve the selected module and horizontal position.
- Module ordering, pinning, recents, personalization, and persistence are deferred until a concrete need; do not create a speculative module-registry framework.

#### Header rows on Home/module surfaces

Order from top to bottom:

1. horizontally scrollable adaptive module strip;
2. search field;
3. horizontally scrollable internal tabs **only when a module is selected**;
4. main page body.

The Home/module discovery header does not automatically appear on Chat, Profile, Settings, or Notifications; those destinations use their own focused page headers.

#### Floating bottom dock

- Fixed near the bottom safe area.
- Centered rounded capsule.
- Slightly translucent, theme-aware surface with a thin border and restrained elevation.
- Blur may be used only as a progressive enhancement; readability cannot depend on blur support.
- Contains exactly three icon-only destinations in the current approved shell:
  - Home on the visual right;
  - Chat in the center;
  - Profile on the visual left.
- Every icon-only action has a localized semantic label and at least a 48dp touch target.
- Tapping an icon navigates directly.
- Horizontal swiping across the dock follows visual RTL adjacency:
  - swipe toward the left: `Home → Chat → Profile`;
  - swipe toward the right: `Profile → Chat → Home`.
- A swipe must not wrap from one end to the other.
- Home is selected only on Home.
- Chat is selected on the Chat destination, including its protected-login state.
- Profile is selected on Profile, including the guest phone-login state.
- No bottom-dock destination is selected while a module is active.
- Selected state must not rely on color alone; use a combination of accent, shape/indicator, and icon treatment.

### F. Chat access

- Chat is represented in the approved bottom dock.
- Chat is a protected capability.
- A guest tapping Chat is sent directly into the phone OTP flow with the Chat destination preserved.
- After successful login, navigation resumes to Chat.
- M03_WP01 does not create a Chat feature, route, placeholder screen, backend, or messaging infrastructure.
- If no real Chat route exists when M03_WP04 is implemented, M03_WP04 must not ship a dead dock action; it must stop for a scoped product decision or omit the unavailable action until its real destination exists.

### G. Profile, Settings, and Notifications

#### Guest Profile

- Tapping Profile while unauthenticated keeps Profile selected in the bottom dock.
- Show the phone-number OTP login experience directly.
- Do not show an auth-method chooser.
- Do not offer email/password login.
- Settings remains accessible to guests.

#### Authenticated Profile

- Show an avatar placeholder; avatar upload is not approved yet.
- Show and allow editing of:
  - first name;
  - last name;
  - optional email contact field.
- Show the verified phone number as read-only with a verification indicator.
- Provide explicit save, validation, loading, error, and success states.
- Keep Logout and account/security actions lower in the page hierarchy, not as the primary header action.
- Validation lengths and backend profile-field constraints must be resolved from the real M03_WP05 API/domain design; M03_WP01 must not invent arbitrary limits.

#### Profile header

In RTL directional terms:

- Settings appears at `start` — visually top-right.
- Notifications appears at `end` — visually top-left.
- Use directional layout APIs, never hardcoded left/right placement in implementation guidance.
- Notifications may display an unread badge when real notification data exists.

#### Settings

- Guest-accessible.
- Initially documents:
  - appearance: System / Light / Dark;
  - app/about information;
  - account/security and Logout only when authenticated.
- Language switching is not introduced; Persian `fa-IR` remains the only configured locale.
- No speculative settings catalog.

#### Notifications

- Protected capability.
- Guests enter phone OTP with Notifications preserved as the destination.
- Initial implemented states will be loading, empty, error, and data when a real notification source exists.
- O3 remains unresolved.
- Do not add FCM, a regional push SDK, permissions, background handlers, tokens, or push-provider configuration in M03_WP01 or M03_WP06 unless O3 is separately resolved.

For navigation-context selection, document Profile as the parent bottom-dock context for its subordinate Profile/Login/Settings/Notifications routes unless inspection reveals an existing route contract that makes this impossible. If there is a conflict, report it before finalizing rather than silently choosing a different rule.

### H. Motion, accessibility, and responsive behavior

Freeze the following design constraints:

- Standard state transitions: approximately 180–250ms.
- Motion explains state changes; avoid decorative bouncing, large parallax, or long transitions.
- Respect reduced-motion/system accessibility preferences where Flutter exposes them.
- 8dp spacing foundation with documented semantic spacing tokens.
- Normal page padding starts at 16dp.
- Standard component corner radius: 12–16dp.
- Floating dock radius: approximately 24–28dp.
- Minimum touch target: 48dp.
- Target WCAG AA contrast.
- Support text scaling without fixed-height clipping; verify at 2.0 text scale.
- Phone-first responsive behavior; verify at 320dp width.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`, `end`, and mirrored directional affordances.
- Theme/state behavior must be verified in both light and dark modes and in Persian RTL.
- Translucency cannot reduce text/icon contrast below accessibility requirements.

---

## ARCHITECTURE DECISION RECORDS

Create two new accepted ADRs. Use the next available sequential numbers after inspecting the repository. With the expected v1.3/ADR-0007 baseline, they should be:

### `docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md`

Required content:

- Context: authenticated-first and dual-credential assumptions no longer match the approved product behavior.
- Decision:
  - guest-accessible startup/Home;
  - capability-level route protection;
  - direct phone OTP entry;
  - email as optional profile data;
  - existing provider-neutral session and custom backend/token security retained;
  - protected return-destination behavior retained;
  - migration/data-safety guardrails;
  - O8 still gates external distribution.
- Relationship to prior ADRs:
  - ADR-0006 remains authoritative for the provider-neutral Flutter session boundary;
  - ADR-0007 remains authoritative for backend ownership, NestJS/PostgreSQL topology, access/refresh-token security, session revocation, fixture delivery, and server authority;
  - ADR-0008 **supersedes only** ADR-0007's phone-plus-email/password credential choice and any authenticated-first product implication.
- Alternatives rejected:
  - mandatory login at launch;
  - email/password plus phone choice;
  - anonymous backend guest accounts;
  - keeping deprecated UI routes hidden but active indefinitely;
  - destructive database reset.
- Consequences and revisit conditions.

Do not rewrite ADR-0006 or ADR-0007. Accepted ADR history is immutable.

### `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`

Required content:

- Context: O7 placeholder theme and future module growth require a stable, RTL-first shell and visual foundation.
- Decision:
  - Windows 11 / Fluent-inspired but Laforika-owned design direction;
  - exact semantic light/dark palette from this prompt;
  - Material 3 and Laforika semantic tokens rather than a Fluent framework;
  - System/Light/Dark with System default;
  - adaptive module strip;
  - contextual internal tabs;
  - search scoping;
  - floating three-destination bottom dock and selection rules;
  - Profile/Settings/Notifications directional header rules;
  - accessibility, motion, RTL, and responsive constraints;
  - no speculative module framework.
- O7 status:
  - resolved for the in-app visual system, palette, typography direction, and shell behavior;
  - logo, launch icon, store icon, marketing identity, illustrations, and external brand assets remain deferred.
- Alternatives rejected:
  - literal Windows clone;
  - Fluent UI package dependency;
  - light-only theme;
  - module tabs on Home;
  - keeping Home selected while a module is active;
  - unbounded static module row;
  - dead placeholder module destinations.
- Consequences and revisit conditions.

Update `docs/architecture/adr/README.md` with both ADRs and accurately describe ADR-0008 as a partial supersession of the credential decision in ADR-0007 without changing the old accepted ADR file.

---

## DESIGN SPECIFICATIONS

Create `docs/design/` only because this task introduces concrete approved design specifications.

### `docs/design/UI_FOUNDATION.md`

It must be concise enough to use, but complete enough to implement consistently. Include:

1. authority and relationship to `ARCHITECTURE.md`, ADR-0009, and `AGENTS.md`;
2. brand attributes: calm, trustworthy, culturally familiar, modern, useful;
3. Windows 11 / Fluent inspiration boundaries;
4. complete semantic light/dark palette table from this prompt;
5. rules for semantic tokens and prohibition on raw feature colors;
6. System/Light/Dark behavior and System default;
7. Vazirmatn typography roles and approved weights;
8. spacing, radius, border, elevation, and translucency principles;
9. icon rules: consistent family, outline inactive, stronger/filled selected, RTL mirroring, semantics;
10. motion durations and reduced-motion behavior;
11. accessibility and contrast requirements;
12. responsive breakpoints/verification targets without adding a heavy framework;
13. component state checklist:
    - default;
    - selected;
    - pressed;
    - focused where applicable;
    - disabled;
    - loading;
    - empty;
    - error;
    - offline when relevant;
    - long text;
    - large text;
    - light and dark;
14. explicit deferred items: final logo, store assets, illustrations, module-specific palettes, push-provider visuals.

Do not claim that these tokens are already implemented.

### `docs/design/APP_SHELL.md`

Include:

1. shell scope and hierarchy;
2. RTL visual order;
3. Home/module header row order;
4. expanded and compact module-strip behavior;
5. Home search vs module search scope;
6. contextual internal-tab visibility;
7. floating dock structure, selection rules, and swipe mapping;
8. public/protected destination behavior;
9. Profile guest/authenticated states;
10. Settings and Notifications access policy;
11. route-state matrix;
12. four canonical visual states using generic labels only:
    - Home, expanded header;
    - Home, compact header;
    - Module 1 / Item 1, expanded header;
    - Module 1 / Item 1, compact header;
13. additional route states for Chat guest/authenticated and Profile guest/authenticated;
14. accessibility/semantics requirements;
15. implementation boundaries:
    - real modules only in production;
    - no dummy cards or dead destinations;
    - no speculative registry/persistence;
    - feature route barrels remain the integration boundary;
16. a clear distinction between approved behavior and implementation work deferred to M03_WP02–M03_WP07.

Use tables and simple text diagrams where they improve precision. Do not embed generated mockup images or external copyrighted assets in this package.

---

## ARCHITECTURE DOCUMENT UPDATE

Update `docs/architecture/ARCHITECTURE.md` as the single source of truth.

### Versioning

- Inspect the current version.
- If it is still v1.3, bump it to **v1.4**.
- Otherwise use the next appropriate minor version and report why.
- Keep status `FROZEN` after incorporating these approved decisions.
- Use the actual update date.

### Required changes

Reconcile at least these areas:

- assumptions:
  - remove the assumption that login is required to enter the app;
  - retain authentication as a requirement for protected capabilities;
  - update the visual/branding assumption;
- load-bearing decision table:
  - add ADR-0008 and ADR-0009;
- repository shape:
  - add `docs/design/` as approved documentation, not code infrastructure;
- navigation:
  - guest-first redirect matrix;
  - public/protected capability rules;
  - validated return destinations;
  - shell selection and module-integration behavior at the appropriate level;
- authentication:
  - phone OTP only;
  - email as profile contact data;
  - retained token/session security;
  - migration guardrails;
- localization/UI/accessibility:
  - semantic light/dark palette;
  - System default;
  - Vazirmatn;
  - RTL shell behavior;
  - motion, text scale, touch target, translucency fallback;
  - references to the two design specifications;
- security/privacy:
  - retain O8 controlled-test-only gate;
  - no guest token/account;
  - profile-data treatment remains subject to O8 lifecycle policy;
- testing strategy:
  - future route matrix includes guest/authenticated/public/protected states;
  - light/dark RTL goldens;
  - 320dp and 2.0 text-scale checks;
  - dock swipe and module-header state coverage;
- roadmap:
  - preserve completed milestone history;
  - document M03_WP01–M03_WP07 as the approved dependency-ordered transition plan;
  - keep M04/M05 future-module direction after this transition (M03 is this transition program);
- owner decisions:
  - O1 remains resolved to custom NestJS/PostgreSQL, amended by ADR-0008 to phone OTP only;
  - O7 is partially resolved for in-app visual foundation and shell; external brand assets remain open;
  - O2–O6 and O8 remain unresolved unless already resolved by another approved change on the actual branch;
- freeze record and change control:
  - explain the two new ADRs and their partial supersession relationship.

### Controlled transition note

Because M03_WP01 changes the authoritative target before code packages implement it, add a concise, explicit transition note:

- current dual-auth/auth-gated/shell code may temporarily differ in the exact areas assigned to M03_WP02–M03_WP07;
- this is a known, bounded migration gap, not permission for new code to continue the deprecated direction;
- each follow-up package closes a named gap;
- do not falsely claim the target behavior is already implemented.

Do not weaken the rule that architecture contradictions outside this approved transition are defects.

---

## AGENTS.md UPDATE

Update root `AGENTS.md` only where necessary to make future implementation prompts deterministic. Keep it operational; do not duplicate all design prose.

Required focused updates:

- frozen project configuration:
  - guest-first access model;
  - phone OTP only;
  - Fluent-inspired semantic light/dark direction with System default;
- required inspection:
  - UI/shell tasks must read `docs/design/UI_FOUNDATION.md` and `docs/design/APP_SHELL.md`;
- navigation:
  - Home/public routes are guest-accessible;
  - protected capability redirects preserve validated destinations;
  - Home selection, module selection, and contextual-tab rules;
- authentication:
  - direct phone OTP;
  - no email/password login or password-reset implementation;
  - email is profile data;
  - retained session/token/security rules;
- localization/RTL/UI/accessibility:
  - semantic theme tokens;
  - light/dark/System;
  - RTL shell/directional APIs;
  - future golden/state requirements;
- guardrails:
  - no new email/password credential UI or backend behavior unless a future approved ADR changes direction;
  - no guest backend identity/token invented;
  - no Fluent framework dependency;
  - no dead placeholder modules or speculative module registry;
- testing/reporting:
  - ensure future packages report guest/auth route matrix and visual-state verification where applicable.

Preserve existing Git, inventory, security, backend, and quality-gate rules.

---

## README UPDATE

Update root `README.md` for stable operator/contributor understanding:

- describe Laforika as Persian-first, guest-explorable, with phone OTP required only for protected capabilities;
- describe System/Light/Dark and the Fluent-inspired Laforika direction as the approved target, not necessarily fully implemented yet;
- link `docs/design/UI_FOUNDATION.md` and `docs/design/APP_SHELL.md`;
- update the roadmap to show the M03_WP01–M03_WP07 transition sequence and the exact next package after M03_WP01;
- retain real-account controlled-testing/O8 warning;
- retain route-registry boundaries;
- make current implementation vs approved target explicit during the transition;
- do not rewrite historical completed-work claims.

Do not edit prior versioned milestone prompts to make history look current. They are delivery records.

---

## WORK-PACKAGE ROADMAP TO DOCUMENT

Document this dependency order consistently in architecture, README, and the M03_WP01 prompt itself:

### M03_WP01 — Documentation and decision freeze

- ADR-0008 and ADR-0009;
- architecture update;
- UI foundation and shell specifications;
- no implementation.

### M03_WP02 — Light/dark theme foundation

- semantic theme tokens;
- Material 3 light and dark themes;
- System/Light/Dark selection;
- System default;
- persistence through the approved preferences facade/dependency;
- typography, spacing, radius, border, elevation tokens;
- light/dark RTL visual tests;
- no routing/auth/shell redesign.

### M03_WP03 — Guest-first routing and phone-only authentication

- Home/public routes available to guests;
- direct phone OTP;
- protected return destinations;
- remove method chooser, email/password login, password reset;
- backend/OpenAPI/Prisma migration as actually required;
- email becomes profile data;
- forward, non-destructive migration;
- no shell redesign.

### M03_WP04 — Adaptive application shell

- adaptive RTL module strip;
- search row;
- contextual internal tabs;
- floating bottom dock;
- correct selection states;
- dock swipe behavior;
- real registered destinations only;
- no dead Chat/module placeholder.

### M03_WP05 — Profile vertical slice

- guest direct-phone-login state;
- authenticated profile;
- first name, last name, optional email;
- read-only verified phone;
- Settings/Notifications header actions;
- backend profile contract/endpoints as required;
- save/error/loading/success/logout coverage.

### M03_WP06 — Settings and Notifications

- guest-accessible appearance settings;
- System/Light/Dark selector;
- About/account sections;
- protected Notifications route and real states;
- no push SDK while O3 is unresolved.

### M03_WP07 — Integration and visual hardening

- complete guest/auth/public/protected route matrix;
- return-destination coverage;
- light/dark RTL goldens;
- 320dp width;
- 2.0 text scale;
- semantics;
- dock swipe;
- expanded/compact module header;
- documentation reconciliation.

Exact next package after M03_WP01: **M03_WP02 — Light/dark theme foundation**.

---

## SCOPE

### In scope

- `docs/architecture/ARCHITECTURE.md`
- new ADR-0008
- new ADR-0009
- `docs/architecture/adr/README.md`
- new `docs/design/UI_FOUNDATION.md`
- new `docs/design/APP_SHELL.md`
- root `AGENTS.md`
- root `README.md`
- this exact prompt committed as:
  - `docs/prompts/M03_WP01_GUEST_FIRST_UI_FOUNDATION_DOCUMENTATION_PROMPT.md`
- `docs/project_inventory.md` **only at the terminating inventory step after review and final green CI**

### Out of scope / do not touch

- any file under `lib/`
- any file under `test/` or `integration_test/`
- any file under `backend/`, including Prisma migrations and OpenAPI
- `pubspec.yaml` or lockfiles
- generated localization/DTO files
- ARB strings
- environment/config files
- CI workflows
- Android/iOS configuration
- assets, fonts, icons, images, launch screens
- previous accepted ADR contents
- previous milestone prompts
- historical project-inventory entries
- version/build number
- source-code formatting/refactoring
- implementation of M03_WP02–M03_WP07
- creation of dummy modules, Chat, Profile, Settings, Notifications, or Search features
- new dependencies
- Git history rewriting or destructive repository operations

---

## RELEVANT CONTEXT — READ FULLY BEFORE EDITING

- `AGENTS.md`
- `README.md`
- `docs/project_inventory.md`
- `docs/architecture/ARCHITECTURE.md`
- every ADR under `docs/architecture/adr/`
- `docs/architecture/adr/README.md`
- `docs/prompts/M1_AUTHENTICATION_VERTICAL_SLICE_PROMPT.md`
- `docs/prompts/M2_HOME_DISCOVERY_SHELL_PROMPT.md`
- `.github/workflows/ci.yml`
- `pubspec.yaml`
- `analysis_options.yaml`
- `l10n.yaml`
- `lib/app/app.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/routes.dart`
- `lib/core/auth/`
- `lib/core/theme/`
- `lib/features/auth/`
- `lib/features/home/`
- `lib/l10n/app_fa.arb`
- existing router, auth, Home, theme, and integration tests
- `backend/README.md`
- `backend/package.json`
- `backend/prisma/schema.prisma`
- `backend/openapi/openapi.json`

The code/backend inspection is required only to accurately document current-vs-target behavior. Do not edit those files.

---

## STEP 0 — INSPECT

1. Complete the mandatory precondition and baseline verification.
2. Read all required context fully.
3. Identify every current statement that conflicts with the newly approved direction.
4. Separate documents into:
   - authoritative current architecture;
   - immutable historical ADR/prompt records;
   - operational contributor guidance;
   - current implementation/operator documentation.
5. Do not “fix” immutable historical records.
6. Confirm the next ADR numbers and architecture version from the actual branch.
7. Confirm whether O2–O8 changed elsewhere; do not overwrite newer approved decisions.
8. Confirm whether a docs link checker or markdown linter already exists. Do not add one for this package.
9. Report any blocker before editing, especially:
   - M2 not merged/inventoried;
   - unexpected newer ADRs;
   - architecture version drift;
   - an already approved conflicting owner decision;
   - dirty/untracked source changes.

---

## STEP 1 — PLAN

Provide a concise plan containing:

- verified base branch and SHA;
- current architecture version and next version;
- current highest ADR number and proposed new numbers;
- exact file surface;
- how immutable historical documents will be preserved;
- how current-vs-target transition gaps will be labeled;
- documentation validation commands;
- proposed atomic commits;
- explicit confirmation that no production/backend/test/generated file will change.

Proceed without waiting unless a blocker above exists.

---

## STEP 2 — IMPLEMENT

- Keep the diff documentation-only.
- Preserve repository terminology and document hierarchy.
- Make `ARCHITECTURE.md` authoritative and internally coherent.
- Keep ADRs focused on decisions and rationale; keep design specs focused on implementable UI behavior.
- Avoid copying the same full palette/rules into every file; use references where appropriate while keeping critical guardrails in `AGENTS.md`.
- Explicitly distinguish:
  - current implementation;
  - approved target behavior;
  - deferred implementation package.
- Never claim M03_WP02–M03_WP07 behavior is implemented.
- Do not invent backend API details, validation limits, database migrations, feature names, or module content.
- Do not use “left/right” in implementation rules where directional `start/end` is required; parenthetical visual clarification is allowed.
- Do not edit generated files.
- Commit this prompt exactly at the required `docs/prompts/` path.

Suggested logical commits, adjusted only if the actual diff supports a better atomic split:

1. `docs(architecture): define guest-first phone-only access`
2. `docs(design): define visual foundation and adaptive shell`
3. `docs(project): align contributor and roadmap guidance`

Do not create the terminating inventory commit until after archive review and final implementation-doc review.

---

## ACCEPTANCE CRITERIA

- [ ] Work starts from clean synchronized default branch after terminating M2 merge/inventory.
- [ ] No production, backend, test, generated, dependency, configuration, CI, platform, or asset file changes.
- [ ] Two new accepted ADRs exist with the correct sequential numbers.
- [ ] ADR-0008 precisely supersedes only the dual-credential/authenticated-first portions of ADR-0007.
- [ ] ADR-0006 and ADR-0007 contents remain unchanged.
- [ ] ADR index is updated accurately.
- [ ] Architecture version is bumped and remains `FROZEN`.
- [ ] Architecture states guest-accessible Home and capability-level protection.
- [ ] Architecture states phone OTP as the only login credential.
- [ ] Architecture states email is optional profile data, not a credential.
- [ ] Existing token/session/security decisions are preserved.
- [ ] Migration/data-safety constraints are documented.
- [ ] Exact semantic light and dark palettes are documented.
- [ ] System/Light/Dark with System default is documented.
- [ ] O7 is marked partially resolved for in-app visual design while external brand assets remain open.
- [ ] `UI_FOUNDATION.md` exists and covers theme, type, spacing, shape, elevation, icons, motion, accessibility, responsive behavior, and states.
- [ ] `APP_SHELL.md` exists and covers all Home/module/dock/Profile/Settings/Notifications rules.
- [ ] Home states have no internal tabs and no selected module.
- [ ] Module states clear bottom selection and select the first internal tab.
- [ ] Floating dock selection and RTL swipe mapping are unambiguous.
- [ ] Chat and Notifications are documented as protected without speculative implementations.
- [ ] Guest Profile goes directly to phone OTP and keeps Profile selected.
- [ ] Authenticated Profile fields and directional header actions are documented.
- [ ] README and AGENTS align with the new architecture target.
- [ ] Prior milestone prompts and historical inventory entries remain untouched.
- [ ] M03_WP02–M03_WP07 dependency order is documented consistently.
- [ ] Exact next package is M03_WP02 — Light/dark theme foundation.
- [ ] All internal links resolve.
- [ ] No stale non-historical statement presents authenticated-first or email/password as the approved target.
- [ ] A bounded transition note prevents documentation from falsely claiming code already conforms.
- [ ] This exact prompt is committed under `docs/prompts/`.

---

## REQUIRED VALIDATION

Run and report actual results.

### Documentation validation

- [ ] `git diff --check`
- [ ] Inspect `git diff --stat`.
- [ ] Inspect the complete diff.
- [ ] Verify every new/changed relative Markdown link resolves.
- [ ] Verify the ADR index numbers/titles/statuses match the actual files.
- [ ] Verify `ARCHITECTURE.md`, `README.md`, `AGENTS.md`, and both design specs use consistent terminology.
- [ ] Search changed current-facing docs for stale claims such as:
  - authenticated Home as the target;
  - phone OTP plus email/password as the target;
  - O7 entirely unresolved;
  - placeholder light-only theme as the target.
- [ ] Exclude immutable historical ADRs, previous prompts, and historical inventory entries from stale-claim remediation.
- [ ] `git status --short` contains only intended documentation files.

### Repository quality gates

This is docs-only, so source tests are not logically changed. Follow the actual repository policy:

- Run any locally required docs/check commands that already exist.
- Do not add a Markdown dependency or formatter.
- If Flutter/backend gates are not run locally because the diff is documentation-only, mark each as **not run — docs-only**, not passed.
- PR CI must still complete successfully according to the repository workflow.
- Do not claim a gate passed unless it ran.

### Generated output

- No generation command should produce a diff.
- Do not hand-edit generated files.
- If any generated or source file becomes dirty, stop and investigate; do not include it.

---

## STEP 3 — CHECK IN AND REVIEW

Check-in mode: **branch + atomic commits + PR + reviewed archive**.

- Branch: `docs/guest-first-ui-foundation`
- Never commit directly to `main`/`master`.
- Use Conventional Commits.
- Push the branch and open/update one PR using the `AGENTS.md` PR body.
- In the PR notes, state clearly:
  - documentation-only architecture change;
  - M03_WP02–M03_WP07 are not implemented;
  - temporary known code-to-target gaps are documented;
  - no accepted historical ADR was rewritten.
- Wait for CI.
- Create a clean tracked-source archive from the exact PR-head implementation-documentation commit.
- Exclude `.git`, caches, build outputs, secrets, local configuration, and generated temporary files.
- Report archive filename and exact commit SHA.
- Stop for owner/external review.
- Do not update the inventory or merge before review.

---

## STEP 4 — TERMINATING INVENTORY UPDATE

After owner/external review fixes are complete and final applicable CI is green:

1. Update `docs/project_inventory.md` exactly once on the same branch.
2. Do not rewrite earlier entries.
3. Add one completed-check-in entry for:
   - **M03_WP01 — Documentation and decision freeze**;
   - PR number;
   - final reviewed implementation-documentation commit SHA, meaning the last reviewed commit before the inventory update;
   - completed documentation scope;
   - verification results;
   - remaining decisions/limitations:
     - O2–O6 and O8 remain open unless actual approved repository state says otherwise;
     - O7 external brand assets remain deferred;
     - M03_WP02–M03_WP07 implementation remains pending;
   - exact next package: **M03_WP02 — Light/dark theme foundation**.
4. Do not record the inventory commit SHA, merge SHA, branch state, or “pending merge.”
5. Commit the inventory update separately, push it, and rerun applicable CI.
6. Merge only after green CI and explicit approval.

---

## REQUIRED REPORT BACK

Return a concise report with:

- Status: done / partial / blocked.
- Verified base branch and SHA.
- Architecture version before/after.
- ADR numbers and titles created.
- Summary of decisions documented.
- Files changed.
- Confirmation that no code/backend/test/generated/dependency files changed.
- Validation commands with pass/fail/not-run status.
- CI status and PR link.
- Clean review archive filename and exact commit SHA, when created.
- Architecture/ADR impact.
- Known temporary implementation gaps assigned to M03_WP02–M03_WP07.
- Remaining owner decisions.
- Exact next package: M03_WP02 — Light/dark theme foundation.
- Any blocker or approved deviation.

Do not over-explain, do not claim implementation completion, and do not generate the M03_WP02 coding prompt unless the owner explicitly requests it after M03_WP01 review.
