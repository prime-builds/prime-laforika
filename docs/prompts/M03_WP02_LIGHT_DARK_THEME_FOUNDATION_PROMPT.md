# Laforika M03_WP02 — Light/Dark Theme Foundation Prompt

## TASK

Deliver **M03_WP02 — Light/dark theme foundation** for Laforika.

Implement the approved Laforika-owned, Windows 11 / Fluent-inspired visual foundation in Flutter:

1. semantic light and dark color tokens;
2. Material 3 light and dark `ThemeData`;
3. `System`, `Light`, and `Dark` appearance modes, with `System` as the default;
4. non-sensitive appearance persistence through a minimal `PrefsFacade` backed by `shared_preferences`;
5. Riverpod-owned appearance state wired into the application root;
6. Vazirmatn typography and semantic spacing/radius/elevation/motion tokens;
7. focused unit, widget, RTL, contrast, large-text, and light/dark golden coverage.

Do **not** redesign Home, change authentication/routing, implement the adaptive application shell, create Settings/Profile/Notifications pages, or add any production module in this package.

Persist this exact task prompt in the repository as:

```text
docs/prompts/M03_WP02_LIGHT_DARK_THEME_FOUNDATION_PROMPT.md
```

---

## WHY

The current M2 code still uses a neutral, light-only placeholder theme. M03_WP01 froze the approved visual direction in architecture v1.4, ADR-0009, and `docs/design/UI_FOUNDATION.md`, but did not implement it.

M03_WP02 establishes the visual and appearance-state foundation required by later packages:

- M03_WP03 guest-first routing and phone-only authentication;
- M03_WP04 adaptive application shell;
- M03_WP05 Profile;
- M03_WP06 Settings and Notifications;
- M03_WP07 integration and visual hardening.

The outcome that matters is one centralized, testable, RTL-safe theme system that later features consume without hardcoded colors, duplicated typography, theme flashes, or speculative UI infrastructure.

---

## MILESTONE

**M03_WP02 — Light/dark theme foundation.**

This package implements the visual-theme portion of architecture v1.4 and ADR-0009. It does not alter the approved architecture direction and does not require an architecture version bump.

Exact next package after successful completion and merge:

**M03_WP03 — Guest-first routing and phone-only authentication.**

---

## REVIEWED BASELINE AND MANDATORY PRECONDITIONS

This prompt was prepared from the latest supplied M03_WP01 archive at commit:

```text
af1936b0006feda3944bb3693b8dd97f47bf1ebd
```

That archive is inspection evidence only. Do not restore older files from it over the current repository. The clean, synchronized default branch after M03_WP01 completion is the implementation source of truth, including any runtime/build fixes already made by Composer to keep the application working.

Before creating the M03_WP02 branch:

1. Read `AGENTS.md` fully.
2. Confirm PR #8 / M03_WP01 has completed the terminating workflow:
   - the reviewed documentation correction is present;
   - CI is green;
   - one M03_WP01 entry exists in `docs/project_inventory.md`;
   - PR #8 is merged;
   - local `main`/`master` is clean and synchronized with the remote.
3. Confirm this exact line exists in:

   ```text
   docs/prompts/M03_WP01_GUEST_FIRST_UI_FOUNDATION_DOCUMENTATION_PROMPT.md
   ```

   ```markdown
   **M03_WP01 — Documentation and decision freeze.**
   ```

4. If the line is still the old milestone-neutral wording, finish that correction on the M03_WP01 branch/PR first. Do not hide the correction inside M03_WP02.
5. Confirm no unrecorded local source, generated, configuration, or documentation changes exist.
6. Record the actual M03_WP02 base commit SHA in the plan and final report.
7. Do not start from an extracted archive without Git history, an old M2 branch, the M03_WP01 feature branch, or a dirty working tree.

**Stop** if M03_WP01 is not merged and inventoried. Work packages must remain isolated.

---

## AUTHORITATIVE DOCUMENTS

Read fully before planning or editing:

- `AGENTS.md`
- `README.md`
- `docs/project_inventory.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/adr/0001-modular-feature-first-architecture.md`
- `docs/architecture/adr/0002-riverpod-state-and-di.md`
- `docs/architecture/adr/0005-local-persistence-and-offline.md`
- `docs/architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`
- `docs/design/UI_FOUNDATION.md`
- `docs/design/APP_SHELL.md` only to preserve package boundaries; do not implement its shell behavior here
- `docs/prompts/M03_WP01_GUEST_FIRST_UI_FOUNDATION_DOCUMENTATION_PROMPT.md`
- `pubspec.yaml`
- `analysis_options.yaml`
- `l10n.yaml`
- `.gitignore`
- `.github/workflows/*`

