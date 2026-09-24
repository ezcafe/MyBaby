# Idea: Essay-aligned care recommendations (Watch + web)

**Updated:** 2026-09-24  
**Mode:** simple bootstrap (Gate A / A2 skipped)

## Problem

MyBaby Watch tips/chips are static sample English copy and do not follow baby age or the care essay. my-apps shows age-based header/footer tips and bottle chips, but some **code bands** disagree with the essay (e.g. newborn bottle ml). Caregivers get mixed advice between essay, web tips, and Watch.

## Outcome

1. **Both apps** use the **same essay-derived numbers** for age-stage recommendations (feed/bottle ml + feed counts, sleep totals / awake cues, diaper size tips, pump frequency/ml tips).
2. **MyBaby Watch** shows those recommendations on each care page (Feed, Bottle, Sleep, Diaper, Pump / Pump amount) by baby age (month/stage), same job as my-apps header/footer tips + chips.
3. **Watch supports English and Vietnamese** (system locale or equivalent existing pattern).
4. Essay long-form (Section I + five stages) stays the source of truth; VI essay may be refreshed from the user paste if it differs from shipped VI.

## Scope

- **my-apps:** Realign `baby-age-guide` / next-due / header-footer tip keys so operational recommendations match essay stage numbers; keep essay i18n in sync EN/VI.
- **MyBaby:** Age-stage tip resolver + bottle/pump chip snaps from essay bands; Localizable EN/VI strings for page tips/labels as needed; sample snapshot uses ageDays → stage.
- Keep existing Watch page chrome (header / controls / one footer).

## Non-goals

- Full essay browser / guidelines UI on Watch
- WHO percentile charts
- Seeded vaccine schedule product
- New GraphQL fields unless Analyze proves Watch cannot work offline/local with birthDate/ageDays already on snapshot
- Redesign of Watch layout or web home chrome

## Has UI

**yes** — tip/chip copy in existing slots (copy/token-only; no Gate A2).

## Acceptance (draft)

- [ ] For a fixed ageDays in each essay stage, web tip/chip numbers match essay for that stage
- [ ] Watch Feed/Bottle/Sleep/Diaper/Pump pages show matching stage tips (EN + VI)
- [ ] Unit tests cover stage→band mapping and key tip strings in both locales (or Watch equivalent)
- [ ] No tip + recovery footer stack regression on Watch

## Decisions already made

- Mode: simple / Review: lite
- Scope: both repos (align to essay)
