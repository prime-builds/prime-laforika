# Laforika M03_WP05 — Profile Vertical Slice Prompt

## TASK

Deliver **M03_WP05 — Profile vertical slice** for Laforika.

Implement the first real Profile destination end to end so that:

1. Profile becomes a genuine guest-accessible bottom-dock destination alongside Home;
2. a guest who opens Profile sees the direct phone-number OTP experience inside the Profile context, with Profile still selected in the dock;
3. after successful phone verification, the same Profile route renders the authenticated profile without an intermediate method chooser or email/password flow;
4. an authenticated user can view the verified phone number and edit first name, last name, and optional contact email;
5. Profile exposes explicit save, validation, loading, retry, error, success, and dirty-form behavior;
6. Account Security and Logout move into the lower Profile hierarchy;
7. the backend, Prisma schema/migration, OpenAPI contract, Flutter repository/controller/UI, localization, and tests implement one coherent profile contract;
8. Home and Profile dock selection, taps, and RTL swipe adjacency work with the two real production destinations;
9. Settings and Notifications remain staged for **M03_WP06** and are not implemented as dead routes or placeholder pages in this package.

Persist this exact task prompt in the repository as:

```text
docs/prompts/M03_WP05_PROFILE_VERTICAL_SLICE_PROMPT.md
```

---

## WHY

M03_WP03 established guest-first routing and phone-only identity. M03_WP04 established the adaptive shell but correctly shipped a Home-only production dock because no real Profile route existed yet.

M03_WP05 must now provide the account-facing destination promised by the approved product design:

- guests can open Profile and sign in only when they choose to;
- authenticated users can manage basic personal profile data;
- the verified phone identity remains visible and immutable in ordinary profile editing;
- email remains optional contact data and never becomes a login credential;
- account/security and logout actions belong to Profile rather than primary Home chrome;
- the production dock grows only because a real destination now exists.

The outcome that matters is a complete, tested vertical slice rather than a visual placeholder: real persisted profile data, real authorization, real error handling, real guest/authenticated state transitions, and real Android-emulator verification.

---

## MILESTONE

**M03_WP05 — Profile vertical slice.**

This package implements the Profile portion of architecture v1.4, ADR-0008, ADR-0009, and `docs/design/APP_SHELL.md`.

It does not change the approved architecture direction and does not require an architecture-version bump or a new ADR unless inspection reveals a genuine conflict that cannot be resolved within this prompt.

Exact next package after successful completion and merge:

**M03_WP06 — Settings and Notifications.**

---

## REVIEWED BASELINE AND MANDATORY PRECONDITIONS

This prompt was prepared from the final reviewed M03_WP04 source archive at:

```text
a874ec9b3eb918e030290fa3fab92ba2429809dd
```

That archive is inspection evidence only. The clean synchronized default branch after M03_WP04 completion is the implementation source of truth. Preserve any Composer/runtime/build fixes already present on the merged default branch.

Before creating the M03_WP05 branch:

1. Read `AGENTS.md` fully.
2. Read `docs/architecture/ARCHITECTURE.md` fully.
3. Read at minimum:
   - `docs/architecture/adr/0003-go-router-navigation.md`
   - `docs/architecture/adr/0004-networking-and-error-model.md`
   - `docs/architecture/adr/0006-authentication-and-session.md`
   - `docs/architecture/adr/0007-custom-authentication-backend-and-session-security.md`
   - `docs/architecture/adr/0008-guest-first-access-and-phone-only-authentication.md`
   - `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`
   - `docs/design/UI_FOUNDATION.md`
   - `docs/design/APP_SHELL.md`
   - `docs/project_inventory.md`
4. Confirm M03_WP04 completed its terminating workflow:
   - reviewed implementation SHA is present;
   - one terminating M03_WP04 inventory entry exists;
   - inventory CI is green;
   - PR #11 is merged;
   - local `main`/`master` is clean and synchronized with remote;
   - the merged source includes the approved M03_WP04 remediation.
5. Confirm the exact next package in current documentation is M03_WP05.
6. Confirm no unrecorded working-tree changes exist.
7. Record the actual base SHA in the plan and report. Do not reuse a SHA from this prompt as the branch base by assumption.
8. If M03_WP04 is not inventoried and merged, stop. Do not combine M03_WP04 closure with M03_WP05 implementation.
9. Do not start from an extracted archive without Git history, the M03_WP04 feature branch, or a dirty tree.

---

## OWNER DECISIONS — AUTHORITATIVE FOR THIS PACKAGE

### A. Access and identity

- Home remains public and guest-safe.
- Profile is a **guest-accessible** route and a real bottom-dock destination.
- Opening Profile while unauthenticated shows direct phone OTP inside the Profile context.
- Profile remains selected in the dock throughout guest sign-in.
- Phone OTP is the only user-facing authentication method.
- Do not add an auth-method chooser, email/password login, password reset, social login, or password fields.
- The verified phone number is the account's primary identity and is read-only in ordinary profile editing.
- A future change-phone security flow is separate and is not approved here.
- Email is optional profile/contact data only. Editing it must not create or restore any email login credential.
- No fake guest account, anonymous backend principal, or guest token.

