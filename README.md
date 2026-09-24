# MyBaby Watch — Baby Care home + companions

UI-first watchOS 10+ companion for one-thumb care logging. Status uses **sample data** until GraphQL (`BABY_API.md`) is wired.

## Web → Watch page map

| Web home section | Watch page (swipe order) |
|------------------|--------------------------|
| Breast + Bottle | **1 · Feed** (breast L/R + ml chips + Custom; vertical scroll) |
| Nap | **2 · Sleep** |
| Diaper | **3 · Diaper** |
| Pump timers + amount | **4 · Pump** (L / R / Both + ml chips + Custom; vertical scroll) |
| Last care status | **5 · Last care** (status rows; vertical scroll) |

No app title chrome. Each care page: **header** (lead + quieter detail) → **controls** → **one footer** (recovery → fail → tip). Feed, Pump, and Last care scroll vertically when content is tall.

Care taps follow web quick-care local rules: Feed / Bottle / Diaper end an open nap; Pump family does not. Sleep chip owns start/stop. Log chips use a short done flash only.

Deep links: `mybaby://home?page=feed|sleep|diaper|pump|status`  
Aliases (same pages): `breast` / `bottle` → Feed; `nap` → Sleep; `pump-amount` → Pump.

## Add companions to the Watch face / Smart Stack

1. Build & run **MyBaby Watch App** on a watchOS 10+ simulator or device (embeds **MyBaby Watch Widgets**).
2. **Face complications:** long-press face → Edit → pick a slot → choose **Baby Care** (circular / corner / rectangular / inline).
3. **Smart Stack:** turn Digital Crown to Smart Stack → Edit → add **Baby Care** (accessory circular / rectangular).
4. Tap a companion to open the matching home page.

Companions share one **Baby Care** widget kind for face and Smart Stack. They show one primary signal: open nap → overdue → next feed → last care. Logging stays in the app.

## Project layout

- `MyBaby Watch App/` — `BabyHomeView`, chips, auth stub
- `BabyCareShared/` — snapshot, primary signal, deep link, care side effects, chip mls, timeline helper
- `MyBaby Watch Widgets/` — complications + Smart Stack widgets

## Auth

In-app **Connect iPhone / API token** is a stub. Previews and default run use sample mode (`bypassAuth`).