Inspect the current implementation and tests, especially:

- `lib/app/app.dart`
- `lib/app/fatal_startup_app.dart`
- `lib/bootstrap.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_tokens.dart`
- `lib/core/storage/`
- `lib/core/config/`
- all current feature screens that consume `Theme.of(context)` or `AppTokens`
- `test/app/app_test.dart`
- theme/app-related tests and test support fakes
- the current generated-localization workflow

The current repository wins over any filename/path suggestion in this prompt when the repository has evolved without conflicting with the frozen architecture.

---

## OWNER DECISIONS

### Required resolved decisions

- **O7 is partially resolved** for the in-app visual system by ADR-0009 and `docs/design/UI_FOUNDATION.md`.
- The approved theme is Laforika-owned and only Fluent-inspired.
- Appearance modes are `System`, `Light`, and `Dark`.
- `System` is the default.
- Vazirmatn remains the application typeface.
- Persian `fa-IR` and RTL remain first-class at the application root.
- `shared_preferences` is the approved storage technology for non-sensitive preferences.

### Decisions that must remain untouched

- O1 and ADR-0008 authentication direction: no auth changes in this package.
- O2–O6 and O8 remain unresolved and must not be assumed.
- External logo, launch/store icons, marketing assets, illustrations, and module-specific branding remain outside the resolved portion of O7.
- Do not select a specialized M04 module.
- Do not introduce push, maps, analytics, crash reporting, Jalali display, database technology, or distribution/signing changes.

---

## APPROVED VISUAL CONTRACT

Implement these semantic values exactly.

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

These are semantic design tokens. Do not hardcode these values inside feature widgets.

### Geometry and motion

- 8dp spacing foundation.
- Existing semantic spacing values 8 / 16 / 24 / 32 remain available through centralized tokens.
- Normal page padding starts at 16dp.
- Standard component radii live in the 12–16dp range.
- The future floating dock radius token may use the approved 24–28dp range, but no dock widget is implemented here.
- Borders use a restrained 1dp semantic divider/outline.
- Elevation remains subtle.
- Standard motion tokens remain within approximately 180–250ms.
- Minimum interactive target remains 48dp.

### Typography

- Use the bundled Vazirmatn family.
- Use semantic Material text roles (`display`, `headline`, `title`, `body`, `label`) rather than one-off styles.
- Approved normal UI weights are 400, 500, and 600.
- Keep colors theme-derived.
- Do not create decorative typography or module-specific type systems.
- Do not remove bundled font files or change their licensing.

---

## SCOPE

### In scope

1. Replace the current placeholder theme with centralized semantic light/dark theme infrastructure.
2. Add a minimal product-agnostic `PrefsFacade` and concrete `shared_preferences` adapter for non-sensitive settings.
3. Add the approved `shared_preferences` dependency and update `pubspec.lock`.
4. Add a stable, centralized appearance preference key and serialization contract.
5. Add an appearance model/controller/provider owned by Riverpod.
6. Default to `System` when no valid stored preference exists.
7. Restore a valid stored `System`, `Light`, or `Dark` mode deterministically.
8. Persist appearance changes through the facade.
9. Wire `theme`, `darkTheme`, and `themeMode` into `MaterialApp.router`.
10. Make the fatal-startup surface at least system-light/dark aware without making preference storage a fatal dependency.
11. Map the approved semantic colors into Material 3 `ColorScheme`, component themes, and a theme extension or equivalent semantic API for roles not represented cleanly by `ColorScheme`.
12. Centralize typography, spacing, radii, border/elevation, motion, and touch-target tokens.
13. Ensure current screens remain functional and readable in both themes without redesigning their layout.
14. Add unit/widget tests, contrast checks, 320dp / 2.0 text-scale checks, and new scoped light/dark RTL golden baselines.
15. Update current-state documentation to mark M03_WP02 implemented and M03_WP03 as the exact next package.
16. Add this prompt under `docs/prompts/`.

### Out of scope / do not touch

