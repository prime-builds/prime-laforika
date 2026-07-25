# Laforika — Application Shell

**Status:** Approved target specification · **Date:** 2026-07-25 · **Implements in:** WP3 (shell), WP2 (guest routing), WP4–WP5 (Profile/Settings/Notifications), WP6 (hardening)

This document freezes adaptive shell behavior. It is **not** implemented by WP0. Diagrams use
generic labels only (`Module 1`, `Item 1`). Do not invent production modules or dummy content.

Authority: [`../architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md),
[ADR-0009](../architecture/adr/0009-fluent-inspired-visual-foundation-and-adaptive-app-shell.md),
[`UI_FOUNDATION.md`](./UI_FOUNDATION.md), [`../../AGENTS.md`](../../AGENTS.md).

---

## 1. Shell scope and hierarchy

```text
Application shell
├─ Top: adaptive module strip (Home/module surfaces only)
├─ Search field (Home/module surfaces only)
├─ Contextual internal tabs (module surfaces only)
├─ Main body
└─ Floating bottom dock: Home · Chat · Profile
```

Chat, Profile, Settings, and Notifications use their own focused page headers. The Home/module
discovery header does **not** automatically appear on those destinations.

Feature route barrels remain the integration boundary. Production ships **real registered
destinations only** — no dead dock actions, no dummy module cards, no speculative module registry.

---

## 2. RTL visual order

Persian RTL is first-class. Implementation uses directional APIs (`EdgeInsetsDirectional`,
`AlignmentDirectional`, `start`, `end`). Hardcoded left/right placement is forbidden in
implementation guidance except as parenthetical visual clarification.

Bottom dock visual order (RTL):

```text
[ Profile ]  [ Chat ]  [ Home ]
   visual left          visual right
```

---

## 3. Home / module header row order

On Home and module surfaces, top-to-bottom:

1. Horizontally scrollable adaptive module strip
2. Search field
3. Horizontally scrollable internal tabs **only when a module is selected**
4. Main page body

---

## 4. Adaptive module strip

| State | Appearance |
|---|---|
| Expanded | Larger rounded item: module icon + localized title |
| Compact | Smaller rounded chips: localized title only (icons removed) |

Behavior:

- Horizontally scrollable and RTL-aware.
- As the main content scrolls upward, items transition expanded → compact.
- Transition preserves the **selected module** and **horizontal scroll position**.
- Module ordering, pinning, recents, personalization, and persistence are **deferred**.
- Do not create a speculative module-registry framework.

---

## 5. Search scope

| Context | Search scope |
|---|---|
| Home (no module selected) | Application-wide across content the current user is allowed to access |
| Active module | Scoped to that module |

---

## 6. Contextual internal tabs

- Appear **only** when a module is active.
- Do **not** appear on Home.
- Entering a module selects the **first** internal tab unless a reconstructable deep link selects
  another valid tab.
- Main body renders the selected module tab/page.

---

## 7. Floating bottom dock

### Structure

- Fixed near the bottom safe area.
- Centered rounded capsule (~24–28dp radius).
- Slightly translucent, theme-aware surface with thin border and restrained elevation.
- Blur may be used only as progressive enhancement; readability cannot depend on blur.
- Exactly three icon-only destinations in the current approved shell:
  - **Home** — visual right
  - **Chat** — center
  - **Profile** — visual left
- Every icon-only action: localized semantic label + ≥48dp touch target.
- Tapping an icon navigates directly.

### Selection rules

| Active destination | Dock selection |
|---|---|
| Home | Home selected |
| Chat (including protected-login state) | Chat selected |
| Profile (including guest phone-login state) | Profile selected |
| Settings / Notifications under Profile context | Profile selected (parent dock context) |
| Any active module | **No** dock destination selected |

Selected state must combine accent, shape/indicator, and icon treatment — not color alone.

### RTL swipe mapping

Horizontal swiping across the dock follows visual RTL adjacency and **must not wrap**:

| Swipe toward | Sequence |
|---|---|
| Visual left | `Home → Chat → Profile` |
| Visual right | `Profile → Chat → Home` |

---

## 8. Public / protected destination behavior

| Destination | Access | Guest behavior |
|---|---|---|
| Home | Public | Enter after session restoration |
| Public modules / public content | Public | Explorable without login |
| Chat | Protected | Phone OTP with Chat preserved as return destination |
| Notifications | Protected | Phone OTP with Notifications preserved |
| Profile | Guest-accessible shell destination | Show phone OTP directly; Profile stays selected |
| Settings | Guest-accessible | Available to guests |

No fake guest account, anonymous backend principal, guest access token, or guest database scope.

If no real Chat route exists when WP3 is implemented, WP3 must not ship a dead dock action; it must
stop for a scoped product decision or omit the unavailable action until a real destination exists.

---

## 9. Profile states

### Guest Profile

- Profile remains selected in the bottom dock.
- Show the **phone-number OTP** login experience directly.
- Do **not** show an auth-method chooser.
- Do **not** offer email/password login.
- Settings remains accessible to guests.

### Authenticated Profile

- Avatar placeholder only (upload not approved).
- Editable: first name, last name, optional email contact field.
- Verified phone number: read-only with verification indicator.
- Explicit save, validation, loading, error, and success states.
- Logout and account/security actions lower in the page hierarchy (not primary header action).
- Validation lengths and backend constraints come from the real WP4 API/domain design — do not
  invent limits here.

### Profile header (directional)

| Action | Directional placement | Visual (RTL) |
|---|---|---|
| Settings | `start` | top-right |
| Notifications | `end` | top-left |

Notifications may show an unread badge when real notification data exists.

---

## 10. Settings and Notifications

### Settings (guest-accessible)

Initially documents:

- Appearance: System / Light / Dark
- App / about information
- Account/security and Logout **only when authenticated**

No language switcher. No speculative settings catalog.

### Notifications (protected)

- Guests enter phone OTP with Notifications preserved.
- Initial implemented states: loading, empty, error, data — when a real notification source exists.
- O3 remains unresolved. Do not add FCM, a regional push SDK, permissions, background handlers,
  tokens, or push-provider configuration in WP0 or WP5 unless O3 is separately resolved.

---

## 11. Route-state matrix

| Session | Destination class | Result |
|---|---|---|
| `unknown` / hydration | any | Deterministic startup surface; no login flash |
| `unauthenticated` | public (incl. Home) | Allow |
| `unauthenticated` | protected (Chat, Notifications, …) | Phone OTP; preserve validated return destination |
| `unauthenticated` | Profile | Profile destination with direct phone OTP UI; Profile dock selected |
| `unauthenticated` | Settings | Allow |
| `authenticated` | public or protected | Allow |
| `authenticated` | auth-only OTP/login routes | Return to validated destination, else Home |

Preserved destinations must resolve to registered internal routes; external/malformed/unknown
locations are discarded. Client guards are UX; NestJS authorization is authoritative.

**Navigation-context selection:** Profile is the parent bottom-dock context for subordinate
Profile / Login / Settings / Notifications routes unless a future inspected route contract makes
that impossible — report conflicts before inventing a different rule.

---

## 12. Canonical visual states (generic labels)

Documentation-only ASCII states. Production must not ship dummy content.

### A. Home — expanded header

```text
+-------------------------------------------------+
| [Mod1 icon+title] [Mod2] [Mod3]     expanded    |
| +-------------- search (app-wide) -------------+|
| +----------------------------------------------+|
|                                                 |
|                 Home body content               |
|                                                 |
|            (( Profile · Chat · Home ))          |
|                         ^ Home selected         |
+-------------------------------------------------+
```

- No module selected · no internal tabs · Home dock selected

### B. Home — compact header

```text
+-------------------------------------------------+
| [Mod1] [Mod2] [Mod3]                compact     |
| +-------------- search (app-wide) -------------+|
| +----------------------------------------------+|
|              Home body (scrolled)               |
|            (( Profile · Chat · Home ))          |
+-------------------------------------------------+
```

### C. Module 1 / Item 1 — expanded header

```text
+-------------------------------------------------+
| [Module 1 icon+title] [Module 2] …  selected    |
| +------------ search (module-scoped) ----------+|
| +----------------------------------------------+|
| [ Item 1 ] [ Item 2 ] [ Item 3 ]       tabs     |
|                 Item 1 body                     |
|            (( Profile · Chat · Home ))          |
|                     ^ none selected             |
+-------------------------------------------------+
```

### D. Module 1 / Item 1 — compact header

```text
+-------------------------------------------------+
| [Module 1] [Module 2] …             compact     |
| +------------ search (module-scoped) ----------+|
| +----------------------------------------------+|
| [ Item 1 ] [ Item 2 ] [ Item 3 ]                |
|              Item 1 body (scrolled)             |
|            (( Profile · Chat · Home ))          |
+-------------------------------------------------+
```

---

## 13. Additional route states

### Chat — guest

- Chat dock selected.
- Direct phone OTP with Chat preserved as return destination.
- No method chooser · no email/password.

### Chat — authenticated

- Chat dock selected.
- Real Chat surface when the feature exists (not created by WP0/WP3 placeholders).

### Profile — guest

- Profile dock selected.
- Direct phone OTP UI.
- Settings still reachable.

### Profile — authenticated

- Profile dock selected.
- Editable profile fields + read-only verified phone.
- Settings (`start`) and Notifications (`end`) header actions.

---

## 14. Accessibility / semantics

- ≥48dp touch targets on dock and strip items.
- Localized semantics for every icon-only control.
- Selected state not color-only.
- Verify light/dark, RTL, 320dp width, and 2.0 text scale (WP6).
- Translucency must not drop contrast below WCAG AA targets.
- Respect reduced motion where Flutter exposes it.

---

## 15. Implementation boundaries

| Allowed | Forbidden |
|---|---|
| Real registered feature destinations | Dead Chat/module placeholder actions |
| Feature public barrels for routes | Cross-feature internal imports |
| Generic docs labels (`Module 1`) | Inventing production module names/content |
| Deferred personalization until needed | Speculative module registry / persistence |
| WP-scoped implementation packages | Claiming shell behavior done in WP0 |

---

## 16. Approved behavior vs deferred packages

| Behavior | Package |
|---|---|
| Theme tokens / System·Light·Dark | WP1 |
| Guest-first routing + phone-only auth | WP2 |
| Adaptive strip, search, tabs, dock | WP3 |
| Profile vertical slice | WP4 |
| Settings + Notifications | WP5 |
| Route matrix + visual hardening | WP6 |

WP0 documents only. Current authenticated-first Home and placeholder theme are known temporary
gaps until the packages above close them.
