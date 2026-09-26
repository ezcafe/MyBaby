# UI concept (UI/UX designer): watch-hig-ui

**Result:** done
**Updated:** 2026-09-26
**Has UI:** yes

## Sources followed

| Source | Applied? | Notes |
|--------|----------|-------|
| Project `docs/DESIGN_GUIDE.md` / AGENTS.md UI rules | yes | Teal tokens, concentric radii via tokens |
| `clean-minimal-ui` skill | yes | Quiet teal / neutral |
| `frontend-ui-engineering` skill | yes | Hierarchy, a11y labels |
| Existing UI patterns in repo | yes | Care chips, gear sheet, connect presets |

## Concept depth

**full** — home pages, connect, Last care, complication.

## Align with Gate A (80/20)

| Item | From 01a / idea | How concept honors it |
|------|-----------------|-----------------------|
| Important info/action #1 | Primary care control | Breast L/R (Feed), Nap (Sleep) dominate |
| Important info/action #2 | Sense of place | Per-page gradient `containerBackground` + Crown page dots |
| Secondary | Bottle/Pump amounts, help, Settings | Bottle sheet; Need help?; gear |
| Top user journey | Raise → Crown → tap → Done | Vertical pages; one-screen Feed/Sleep |
| Sensible defaults | Land Feed | Page 1 = Feed |

## Screen / surface map

| Surface | Purpose | Primary actions |
|---------|---------|-----------------|
| Feed (vertical page) | Log breast / open bottle | L, R, Bottle |
| Bottle sheet | ml chips + Custom | 90 / 120 / 150 / Custom |
| Sleep | Start/stop nap | Nap chip |
| Last care | Glance primary + rows | Read-only |
| Connect | Pair | Local/Production, code, Save |
| Complication rectangular | Face / Smart Stack | Primary + secondary |

## UI references (required for Gate A2; confirm at Gate B without re-show)

| Surface | Variant | File path | Source | Preview URL | Shown at Gate A2? | Confirmed at Gate B? |
|---------|---------|-----------|--------|-------------|-------------------|----------------------|
| Feed | light | `ui-refs/_proposed-feed-vertical.html` | html-prototype | http://127.0.0.1:8765/_proposed-feed-vertical.html | yes | |
| Sleep | dark-ish | `ui-refs/_proposed-sleep-bg.html` | html-prototype | http://127.0.0.1:8765/_proposed-sleep-bg.html | yes | |
| Last care | light | `ui-refs/_proposed-last-care.html` | html-prototype | http://127.0.0.1:8765/_proposed-last-care.html | yes | |
| Connect | light | `ui-refs/_proposed-connect-short.html` | html-prototype | http://127.0.0.1:8765/_proposed-connect-short.html | yes | |
| Complication | light | `ui-refs/_proposed-complication-rect.html` | html-prototype | http://127.0.0.1:8765/_proposed-complication-rect.html | yes | |

Preview: <http://127.0.0.1:8765/_proposed-feed-vertical.html>

## Layout concept (plain words)

- **Hierarchy / eye flow:** Background tint → (optional short lead) → primary chips → tip/footer. Toolbar: gear + ProgressView when loading.
- **Core vs secondary:** Breast/Nap/Diaper kinds on page; Bottle ml + Pump amounts in sheets; Need help? disclosure on Connect.
- **Vertical nav:** Page indicator beside Crown (simulated dots on right); Feed first.
- **Materials:** Idle chips = frosted surface; running/done = solid accent; fail = danger surface.
- **Last care:** Large primary signal (timer / next feed), then 3 short status rows.
- **Complication:** Brand line optional tiny; one primary bold; one secondary caption.

## States

- Idle / running / done flash / fail+Retry (bottom toolbar Retry when fail)
- Updating: ProgressView in toolbar (no “Updating…” under header)
- Always On: keep timer subtitle high-contrast; mute decorative fill

## Skeleton parity

N/A — Watch (no web skeletons). Mount ±1 pages unchanged.

## Mobile / a11y notes

- Hit ≥44pt; VoiceOver labels keep chip identity on fail
- VerticalPage for Crown; avoid nested scroll on Feed/Sleep after density cut

## Style rules checklist

- Teal accent `#0D9488` light / `#2DD4BF` dark
- Outer radius 8 / nested 6
- No purple gradients; backgrounds convey page/urgency only

## Out of scope for this concept

- Care rule changes; new API shapes; Settings as a swipe page

## Handoff to Analyze / Design

- Implement `.verticalPage` + `containerBackground` per page/state
- Feed: Bottle sheet; Pump: timers on page, amounts in sheet
- App Group store for snapshot → widget timeline
- Connect: primary path only; Need help? disclosure
- Build must match these HTML files (size 198×242 watch frame, texts, chrome)
