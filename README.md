# MyBaby Watch — Baby Care home + companions

WatchOS 10+ companion for one-thumb care logging. Use **Offline** (iCloud) by default, or **Cloud** to connect to your my-apps Baby GraphQL API. Previews may still use **sample** data.

## Connect — Offline (default)

1. On Watch: open Connect (first launch, or after Log out).
2. **Offline** is selected by default → **Start Offline**.
3. Care events store in **iCloud** (CloudKit private DB, container `iCloud.vn.in4.MyBaby`).
4. Sign in to iCloud on the device; otherwise Start Offline shows an error.

### Companion join contract (future apps)

| Item | Value |
|------|--------|
| Container | `iCloud.vn.in4.MyBaby` |
| Database | Private |
| Record type | `CareEvent` |
| Fields | `kind`, `at`, `side?`, `ml?`, `diaperKind?`, `durationSec?`, `schemaVersion` (start at 1) |

No companion iPhone/iPad UI in this pass — join the same container later.

## Connect — Cloud (live API)

1. On the web app (laptop): **Settings → API tokens → Device pairing** → select **Baby Care** → **Generate code**.
2. On Watch Connect: tap **Cloud** (URL defaults to `http://127.0.0.1:3000`).
3. Enter the short pairing code → **Save & connect**.
4. Or open **Need help?** → **Advanced** paste URL & `mny_…` token.
5. After **Log out**, you must Connect again (Offline or Cloud).

Redeem: `POST {PAIRING_ORIGIN}/api/watch/pair/redeem`. Care calls: `POST {BASE_URL}/api/graphql/baby` (see my-apps `docs/BABY_API.md`).

**Cloud URL default:** `http://127.0.0.1:3000`. Override pairing origin via Info.plist `BabyProductionPairingOrigin` for a deployed HTTPS host.

**Device + local HTTP:** Simulator can use `127.0.0.1`. A physical Watch cannot reach your Mac that way — use an HTTPS tunnel or deploy host.

## Web → Watch page map

| Web home section | Watch page (Digital Crown / vertical order) |
|------------------|-----------------------------------------------|
| Breast + Bottle | **1 · Feed** (breast L/R + **Bottle** sheet for ml chips + Custom) |
| Nap | **2 · Sleep** |
| Diaper | **3 · Diaper** |
| Pump timers + amount | **4 · Pump** (L / R / Both + **Amount** sheet for ml) |
| Last care status | **5 · Last care** (status rows + **Settings** button) |
| Settings / logout | **Settings sheet** from Last care (host + Log out confirm — not a swipe page) |

No app title chrome. Vertical pages use place/urgency `containerBackground`. Toolbar shows ProgressView while status loads; **Retry** on the bottom bar when a send fails. Each care page: **header** → **controls** → **footer** (recovery → fail → tip). Live send failures keep chip identity and show **Failed** on the subtitle.

Care taps follow web quick-care local rules: Feed / Bottle / Diaper end an open nap; Pump family does not. Sleep chip owns start/stop. Log chips use a short done flash only. Live mode: timer **starts** stay local; stops and one-shot logs call `babyQuickCare`.

Deep links: `mybaby://home?page=feed|sleep|diaper|pump|status`  
`page=settings` opens the Settings sheet.  
Aliases (same pages): `breast` / `bottle` → Feed; `nap` → Sleep; `pump-amount` → Pump.

## Add companions to the Watch face / Smart Stack

1. Build & run **MyBaby Watch App** on a watchOS 10+ simulator or device (embeds **MyBaby Watch Widgets**).
2. Enable App Group `group.vn.in4.MyBaby` on Watch app + widgets (signing).
3. **Face complications:** long-press face → Edit → pick a slot → choose **Baby Care** → set **Care type** (Auto or Feed / Sleep / Diaper / Pump).
4. **Smart Stack:** turn Digital Crown to Smart Stack → Edit → add **Baby Care** (or a preconfigured Feed/Sleep/… recommendation) → set **Care type** if needed.
5. Tap a companion to open the matching home page (Pump → Pump, Sleep → Sleep, Auto → page for what is shown).

Companions share one **Baby Care** widget kind. Edit a slot to pick **Care type**: **Auto** (any running timer, else latest care), or **Feed / Sleep / Diaper / Pump**. Tap opens the matching home page. They read the App Group snapshot written by the app. While a care timer runs (for that type, or any type when Auto), the face shows a live timer; when idle, last care time in teal (in range) or red (out of range). Logging stays in the app.

## Project layout

- `MyBaby Watch App/` — `BabyHomeView`, chips, connect UI
- `BabyCareShared/` — snapshot, status store, API config/client, mapper, deep link, care side effects, chip mls, timeline helper
- `MyBaby Watch Widgets/` — complications + Smart Stack widgets

## Auth

- Production entry: `ContentView(bypassAuth: false)` — Connect when not connected (Offline or Cloud).
- Previews: `bypassAuth: true`.
- Cloud: token in Keychain; base URL in UserDefaults.
- Offline: mode in UserDefaults; care events in CloudKit (never tokens).
- Status DTO in App Group for widgets (no token).
