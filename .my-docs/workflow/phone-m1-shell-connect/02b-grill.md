# Grill: phone-m1-shell-connect

**Result:** frontier-empty  
**HITL:** auto settle (user-first) — Gate B remains **blocking** for design/tasks approval  
**Updated:** 2026-09-30  
**Note:** main-thread

## Round 1 (frontier) — settled

❓ **Q1 — iOS app target**  
Options: (1) New/replace as real iOS Application target with SwiftUI `@main` App; (2) Keep ExtensionKit appex and try to host Connect there.  
➡️ **Settled Option 1** — user-first: parents need a normal Phone app icon and Connect UI; appex cannot be the product. System: clear Xcode product type.

❓ **Q2 — Session model in M1**  
Options: (1) Thin Phone session (connect/mode/offline/live/leave + placeholder home); (2) Move full Watch `BabyHomeStatusModel` into shared now.  
➡️ **Settled Option 1** — user-first: M1 ships Connect only; avoid unfinished care chrome. System: smaller blast radius; M2 can share/extract model later.

❓ **Q3 — App Intents appex**  
Options: (1) Park/remove from primary scheme (defer intents); (2) Keep as required dependency of Phone app in M1.  
➡️ **Settled Option 1** — user-first: do not block Connect on intents. System: delete or leave unused target; no M1 feature dependency.

❓ **Q4 — Advanced paste**  
Options: (1) Include Advanced paste URL+token on Cloud (Watch parity); (2) Pairing code only in M1.  
➡️ **Settled Option 1** — user-first: recovery path when pairing UI fails. System: reuse Watch pattern.

❓ **Q5 — Mode UserDefaults**  
Options: (1) Phone-local `UserDefaults.standard` (or Phone app suite) for mode; (2) Force App Group suite shared with Watch for mode flag in M1.  
➡️ **Settled Option 1** — user-first: Offline **care events** already sync via CloudKit; mode flag need not cross devices in M1. System: App Group still enabled for M3 snapshot later.

## Scenario stress-test

| Scenario | Outcome (settled) |
|----------|-------------------|
| iCloud signed out → Start Offline | Show error; do not set connected success |
| Watch Offline + Phone Start Offline same Apple ID | Same CloudKit private DB; M1 no care UI but store ready |
| Leave Offline → Connect | Clear session; **keep** CloudKit CareEvents |

## Glossary / ADR

- Terms: **Offline** = iCloud CareEvent store (not sample); **Cloud** = my-apps live API. Prefer updating repo `GLOSSARY.md` if present — skip create if none (lazy).
- ADR: none new — Offline container already decided in `offline-icloud-mode`; M1 is companion join.

## Frontier after Round 1

**empty** — Design may proceed.
