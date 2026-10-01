# Grill: phone-hig-ui

**HITL:** Gate B is blocking for Build; Grill **auto-settled** (user-first) so Design can proceed.  
**Result:** frontier-empty

## Frontier round 1 (auto)

❓ **N1 — Connect chrome**  
Option 1: Form + segmented Offline|Cloud + parent title + prominent CTA  
Option 2: Polish existing custom chips only  

➡️ **Recommended: Option 1** — user-first: parents expect system forms; system: matches HIG Forms/Pickers.

❓ **N2 — Phone care scale**  
Option 1: Shared platform metrics (`#if os(iOS)` / size helper in tokens + chips)  
Option 2: Phone-only page wrappers  

➡️ **Recommended: Option 1** — user-first: bigger taps on phone; system: one source, Watch stays compact.

❓ **N3 — Fifth tab label**  
Option 1: **Status**  
Option 2: **Last care**  

➡️ **Recommended: Option 1 Status** — user-first: short clear tab word; system: fits tab bar.

❓ **N4 — Leave confirmation**  
Option 1: Confirm before Leave  
Option 2: Immediate Leave  

➡️ **Recommended: Option 1** — user-first: avoid accidental disconnect; system: one alert.

## Scenario stress-test

| Scenario | Outcome |
|----------|---------|
| Parent opens Connect at 3am, wants Offline | Sees “Get started” / Offline selected → Start Offline — no “API server” |
| Feeds with Dynamic Type large | Breast chips still ≥44pt and readable titles on iOS |
| Accidental Leave tap | Confirm cancels → stays connected |

## Settled → analysis

- N1 Option 1, N2 Option 1, N3 Status, N4 confirm — written into Design locks.
- Glossary/ADR: none required (no new domain terms / irreversible data).

## Grill digest

1. Connect → system Form + parent copy  
2. Shared iOS metrics for chips (Watch unchanged)  
3. Tab “Last” → “Status”  
4. Leave needs confirm  
