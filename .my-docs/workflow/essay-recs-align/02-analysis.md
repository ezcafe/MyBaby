# Analysis: essay-recs-align

**Updated:** 2026-09-24  
**Mode:** simple · main-thread fallback (Analyze Task usage limit)

## Overall deep dive

### What is this?
Align **operational recommendations** (tips + bottle/pump chip snaps + related intervals) to the **care essay** in **my-apps** and **MyBaby Watch**, by baby age stage, with Watch **EN + VI**.

### Why do we need this?
Essay, web chips/tips, and Watch sample tips disagree today. Caregivers get different ml/sleep/diaper advice on the wrist vs phone vs long guide.

### How to do this?
1. Treat essay stages (`babyCareGuideStageForAge`: newborn / m1_3 / m3_6 / m6_12 / m12_24) as the **shared stage cuts**.
2. Realign my-apps feed ml bands + nap tip copy to essay numbers; keep diaper/pump footer keys stage-based (already close).
3. Add Watch **stage tip resolver** + **LocalizedString** EN/VI; drive chip snaps from ageDays (not only `[60,90,120]`).
4. Prefer **local** resolution (no new API) while Watch still uses sample/status snapshot with `ageDays`.

**Other ways:** GraphQL tip payload (premature); shared JSON codegen (nice later, heavier now).

**Best practices:** Keep one footer slot on Watch; mirror web tip jobs (header detail / footer tip); unit-test stage→numbers against essay fixtures; do not invent dosages beyond essay.

---

## Solution pieces (≤5)

### 1. my-apps feed / bottle bands → essay

| | |
|--|--|
| **What** | `FEED_GUIDE_BANDS` in `lib/baby-age-guide.ts` drive chips + suggested ml |
| **Why** | Day 0–2 `5–15` / week `60–90` disagree with essay bottle **30–60** (newborn) and **150–210** (3–6m) |
| **How** | Remap bands to essay stage ranges (and optional 1–2m vs 2–3m split inside m1_3). Update `baby-age-guide.test.ts` + chip tests. Keep history-first `buildBabyBottleChipMls`. |
| **Other** | Leave early-life colostrum-only band as non-chip “info” only — reject if it keeps chip ≠ essay bottle line |

### 2. my-apps sleep / interval tips → essay

| | |
|--|--|
| **What** | Nap header blends (`SLEEP_GUIDE_BANDS` + `home.header.nap.blend*`); awake windows in `baby-next-due.ts` |
| **Why** | Six blend bands (15–16h, 13–14h…) ≠ five essay sleep totals |
| **How** | Map blends (and keys) to five essay stages; newborn awake **45–60** → interval ~50–60 min OK. Update EN/VI strings. |
| **Other** | Keep six bands but rewrite strings to essay — worse; prefer five-stage alignment |

### 3. my-apps diaper / pump / breast footers

| | |
|--|--|
| **What** | `home.footer.diaper.*`, `home.footer.pump.*`, `home.footer.breastFeeds` via `babyCareGuideStageForAge` |
| **Why** | Already essay-shaped; verify VI paste parity; breast min/max from feed band |
| **How** | Audit strings vs essay; fix any drift; breast feeds from remapped bands |

### 4. MyBaby Watch tips by stage + EN/VI

| | |
|--|--|
| **What** | Snapshot tips today are hardcoded EN sample (`BabyHomeStatusSnapshot`) |
| **Why** | No age resolver, no Localizable |
| **How** | Swift `CareGuideStage` + tip tables (mirror web keys); `String(localized:)` / `Localizable.xcstrings` EN+VI; resolve from `ageDays` when building tips/chips for sample and future API |
| **Other** | Server-sent tip strings — **Has API yes**; skip until GraphQL live |

### 5. Watch bottle/pump snaps from essay bands

| | |
|--|--|
| **What** | `BabyBottleChipMls.noBirthSnaps = [60,90,120]` always |
| **Why** | Not age-aware; ≠ essay |
| **How** | `snapsForAge(ageDays)` from essay ml band (mid/edges like web); empty history → those snaps; no birth → keep usability snaps but label not “recommended” |

---

## Decision A — How to share numbers across repos

### Option 1 — Mirror tables (Swift copy of TS bands) *(recommended)*
- **What it is:** Duplicate essay stage→ml/tip keys in Swift; tests lock same fixtures.
- **Example:** Both map day 120 → m3_6 → bottle 150–210; Watch snaps `[150,180,210]`.
- **Pros:** Works offline/sample; no API; matches current Watch architecture.
- **Cons:** Two places to edit; drift risk (mitigate with shared fixture checklist in tasks/tests).

### Option 2 — GraphQL returns tips + snaps
- **What it is:** API adds tip fields / chip snaps by locale.
- **Example:** `babyHomeQuickStatus.tips.sleep` EN/VI.
- **Pros:** Single server source.
- **Cons:** Watch GraphQL not wired; blocks sample mode; **Has API yes**.

### Option 3 — Shared JSON package / codegen
- **What it is:** One JSON essay bands → TS + Swift codegen.
- **Example:** `care-guide-bands.json` in a shared folder.
- **Pros:** True single source.
- **Cons:** Tooling cost; cross-repo packaging for this simple run.

**Recommendation:** **Option 1** for this run. Revisit Option 3 later.

---

## Reusable patterns

| Pattern | Where |
|---------|--------|
| `babyCareGuideStageForAge` | `lib/baby-age-guide.ts` — reuse cuts on Watch |
| `buildBabyBottleChipMls` | TS + `BabyBottleChipMls` Swift — keep |
| Footer one-slot | Watch `CareFooterResolver` — tip after recovery/fail |
| Footer i18n keys by stage | `messages/baby/{en,vi}.ts` `home.footer.*` |
| Essay long-form | `home.guide.*` — do not put full essay on Watch |

## System shape candidates

- **Client resolvers:** ageDays → stage → tip strings + snaps (web TS, Watch Swift).
- **No new persistence.** Snapshot already has `ageDays`.
- **Locale:** Watch prefers system locale (`Locale.current` / String Catalog); web already EN/VI messages.

## Spike notes

None run. Quick skim enough: gap is bands vs essay, not missing UI slots.

## Has API / Has DB

| Flag | Rec | Why |
|------|-----|-----|
| **Has API** | **no** | Local tip/chip resolve; no new public contract this run |
| **Has DB** | **no** | No schema/migration |

## Clear enough to design?

**Yes**, with one design-time choice to lock:

1. **m1_3 bottle split:** keep essay’s 1–2m (90–120) vs 2–3m (120–150) as **two** feed bands, or one band 90–150?
2. **Newborn first days:** essay bottle line is 30–60; colostrum 5ml is breastfeeding — chips should follow **30–60**, not 5–15.
3. **Watch language:** system locale only (no in-app toggle) — OK?

Parent should confirm 1–3 if unsure; Design may recommend defaults: **split m1_3**, **chips = bottle essay**, **system locale**.

## Key file paths

- my-apps: `lib/baby-age-guide.ts`, `lib/baby-next-due.ts`, `messages/baby/en.ts`, `messages/baby/vi.ts`, `components/baby-home.tsx` (tips wiring)
- MyBaby: `BabyCareShared/BabyHomeStatusSnapshot.swift`, `BabyCareShared/CareSideEffects.swift`, `MyBaby Watch App/Views/Pages/CarePages.swift`
