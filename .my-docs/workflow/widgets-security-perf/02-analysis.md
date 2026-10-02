# Analysis: widgets-security-perf

## Overall deep dive

### What is this?

A Phone + Watch Widgets pack: harden App Group trust (honest empty, no secrets), Lock Screen privacy, and WidgetKit refresh budget — aligned with Apple WidgetKit / HIG / extension practices.

### Why do we need this?

Parents trust the face. Empty mailbox still paints **sample** care (`sampleNextFeed`), which looks live. Privacy and reload cost matter on Lock Screen / Always On and battery. Skipping leaves false trust and leftover risk after HIG packs.

### How to do this?

Change shared `BabyCareStatusStore` empty path + tests; audit privacySensitive on care-time Text; keep timeline + coalescer with small tune/docs. Other ways: Phone-only empty (Watch drift); docs-only audit (fails Outcome). Best practice: App Group status-only, no network in extension, lightweight timelines, privacySensitive on personal times ([WidgetKit](https://developer.apple.com/documentation/widgetkit), [privacySensitive](https://developer.apple.com/documentation/swiftui/view/privacysensitive(_:))).

**Has API:** no — no public HTTP/GraphQL contract change.  
**Has DB:** no — App Group UserDefaults mailbox only (not a DB schema).  
**Grill recommended:** yes — open frontier on empty snapshot shape + privacy secondary lines + timeline tune.

## Solution pieces (≤5)

### 1. Honest empty mailbox snapshot

- **What:** `snapshotForWidgets` when load fails → empty care snapshot (display `.empty`), not `sampleNextFeed`.
- **Why:** Sample shows fake bottle/diaper ages as live trust.
- **How:** Add `BabyHomeStatusSnapshot.emptyForWidgets` (or similar); use as empty fallback and as `apply(dto:onto:)` base. Keep `sample*` for placeholder / `context.isPreview` only. Update test `statusStoreEmptyFallsBackForWidgets`. Alt: UI-only empty when detect sample — fragile.

### 2. Mailbox secrets boundary (verify + keep)

- **What:** DTO status-only; forbidden key tests; entitlements App Group only.
- **Why:** Tokens must stay Keychain (apps), never widgets.
- **How:** Keep `forbiddenKeys` + `encodedObjectKeys` tests; confirm widget targets do not call GraphQL/pair. No new store. Alt: FileManager App Group file — unnecessary churn.

### 3. Privacy redaction gaps

- **What:** Ensure all care-time Text on accessory / Home faces use `.privacySensitive()` (primary done; **secondary** lines on rectangular/medium may still show ages without it).
- **Why:** Lock Screen / shared glance can leak “Last feed · 25m”.
- **How:** Apply privacySensitive to secondary care-time Text (Phone + Watch); empty copy can stay clear. Alt: whole-view privacySensitive — may over-redact chrome.

### 4. Timeline + coalescer budget

- **What:** Keep single-entry timeline + `.after(nextUpdate)`; keep 750ms coalesce reloading both kinds; add/confirm unit coverage.
- **Why:** Apple expects cheap timelines; thrash burns battery.
- **How:** Document policy; optional micro-tune only if Analyze finds a clear bug (timer already uses `Text.timer` + 15m horizon). Alt: multi-entry timeline for overdue boundary — more complex, defer unless needed.

### 5. Deep-link safety (verify)

- **What:** `widgetURL` uses `BabyHomeDeepLink.url(page:)` from display — known pages only.
- **Why:** Tap must not invent arbitrary URLs.
- **How:** No change if still only `BabyHomePage` values; add unit assert if missing. Alt: AppIntent open — out of scope.

## Design tree (frontier)

### Settled

- Scope = Phone + Watch + shared (Decision 1 Option 3)
- No network in extensions; App Group status-only
- Has API = no; Has DB = no
- HIG visual redesign out of scope
- Sample stays for placeholder / gallery preview only
- Grill human `1/1/1/1`: emptyForWidgets; secondary privacySensitive; timeline verify-only; shared “No care yet”

### Open frontier

- (empty after Grill)

### Blocked

- None

## Reusable patterns

- `BabyCareStatusStore` + `forbiddenKeys` tests
- `BabyCareComplicationDisplay.emptyPrimaryText` / `.empty` mode
- `WidgetTimelineReloadCoalescer` test doubles in Watch AppTests
- `.privacySensitive()` on primary timer/relative Text (Phone + Watch)
- Preview path: `context.isPreview ? sample : store`

## System shape candidates

1. **Shared empty + shared privacy fix** (recommended) — one store change, both widgets honest
2. **Per-extension UI empty only** — leaves sample in store for any other reader

## Clarity check

Instructions and references are clear enough to Grill/Design. Frontier items above are Design decisions, not blockers.

## Grill recommended?

**yes**
