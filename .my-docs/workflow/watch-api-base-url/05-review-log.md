# Review log: watch-api-base-url

**Result:** clean
**Round:** 1
**Updated:** 2026-09-24
**Review profile:** lite
**SPM plan:** security

## Adversarial

**Result:** clean

| Severity | Finding | Suggestion |
|----------|---------|------------|
| Enhancement | Pump timer stop sends `kind: BREAST` + `breastRunning` with `pump_*` sides — matches BABY_API timer side list, but not manually verified against live server | Manual smoke against my-apps before Gate C |
| Nit | Live mutations fire `Task {}` without awaiting in UI — fine for Watch; failures go to statusFail | Keep |

## Quality

**Result:** clean

| Severity | Finding | Suggestion |
|----------|---------|------------|
| — | Config / client / mapper / connect UI / live model match design Option 1 | — |
| Nit | `inout` on `@Observable` props broke timers; fixed by direct property writes | Keep pattern |

## Merged SPM

**Lens:** security only (1 lens — no Merge Task)

See `05-lens-security.md`.

## Fix ask

(none Critical/Major)

## Round notes

- main-thread fallback — build, smoke, review — usage limit
