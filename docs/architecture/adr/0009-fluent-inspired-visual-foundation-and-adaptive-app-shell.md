# ADR-0009 — Fluent-inspired visual foundation and adaptive app shell

**Status:** Accepted · **Date:** 2026-07-25

## Context

O7 previously left branding as a neutral placeholder theme. Module growth after M2 requires a
stable, RTL-first application shell and a coherent light/dark visual foundation before shell and
theme implementation packages begin. Owner-approved direction uses Windows 11 / Fluent as visual
inspiration while remaining a Laforika-owned design system implemented with Flutter Material 3
semantic tokens—not a Windows clone or a Fluent UI framework dependency.

## Decision

### Visual foundation

- Adopt a Windows 11 / Fluent-inspired but Laforika-owned semantic light and dark visual system.
- Implement through Laforika-owned semantic tokens and Flutter Material 3 `ThemeData`.
- Do not add Microsoft assets, proprietary icons, copied artwork, or a Fluent UI framework
  dependency.
- Appearance options are `System`, `Light`, and `Dark`. Default appearance is `System`.
- Vazirmatn remains the Persian UI typeface. Persian `fa-IR` and RTL remain first-class from the
  application root.
- Freeze the semantic palette and related foundation rules in
  [`../../design/UI_FOUNDATION.md`](../../design/UI_FOUNDATION.md).

### Adaptive application shell

- Home is selected on first app load after session restoration; no module and no module-internal
  tabs are active on Home.
- Selecting a module clears bottom-dock selection, highlights the module in the top strip, shows
  contextual internal tabs, and selects the first tab unless a reconstructable deep link selects
  another valid tab.
- Home search is application-wide across content the current user may access; module search is
  scoped to the active module.
- The top module strip is horizontally scrollable, RTL-aware, and transitions between expanded
  (icon + title) and compact (title-only) states while preserving selection and scroll position.
- The floating bottom dock exposes exactly three approved destinations today: Home, Chat, and
  Profile, with documented selection and RTL swipe rules.
- Profile, Settings, and Notifications follow the access and header rules in
  [`../../design/APP_SHELL.md`](../../design/APP_SHELL.md).
- Module ordering, pinning, recents, personalization, and a speculative module-registry framework
  are deferred until a concrete need.
- Accessibility, motion, RTL directional layout, text scale, and phone-first responsive
  constraints are frozen in the design specifications.

### O7 status

- **Resolved** for the in-app visual system, semantic palette, typography direction, and shell
  behavior documented here and in the design specifications.
- **Deferred:** logo, launch icon, store icon, marketing identity, illustrations, and other
  external brand assets.

## Alternatives rejected

- **Literal Windows clone or Microsoft assets.** Rejected: brand and legal risk; not Laforika-owned.
- **Fluent UI package dependency.** Rejected: unnecessary load-bearing dependency for a Flutter
  Material 3 app.
- **Light-only theme.** Rejected: owner-approved System/Light/Dark with System default.
- **Module tabs on Home or keeping Home selected while a module is active.** Rejected: conflicts
  with the approved shell state model.
- **Unbounded static module row.** Rejected: does not scale; adaptive compact/expanded strip is
  required.
- **Dead placeholder module or Chat destinations.** Rejected: production ships only real
  registered destinations.

## Consequences

- Theme token and Material 3 light/dark implementation belongs to WP1.
- Adaptive shell, dock, and selection-state implementation belongs to WP3.
- Profile / Settings / Notifications vertical slices belong to WP4–WP5.
- Current placeholder light theme and authenticated Home shell may temporarily differ until those
  packages land; new work must follow the approved target, not extend the placeholder direction.
- External brand assets remain an open O7 remainder and must not be invented in implementation
  packages unless separately approved.

## Revisit when

- External brand assets (logo, store icon, marketing) are approved.
- Additional bottom-dock destinations or shell regions are product-approved.
- A concrete need justifies module personalization/persistence infrastructure.
- Accessibility or platform constraints require changing motion, translucency, or contrast rules.