- Guest-first route behavior.
- Auth redirect changes.
- Removal of email/password or password-reset flows.
- Phone-only auth implementation.
- Backend code, schema, Prisma migrations, OpenAPI, or API contracts.
- Home redesign.
- Adaptive module strip.
- Search behavior changes.
- Module internal tabs.
- Floating bottom dock.
- Chat route or feature.
- Profile page.
- Settings page or user-facing theme selector.
- Notifications page or push infrastructure.
- New modules or module registry.
- External branding assets, Microsoft assets, proprietary icons, copied Windows artwork, or a Fluent UI package.
- Dynamic color / wallpaper-derived accent colors.
- Per-module palettes.
- A broad reusable component library.
- Heavy responsive or design-system dependencies.
- Changes to Flutter/Dart versions, flavors, application identity, deployment targets, CI/CD, signing, or distribution.
- Architecture version bump or new ADR unless an actual conflict is found and owner approval is obtained.

---

## IMPLEMENTATION REQUIREMENTS

### 1. Preserve the working repository baseline

- Inspect the actual default-branch code before editing.
- Preserve Composer/runtime fixes already present in bootstrap, provider lifecycle, Dio/auth wiring, Android build configuration, backend setup, and tests.
- Do not replace current files wholesale from earlier archives.
- Keep changes narrowly focused on theme, preference storage, tests, prompt archival, and directly affected documentation.
- Do not refactor auth, routing, Home, backend, or build setup as drive-by cleanup.

### 2. Dependency and storage facade

Add only the approved dependency needed by this package:

```text
shared_preferences
```

Requirements:

- Select a version compatible with the frozen Flutter/Dart toolchain and current dependency graph.
- Commit `pubspec.lock`.
- Do not add another preferences, database, state, DI, theme, golden, or responsive package.
- Introduce a minimal product-agnostic `PrefsFacade` under `core/storage/`.
- Expose only operations justified by the appearance preference; avoid a speculative storage framework.
- Provide a concrete adapter backed by the supported `shared_preferences` API for the selected package version.
- Provide a Riverpod provider for dependency injection and straightforward test override.
- Appearance is non-sensitive, installation-level UI state. Do not store it in secure storage or scope it to an authenticated account.
- Centralize the preference key; do not scatter string literals.
- Persist stable values:
  - `system`
  - `light`
  - `dark`
- Missing or unknown values fall back to `System` safely.
- Preference read/write failure must not crash application startup or expose raw exceptions. Use `System` for the current run and report only sanitized local diagnostics where appropriate.
- Do not add telemetry or remote logging.

### 3. Deterministic appearance state

Create a focused appearance model and Riverpod owner under `core/theme/`.

Requirements:

- Use Riverpod as both state management and dependency injection.
- Do not add a service locator.
- State is mutated only by its owning controller/notifier.
- The app-wide provider must remain stable for the application lifetime.
- Expose a clean API that later Settings UI can call without depending directly on `shared_preferences`.
- Keep persistence details out of widgets.
- The default state is `System`.
- Valid persisted state is restored before or during root composition in a deterministic way that avoids a visible light-to-dark flash.
- Do not add a second splash screen or reuse auth session state for theme loading.
- A failed preference load must degrade to `System`, not the fatal-startup app.
- Updating appearance changes the current app theme and persists the new value.
- The controller must remain testable with an in-memory `PrefsFacade`.

Implementation shape may differ after inspection, but a reasonable non-binding surface is:

```text
lib/core/storage/prefs_facade.dart
lib/core/storage/shared_preferences_prefs_facade.dart
lib/core/storage/prefs_facade_provider.dart
lib/core/theme/app_appearance.dart
lib/core/theme/app_appearance_controller.dart
```

Do not create empty abstractions or generated Riverpod code unless the existing project convention and concrete benefit justify it.

### 4. Semantic theme tokens

Replace placeholder color constants with semantic token ownership in `core/theme/`.

Requirements:

- Keep non-color tokens centralized.
- Provide named semantic access for all approved colors.
- Use a `ThemeExtension` or an equally clear theme-owned mechanism for semantic roles not represented cleanly by `ColorScheme`, including at least:
  - app background;
  - secondary surface;
  - elevated surface;
  - secondary text;
  - border/divider;
  - subtle selection;
  - success.
- Populate `ColorScheme` coherently for standard Material components.
- Feature widgets must consume `Theme.of(context)`, `ColorScheme`, the semantic theme extension, and centralized non-color tokens.
- No raw palette values in feature code.
- Preserve `AppTokens` public usages or migrate them carefully without breaking current screens.
- Do not expose mutable global colors.

A reasonable non-binding file surface is:

```text
lib/core/theme/app_tokens.dart
lib/core/theme/app_semantic_colors.dart
lib/core/theme/app_theme.dart
```

### 5. Material 3 light and dark themes

Build explicit light and dark `ThemeData` using `useMaterial3: true`.

