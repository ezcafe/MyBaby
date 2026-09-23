# MyBaby Watch — Baby Care home + companions

UI-first watchOS 10+ companion for one-thumb care logging. Status uses **sample data** until GraphQL (`BABY_API.md`) is wired.

## Web → Watch page map

| Web home section | Watch page (swipe order) |
|------------------|--------------------------|
| Breast + Bottle | **1 · Feed + Bottle** (stacked) |
| Nap | **2 · Sleep** |
| Diaper | **3 · Diaper** |
| Pump | **4 · Pump** |
| Last care status | **5 · Last care** |

Each care page keeps web chrome: **header** (when next) → **controls** (chips) → **one footer** (recovery → fail → tip).

Deep links: `mybaby://home?page=feed|sleep|diaper|pump|status`

## Add companions to the Watch face / Smart Stack

1. Build & run **MyBaby Watch App** on a watchOS 10+ simulator or device (embeds **MyBaby Watch Widgets**).
2. **Face complications:** long-press face → Edit → pick a slot → choose **Baby Care** (circular / corner / rectangular / inline).
3. **Smart Stack:** turn Digital Crown to Smart Stack → Edit → add **Baby Care** (small or medium).
4. Tap a companion to open the matching home page.

Companions show one primary signal: open nap → overdue → next feed → last care. Logging stays in the app.

On watchOS, Smart Stack / face slots use **accessory** families (circular, corner, rectangular, inline). iOS `systemSmall` / `systemMedium` are not available on Watch.

## Project layout

- `MyBaby Watch App/` — `BabyHomeView`, chips, auth stub
- `BabyCareShared/` — snapshot, primary signal, deep link, timeline helper (app + widgets)
- `MyBaby Watch Widgets/` — complications + Smart Stack widgets

## Auth

In-app **Connect iPhone / API token** is a stub. Previews and default run use sample mode (`bypassAuth`).
