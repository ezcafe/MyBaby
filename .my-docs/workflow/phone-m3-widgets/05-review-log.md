# Code review: phone-m3-widgets

## Adversarial

| Sev | Finding | Status |
|-----|---------|--------|
| — | Dual reload kinds covered by unit test | ok |
| — | Stub Control/Live Activity removed from bundle | ok |
| Minor | Gallery add-widget still manual | accepted — no Phone UITest |

## Quality

| Sev | Finding | Status |
|-----|---------|--------|
| — | Design Option 1 honored (Shared display + Phone UI) | ok |
| — | Gate A #1/#2 timer + color/kind | ok |
| — | Kind `BabyCarePhoneHome`; small+medium only | ok |

## Merged SPM

**SPM plan:** security

### Security (inline)

| Sev | Finding | Status |
|-----|---------|--------|
| — | App Group mailbox only; no token keys (existing forbiddenKeys) | ok |
| — | Widget extension has App Group entitlements; no Keychain API use in widget UI | ok |
| — | Deep link opens app pages only | ok |

## Fix ask

None.

## Result

**clean**

## Round notes

- main-thread fallback — review — usage limits on Tasks
- Smoke pass before review