At minimum, map and verify:

- `brightness`;
- `colorScheme`;
- scaffold/app background;
- primary, secondary, and elevated surfaces;
- primary and secondary text;
- outline/divider;
- primary actions and content on accent;
- error and success semantics;
- app bars;
- cards;
- dividers;
- text selection/cursor;
- text fields;
- filled/elevated/text/outlined buttons currently used by the app;
- progress indicators;
- dialogs/snackbars/sheets where current screens use them.

Rules:

- Use calm surfaces, restrained accent, rounded geometry, and subtle depth.
- Do not imitate Windows controls literally.
- Do not add shell-specific navigation styling before M03_WP04.
- Do not add a translucent dock, blur, or app-shell widgets.
- Selected-state tokens must support a future non-color-only indicator, but no shell selected state is implemented here.
- Existing screens must remain readable in both themes.

### 6. Typography

- Apply Vazirmatn to the complete light and dark `TextTheme`.
- Keep semantic Material roles.
- Use approved weights 400/500/600 for normal UI hierarchy.
- Ensure primary/secondary text colors derive from the active theme.
- Do not hardcode text colors in a screen unless it is a semantic exception already required by `ColorScheme`.
- Preserve text scaling.
- Do not use fixed heights that clip at 2.0 text scale.

### 7. Root application wiring

Update `LaforikaApp` to consume the appearance provider and configure:

```dart
theme: <light theme>,
darkTheme: <dark theme>,
themeMode: <Riverpod-owned mode>,
```

Preserve:

- `fa-IR` as the only configured locale;
- root RTL behavior;
- generated localization delegates;
- router ownership and provider lifetime;
- current auth/session startup behavior until M03_WP03;
- debug banner behavior;
- existing application title localization.

Do not move route or auth logic into the theme controller.

### 8. Bootstrap and failure behavior

- Integrate the preferences adapter without destabilizing the current bootstrap zone, config validation, `ProviderScope`, auth gateway lifetime, or Dio attachment behavior.
- Preserve comments/logic documenting provider-lifetime fixes unless an equivalent tested implementation replaces them for a clear reason.
- Preference initialization is non-critical. Failure must fall back to `System` and allow the app to start.
- Config validation remains fatal as currently designed.
- The fatal-startup app must render coherently in light and dark system appearance without requiring the preference facade to succeed.
- Never log raw preference exceptions or values.

### 9. No Settings UI yet

M03_WP02 provides the state/API for a future selector but does not expose a production user-facing theme switch.

Do not:

- add a Settings route;
- place a theme selector on Home or auth screens;
- add a debug menu or hidden gesture;
- add temporary production controls.

Tests may set the appearance provider/fake preference directly.

### 10. Documentation reconciliation

After implementation, update only current-state wording that would otherwise be false.

At minimum inspect and update as needed:

- `README.md`
  - current implementation now includes M03_WP02 theme foundation;
  - remaining transition packages are M03_WP03–M03_WP07;
  - exact next package is M03_WP03.
- `docs/architecture/ARCHITECTURE.md`
  - replace the temporary statement that theme tokens remain a placeholder until M03_WP02;
  - state that the theme foundation is implemented while shell/profile/settings/auth transitions remain pending;
  - keep architecture version 1.4 unless an approved architecture change is made.
- `docs/design/UI_FOUNDATION.md`
  - mark the M03_WP02 foundation as implemented;
  - keep M03_WP07 visual hardening explicitly pending.
- `AGENTS.md`
  - change only stale current-state language when necessary;
  - do not weaken operational or architecture guardrails.
- `docs/prompts/M03_WP02_LIGHT_DARK_THEME_FOUNDATION_PROMPT.md`
  - persist this exact prompt.

Do not rewrite accepted ADR-0009 to describe implementation status. ADRs record decisions, not mutable progress.

Do not update `docs/project_inventory.md` before archive review and final green CI.

---

## EXPECTED FILE SURFACE

The final diff will likely include a focused subset of:

```text
pubspec.yaml
pubspec.lock
lib/bootstrap.dart
lib/app/app.dart
lib/app/fatal_startup_app.dart
lib/core/storage/prefs_facade.dart
lib/core/storage/shared_preferences_prefs_facade.dart
lib/core/storage/prefs_facade_provider.dart
lib/core/theme/app_appearance.dart
lib/core/theme/app_appearance_controller.dart
lib/core/theme/app_semantic_colors.dart
lib/core/theme/app_tokens.dart
lib/core/theme/app_theme.dart
test/core/storage/...
test/core/theme/...
test/app/app_test.dart
test/goldens/...
docs/prompts/M03_WP02_LIGHT_DARK_THEME_FOUNDATION_PROMPT.md
README.md
docs/architecture/ARCHITECTURE.md
docs/design/UI_FOUNDATION.md
```

