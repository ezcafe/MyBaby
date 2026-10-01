# Code review: phone-m2-care-home

## Adversarial

| Sev | Finding | Status |
|-----|---------|--------|
| Major | Watch unit run canceled — no green proof for `PhoneCareWiringTests` | **fixed** — CLI TEST SUCCEEDED; 4/4 PhoneCareWiringTests pass |
| Minor | `persistStatusForWidgets` reloads Watch complication kind on Phone | accepted M2 (M3 widgets) |
| Nit | Care pages use Watch `caption2` tokens on iPhone | ok for M2 parity |

## Quality

| Sev | Finding | Status |
|-----|---------|--------|
| — | Design Option 1 honored (shared model + bottom TabView) | ok |
| — | Gate A #1 chips / #2 timer via reused CarePages | ok |
| Minor | Empty Watch `Models/` / `Theme/` dirs after move | nit — cleanup optional |

## Merged SPM

**SPM plan:** security

### Security (inline)

| Sev | Finding | Status |
|-----|---------|--------|
| — | Token remains Keychain via session leave; care model logout on settings leave | ok |
| — | No token in App Group snapshot path | ok (existing) |

## Fix ask

None required for Gate C.

## Result

**clean**

## Round notes

- main-thread review — Task usage limit / sandbox
- Build evidence from user Xcode DerivedData
- **20:44** · units green via CLI → clean
