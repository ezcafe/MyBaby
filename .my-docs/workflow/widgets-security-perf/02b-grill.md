# Grill: widgets-security-perf

**Result:** frontier-empty  
**HITL:** blocking (Gate B tier) — human settled round 1  
**Updated:** 2026-10-02

## Design tree

```
Honest empty mailbox ✅
  ├─ Empty snapshot factory = emptyForWidgets ✅
  └─ apply(dto:) base = empty ✅
Privacy on faces ✅
  └─ Secondary care-time lines privacySensitive ✅
Refresh budget ✅
  └─ Verify-only (no numeric tune) ✅
Empty copy ✅
  └─ Reuse “No care yet” ✅
```

## Frontier round 1 — settled (human `1 / 1 / 1 / 1`)

| Q | Pick | Note |
|---|------|------|
| Q1 Empty snapshot | Option 1 | `emptyForWidgets`; sample only preview/placeholder |
| Q2 Secondary privacy | Option 1 | privacySensitive on secondary care-time Text |
| Q3 Timeline/coalescer | Option 1 | Verify + tests/docs only |
| Q4 Circular empty copy | Option 1 | Reuse “No care yet” |

## Scenario stress-test

| Scenario | Expected after pack |
|----------|---------------------|
| Fresh install, never Connected, widget added | Empty face, not sample bottle 25m |
| Gallery / Add Widget preview | Sample still OK via `isPreview` / placeholder |
| Locked Phone Lock Screen accessory | Care ages redacted (primary + secondary) |
| Rapid care taps | One coalesced reload wave, both kinds |

## Glossary / ADR

- No new glossary this round.
- ADR: none — reversible code; “never sample as live” captured in Design Non-goals / tasks.

## Settled (all)

- Scope Phone + Watch + shared
- No network in extensions; Has API no / Has DB no
- Honest empty factory + apply base
- Secondary privacySensitive
- Timeline/coalescer verify-only
- Shared empty string “No care yet”