This list is not permission to create every file blindly. Inspect the tree, use the smallest coherent surface, and report deviations.

Do not modify backend files, auth feature files, Home layout files, router files, platform files, CI workflows, generated localization output, or ARB files unless a direct, demonstrated compile/test consequence requires a minimal correction within scope. Stop for approval if scope must expand materially.

---

## ACCEPTANCE CRITERIA

### Theme contract

- [ ] Exact approved light and dark semantic color values are centralized in `core/theme/`.
- [ ] Standard Material roles are mapped into coherent light and dark `ColorScheme`s.
- [ ] Non-standard semantic roles are available through a theme-owned API such as `ThemeExtension`.
- [ ] `ThemeData` uses Material 3 and Vazirmatn in both brightness modes.
- [ ] Scaffold, surfaces, text, borders, actions, inputs, progress, and current common components render coherently in light and dark.
- [ ] Feature code does not receive new raw palette literals.
- [ ] Placeholder M0 theme comments/identifiers are removed or updated accurately.

### Appearance state and persistence

- [ ] Supported modes are exactly `System`, `Light`, and `Dark`.
- [ ] Default is `System`.
- [ ] Missing preference falls back to `System`.
- [ ] Invalid preference falls back safely to `System`.
- [ ] Valid stored mode is restored deterministically without a visible theme flash.
- [ ] Changing mode updates the application immediately.
- [ ] Changing mode persists the stable serialized value.
- [ ] Preference failures do not crash startup and do not expose raw details.
- [ ] Appearance state is owned by a focused Riverpod controller/provider.
- [ ] Widgets do not call `shared_preferences` directly.
- [ ] Preference storage is non-sensitive and not stored in `SecureStore`.

### Application integration

- [ ] `MaterialApp.router` configures light theme, dark theme, and Riverpod-driven theme mode.
- [ ] `fa-IR` and RTL root assertions continue to pass.
- [ ] Router/auth/session behavior remains unchanged.
- [ ] Existing Home and auth screens remain usable in light and dark without layout redesign.
- [ ] Fatal-startup UI responds coherently to system brightness and remains deterministic.
- [ ] No Settings/Profile/Notifications/shell/module UI is introduced.

### Accessibility and visual verification

- [ ] Required text/accent/error/success color pairs meet WCAG AA contrast targets defined by the approved palette.
- [ ] A test covers 320dp width without overflow for the scoped theme specimen/current root surface.
- [ ] A test covers 2.0 text scale without clipping/overflow for the scoped theme specimen/current root surface.
- [ ] New light and dark Persian RTL goldens are added for a focused theme specimen or stable existing surface.
- [ ] Golden harness uses the bundled Vazirmatn font rather than silently accepting the test font where practical with stock Flutter tooling.
- [ ] Existing unrelated goldens are not rebaselined.

### Documentation and architecture

- [ ] No new ADR or architecture version bump is made.
- [ ] README/current-state documentation accurately reports M03_WP02 implemented.
- [ ] M03_WP07 visual hardening remains pending.
- [ ] Exact next package is M03_WP03 — Guest-first routing and phone-only authentication.
- [ ] This prompt is committed under `docs/prompts/`.
- [ ] No inventory entry is added before external review.

### Repository quality

- [ ] Diff remains within scope.
- [ ] No generated file is hand-edited.
- [ ] No secret, account data, raw exception, debug print, unexplained TODO, or unrelated refactor is introduced.
- [ ] Current Composer/runtime fixes remain intact.
- [ ] All applicable quality gates pass or are reported as not run with exact environment reason.

---

## REQUIRED TESTS

### Unit — semantic tokens and theme construction

Add focused tests that verify:

- exact light palette values;
- exact dark palette values;
- light/dark `ColorScheme.brightness`;
- scaffold/background and primary surface mapping;
- primary/secondary text mapping;
- accent/on-accent mapping;
- border, subtle selection, error, and success semantic access;
- Vazirmatn font family on representative text roles;
- semantic spacing/radius/motion/touch-target token invariants;
- no accidental equality between essential light/dark surfaces that should differ.

### Unit — contrast

Use a deterministic contrast-ratio helper in tests and verify at least:

