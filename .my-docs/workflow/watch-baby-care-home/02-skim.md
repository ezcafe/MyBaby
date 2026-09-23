# Light repo skim: watch-baby-care-home

**Result:** done
**Updated:** 2026-09-23
**Size:** keep ≤ ~40 lines (cap) — short tables (≤5 rows each)
**Purpose:** constraints only — ground Gate A2 / UI concept / Analyze in what already exists. Not a full analysis.

## Project shape (1–3 sentences)

Greenfield watchOS 10+ SwiftUI app (`MyBaby Watch App`) with Hello World `ContentView` / `MyBabyApp` only. No WidgetKit extension, no Baby Care UI, no shared status model yet. Care contract lives outside this repo in my-apps `BABY_API.md` (GraphQL `babyHomeQuickStatus` / `babyQuickCare`).

## Related existing UI / screens

| Path | What it does | Reuse? |
|------|--------------|--------|
| `MyBaby Watch App/ContentView.swift` | Hello World shell | Replace with `BabyHomeView` |
| `MyBaby Watch App/MyBabyApp.swift` | `@main` entry | Keep; wire deep links later |
| my-apps web `/baby` home (outside repo) | Source of section order + chrome | Visual/IA parity — screenshot for ui-refs |
| (none in Watch) | WidgetKit / complications | New extension target |

## Related APIs / data

| Path or route | Notes |
|---------------|-------|
| `/Users/ptquang86/ws/my-apps/docs/BABY_API.md` | Bearer `mny_…` Baby grant; GraphQL baby |
| `babyHomeQuickStatus` / `babyQuickCare` | Home quick path (UI-first: sample model OK) |
| Auth on Watch | Stub Connect / token — no session cookies |

## Hard constraints (do not fight)

1. watchOS 10+ / Series 5+; SwiftUI + WidgetKit; stack sections (no side-by-side Breast|Bottle).
2. Section order fixed: Breast → Bottle → Nap → Diaper → Pump → Last care; one footer slot per section.
3. UI-first: shared `BabyHomeStatusModel` + sample data; real GraphQL later. Auth stub only.
4. Teal clean-minimal tokens from prompt; no purple/cream marketing look.
5. Companions glance-only (one primary signal); logging stays in-app.

## Risks if we ignore the repo

- Inventing REST or cookie auth instead of Bearer GraphQL from `BABY_API.md`.
- Building companions without a shared status model → face/app drift.
- Ignoring empty Watch shell → wrong assumptions about existing chrome (there is none — concept drafts OK).

## Enough for UI concept / Analyze?

yes — greenfield Watch + external API doc + Gate A ok. Prefer screenshots of web `/baby` home for IA/visual parity; Watch chrome will be concept-draft until Build.
