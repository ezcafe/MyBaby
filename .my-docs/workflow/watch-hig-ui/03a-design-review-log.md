# Design review log: watch-hig-ui

**Result:** clean  
**Round:** 1  
**Updated:** 2026-09-26  
**Note:** main-thread fallback — usage limit

## API contract review

**Result:** skipped — Has API = no

## DB design review

**Result:** skipped — Has DB = no

## Design review

**Result:** clean

### Findings

| Severity | Area | Finding | Suggestion |
|----------|------|---------|------------|
| Enhancement | Tasks | Store must assert no token fields | Already in Security checks; Task 5 tests should assert DTO keys exclude token |
| Nit | Pump | Sheet trigger label “Amount” vs “Pump ml” | Build: use **Amount** (short) |

### Alignment checks

- Gate A / 01b / HTML: vertical Feed+Bottle sheet, Sleep bg, Last care hero, Connect Need help?, rect complication — design locks match
- System design + patterns: present and non-duplicative
- Sequence covers App Group write → widget reload
- Care rules / API / DB correctly out of scope

### Fix ask

(none Critical/Major)

## Round notes

- Proceed to TDD test-case review → Gate B.