- light primary text on app background;
- light secondary text on primary surface;
- light content on brand accent;
- light error and success on a valid documented surface;
- dark primary text on app background;
- dark secondary text on primary surface;
- dark content on brand accent;
- dark error and success on a valid documented surface.

Use WCAG AA thresholds appropriate to normal text for the tested pairs. Do not change approved colors merely to make a weak or incorrectly chosen test pair pass; test the intended pairings.

### Unit — preference adapter/controller

Use an in-memory fake facade for controller tests. Cover:

- absent key → `System`;
- stored `system` → `System`;
- stored `light` → `Light`;
- stored `dark` → `Dark`;
- unknown/corrupt value → safe `System` fallback;
- setting each mode changes state;
- setting each mode writes its stable string;
- repeated selection does not produce incorrect state or duplicate side effects beyond the chosen documented policy;
- read/write failure degrades safely and exposes no raw error to widgets.

Test the concrete adapter only to the extent possible without brittle plugin integration; do not make unit tests depend on device storage. Override the facade/provider in tests.

### Widget — root application

Cover:

- `LaforikaApp` still uses `fa-IR` and RTL;
- default appearance is `ThemeMode.system`;
- stored/overridden light mode produces a light root theme;
- stored/overridden dark mode produces a dark root theme;
- changing the controller mode updates the rendered root theme;
- existing startup/auth/Home routing behavior is unchanged for the current baseline;
- no theme-loading screen or auth flash is introduced.

### Widget — failure surface

Cover:

- fatal-startup surface in light system brightness;
- fatal-startup surface in dark system brightness;
- no raw exception/config/preference detail is rendered;
- localization and RTL remain correct.

### Widget — width and text scale

At minimum:

- pump a scoped theme specimen or stable current root surface at 320 logical pixels wide;
- pump at text scale 2.0;
- assert no Flutter overflow/error exception;
- ensure controls remain at least 48dp where the specimen includes controls;
- avoid fixed-height test fixtures that conceal real clipping.

### Golden / RTL — owner-approved limited baseline

The owner approved new visual baselines for M03_WP02 limited to the theme foundation.

Add exactly scoped new golden coverage, preferably a test-only theme specimen that exercises:

- app background;
- primary/secondary/elevated surfaces;
- primary/secondary text;
- representative text roles;
- primary, secondary, and disabled actions;
- a text field;
- border/divider;
- subtle selection;
- error and success states;
- progress/selected accent;
- Persian RTL direction.

Generate:

- one light RTL baseline;
- one dark RTL baseline.

Rules:

- Use a fixed, documented test surface size and pixel ratio.
- Load Vazirmatn from bundled assets in the golden harness using stock Flutter test APIs.
- Do not add a golden toolkit dependency.
- Do not update unrelated existing goldens.
- Run `flutter test --update-goldens` only for the targeted new golden test(s), inspect the images, and then run normal `flutter test`.
- Report the exact golden command and files created.

### Integration

Because root bootstrap and application wiring change, run the existing dev Android-emulator auth integration flow against the real local backend when the required environment is available:

```powershell
flutter test integration_test/auth_flow_test.dart --flavor dev `
  --dart-define=APP_FLAVOR=dev `
  --dart-define-from-file=config/dev.json `
  --dart-define=FIXTURE_INBOX_KEY=<from-backend-env> `
  -d <emulator-id>
```

Do not change the auth integration scenario to fit the theme package. If environment constraints prevent it, report the exact blocker and do not claim it passed.

---

## CONSTRAINTS

- Follow `app → features → core` boundaries.
- `core/` must remain product-agnostic and must not import `features/` or `app/`.
- Do not create a new feature for appearance; this is app-wide infrastructure in `core/theme` and `core/storage`.
- Riverpod remains state and DI.
- No service locator.
- No Fluent UI package.
- No additional state, storage, design-system, responsive, golden, icon, or animation dependency.
- No raw palette values in features.
- No user-facing text is added unless absolutely required; any added text must use ARB/gen_l10n.
- Do not hand-edit generated localization or JSON-serialization files.
- Do not change auth, routes, backend, API, schema, platform identity, flavors, CI, signing, deployment targets, or toolchain.
- Do not modify historical migrations.
- Do not resolve O2–O6 or O8.
- Do not invent external branding assets or production modules.
- Preserve public contracts unless a narrowly scoped theme API replacement is internal and all usages/tests are updated atomically.
- Preserve existing runtime/build fixes from the current branch.
- Check-in mode: branch + atomic commits + PR + CI + reviewed source archive; inventory only after external approval.

