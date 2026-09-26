# Idea: Fix Connect Production button

## Problem

On MyBaby Watch **Connect**, tapping **Production** does not work as expected (no useful change vs Local / pairing still aims at the wrong host). Parents cannot pick the production pairing server reliably.

## User / audience

Parents pairing Watch to the live my-apps Baby Care API via the Connect screen.

## Outcome

Done when:

1. Connect shows an always-visible **URL input** the user can edit.
2. **Local** / **Production** fill that field and show **active/selected** chrome.
3. Unit tests cover URL → preset resolver.

## Metric

Unit tests for resolver; manual: type URL; tap Local/Production and see field + selected chip update.

## Has UI

**yes** — existing Connect surface; behavior / config fix (no new layout).

## Lean / skip hints

- **Lean UI concept?** n/a — simple mode; Gate A/A2 skipped
- **Copy/token-only?** no (behavior + config)

## 80/20 UI (day-to-day)

### Main user goals

- Pick Local or Production host, enter pairing code, Save & connect.

### Vital few

- Production sets a real production origin.
- Visible host feedback after preset tap.

### Core actions

- Important #1: Pairing code + Save & connect
- Important #2: Local / Production presets

## Non-goals

- Redesign Connect layout
- New pairing API / DB
- iPhone companion
- Changing Local preset (`127.0.0.1:3000`)

## Assumptions to attack

- Production “not working” = same default URL as Local (and missing plist) rather than a SwiftUI button wiring bug
- Real deploy origin should live in Info.plist `BabyProductionPairingOrigin` (or a distinct code default) — confirm in Analyze

## Success criteria

- Production preset ≠ Local preset after fix (unless user intentionally configures them equal)
- Host line reflects the chosen preset
- Existing redeem / advanced paste paths still work
- Tests cover preset difference + plist override path

## Open questions

1. What exact Production HTTPS origin should ship as default / plist value for this project? (Ask user if not in repo.)
