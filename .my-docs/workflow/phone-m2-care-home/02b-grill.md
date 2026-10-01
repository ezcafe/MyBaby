# Grill: phone-m2-care-home

## Round 1 — frontier (auto-settled · user-first)

❓ **Q1 — Phone navigation**
- Option 1: Watch-style vertical `.page` TabView  
- Option 2: iOS bottom `TabView` for Feed / Sleep / Diaper / Pump / Last care  
- Option 3: Single scrolling home (web-like sections)

➡️ **Recommended: Option 2** — user-first: iPhone caregivers discover tabs; same five care surfaces as Watch; larger thumb targets. System: still reuse page views.

---

❓ **Q2 — Model sharing**
- Option 1: Add Watch `BabyHomeStatusModel` (+ needed helpers) to Phone target / Shared compile  
- Option 2: Move model into `BabyCareShared` now  
- Option 3: New Phone-only model

➡️ **Recommended: Option 1** — user-first: identical rules/fail/retry immediately. System: model already `#if os(watchOS)` gated for WatchKit; extract to Shared only if compile fails.

---

❓ **Q3 — Diaper dirty detail**
- Option 1: Include detail sheet in M2 (Watch parity)  
- Option 2: Wet/dirty chips only; defer detail

➡️ **Recommended: Option 1** — user-first: dirty/mixed logging is daily; Watch already teaches the sheet.

---

❓ **Q4 — Last care placement**
- Option 1: Fifth bottom tab (parity with Watch pages)  
- Option 2: Header strip only

➡️ **Recommended: Option 1** — user-first: full last-care list stays reachable; strip alone loses depth.

## Scenario stress-test

| Scenario | Outcome (settled) |
|----------|-------------------|
| Live send fails mid-timer | Chip shows Failed; Retry same `clientRequestId`; timer state preserved per Watch model |
| Offline CloudKit write fails | Surface fail; do not claim saved; leave Connect path unchanged |
| Two caregivers same iCloud Offline | Same private DB via Apple ID; last-writer CloudKit semantics accepted (no merge engine in M2) |

## Glossary / ADR

- No new ADR (reuse Offline + quick-care locks).
- Terms already covered by Watch/Offline docs; no new glossary file required for M2.

## Settled (for Design)

| ID | Pick |
|----|------|
| N1 | Option 2 — iOS bottom tabs (5 pages) |
| N2 | Option 1 — compile/share Watch care model into Phone |
| N3 | Option 1 — diaper detail in M2 |
| N4 | Option 1 — Last care fifth tab |

## Result

**frontier-empty** · auto · user-first picks

## Round notes

- main-thread fallback — Grill — usage limit
- HITL Gate B is blocking for Gate B proper; Grill auto per prefer-auto