---

## STOP CONDITIONS

Stop before editing or during implementation and report clearly if:

1. M03_WP01 is not merged and inventoried.
2. The current default branch is dirty, behind remote, or contains unexplained changes.
3. The M03_WP01 milestone declaration correction is absent.
4. Architecture v1.4 / ADR-0009 / UI foundation docs are missing or conflict materially.
5. Implementing appearance persistence appears to require another storage technology.
6. The selected `shared_preferences` version requires a Flutter/Dart toolchain upgrade.
7. A backend, auth, routing, CI, platform, deployment, or owner-decision change becomes necessary.
8. Current Composer fixes would need to be reverted to proceed.
9. Approved palette values fail contrast only because the implementation maps them to an unintended surface pairing; stop and report rather than silently alter the palette.
10. A golden baseline cannot be produced deterministically with the existing toolchain without adding an unapproved dependency.
11. Any secret, real account data, local `.env`, signing material, or machine-specific configuration is staged.

---

## STEP 0 — INSPECT

1. Read every authoritative document listed above.
2. Confirm M03_WP01 completion and the exact base commit.
3. Inspect `pubspec.yaml` and `pubspec.lock` for dependency compatibility.
4. Inspect bootstrap/provider lifetime behavior and preserve existing fixes.
5. Inspect every current use of `AppTokens`, `buildAppTheme`, `Theme.of`, raw colors, `TextStyle`, and fixed heights.
6. Inspect current tests and determine the smallest test support additions.
7. Inspect CI and local build conventions, including known Android mirror/VPN limitations.
8. Inspect whether any goldens already exist; do not overwrite unrelated baselines.
9. Confirm no generated code or ARB changes are necessary.
10. Report any blocker before editing.

---

## STEP 1 — PLAN

Return a concise implementation plan before editing that includes:

- actual base commit SHA;
- branch name;
- chosen theme/palette structure;
- chosen `PrefsFacade` surface;
- appearance initialization strategy and why it avoids visible theme flash;
- Riverpod provider/controller ownership;
- expected production files;
- expected test files;
- golden specimen strategy and filenames;
- documentation updates;
- commands to run;
- architecture/ADR impact (`none; implements existing v1.4/ADR-0009` expected);
- any deviations from this prompt.

Proceed without waiting only when no `AGENTS.md` guardrail or stop condition blocks the task.

---

## STEP 2 — IMPLEMENT

1. Create branch:

   ```text
   feat/m03-wp02-theme-foundation
   ```

2. Add the approved dependency and minimal preference facade.
3. Add appearance model/controller/provider and deterministic initialization.
4. Replace placeholder theme infrastructure with semantic light/dark themes.
5. Wire the root app and fatal-startup surface.
6. Preserve current routing/auth/Home behavior.
7. Add tests with implementation.
8. Add targeted light/dark RTL golden baselines under the approved scope.
9. Persist this prompt under `docs/prompts/`.
10. Reconcile current-state docs without changing architecture direction.
11. Keep the diff strictly within package scope.
12. Never hand-edit generated files.

Recommended atomic commit shape, adjustable after inspection:

```text
feat(theme): add semantic light and dark appearance foundation
test(theme): cover persistence contrast and visual baselines
docs(theme): record M03_WP02 implementation state
```

Do not create an inventory commit yet.

---

## STEP 3 — VERIFY

Run and report real results for every applicable command.