### B. Authenticated profile fields

The authenticated Profile supports:

- avatar placeholder only;
- first name — optional and editable;
- last name — optional and editable;
- verified phone number — visible and read-only;
- email — optional and editable contact data;
- email contact verification status may be displayed when returned by the backend, but no email-verification flow is implemented here;
- explicit Save;
- explicit loading, retry, validation, saving, success, error, and unsaved-change states;
- Account Security action lower in the page hierarchy;
- Logout action lower in the page hierarchy.

No avatar upload, biography, username, birthday, address, social links, preferences catalog, account deletion, or change-phone flow.

### C. Profile-field normalization and limits

Use this approved contract consistently in backend validation, database shape, Flutter validation, OpenAPI, and tests:

- `firstName` and `lastName` are nullable.
- Trim surrounding Unicode whitespace.
- Blank-after-trim becomes `null`.
- Each non-null name is at most **100 Unicode characters**.
- Do not impose Latin-only character restrictions; Persian names must work.
- `email` is nullable contact data.
- Trim surrounding whitespace.
- Blank-after-trim becomes `null`.
- A non-null email must be syntactically valid and at most **254 characters**.
- Preserve a user-facing display form and use a normalized lowercase value only for uniqueness/comparison.
- Changing or clearing email clears `emailVerifiedAt`.
- Saving an unchanged email must not unnecessarily clear an existing verification timestamp.
- Existing normalized-email uniqueness remains authoritative.
- A duplicate contact email must fail with a stable machine-readable conflict code and must not expose another account.

If the existing repository already provides stricter proven normalization utilities, reuse them when they do not conflict with these rules. Do not add an email-validation dependency merely for this package unless inspection proves the existing stack cannot satisfy the contract; stop for approval before adding a new dependency.

### D. API ownership

Add a Profile-owned protected API contract rather than leaking profile endpoints into presentation or re-expanding the authentication feature's credential responsibilities.

Approved endpoint shape:

```text
GET   /v1/account/profile
PATCH /v1/account/profile
```

Both require the existing bearer access-token guard and always operate on `req.auth.accountId`. They never accept an arbitrary account ID.

Approved response shape:

```json
{
  "accountId": "uuid",
  "phone": "+989121234567",
  "phoneVerified": true,
  "firstName": null,
  "lastName": null,
  "email": null,
  "emailVerified": false
}
```

Approved PATCH semantics:

- omitted field = unchanged;
- explicit `null` = clear that editable field;
- blank strings normalize to `null`;
- return the complete updated profile view;
- update only the authenticated account;
- perform normalization and update atomically;
- map uniqueness conflicts to a stable API error code such as `PROFILE_EMAIL_IN_USE`;
- use existing correlation/error response conventions;
- do not return internal normalized columns or timestamps unless the contract genuinely needs them.

Keep the existing `GET /v1/account/me` authentication/session probe intact unless a minimal backward-compatible response extension is clearly justified. Do not move profile editing into `AuthRepository`; the Profile feature owns its endpoint paths and DTOs.

### E. Settings and Notifications staging

The approved final Profile header places:

- Settings at directional `start` / visual top-right in RTL;
- Notifications at directional `end` / visual top-left in RTL.

However, their real destinations belong to **M03_WP06**.

Therefore:

- do not add dead Settings or Notifications routes;
- do not add “coming soon” pages, snackbars, fake unread badges, fake data, disabled decorative controls, or placeholder destination content;
- build the Profile header/component so real directional actions can be supplied when destinations exist;
- exercise Settings/Notifications directional placement, semantics, and callbacks in test-only fixtures;
- in production M03_WP05, render only actions backed by real synchronized routes;
- if the synchronized repository unexpectedly already contains complete real Settings or Notifications routes, inspect them and integrate only through their public contracts.

M03_WP06 will activate the production header actions.

### F. Dock and navigation

With Profile implemented, production dock destinations are:

```text
[ Profile ]  [ Home ]
 visual left  visual right
```

Chat remains unavailable and must not appear.

Required behavior:

- Home route: Home selected.
- Profile route, including guest OTP context: Profile selected.
- Direct taps navigate to the selected route.
- RTL dock swipe adjacency works between Home and Profile without wrapping.
- Profile → visual right is an edge no-op.
- Home → visual left reaches Profile.
- Profile → visual left reaches Home only if that direction matches the visible adjacency implemented by the approved shell helper; preserve the already reviewed WP04 adjacency semantics and test actual visible positions rather than guessing terminology.
- Use exported route constants; no raw route strings at screen call sites.
- Profile route must cold-start/deep-link without `extra`.
- Profile is public, not protected.
- Account Security remains protected and preserves its existing phone-OTP return behavior.
- Do not add Chat.
- Do not invent a generic module registry or global navigation framework.

Use a minimal composition seam that allows Home and Profile to consume the same real production dock destination list without circular feature imports and without violating `app → features → core`. A small app-owned route composition input or similarly narrow inspected solution is acceptable. Do not create a service locator or speculative navigation state layer.

### G. Logout behavior

