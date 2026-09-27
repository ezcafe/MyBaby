# UI concept (UI/UX designer): watch-complication-timer-status

**Result:** done
**Updated:** 2026-09-27
**Has UI:** yes

## Sources followed

| Source | Applied? | Notes |
|--------|----------|-------|
| Existing `BabyCareWidgets` / prior `_proposed-complication-rect.html` | yes | 162×68 rect; teal `#2DD4BF` |
| `BabyTokens` danger / accent | yes | Red `#F87171` dark; teal accent |
| Gate A 80/20 | yes | #1 value, #2 color/kind |
| `02-skim.md` | yes | App Group only; all four families |

## Concept depth

**lean** — one surface (complications) × three states.

## Align with Gate A (80/20)

| Item | From 01a / idea | How concept honors it |
|------|-----------------|-----------------------|
| Important #1 | Live timer or last-care time | Large primary in every family |
| Important #2 | Kind / teal vs red | Icon + color on value (and brand on rect) |
| Secondary | App logging | Rectangular secondary line only |
| Journey | Raise wrist glance | No chrome beyond accessory slots |

## Screen / surface map

| Surface | Purpose | Primary |
|---------|---------|---------|
| Circular | Face / Smart Stack glance | Icon + timer or relative time |
| Corner | Face corner | Short label + time |
| Inline | Face inline | Icon + short sentence |
| Rectangular | Face / Smart Stack | Brand + primary + one secondary |

## UI references (required for Gate A2)

| Surface | Variant | File path | Source | Preview URL | Shown at Gate A2? |
|---------|---------|-----------|--------|-------------|-------------------|
| All families × 3 states | dark accessory | `ui-refs/_proposed-complications.html` | html-prototype | http://127.0.0.1:8765/_proposed-complications.html | yes |

## Layout concept (plain words)

- **Timer running:** teal; live count-up from start date; kind = Nap / Breast / Pump.
- **Idle in range:** teal; “Last {kind} · {relative}”.
- **Idle out of range:** red (danger token); same last-care copy; rectangular secondary may say “Feed overdue”.
- **Rectangular sizes** match prior 162×68 proposal; circular ~44pt.

## States

| State | Color | Value |
|-------|-------|-------|
| Running timer | teal | `.timer` digits |
| Idle in range | teal | last care relative |
| Idle out of range | red | last care relative |

## Skeleton parity

N/A — Watch widgets.

## Mobile / a11y notes

- Tabular / monospaced digits for timers
- Color not sole cue: keep kind word/icon with red state
- Always On: prefer high-contrast red/teal over muted gray

## Out of scope for this concept

- APNs; in-app chip redesign; new widget kinds

## Handoff to Analyze / Design

- Extend App Group DTO with running breast/pump start (+ kind)
- Widget views: `Text(start, style: .timer)` when running
- Idle color from overdue / recommendation band
- Build must match `_proposed-complications.html` (sizes, texts, teal/red)