### Dependency and generation hygiene

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code -- lib/l10n/generated lib/features/auth/data
```

Generated-code commands may be reported not applicable only after inspection demonstrates no source inputs changed. Do not hand-edit generated output.

### Formatting, analysis, tests, boundaries

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

### Targeted golden generation

Run the exact targeted golden test with baseline update, inspect the generated files, then rerun the normal test suite. Example command shape:

```powershell
flutter test test/core/theme/<theme_golden_test>.dart --update-goldens
flutter test test/core/theme/<theme_golden_test>.dart
```

Report the actual path and command used.

### Local flavor debug APK matrix

```powershell
foreach ($FLAVOR in @("dev", "staging", "prod")) {
  flutter build apk --debug --flavor $FLAVOR `
    --dart-define=APP_FLAVOR=$FLAVOR `
    --dart-define-from-file="config/$FLAVOR.json"
}
```

Do not modify CI to add APK artifacts. Preserve the owner-approved CI quota deviation.

### Android-emulator integration

Run the current dev auth integration against the real local backend when available, using the repository README command and actual emulator ID.

### Manual verification

On an emulator/device where practical, verify:

- System mode follows OS light/dark changes;
- light and dark current screens remain readable;
- Persian RTL remains correct;
- no visible theme flash during launch;
- no change to auth/session navigation behavior;
- no overflow at 320dp and large text for the scoped surface.

Do not claim any command or manual check passed unless it was actually performed. Report exact environment limitations.

### Diff inspection

Before committing and before archive export:

```powershell
git status --short
git diff --stat
git diff
```

Confirm:

- no backend/auth/router/Home redesign changes;
- no secret or machine-specific file;
- no unrelated generated diff;
- no unapproved dependency;
- no existing golden rebaseline outside scope;
- no regression/reversion of Composer runtime fixes.

---

## STEP 4 — CHECK IN AND REVIEW WORKFLOW

Follow the terminating workflow in `AGENTS.md` exactly.

### Implementation review stage

1. Commit atomic implementation/test/docs changes on `feat/m03-wp02-theme-foundation`.
2. Push and open/update one PR.
3. Use Conventional Commits.
4. Use the `AGENTS.md` PR body.
5. Wait for CI (`backend` + `quality`) to finish green.
6. Create a clean source archive from the exact PR-head implementation commit:
   - tracked source/documentation only;
   - exclude `.git`, build outputs, caches, secrets, local configuration, test databases, keys, and signing files;
   - filename pattern:

     ```text
     laforika-m03-wp02-theme-<short-sha>-src.zip
     ```

7. Report archive filename and exact commit SHA.
8. Stop for owner/external review.
9. Do not merge.
10. Do not update `docs/project_inventory.md` yet.

### After external approval

1. Apply review fixes on the same branch.
2. Push and obtain final green CI.
3. Update `docs/project_inventory.md` exactly once for M03_WP02.
4. Inventory entry must record only:
   - work package: M03_WP02 — Light/dark theme foundation;
   - PR number;
   - final reviewed implementation commit SHA before inventory update;
   - completed scope;
   - actual verification results;
   - remaining limitations/owner decisions;
   - exact next package: M03_WP03 — Guest-first routing and phone-only authentication.
5. Do not record inventory commit SHA, merge SHA, branch status, or pending-merge wording.
6. Commit and push the inventory update.
7. Rerun applicable CI.
8. Merge only after green CI and explicit owner approval.

---

## PR BODY REQUIREMENTS

Use the repository PR template shape and include:

```markdown
## Summary
- Implements M03_WP02 semantic light/dark Material 3 theme foundation.
- Adds System/Light/Dark Riverpod appearance state with shared-preferences persistence.
- Adds scoped RTL, contrast, large-text, and golden coverage.

## Related
- M03_WP02
- ADR-0009

## Changes
-

## Testing
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter analyze --fatal-infos`
- [ ] `flutter test`
- [ ] `dart run tool/check_import_boundaries.dart`
- [ ] Targeted golden generation + normal golden test
- [ ] `dev`, `staging`, `prod` debug APK builds
- [ ] Dev Android-emulator auth integration
- [ ] Manual light/dark/System + RTL verification

## Screenshots
- Light RTL theme specimen
- Dark RTL theme specimen

## Notes for reviewer
- No auth, routing, Home shell, backend, settings UI, or architecture-direction changes.
- M03_WP03 remains next.
```

Use actual results, not prechecked claims.

---

## REPORT BACK

Return a concise report containing:

- **Status:** done / partial / blocked
- **Base commit:** actual SHA
- **Branch:** actual branch
- **Summary:**
- **Files changed:**
- **Dependencies added:**
- **Theme structure:** semantic tokens, ThemeExtension/equivalent, light/dark builders
- **Appearance persistence:** facade, key, serialization, failure behavior
- **Tests added/updated:** unit, widget, contrast, width/text-scale, golden, integration
- **Golden files:** exact paths
- **Commands and results:** pass/fail/not run with reasons
- **Manual verification:** actual device/emulator and results
- **CI:** job names and result
- **Architecture/ADR impact:** expected `none; implements architecture v1.4 / ADR-0009`
- **Approved deviations:**
- **Preserved Composer/runtime fixes:** confirmation after diff review
- **Blockers or follow-ups:**
- **Archive:** exact filename and reviewed implementation commit SHA
- **Inventory status:** not updated before review
- **Exact next package:** M03_WP03 — Guest-first routing and phone-only authentication

Do not overstate visual hardening: M03_WP07 remains responsible for final full-app light/dark RTL goldens, broad 320dp/2.0 text-scale coverage, and integration hardening.