- Move the primary authenticated Logout action into Profile.
- Remove the transitional authenticated Home-body Logout action after Profile provides the replacement.
- Logging out from Profile clears the Laforika session through the existing auth controller/gateway and leaves the user on `/profile`, which then renders the guest phone-login state with Profile selected.
- Account Security retains its existing session-management and logout behavior unless a focused consistency change is required and covered by tests.
- Do not implement account deletion; O8 remains unresolved.

The current Account Security discovery entry may remain on Home for continuity and Home-search usefulness. Profile must also expose Account Security as the canonical account action. Do not remove the Home discovery action if doing so would leave a meaningless empty search surface unless the implementation deliberately and cleanly omits search when no real entries exist and updates all affected tests/goldens. Keep scope focused.

---

## SCOPE

### In scope

#### Flutter

- New `features/profile/` feature with curated public barrel.
- Public `/profile` route and route constants/registries.
- Guest Profile state with embedded/reusable direct phone OTP UI.
- Authenticated Profile loading/editor states.
- Profile repository, DTOs, controller/state, validation, and failure mapping.
- Read-only verified phone display.
- Editable first name, last name, optional email.
- Save/retry/success/error/dirty-state behavior.
- Account Security and Logout actions in Profile.
- Production Home + Profile dock composition and selection.
- Home removal of transitional logout action.
- Refactor of phone OTP presentation only as needed to share a real form/panel between `/auth` and guest Profile while preserving current route behavior and selectors.
- Localization and generated localization updates.
- Tests, affected goldens, and integration flow updates.

#### Backend

- Profile/account module or equivalently focused backend ownership consistent with NestJS conventions.
- Protected GET/PATCH profile endpoints.
- DTO validation and OpenAPI annotations.
- Prisma first-name/last-name schema additions through one committed forward migration.
- Atomic profile update and email uniqueness/error handling.
- Backend unit/e2e/OpenAPI/migration-behavior tests.

#### Documentation

- Persist this prompt.
- Update `README.md`, `AGENTS.md`, `ARCHITECTURE.md`, `APP_SHELL.md`, backend README/OpenAPI guidance, and other directly affected current-state docs.
- Mark M03_WP05 implemented only after implementation is actually complete on the feature branch.
- Identify M03_WP06 as exact next package.

### Out of scope / do not touch

- Settings page implementation.
- Notifications page/data/push infrastructure.
- FCM, regional push SDKs, notification permission prompts, device tokens, background handlers, badges backed by fake data.
- Chat destination or content.
- Specialized modules or module registry.
- Avatar upload/storage/media picker.
- Change-phone flow.
- Email verification delivery or email authentication.
- Passwords, password reset, auth-method chooser.
- Account deletion, retention, export, or privacy-policy decisions.
- O2–O6 or O8 resolution.
- Theme palette changes.
- Toolchain, SDK, flavor, package identity, CI/CD, signing, release, or distribution changes.
- New dependency unless explicitly approved after a real blocker.
- Rewriting historical migrations or accepted ADRs.
- Editing generated files by hand.
- Updating unrelated goldens.
- Inventory entry before external approval.

---

## EXPECTED REPOSITORY SHAPE

Use the smallest shape supported by actual complexity. A likely Flutter structure is:

```text
lib/features/profile/
├─ profile.dart
├─ data/
│  ├─ profile_dtos.dart
│  ├─ profile_dtos.g.dart
│  └─ profile_repository.dart
└─ presentation/
   ├─ profile_controller.dart
   ├─ profile_screen.dart
   ├─ profile_editor.dart              # only if extraction improves clarity
   └─ profile_error_mapper.dart         # only if profile-specific mapping is real
```

Do not create an empty `domain/` layer. Add one only if inspection finds meaningful business rules that cannot remain as tested controller/repository logic.

A likely backend structure is:

```text
backend/src/profile/
├─ profile.module.ts
├─ application/profile.service.ts
└─ presentation/
   ├─ profile.controller.ts
   └─ profile.dto.ts
```

An account-named module is also acceptable if it is clearer and does not entangle session authentication. Follow existing NestJS conventions and keep endpoint ownership coherent.

Add one forward Prisma migration after `20260725120000_phone_only_auth`. Never edit previous migration SQL.

---

## DATA AND DATABASE REQUIREMENTS

### Prisma model

Add nullable profile-name columns to `User`:

- `firstName` mapped to `first_name`;
- `lastName` mapped to `last_name`;
- both nullable;
- database length compatible with the 100-character contract.

Preserve:

- `phoneE164` uniqueness and non-null identity;
- `emailNormalized` uniqueness;
- `emailDisplay`;
- `emailVerifiedAt`;
- account/session/challenge/security-event relations;
- stable user/account IDs.

### Migration safety

- One forward migration only.
- Historical migrations remain byte-for-byte unchanged.
- No database reset, destructive recreation, or data deletion shortcut.
- Existing users survive with the same IDs, sessions, phone, email, and relations.
- New name columns default to null.
- Existing email data remains intact.
- Migration works from a clean database through full history.

Use the existing disposable-PostgreSQL migration-test approach introduced in M03_WP03. Add behavior coverage proving:

