# UI concept (UI/UX designer): watch-fail-status-settings

**Result:** done  
**Updated:** 2026-09-26  
**Has UI:** yes  
**Note:** main-thread fallback — usage limit

## Sources followed

| Source | Applied? | Notes |
|--------|----------|-------|
| Watch `BabyTokens` / `CareControls` | yes | Teal accent, surface chips, secondary 11pt |
| Gate A 80/20 | yes | Fail on chip #1; Settings logout #2 |
| `02-skim.md` | yes | Reuse footer; add page; token clear |

## Concept depth

**full** — chip fail state + Settings page.

## Align with Gate A (80/20)

| Item | From 01a / idea | How concept honors it |
|------|-----------------|------------------------|
| #1 | Error on failed trigger | Chip subtitle/title shows “Failed” + danger tint |
| #2 | Settings + Log out | Last page: host + Log out button |
| Secondary | Gear / reconnect detail | Gear may open connect; pairing fields stay on connect |
| Journey | Fail → retry → Settings logout | Chip clears on success; logout → connect |

## Screen / surface map

| Surface | Purpose | Primary actions |
|---------|---------|-----------------|
| Care pages (Feed etc.) | Log care; show fail on chip | Same chips; failed control uses error phase |
| Settings (new, last) | Session / logout | Show host; **Log out** only |
| Connect (after logout) | Must connect before care | Quick guide + presets + code + Save & connect |

## UI reference (HTML only — Gate A2)

| Surface | Variant | File path | Source | Preview URL |
|---------|---------|-----------|--------|-------------|
| Feed — bottle chip failed | light | `ui-refs/_proposed-feed-chip-fail.html` | html-prototype | http://127.0.0.1:8765/_proposed-feed-chip-fail.html |
| Settings — logout | light | `ui-refs/_proposed-settings.html` | html-prototype | http://127.0.0.1:8765/_proposed-settings.html |
| Connect — quick guide | light | `ui-refs/_proposed-connect-guide.html` | html-prototype | http://127.0.0.1:8765/_proposed-connect-guide.html |

## Layout concept

- **Chip fail:** Keep chip size/shape. Failed control: surface border/text uses danger (`#DC2626` light) — title “Failed” (or keep side title + “Failed” subtitle). Other chips unchanged. Footer may still show short statusFail as backup.
- **Settings page:** Header “Settings” → muted host line → **Log out** only. No Reconnect button.
- **Connect page (after logout):** Controls first (presets → code → Save & connect). **Quick connect** guide at the **bottom** of the page (web pairing steps). No care home until connected.
- **Strip order:** Feed · Sleep · Diaper · Pump · Last care · **Settings**.

## States

| State | Behavior |
|-------|----------|
| Idle / success | Chips as today; done flash unchanged |
| Send fail (chip-owned) | That chip → fail phase until retry success or clear |
| Status load fail (no chip) | Footer `statusFail` only (Design default) |
| Logged out | Clear token; `isConnected = false`; **must** complete Connect before care pages. No sample shortcut on this path. |

## Decisions locked (Gate A2 feedback)

- Remove **Reconnect** from Settings (logout is the exit).
- After **Log out**, user **must Connect** before using the app (auth gate; no care until connected).
- Connection page shows a **quick connect guide**.
- Keep toolbar gear optional shortcut (Design may drop if redundant).
- Chip copy: **Failed**; reason in footer when useful.
- Status-load fail → footer only.
