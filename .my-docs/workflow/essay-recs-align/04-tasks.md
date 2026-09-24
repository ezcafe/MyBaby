# Tasks: essay-recs-align

**Updated:** 2026-09-24  
**TDD:** failing tests first, then production code.

## Task 1: Essay feed-band fixtures + my-apps remap

**Repos:** `/Users/ptquang86/ws/my-apps`

**Goal:** `FEED_GUIDE_BANDS` match essay bottle/feeds map in `03-design.md`.

**Tests first (fail):**
- [ ] `baby-age-guide.test.ts`: day 0/30 → ml 30–60, **bottle** feeds 7–8
- [ ] day 45 → 90–120; day 75 → 120–150
- [ ] day 120 → 150–210; day 200 → 180–240
- [ ] day ≥365: chip band documented (e.g. 120–180); tip is daily milk not chip sum
- [ ] `feedsMax` / mid defaults update; remove reliance on 5–15 newborn chip band
- [ ] Breast footer counts **not** taken from bottle `feedsMin/Max` (newborn breast 8–12 ≠ bottle 7–8)

**Implement:**
- [ ] Remap `lib/baby-age-guide.ts` bands (bottle counts only)
- [ ] Breast session tip: stage map or keys from essay (8–12 / 6–8 / 5–6…)
- [ ] Fix callers/tests (`babySuggestedBottleMl`, chip builders, breast footer wiring)

**Done when:** unit green; newborn chips never suggest 5–15; breast ≠ bottle feed counts.

---

## Task 2: Sleep blends + intervals align to five essay stages

**Repos:** my-apps

**Tests first:**
- [ ] Sleep blend keys map to five essay totals (16–18, 14–16, 14–15, 12–14, 11–14) — not 15–16 / 13–14 orphan bands unless renamed to match essay
- [ ] Newborn awake window stays ~45–60 min (interval ~50–60 OK)

**Implement:**
- [ ] Update `SLEEP_GUIDE_BANDS` + EN/VI `home.header.nap.blend*`
- [ ] Adjust `baby-next-due` only if essay-conflicted; keep diaper 2–3h newborn

**Done when:** nap header for each essay stage shows essay sleep totals.

---

## Task 3: Audit diaper/pump/breast footers + VI guide paste

**Repos:** my-apps

**Tests first:**
- [ ] Footer stage keys still `babyCareGuideStageForAge`
- [ ] Assert EN/VI diaper/pump footers contain Size S/M/L and pump ml ranges from essay
- [ ] Guide audit checklist: Section I (room/body/SIDS) + five stages each with sleep, nutrition, WHO, health, diaper keys present in EN and VI

**Implement:**
- [ ] Fix any footer string drift vs essay
- [ ] Sync VI (and EN if needed) `home.guide.*` to `01-guideline-content.md` / user paste — no medical invention

**Done when:** footers match essay; guide checklist pass EN+VI.

---

## Task 4: Watch CareGuide stage + snaps (tests first)

**Repos:** `/Users/ptquang86/ws/apple/MyBaby`

**Tests first:**
- [ ] `careGuideStage(ageDays)` cuts match web (0–30, 31–90, …)
- [ ] `bottleSnaps(ageDays)` for 0, 45, 75, 120, 200 match essay band edges/mids (document expected triple)
- [ ] `build` still history-first with new snaps

**Implement:**
- [ ] `BabyCareShared/CareGuide.swift` (or extend `CareSideEffects.swift`)
- [ ] Wire sample snapshot chips via `snapsForAge`

**Done when:** unit tests green in Watch AppTests.

---

## Task 5: Watch EN/VI tips on each care page

**Repos:** MyBaby

**Tests first:**
- [ ] Tip resolver returns non-empty EN strings per page for newborn + m3_6
- [ ] With `Locale(identifier: "vi")` (or catalog override), Vietnamese strings differ and match pump/diaper essay meaning

**Implement:**
- [ ] Add `Localizable.xcstrings` (en + vi) for page tips + section leads if still hardcoded
- [ ] Snapshot/helpers resolve tips from stage + locale
- [ ] CarePages keep one footer slot (recovery > fail > tip)

**Done when:** EN + VI tips by stage; sample pages show age-appropriate copy.

---

## Task 6: Cross-app fixture checklist test (light)

**Repos:** both (document + optional mirrored constant comments)

**Tests first:**
- [ ] my-apps test file or shared markdown fixture list of ml ranges
- [ ] Watch test imports same expected numbers (copy literals OK this run)

**Done when:** one checklist of essay ml numbers asserted in both repos’ tests.

---

## Out of scope (do not implement)

- Full essay UI on Watch
- GraphQL tip fields
- WHO charts / vaccine schedule product