1. clean full-history migration succeeds;
2. a legacy phone-backed account with sessions survives with the same IDs/relations and null names;
3. existing email display/normalized/verification values survive the schema migration;
4. resulting columns and nullability match the intended schema;
5. previous migration checks remain green.

Do not weaken or replace the existing phone-only migration tests.

---

## BACKEND CONTRACT AND BEHAVIOR

### Authorization

- Both profile endpoints use the existing access-token guard.
- Account identity comes only from the verified request auth context.
- No account ID in body/path/query.
- Unauthorized requests return the existing stable 401 contract.

### GET profile

Return the authenticated account's current complete profile view.

- `phone` is the verified `phoneE164` identity.
- `phoneVerified` is true under the current phone-only schema.
- Names and email are nullable.
- `emailVerified` reflects `emailVerifiedAt != null` only for the current unchanged email.
- Never return `emailNormalized`, token/session fields, disabled/security internals, or another account's data.

### PATCH profile

- Accept only `firstName`, `lastName`, and `email`.
- Reject unknown fields according to current global validation-pipe behavior.
- Omitted means unchanged.
- Null/blank clears.
- Apply normalization server-side regardless of client validation.
- Validate lengths and email syntax.
- Update one authenticated account atomically.
- If normalized email changes, clear `emailVerifiedAt`.
- If normalized email is unchanged, preserve current email verification state while allowing display-form cleanup when appropriate.
- Handle concurrent duplicate-email updates safely through database uniqueness plus stable error mapping.
- Never move an email from another account.
- Return complete updated profile.

### Stable errors

Use current `AppError`/API error response conventions. At minimum cover:

- invalid profile input;
- email already in use;
- unauthorized session;
- account not found/disabled if existing conventions require it;
- internal conflict/transport mapping without leaking Prisma details.

Add localized Flutter mappings for user-actionable profile failures. Do not show raw backend messages, Prisma codes, stack traces, email/phone values, or PII in logs.

### OpenAPI

- Generate/update the versioned contract from source annotations.
- Add contract tests for the new GET/PATCH paths, bearer security, nullable fields, max lengths, response schema, and stable error responses.
- Regeneration must leave the repository clean.
- Do not hand-edit generated OpenAPI output.

---

## FLUTTER PROFILE CONTRACT

### 1. Route and registration

Add Profile-owned public constants and registries through `profile.dart`:

```text
profileRouteName
profileRoutePath = /profile
profileRegisteredPaths
profilePublicPaths
profileRoutes(...)
```

Aggregate through `app/router/routes.dart` without raw strings.

Profile must be:

- registered;
- public;
- reconstructable from cold start/deep link;
- not in `authOnlyPaths`;
- not in protected paths;
- selected as Profile dock context for both guest and authenticated states.

Router behavior:

- unauthenticated `/profile` stays `/profile`;
- authenticated `/profile` stays `/profile`;
- `/auth?from=/profile` is not required for the normal Profile path because Profile owns its direct guest OTP UI;
- existing protected-route restoration remains unchanged;
- unknown/external return validation remains unchanged.

Add route-matrix tests.

### 2. Production dock composition

The dock now has two real production destinations:

- Profile;
- Home.

Do not add Chat.

Avoid circular feature imports. Keep route ownership in feature barrels and composition in an architecture-valid place. The app composition may supply a small immutable list/config to Home/Profile route builders or use an equally narrow inspected solution.

Requirements:

- Home golden/widget tests show Home selected and Profile available.
- Profile tests show Profile selected and Home available.
- visible x-order is Profile left, Home right in RTL;
- direct taps work;
- swipe adjacency/no-wrap works;
- 48dp targets and semantic labels remain;
- selected state remains non-color-only;
- account/security is not misrepresented as Profile dock selection when rendered as its focused screen.

### 3. Shared phone OTP UI

Do not duplicate the phone challenge/verification implementation.

Refactor the current `PhoneAuthScreen` only as needed into a reusable, intentionally exported auth presentation contract, for example a `PhoneAuthPanel`/`PhoneAuthForm`, while preserving:

- `/auth` focused screen behavior;
- all existing integration keys where reasonable:
  - `auth_phone_field`
  - `auth_phone_send`
  - `auth_otp_field`
  - `auth_otp_verify`
  - `auth_phone_resend`
- cooldown, validation, loading, error handling, and credentials acceptance;
- router-driven protected return restoration;
- no direct feature-internal imports from Profile; export the reusable entry through `auth.dart`.

Guest Profile composition:

- Profile shell/dock remains visible and selected.
- Present concise localized benefit/context copy.
- Render the reusable direct phone form.
- No nested full-screen Scaffold/AppBar duplication.
- Successful credentials acceptance causes Profile to rebuild as authenticated on the same route.
- Do not manually force navigation to Home after Profile sign-in.

### 4. Authenticated profile loading

On authenticated Profile:

- fetch profile through `ProfileRepository`;
- use Riverpod for screen/feature async state;
- show deterministic initial loading;
- show accessible retry on load failure;
- never display stale data from another account;
- dispose/reset account-scoped state on logout/account change;
- avoid keep-alive unless documented;
- refresh after save from the returned updated response, not an unnecessary second network request unless required by the architecture.

