# UI concept (UI/UX designer): watch-baby-care-home

**Result:** done
**Updated:** 2026-09-23 (Gate A2 approved — Feed+Bottle combined; Last care = page 5)
**Has UI:** yes

## Sources followed

| Source | Applied? | Notes |
|--------|----------|-------|
| Project DESIGN_GUIDE / AGENTS UI | missing in Watch repo | Tokens from prompt + clean-minimal |
| `clean-minimal-ui` | yes | Teal accent, hairline, 8/6 radius |
| Human Gate A2 | yes | Multipage swipe; Feed+Bottle one page; Approve |

## Concept depth

**full**

## Align with Gate A (80/20)

| Item | From 01a / idea | How concept honors it |
|------|-----------------|------------------------|
| #1 | Care chips | Page fills with that page’s controls |
| #2 | Header next/overdue | Per-page header; companions for glance |
| Journey | Glance → page → chip | Deep-link opens page index |
| Defaults | Sample status | Open-nap / next-feed samples |

## Screen / surface map

| Surface | Purpose | Primary actions |
|---------|---------|-----------------|
| `BabyHomeView` page `TabView` | Swipe L/R | Log care |
| **Page 1 — Feed + Bottle** | Breast L/R + bottle ml (stacked) | Start/stop breast; pick ml |
| **Page 2 — Sleep** | Nap timer | Start/stop nap |
| **Page 3 — Diaper** | 2×2 kinds | Log kind |
| **Page 4 — Pump** | L/R + ml | Log pump |
| **Page 5 — Last care** | Four status lines | Glance |
| Complications / Smart Stack | Primary signal / status rows | Deep-link / open app |

## Page order (locked — Gate A2)

1. Feed + Bottle (web Breast + Bottle stacked: Feed block then Bottle block; Crown scroll within page if needed)
2. Sleep (Nap)
3. Diaper
4. Pump
5. Last care (Decision 1 Option 1)

Page dots under title. No Settings / hamburger chrome.

## UI reference images

| File | Surface | Source |
|------|---------|--------|
| `watch-page-feed-bottle-light.png` | Page 1 Feed+Bottle | concept-draft — replace after Build |
| `watch-page-sleep-dark.png` | Page 2 Sleep running | concept-draft |
| `watch-complications.png` | Companions | concept-draft |
| `watch-smart-stack.png` | Smart Stack | concept-draft |

Retired: `watch-page-feed-light.png` (Feed-only).

## Layout / hierarchy (care pages 1–4)

1. Title `Baby Care` / `Baby Care · {n} months|days`
2. Page dots
3. Header (bold lead + next/overdue) → Controls → one Footer slot
4. Page 1 stacks Feed then Bottle (same three-slot pattern each; one footer for the active/pending owner — never tip+recovery)

## Tokens

Light/Dark teal system unchanged (`#FAFAFA`/`#171717`, accent `#0D9488`/`#2DD4BF`).

## Interaction notes

- Swipe pages; within Feed+Bottle page, vertical scroll if both blocks do not fit
- Deep link: `mybaby://home?page=feed|sleep|diaper|pump|status` (`feed` opens page 1)
- Timed / ml / diaper / haptics / auth stub as before
- Companions glance-only

## Out of scope

Growth, vaccines, Insights, Telegram, Settings, birthday modal, guidelines essay
