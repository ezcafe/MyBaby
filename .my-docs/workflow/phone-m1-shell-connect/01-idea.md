# Idea: Phone M1 — app shell + Connect Offline|Cloud

## Project shape (quick scan)

MyBaby is an Apple companion suite: Watch App already logs care via Cloud GraphQL or Offline CloudKit (`iCloud.vn.in4.MyBaby`) and shares status through App Group widgets. `BabyCareShared` holds pairing, API config, Offline store, and snapshot types. **MyBaby Phone App** and **Phone Widgets** targets exist but are stubs (AppIntent placeholders) — no Connect, no Offline join, no care UI yet. my-apps remains the Cloud API + full web Baby module (`docs/BABY_API.md`, `/baby/*`).

## Problem

Parents can use Watch Offline/Cloud, but the iPhone app cannot connect, pair, or join the same Offline iCloud store. Phone targets are empty shells, so the program toward full my-apps Baby on Phone (program Decision 2 Option 2) cannot start.

## User / audience

- Parents / caregivers who will use iPhone as the main companion (later milestones add care + web-depth)
- Caregivers who already use Watch Offline and need Phone to join the **same** iCloud care store
- Developers testing Cloud pairing against my-apps Local/Production hosts

## Outcome

**M1 only** (program end-state is full Baby web module on later milestones):

1. Real Phone app launches to a Connect experience with peer modes **Offline | Cloud** (Offline first + default; no Local chip).
2. **Offline:** Start Offline joins Watch’s CloudKit container / Offline care store path; user sees plain Offline + iCloud status; session restores Offline on cold start without token. **No care chips** in M1.
3. **Cloud:** URL defaults to `http://127.0.0.1:3000`; pairing code redeem (same as Watch) stores token; connected shell shows mode + leave-to-Connect.
4. **Settings basics:** show mode, leave Offline/Cloud, iCloud status / short trouble hint.
5. Phone Widgets remain stub for M3 — not in M1 acceptance.

## Metric

On a device/simulator with entitlements: user selects Offline → Start Offline → app shows connected Offline with iCloud status (ok or clear error); relaunch restores Offline without Connect. Separately: Cloud + valid pairing code → connected live mode with token stored (Keychain path like Watch). Proven by unit tests for connect/mode restore + pairing client reuse; CloudKit account cases may be harnessed/mocked.

## Sources (primary)

| Claim / topic | Primary source (path, URL, or API) | Notes |
|---------------|--------------------------------------|-------|
| Connect Offline\|Cloud UI + defaults | `MyBaby Watch App/Views/AuthConnectView.swift` | Offline default; Start Offline / Save & connect |
| Offline mode + CareEvent store API | `BabyCareShared/OfflineCareStore.swift` | `.sample` / `.live` / `.offline` |
| CloudKit container id | `BabyCareShared/CloudKitOfflineCareStore.swift`; `Config/WatchApp.entitlements` | `iCloud.vn.in4.MyBaby` |
| Pairing redeem | `BabyCareShared/WatchPairClient.swift`; my-apps `docs/BABY_API.md` §2 | `POST /api/watch/pair/redeem` |
| Phone stub today | `MyBaby Phone App/MyBaby_Phone_App.swift` | AppIntent placeholder only |
| Program milestones | `.my-docs/workflow/phone-app-parity/00-run.md` | D1 Option 1 ladder; D2 Option 2 full web end state |
| Watch Offline locks | `.my-docs/workflow/offline-icloud-mode/01-idea.md` + `03-design.md` | Companion join was deferred; M1 is that join for Phone |

## Has UI

**yes** — Phone Connect (Offline \| Cloud) + post-connect shell + Settings basics (mode / leave / iCloud status). No care home chips; no widget UI.

## Lean / skip hints

- **Copy/token-only?** no
- **UI notes for Design:** Match Watch Connect chip hierarchy on iPhone (larger canvas OK); reuse shared connect/mode logic from `BabyCareShared` where possible; empty “home” placeholder after connect is fine until M2

## 80/20 UI (day-to-day)

### Main user goals

- Choose Offline or Cloud on first launch
- Start Offline without typing a pairing code
- Pair Cloud with a short code from my-apps Settings
- See mode and iCloud/connection status; leave mode back to Connect

### Vital few (high-impact ~20%)

- Offline \| Cloud chips (Offline default)
- Start Offline / Save & connect
- Clear fail states (iCloud account problem; bad pairing code)
- Settings: mode + leave + iCloud status

### Primary UI — core actions dominant

- **Important info / action #1 (always visible):** Mode chooser — Offline | Cloud
- **Important info / action #2 (always visible):** Mode continue — Start Offline or Save & connect
- **Core action placement:** Two peer chips; Offline hides URL/pairing; Cloud shows URL (default local preset) + pairing fields
- **Secondary actions:** Need help / Advanced paste (Cloud); iCloud troubleshooting expand; Settings gear after connect

### Top user journey to optimize

Open Phone app → **Offline** (default) → Start Offline → see Offline connected shell → relaunch → still Offline

### Sensible defaults

- Offline selected by default
- Cloud URL prefilled `http://127.0.0.1:3000`
- Offline does not require pairing code

### Biggest usability risks to fix first

- Empty stub / dead AppIntent so user cannot connect at all
- Fake “Offline connected” when iCloud is unavailable
- Confusing Offline (iCloud) vs Cloud (my-apps API) wording
- Token or pairing secrets leaking into App Group / CloudKit

## Non-goals (M1)

- Care home chips / feed / sleep / diaper / pump UI (M2)
- Phone widget timelines / Live Activities (M3)
- Activities, insights, growth, essays, full settings like web (M4+)
- Merging live API history with Offline CloudKit history
- New my-apps Offline HTTP API
- Changing Watch Connect behavior (reuse locks only)

## Assumptions to attack

- Phone can share Watch App Group + same CloudKit container with correct entitlements/signing
- `BabyCareShared` Offline + pair clients compile for iOS without watch-only APIs
- A minimal post-connect shell (placeholder home) is enough until M2
- Pairing endpoint name (`/api/watch/pair/redeem`) stays valid for Phone (same token grant)

## Success criteria

- [ ] Phone app target runs a SwiftUI shell (not AppIntent-only stub)
- [ ] Connect shows Offline | Cloud; Offline default; no Local chip
- [ ] Offline start joins/uses `CloudKitOfflineCareStore` path; status visible; cold start restores offline
- [ ] Cloud pairing redeem stores token; connected live mode; leave returns to Connect
- [ ] Settings basics: mode, leave, iCloud status
- [ ] No care logging UI; no widget feature work claimed done
- [ ] Unit coverage for mode restore + pair client behavior (shared or Phone)

## Open questions

- Exact Xcode target wiring / entitlements files for Phone App (mirror Watch container + App Group) — confirm in Analyze
- Post-connect placeholder copy (“Care home comes next”) vs blank — Design can pick
- Whether Advanced paste URL+token is required in M1 (Watch has it) — prefer yes for parity unless skim shows cost

## Program note (out of M1 Outcome)

Later milestones deliver care home (M2), widgets (M3), then full my-apps Baby surfaces (M4+ split). M1 only unlocks Connect + Offline join + Cloud pair.