A simple `AsyncNotifier`/Notifier state model is preferred when it keeps loading/saving/data/error/dirty states explicit. Do not put network calls in widget `build()`.

### 5. Profile editor

Required controls:

- avatar placeholder with semantics, not upload interaction;
- first-name text field;
- last-name text field;
- phone read-only presentation with verified indicator;
- email text field;
- Save button;
- Account Security action;
- Logout action.

Behavior:

- initialize controllers once from loaded data;
- support Persian text and normal IME behavior;
- use appropriate autofill hints where applicable;
- trim/normalize consistently with server contract;
- client validation mirrors server limits but server remains authoritative;
- Save disabled when loading/saving, invalid, or unchanged;
- dirty state becomes clear after successful save;
- on server validation/conflict, retain user input;
- show localized inline or summary errors accessibly;
- show localized success feedback once;
- avoid duplicate submissions;
- protect against `setState` after dispose;
- do not silently discard edits during background rebuild/auth refresh;
- if leaving with dirty changes, use a focused confirmation only if it can be implemented reliably and tested without broad navigation complexity; otherwise keep this package's navigation simple and report the decision.

Phone display:

- visible and read-only;
- label it as verified;
- do not render it as an enabled editable text field;
- format display safely for Persian UI while preserving the backend E.164 value in data state;
- do not expose a change action.

Email:

- clearly described as optional contact email;
- never call it a login email;
- show verification state only if returned;
- no “verify email” action.

### 6. Header staging

Create a focused Profile header that supports:

- title;
- optional Settings action at directional start/top-right;
- optional Notifications action at directional end/top-left;
- localized semantics/tooltips;
- minimum 48dp targets.

Test the final RTL placement and callbacks with a test-only harness.

In production M03_WP05, omit an action whose real route does not exist. Do not show dead or disabled future controls.

### 7. Account actions

- Account Security uses the existing exported route constant and remains protected.
- Guest Profile does not show Account Security or Logout.
- Authenticated Profile shows both lower than editable profile fields.
- Logout calls the existing auth controller/gateway, not the repository directly from UI.
- After logout, remain on Profile and render guest sign-in.
- Remove Home's transitional logout control and update tests/integration keys accordingly.
- Keep logout-all/session management in Account Security.

---

## STATE, ERROR, AND ACCOUNT-SCOPING REQUIREMENTS

- Profile data is account-scoped.
- A state instance associated with one `accountId` must not survive into another account.
- Logout disposes/invalidates profile state.
- Auth transition from guest to authenticated triggers the correct profile load exactly once.
- Temporary network failure does not log the user out.
- Final 401/session invalidation follows existing auth interceptor/controller behavior.
- Profile failures use `Result<T>` and sealed `Failure` values at repository boundaries.
- Repository catches transport exceptions and maps them; raw Dio/Prisma errors do not cross boundaries.
- No profile data in SharedPreferences.
- No profile data in secure storage.
- No offline cache/database in this package.
- No logging of names, email, phone, request bodies, or response bodies.

---

## LOCALIZATION, RTL, ACCESSIBILITY, AND RESPONSIVENESS

### Localization

All production strings come from ARB/generated localizations. Likely strings include:

- Profile navigation label/title;
- guest Profile introduction;
- first name / last name / phone / verified phone / optional contact email labels;
- email verification state labels;
- Save / saving / saved;
- retry/load failure/validation/conflict messages;
- Account Security;
- Logout;
- avatar placeholder semantics;
- optional Settings/Notifications tooltips for the reusable header contract.

Never hand-edit generated localization output.

### RTL

- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`, and `end`.
- Profile header test must prove Settings visual right and Notifications visual left when both callbacks are supplied.
- Dock test must prove Profile visual left and Home visual right.
- Mirror directional navigation icons where applicable.
- Do not hardcode left/right except when a tested physical-position assertion is intentionally verifying approved RTL output.

### Accessibility

- Every icon-only control has localized tooltip and semantics.
- Minimum 48dp targets.
- Dock selected semantics remain correct.
- Read-only phone and verification status are announced meaningfully.
- Error and success feedback is reachable by assistive technology.
- Form fields have labels and appropriate text-input actions.
- Do not use color alone for required/verified/selected/error state.

### Responsive behavior

Verify at minimum:

- 320dp width;
- normal phone width;
- text scale 2.0;
- light and dark themes;
- guest and authenticated Profile states;
- no fixed-height clipping;
- keyboard/form scrolling keeps controls reachable;
- body clears floating dock and bottom safe area.

---

## TEST REQUIREMENTS

Every new logic unit needs matching tests. Do not weaken existing assertions.

### Flutter unit tests

Cover at minimum:

- profile DTO JSON parsing/serialization;
- profile normalization/validation cases;
- repository endpoint, method, payload, success, malformed response, transport/error mapping;
- controller load/save/dirty/success/error behavior;
- omitted vs null/blank update semantics as represented by the client;
- duplicate save suppression;
- account change/logout invalidation;
- production dock destination composition and adjacency with Home/Profile only.

### Flutter widget tests

#### Guest Profile

- Profile route renders direct phone form, no chooser/email/password UI;
- Profile dock selected;
- Home dock action available;
- direct phone challenge/verify controls preserve expected keys/behavior;
- successful auth transition replaces guest form with authenticated profile without navigating Home;
- no Account Security/Logout while guest;
- no production Settings/Notifications dead controls.

#### Authenticated Profile

- loading;
- loaded values;
- null/empty fields;
- read-only verified phone;
- name/email editing;
- validation limits;
- dirty and Save enablement;
- saving/duplicate-tap prevention;
- save success;
- duplicate-email/server failure retaining input;
- load failure and retry;
- Account Security navigation;
- Logout changes to guest Profile;
- 320dp and text scale 2.0;
- light/dark semantic surfaces.

#### Header fixture

- Settings x-position is visual right/top start in RTL;
- Notifications x-position is visual left/end in RTL;
- callbacks, tooltips, semantics, and 48dp targets;
- optional action omission behaves cleanly.

#### Dock and Home

- Home now renders real Profile + Home dock entries only;
- Profile visible left, Home visible right;
- Home selected on Home;
- Profile selected on Profile;
- taps and swipes work/no-wrap;
- Chat absent;
- Home transitional logout removed;
- no regression in Home search/Account Security discovery.

### Router tests

Cover:

- guest `/profile` allowed;
- authenticated `/profile` allowed;
- startup hydration then guest Home remains unchanged;
- Profile route registered/public;
- Account Security remains protected;
- `/auth?from=/account/security` resumes correctly;
- authenticated user visiting `/auth` still follows existing canonical behavior;
- no redirect loop;
- no Settings/Notifications/Chat routes added;
- cold-start/deep-link Profile works without `extra`.

### Backend unit/service tests

Cover:

- GET profile mapping;
- PATCH name trim/blank/null/unchanged behavior;
- Persian/Unicode name acceptance;
- maximum-length rejection;
- email trim/display/normalization;
- invalid email rejection;
- email unchanged preserves verification;
- email changed/cleared resets verification;
- duplicate email stable conflict mapping;
- current-account-only update;
- not-found/disabled/unauthorized conventions;
- no internal field leakage.

### Backend e2e tests

Using real disposable/test PostgreSQL where current convention requires:

1. unauthorized GET/PATCH rejected;
2. authenticated GET returns own account ID, phone, and profile fields;
3. PATCH names persists and returns updated data;
4. PATCH optional email persists normalized/display values;
5. second account cannot use duplicate email;
6. one account cannot read/update another account;
7. null/blank clears fields;
8. invalid input/overlength rejected with stable error contract;
9. changing email clears verification; unchanged email preserves it;
10. phone remains unchanged and cannot be patched;
11. phone OTP sign-in/session behavior remains valid after profile updates.

### Migration behavior tests

Use real disposable PostgreSQL to prove the migration requirements listed earlier.

### OpenAPI tests

Assert paths, methods, security, request/response schemas, nullable fields, max lengths, and stable error references.

### Golden tests

This task explicitly approves visual baseline changes only for:

- new Profile goldens;
- the existing M03_WP04 production Home light/dark goldens when their dock legitimately changes from Home-only to Profile + Home.

Required representative goldens:

- guest Profile, light RTL;
- authenticated Profile, light RTL;
- authenticated Profile, dark RTL;
- production Home light/dark RTL updated for the two-item dock.

Load Material Icons and Vazirmatn correctly. Render production app/screens through realistic provider overrides rather than simplified misleading specimens.

Do **not** modify:

- M03_WP02 theme specimen goldens;
- module-fixture golden unless a real shared-shell change genuinely alters it and is explicitly explained;
- unrelated baselines.

Never use `--update-goldens` before reviewing the rendered differences. Visually inspect every changed/new golden and report the exact list.

### Android emulator integration

Update and run the real dev integration flow against local backend/PostgreSQL. At minimum verify:

```text
guest Home
→ tap Profile dock
→ direct phone OTP inside Profile
→ authenticated Profile
→ GET profile succeeds for expected accountId
→ edit first name / last name / deterministic unique contact email
→ Save succeeds
→ reload/re-enter Profile and verify persistence
→ open Account Security
→ me()/refresh/session validation remains correct
→ return to Profile as needed
→ logout from Profile
→ guest Profile phone-login state with Profile selected
→ Home remains publicly reachable
```

Keep fixture key secret. Do not log it or include it in reports/archive.

Use a deterministic rerunnable email derived from the controlled test phone/account, or clean up safely through the same profile API. Do not create uncontrolled real-account data.

Integration selectors should be stable. Add focused keys such as:

```text
profile_screen
profile_guest_auth
profile_first_name
profile_last_name
profile_phone
profile_email
profile_save
profile_account_security
profile_logout
shell_dock_profile
shell_dock_home
```

Preserve existing auth selector keys unless a documented atomic update is unavoidable.

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

Run localization/code generation using the repository-approved commands, then confirm generated outputs are committed and a second generation leaves a clean diff.

### Backend

Run the repository's actual scripts from `backend/package.json`, including at minimum:

- format check;
- lint/typecheck;
- unit tests;
- e2e/integration tests;
- disposable-PostgreSQL migration behavior tests;
- OpenAPI generation/contract test and clean-diff check;
- production build.

Report exact script names and results rather than paraphrasing them as passed.

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

If the profile flow is split into a new integration file, run both the existing auth flow and the new profile flow unless they are intentionally consolidated without reducing coverage.

### Additional checks

```bash
git diff --check
git status --short
git diff --stat
```

Inspect full diff, generated files, migration SQL, archive contents, and changed goldens before check-in.

A missing emulator, fixture-key approval, PostgreSQL instance, JDK/Gradle setup, or platform tool is an environment limitation—not automatic approval to skip a required gate. Resolve it where possible. If genuinely blocked, report the exact limitation and obtain explicit owner-approved deviation before claiming completion.

Temporary local Gradle/Kotlin workarounds must be restored and uncommitted.

---

## ACCEPTANCE CRITERIA

### Product and navigation

- [ ] M03_WP04 is inventoried and merged before branch creation.
- [ ] `/profile` is a real public reconstructable route.
- [ ] Production dock contains Profile + Home only.
- [ ] Profile is selected on guest and authenticated Profile.
- [ ] Home remains selected on Home.
- [ ] Chat is absent.
- [ ] Dock taps/swipes/order/no-wrap are tested in RTL.
- [ ] Guest Profile presents direct phone OTP without chooser/email/password.
- [ ] Successful Profile sign-in stays in Profile and reveals authenticated profile.
- [ ] Account Security and Logout exist in authenticated Profile.
- [ ] Home transitional Logout is removed.
- [ ] No dead Settings/Notifications actions or placeholder routes ship.

### Profile data

- [ ] GET/PATCH `/v1/account/profile` are protected and current-account-only.
- [ ] Phone is visible, verified, and not editable.
- [ ] First/last names and optional email persist.
- [ ] Normalization/null/blank/length rules are consistent end to end.
- [ ] Duplicate email fails safely with stable code.
- [ ] Email remains contact data only.
- [ ] Email verification resets only when email changes/clears.
- [ ] Existing account IDs, sessions, phone, email, and relations survive migration.

### Flutter quality

- [ ] Repository/controller state is Riverpod-owned and tested.
- [ ] No network calls occur in widget `build()`.
- [ ] Loading/retry/error/success/dirty/saving states are meaningful.
- [ ] User input survives server failures.
- [ ] Account-scoped state clears on logout/account change.
- [ ] All production strings localized.
- [ ] RTL, 320dp, text scale 2.0, light/dark, semantics, and 48dp targets pass.
- [ ] Reusable phone OTP UI avoids duplication and preserves existing auth behavior.

### Backend quality

- [ ] One forward migration; historical migrations unchanged.
- [ ] Real migration behavior tests pass.
- [ ] OpenAPI is generated/tested and clean.
- [ ] No PII/raw Prisma errors leak.
- [ ] Existing OTP/session/refresh/revocation tests remain green.

### Visual/tests/integration

- [ ] New Profile goldens inspected.
- [ ] Only approved Home goldens updated.
- [ ] WP02 theme goldens unchanged.
- [ ] Flutter and backend test suites pass.
- [ ] Three flavor APKs pass.
- [ ] Real emulator profile/auth flow passes.
- [ ] CI is green at the final reviewed PR head.

### Documentation/workflow

- [ ] Prompt persisted under the exact filename.
- [ ] Current docs mark M03_WP05 implemented and M03_WP06 next.
- [ ] Architecture remains v1.4 unless a separately approved conflict requires change control.
- [ ] No premature inventory entry.
- [ ] Full clean source archive exported from exact final PR-head commit after CI.

---

## CONSTRAINTS

- No architecture or owner-decision changes without explicit approval.
- No new dependency unless inspection proves necessity and approval is obtained first.
- Do not alter Flutter/Dart/Node versions, SDK targets, application IDs, flavors, CI/CD, signing, or distribution.
- Do not change approved theme palette values.
- Do not reintroduce email authentication/password behavior.
- Do not add push infrastructure or resolve O3.
- Do not resolve O8 or implement account deletion.
- Do not edit accepted ADRs to erase history; add a new ADR only if genuinely necessary and approved.
- Do not edit historical Prisma migrations.
- Do not reset/delete databases as a migration shortcut.
- Do not hand-edit generated Dart/OpenAPI files.
- Do not create fake production routes/content.
- Do not modify unrelated goldens.
- Preserve `app → features → core` and curated feature-barrel boundaries.
- No direct feature-internal imports across features.
- No circular cross-feature dependency.
- No raw route strings at feature screen call sites.
- No PII/secrets in logs, tests, screenshots, archives, commits, or PR text.

---

## STEP 0 — INSPECT

Before editing:

1. Complete the mandatory precondition checks.
2. Read all required docs and ADRs.
3. Inspect:
   - `pubspec.yaml`, lockfile, analysis, l10n, CI;
   - app router and route aggregation;
   - Home and shell public contracts/tests/goldens;
   - phone auth screen, auth repository/gateway/controller, Account Security;
   - Dio/interceptor/failure mapping/redaction;
   - current l10n ARB/generated setup;
   - backend AppModule/AuthModule/controller/service/DTO/error conventions;
   - Prisma schema and all migrations;
   - disposable PostgreSQL migration harness;
   - OpenAPI generation and contract tests;
   - integration test selectors and fixture flow;
   - current project inventory/workflow.
4. Inspect whether a profile/account module already exists. Reuse only real architecture-consistent code.
5. Inspect the exact current Home dock-composition approach after merged M03_WP04; do not restore an older implementation from an archive.
6. Identify any conflict before editing. Stop only for a real guardrail/owner-decision blocker.

Return a concise plan with:

- actual base SHA;
- intended branch;
- chosen Flutter feature shape;
- chosen backend module shape;
- migration name/strategy;
- API request/response/error contract;
- dock-composition approach that avoids circular imports;
- phone-form reuse approach;
- expected files/tests/goldens;
- verification commands.

Proceed without waiting unless blocked by `AGENTS.md` or an unresolved decision.

---

## STEP 1 — PLAN

Plan atomic logical commits. A reasonable sequence is:

1. backend schema/profile API/migration/tests/OpenAPI;
2. Flutter profile data/controller and reusable phone-auth presentation seam;
3. route/dock/Home/Profile UI integration and localization;
4. widget/router/golden/integration coverage;
5. documentation and prompt persistence.

Do not force this split if a slightly different atomic sequence is cleaner. Do not mix inventory into implementation commits.

---

## STEP 2 — IMPLEMENT

- Keep diff strictly within M03_WP05.
- Implement backend and Flutter contracts together so they cannot drift.
- Add tests with each logic unit.
- Regenerate generated sources; never hand-edit them.
- Preserve existing public contracts unless this task explicitly evolves them.
- Keep Profile product logic out of `core/`.
- Keep API endpoint knowledge in Profile repository/backend Profile ownership.
- Use existing theme/tokens and shell components.
- Use the real production dock list, not test fixtures.
- Do not add future routes to satisfy visuals.
- Do not leave unexplained TODOs.

---

## STEP 3 — VERIFY

Run every required gate and report exact results. Fix failures rather than weakening tests.

For goldens:

1. render with correct fonts/icons;
2. visually inspect;
3. list every changed PNG;
4. prove WP02 theme goldens are byte-for-byte unchanged;
5. explain legitimate Home golden changes caused by Profile entering the production dock.

For migration tests:

- prove behavior against real disposable PostgreSQL, not SQL-regex inspection only.

For emulator integration:

- run the real flow and keep fixture secrets out of output.

---

## STEP 4 — CHECK IN AND EXTERNAL REVIEW

Use check-in mode:

**branch + atomic commits + push + PR + CI + clean full source archive; stop before inventory/merge.**

Suggested branch:

```text
feat/m03-wp05-profile
```

Use Conventional Commits. Example scopes, adjusted to the real diff:

```text
feat(profile): add protected profile API and persistence
feat(profile): add guest and authenticated profile destination
test(profile): cover profile routing editing and migration
docs(profile): record M03_WP05 implementation state
```

Before PR:

- run applicable gates;
- inspect full diff and migration;
- ensure no secrets/PII;
- ensure no inventory entry;
- ensure prompt is committed.

Use the repository PR-body format and report:

- base SHA;
- final implementation SHA;
- branch/PR;
- architecture impact;
- migration/API details;
- exact tests/gates;
- changed goldens;
- approved deviations or none;
- exact next package M03_WP06.

After CI is green:

1. create a **full clean source archive** from the exact PR-head commit using `git archive` or the repository-approved equivalent;
2. include tracked source/documentation only;
3. do not submit a changeset-only/patch handoff in place of the source tree;
4. report archive filename and exact SHA;
5. stop for external review.

Do not update inventory or merge before external approval.

---

## TERMINATING INVENTORY WORKFLOW — ONLY AFTER EXTERNAL APPROVAL

After explicit approval of the final reviewed PR-head archive:

1. add exactly one terminating M03_WP05 entry to `docs/project_inventory.md`;
2. record the final reviewed implementation SHA, not the inventory commit or merge commit;
3. summarize delivered profile/backend/API/migration/test behavior truthfully;
4. record actual gate results and approved deviations;
5. identify exact next package:

   **M03_WP06 — Settings and Notifications**;

6. commit/push inventory separately;
7. rerun required CI;
8. merge only after approval and green CI.

The inventory entry must not record itself, pending-merge language, temporary branch state, or future implementation as complete.

---

## REPORT BACK

Return a concise final implementation report containing:

- **Status:** done / partial / blocked;
- actual base SHA;
- branch and PR;
- final implementation SHA;
- summary;
- profile API and migration contract;
- Flutter route/dock/guest/authenticated behavior;
- files changed;
- tests added/updated;
- exact commands and pass/fail/not-run results;
- emulator/device result;
- list of changed/new goldens and confirmation that WP02 theme goldens are unchanged;
- architecture/ADR impact;
- approved deviations;
- remaining blockers/owner decisions;
- inventory/merge status;
- full clean source archive name;
- exact next package: **M03_WP06 — Settings and Notifications**.

Do not claim completion for unrun required gates. Do not expose fixture keys, phones, emails, names, tokens, database contents, or other PII.
