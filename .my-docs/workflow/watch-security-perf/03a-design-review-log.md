# Design review log: watch-security-perf

**Result:** clean  
**Round:** 2  
**Updated:** 2026-10-01  

## API contract review (when Has API)

Filled by the isolated **API contract review** Task only. Skip section when Has API = no.

**Result:** skipped  
**Updated:** 2026-10-01  

| Severity | Area | Finding | Suggestion |
|----------|------|---------|------------|
| — | — | Has API = no | — |

**API checklist:** N/A

## DB design review (when Has DB)

Filled by the isolated **DB design review** Task only. Skip section when Has DB = no.

**Result:** skipped  
**Updated:** 2026-10-01  

| Severity | Area | Finding | Suggestion |
|----------|------|---------|------------|
| — | — | Has DB = no | — |

**DB checklist:** N/A

## Findings

| Severity | Area | Finding | Suggestion |
|----------|------|---------|------------|
| — | — | None blocking | Round 1 Major + Enhancements closed |
| Nit | design | Option 1 title still says “Watch ATS only”; What + Task 2 also lock Leave-keep-URL | Optional rename — does not block Build |
| Nit | diagram | Sequence omits remote `http` reject return under Dual transport gate | Optional alt line — Fail path already covered |

## Fix ask for my-design-subflow

None.

## Round notes

- Fresh verifier Round 2. Did not author docs. Did not edit `01`–`04`.
- **Round 1 Fix ask check:**
  1. Major patterns — **closed:** `03-design.md` Design patterns #4 User-safe Fail map + #5 App Group status mailbox (full teach).
  2. Enhancement Task 3 deep-link — **closed:** `04-tasks.md` Task 3 names `onOpenURL` / `BabyHomeDeepLink` page-settings gate + no query→token.
  3. Enhancement ATS teach — **closed:** pattern #1 full What/How/Why/Best practices/Anti-pattern `NSAllowsArbitraryLoads` + Phone Info + Apple ATS Reference.
- **Gate A #1/#2:** Design UI specs + tasks keep care + Connect Offline + Fail/Retry — aligned; no 80/20 re-litigation.
- **Grill Settled honored:** ATS Phone-parity; Leave **keep** base URL; defer Enhancements. Design does not reopen Settled.
- **Analyze deep dive:** What / Why / How present; frontier empty.
- **System design / patterns / OWASP / sequence / Has API·DB N/A:** adequate. All five Analysis reusable patterns taught in Design.
- **Code spot-check:** Watch Info still scheme-only (no ATS); Phone Info has loopback exceptions; `logout` clears token/mode, no `clearBaseURL` — matches Design/Grill.
- Zero Critical / Major / Enhancement → **clean**. Next: TDD test-case review (planned Leave unit) → Gate B blocking.
