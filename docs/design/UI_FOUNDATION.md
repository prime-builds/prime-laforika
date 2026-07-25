# Laforika — UI Foundation

**Status:** Approved target specification · **Date:** 2026-07-25 · **Implements in:** WP1 (theme tokens), WP6 (visual hardening)

This document freezes the in-app visual foundation. It is **not** permission to claim these tokens
are already implemented in code. Current M0–M2 theme code remains a neutral placeholder until WP1.

## 1. Authority

| Document | Role |
|---|---|
| [`../architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) | Single source of truth for product architecture |
| [`../architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md`](../architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md) | Decision and rationale for visual system + shell |
| [`APP_SHELL.md`](./APP_SHELL.md) | Adaptive shell, dock, and route-state behavior |
| [`../../AGENTS.md`](../../AGENTS.md) | Operational guardrails for implementation agents |

When documents disagree, `ARCHITECTURE.md` wins. Material visual-system changes require a new or
superseding ADR and an architecture version bump.

## 2. Brand attributes

Laforika's in-app presence should feel:

- **Calm** — restrained accent usage; quiet surfaces
- **Trustworthy** — clear hierarchy, predictable states, accessible contrast
- **Culturally familiar** — Persian-first typography and RTL layout
- **Modern** — Fluent-inspired geometry and depth without literal Windows chrome
- **Useful** — content and tasks outrank decoration

## 3. Windows 11 / Fluent inspiration boundaries

**Use as inspiration:** restrained accent, calm neutral surfaces, rounded geometry, subtle depth,
separate light/dark neutral ramps.

**Do not:**

- reproduce Windows literally;
- ship Microsoft assets, proprietary icons, or copied artwork;
- add a Fluent UI framework dependency;
- hardcode Windows system colors in feature widgets.

Implement through **Laforika-owned semantic tokens** mapped into Flutter Material 3 `ThemeData`.

## 4. Semantic light / dark palette

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

These values are design tokens for the theme layer. Feature widgets consume theme/token APIs, not
raw hex literals.

## 5. Semantic token rules

- Define colors, spacing, radius, elevation, and type roles as named tokens in `core/theme/`.
- Map tokens into Material 3 `ColorScheme` / `ThemeData` (and dark equivalents).
- Feature code uses `Theme.of(context)`, text theme roles, and shared tokens — never ad-hoc
  feature palettes.
- Selected state must not rely on color alone; combine accent with shape/indicator and icon
  treatment (see shell spec).
- Translucent surfaces must keep text/icon contrast at or above accessibility targets; blur is a
  progressive enhancement only.

## 6. Appearance modes

| Mode | Behavior |
|---|---|
| `System` | Follow platform brightness (**default**) |
| `Light` | Force light semantic palette |
| `Dark` | Force dark semantic palette |

Persistence uses the approved preferences facade (`PrefsFacade` / `shared_preferences`) when WP1
implements selection. Language switching is not introduced; `fa-IR` remains the only configured
locale.

## 7. Typography

- **Typeface:** Vazirmatn (bundled; OFL).
- **Roles:** display, title, body, label — defined as a type scale in `core/theme/`.
- **Approved weights for UI:** Regular (400), Medium (500), SemiBold (600). Prefer Medium/SemiBold
  for emphasis over inventing display decorative styles.
- Features use scale tokens, not one-off `TextStyle`s.
- Format displayed numerals through `intl`; store and compute with Latin digits.

## 8. Spacing, radius, border, elevation, translucency

| Concern | Rule |
|---|---|
| Spacing foundation | 8dp grid |
| Semantic spacing tokens | e.g. 8 / 16 / 24 / 32 (names owned by theme layer) |
| Normal page padding | starts at 16dp |
| Standard component radius | 12–16dp |
| Floating dock radius | approximately 24–28dp |
| Borders | 1dp semantic border/divider color; avoid heavy outlines |
| Elevation | restrained Material elevation / subtle shadow; calm depth |
| Translucency | allowed for dock/surfaces; readability must not depend on blur |

## 9. Icons

- Use one consistent icon family across the app shell.
- Inactive: outline / lower emphasis.
- Selected: stronger weight and/or filled treatment plus non-color indicator.
- Mirror directional affordances in RTL.
- Every icon-only control has a localized semantic label and ≥48dp touch target.

## 10. Motion

- Standard state transitions: approximately **180–250ms**.
- Motion explains state changes (expand/compact strip, dock selection, page enter).
- Avoid decorative bouncing, large parallax, or long transitions.
- Respect reduced-motion / system accessibility preferences where Flutter exposes them.

## 11. Accessibility and contrast

- Target **WCAG AA** contrast for text and essential icons on semantic surfaces.
- Minimum touch target: **48dp**.
- Support text scaling without fixed-height clipping; verify at **2.0** text scale.
- Add `Semantics` / semantic labels for icon-only controls and meaningful images.
- Verify theme and shell states in **light and dark** and in Persian RTL.

## 12. Responsive behavior

- Phone-first. Verify at **320dp** width.
- Use the small shared breakpoint set in `core/theme/` when needed.
- Do **not** add a heavy responsive framework.
- Prefer `LayoutBuilder` / `MediaQuery` over speculative adaptive packages.

## 13. Component state checklist

Implementations and visual tests should cover, where applicable:

| State | Required |
|---|---|
| Default | yes |
| Selected | yes (non-color-only) |
| Pressed | yes |
| Focused | where keyboard/focus applies |
| Disabled | yes |
| Loading | yes |
| Empty | yes |
| Error | yes |
| Offline | when the surface has network-dependent content |
| Long text | yes (no overflow crash; graceful wrap/ellipsis policy) |
| Large text (2.0 scale) | yes |
| Light and dark | yes |

## 14. Explicitly deferred

- Final logo, launch icon, store icon, marketing identity
- Illustrations and external brand assets
- Module-specific accent palettes
- Push-provider visuals (O3 unresolved)
- Speculative design-system component catalogs beyond proven repeated use

## Related implementation packages

| Package | Scope |
|---|---|
| WP1 | Semantic tokens, Material 3 light/dark, System/Light/Dark + persistence |
| WP3 | Shell geometry consuming these tokens |
| WP6 | Goldens, 320dp, 2.0 text scale, contrast hardening |
