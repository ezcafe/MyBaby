# MyBaby Watch — Baby Care home + companions

WatchOS 10+ companion for one-thumb care logging. Use **sample** mode offline, or connect to your my-apps Baby GraphQL API.

## Connect to API (live)

1. On the web app: **Settings → API tokens** → enable **Baby Care** → create token → copy `mny_…`.
2. On Watch: open the connect screen (first launch, or **gear** Settings from care home).
3. Tap **Local** for simulator (`http://127.0.0.1:3000`) or paste your production `https://…` origin (no `/api/graphql/baby` suffix).
4. Paste the token → **Save & connect**.
5. Or **Continue with sample** to use offline sample data.

Endpoint used: `POST {BASE_URL}/api/graphql/baby` (see my-apps `docs/BABY_API.md`).

**Device + local HTTP:** Simulator can use `127.0.0.1`. A physical Watch cannot reach your Mac that way — use an HTTPS tunnel or deploy host. No blanket ATS “allow all HTTP” is enabled; prefer HTTPS for Production.

## Web → Watch page map

| Web home section | Watch page (swipe order) |
|------------------|--------------------------|
| Breast + Bottle | **1 · Feed** (breast L/R + ml chips + Custom; vertical scroll) |
| Nap | **2 · Sleep** |
| Diaper | **3 · Diaper** |
| Pump timers + amount | **4 · Pump** (L / R / Both + ml chips + Custom; vertical scroll) |
| Last care status | **5 · Last care** (status rows; vertical scroll) |

No app title chrome. Each care page: **header** (lead + quieter detail) → **controls** → **one footer** (recovery → fail → tip). Feed, Pump, and Last care scroll vertically when content is tall.

Care taps follow web quick-care local rules: Feed / Bottle / Diaper end an open nap; Pump family does not. Sleep chip owns start/stop. Log chips use a short done flash only. Live mode: timer **starts** stay local; stops and one-shot logs call `babyQuickCare`.

Deep links: `mybaby://home?page=feed|sleep|diaper|pump|status`  
Aliases (same pages): `breast` / `bottle` → Feed; `nap` → Sleep; `pump-amount` → Pump.

## Add companions to the Watch face / Smart Stack

1. Build & run **MyBaby Watch App** on a watchOS 10+ simulator or device (embeds **MyBaby Watch Widgets**).
2. **Face complications:** long-press face → Edit → pick a slot → choose **Baby Care** (circular / corner / rectangular / inline).
3. **Smart Stack:** turn Digital Crown to Smart Stack → Edit → add **Baby Care** (accessory circular / rectangular).
4. Tap a companion to open the matching home page.

Companions share one **Baby Care** widget kind for face and Smart Stack. They show one primary signal: open nap → overdue → next feed → last care. Logging stays in the app.

## Project layout

- `MyBaby Watch App/` — `BabyHomeView`, chips, connect UI
- `BabyCareShared/` — snapshot, API config/client, mapper, deep link, care side effects, chip mls, timeline helper
- `MyBaby Watch Widgets/` — complications + Smart Stack widgets

## Auth

- Production entry: `ContentView(bypassAuth: false)` — connect when not connected.
- Previews: `bypassAuth: true`.
- Token in Keychain; base URL in UserDefaults.
