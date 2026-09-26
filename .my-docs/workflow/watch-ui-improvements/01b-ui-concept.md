# UI concept (UI/UX designer): watch-ui-improvements

**Result:** done  
**Updated:** 2026-09-26  
**Has UI:** yes  
**Note:** main-thread fallback — usage limit; lean concept

## Sources followed

| Source | Applied? | Notes |
|--------|----------|-------|
| Project DESIGN_GUIDE / AGENTS | missing in Watch repo | Use BabyTokens teal |
| `clean-minimal-ui` | yes | Teal, hairline, 44pt |
| Existing Watch patterns | yes | CareControls, AuthConnectView, fail HTML from prior workflow |

## Concept depth

**lean** — Settings sheet + fail/retry chip + Connect polish.

## Align with Gate A (80/20)

| Item | From 01a / idea | How concept honors it |
|------|-----------------|------------------------|
| #1 | Care chips + fail identity | Chip title stays Left/90 ml; subtitle Failed |
| #2 | Footer Retry | Retry button under statusFail |
| Secondary | Session | Gear sheet: host · Log out · Reconnect |
| Journey | Fail → retry; gear → logout | Surfaces below |
| Defaults | No Settings page | Strip ends at Last care |

## Screen / surface map

| Surface | Purpose | Primary actions |
|---------|---------|-----------------|
| Care Feed (fail) | Log + recover | Chips; Failed subtitle; footer Retry |
| Gear Settings sheet | Session | Host; Log out; Reconnect |
| Connect (polish) | Pair | Local/Production ≥44pt; danger error |

## UI references (Gate A2)

| Surface | Variant | File path | Source | Preview URL | Shown at Gate A2? |
|---------|---------|-----------|--------|-------------|-------------------|
| Feed fail + Retry | light | `ui-refs/_proposed-feed-fail-retry.html` | html-prototype | http://127.0.0.1:8765/_proposed-feed-fail-retry.html | yes |
| Settings sheet | light | `ui-refs/_proposed-settings-sheet.html` | html-prototype | http://127.0.0.1:8765/_proposed-settings-sheet.html | yes |
| Connect presets | light | `ui-refs/_proposed-connect-presets.html` | html-prototype | http://127.0.0.1:8765/_proposed-connect-presets.html | yes |

## Layout concept

1. **Fail chip:** Title = control identity (`Left`, `90 ml`). Subtitle = `Failed`. Danger border/surface. Footer: short reason + **Retry**.
2. **Settings sheet:** Overlay card — muted host line → **Log out** (danger outline) → **Reconnect** (accent). No sixth TabView page. Log out confirm = system confirm (not shown in HTML; note in Design).
3. **Connect:** Local/Production row height 44px; error text uses danger color; guide copy ≥11px.

## States

| State | Behavior |
|-------|----------|
| Idle success | Unchanged done flash |
| Send fail | Chip Failed subtitle + footer Retry |
| Live loading | Small ProgressView / “Updating…” near header (optional cue; Build may use toolbar) |
| Logged out | Connect gate (existing) |

## A11y / hit

- Chips ≥44pt; presets 44pt
- Accessibility labels: “Left breast, Failed, tap to retry” etc. (Build)

## Out of scope for concept

- Live widget chrome
- Page ordinal cue
