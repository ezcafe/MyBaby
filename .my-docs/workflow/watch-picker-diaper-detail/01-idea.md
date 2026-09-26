# Idea: Center picker title + diaper detail dialog (Watch)

## Problem

Two Watch care UI gaps after the HIG pack:

1. **Picker title not centered** — Bottle / Pump `CustomMlPicker` title sits left-aligned; parents expect the title in the **horizontal center** of the sheet.
2. **Diaper one-tap with no detail** — Tapping Poop / Mixed (and diaper kind chips) saves immediately. On **my-apps baby home**, Wet/Dry save instantly, but **Poop / Mixed open a dialog** for color, texture, and amount before Save.

## User / audience

Parents logging care on **MyBaby Watch** who already use my-apps baby home diaper quick-care.

## Outcome

Done when:

1. `CustomMlPicker` title is **horizontally centered**.
2. Diaper kind taps follow **my-apps baby home** plan: Wet/Dry → instant save; Poop/Mixed → sheet/dialog for detail (color, texture, amount) then Save — same fields/meaning as web.
3. Unit tests cover picker title alignment contract and diaper tap → sheet vs instant plan.

## Metric

Unit: picker title uses center alignment; `plan`-style tests for Wet/Dry instant vs Poop/Mixed open sheet. Manual: open Bottle/Pump custom picker → title centered; tap Poop → detail sheet → Save logs with details.

## Has UI

**yes** — existing picker sheet + new diaper detail sheet on Watch.

## Lean / skip hints

- **Lean UI concept?** n/a — simple mode; Gate A/A2 skipped
- **Copy/token-only?** no (layout + new dialog behavior)

## 80/20 UI (day-to-day)

### Main user goals

- Log bottle/pump custom ml with a clear, centered sheet title.
- Log poop/mixed diaper with optional detail (color / texture / amount) without leaving Watch.

### Vital few

- Centered picker title.
- Poop/Mixed → detail sheet before save (parity with my-apps).

### Core actions

- Important #1: Wet/Dry one-tap save (unchanged speed).
- Important #2: Poop/Mixed → detail → Save.

## Non-goals

- Redesign full Diaper page layout / grid.
- Change Feed/Sleep/Pump business rules beyond picker title.
- New server schema (reuse existing GraphQL diaper detail fields if already supported).
- Resume / merge prior `watch-hig-ui` Gate C in this run.

## Assumptions to attack

- “Same as my-apps” means **S1 plan**: Wet/Dry instant; Poop/Mixed open sheet (not every diaper button opens a sheet).
- Watch GraphQL client can already send `diaperColor` / `diaperTexture` / `diaperAmount` (or can extend mutation variables without new public API shape) — confirm in Analyze.

## Success criteria

- [ ] Picker title centered horizontally
- [ ] Poop/Mixed open detail dialog; Wet/Dry still instant
- [ ] Detail fields align with my-apps (`lib/baby-diaper-detail.ts` + sheet)
- [ ] Tests for plan + picker title; smoke green

## Open questions

1. None blocking — Analyze confirms GraphQL payload field names and Watch sheet pattern (reuse Bottle/Pump `.sheet`).
