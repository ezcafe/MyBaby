# Analysis: Watch UI improvements

**Size:** Prefer bullets. ≤5 solution pieces.  
**Note:** main-thread fallback — usage limit after Task retry

## Deep dive (required)

### Overall

#### What is this?
Polish pass on MyBaby Watch: fail recovery UX, live loading cue, Settings as gear sheet (Option B), Connect/care chrome polish matching approved HTML ui-refs.

#### Why do we need this?
Fail states lose chip identity and footer Retry is dead; Settings page costs a swipe; Connect hit targets and type are weak for one-thumb use.

#### How to do this?
Extend model + CareControls/CarePages + AuthConnectView; remove Settings TabView page; gear opens sheet. Match `ui-refs/_proposed-*.html`.
- **Other ways:** Keep Settings page (rejected — Option B locked).
- **Best practices:** Reuse `CareFooterSlot`, `BabyPalette`, existing `retryQuickCare` / fail chrome; Watch confirmation for logout.

### Solution pieces

#### 1. Fail identity + footer Retry

##### What is this?
Keep control label on fail; subtitle “Failed”; wire Retry (and Discard when recovery).

##### Why do we need this?
Parents must see which chip failed and recover without guessing.

##### How to do this?
- Approach: Change `TimedCareChip` / ml / diaper fail chrome; store last send payload on model; pass `onRetry` from pages; chip tap on failed retries too.
- Other ways: Alert-only recovery — rejected (Gate A chip-owned).
- Best practices: Existing `lastFailedControl` + `retryQuickCare`; persist `lastQuickCareInput` JSON-ish dict for retry.

#### 2. Live loading cue

##### What is this?
Quiet “Updating…” / ProgressView while `loadLiveStatus` (and optionally in-flight send).

##### Why do we need this?
Network lag looks like a frozen app.

##### How to do this?
- Approach: `isStatusLoading` on model; show muted line under header (HTML) or small ProgressView in toolbar — avoid TimelineView on TabView.
- Other ways: Full-screen overlay — too heavy.
- Best practices: Comment in BabyHomeView already forbids TimelineView wrapping TabView.

#### 3. Settings gear sheet (Option B)

##### What is this?
Drop TabView Settings page; gear opens sheet: host, Log out (confirm), Reconnect.

##### Why do we need this?
Logout is rare; sixth page hurts discovery of Last care.

##### How to do this?
- Approach: Remove `.settings` from mount strip (update enum + tests); `SettingsSheet` + `.sheet`; Reconnect → `showConnect`; deep link `settings` opens sheet.
- Other ways: Full-screen cover — similar; keep page — rejected.
- Best practices: Match `_proposed-settings-sheet.html`.

#### 4. Connect + type + ml polish

##### What is this?
Presets ≥44pt; danger token errors; secondary ≥ caption2; bottle/pump `N ml`; Pump tip once; Last care 2 lines; a11y labels.

##### Why do we need this?
Readability and hit targets on small Watch screens.

##### How to do this?
- Approach: Token/font cleanup; AuthConnectView preset frame height; Pump header detail ≠ tip; CarePages footer tips.
- Other ways: Redesign Connect — out of scope.
- Best practices: `BabyTokens.minHit` / `careChipHeight`.

#### 5. Live widgets (stretch)

##### What is this?
Complications use live snapshot if App Group exists.

##### Why do we need this?
Glance vs app mismatch.

##### How to do this?
- Approach: Defer unless App Group already wired; else non-goal.
- Other ways: Sample-only (today).
- Best practices: Skip if no shared store — avoid fake “live”.

## What exists today

Paged care home with fail-on-chip but title wipe; `CareFooterSlot` Retry unused; gear opens Connect; Settings page last; Connect presets short padding; widgets sample-only.

## Dependencies

- Tests assert 6 pages including `.settings` — must update.
- README page map — update after Build.
- No API/DB contract changes.

## Reference files (for Build)

| Path | Why it matters |
|------|----------------|
| `CareControls.swift` / `CarePages.swift` | Fail chrome, footer, Pump, Last care |
| `BabyHomeView.swift` / `ContentView.swift` | Gear → sheet; strip |
| `AuthConnectView.swift` / `BabyTokens.swift` | Presets, danger, type |
| `BabyHomePage.swift` / model | Enum + retry payload + loading |
| `ui-refs/_proposed-*.html` | Visual lock |

## Reusable patterns

| Pattern | Where | Why |
|---------|-------|-----|
| CareFooterSlot | CareControls | Retry/Discard |
| BabyPalette | Theme | Sheet + fail |
| lastFailedControl | Model | Fail chrome |
| AuthGate / showConnect | ContentView | Reconnect |

## System shape candidates

| Shape | Where | Why |
|-------|-------|-----|
| Observable model + View | Watch App | Own loading/retry state |
| Page strip enum | BabyCareShared | Drop settings case |

## Constraints and risks

- Do not wrap TabView in TimelineView.
- Store last quick-care payload for true Retry (control alone is not enough for breast duration).
- Log out confirm required.

## Settled decisions

- Settings **Option B** (gear sheet).
- Gate A2 HTML approved.
- Has API **no**; Has DB **no**.

## Spike notes

| Spike | Finding | Keep or discard |
|-------|---------|-----------------|
| App Group for widgets | Not required for P0–P1 | Defer widgets |

## Blocking questions

- None — proceed to Design.
