# Design review log: offline-icloud-mode

**Result:** ok  
**Round:** 1  
**Updated:** 2026-09-29  
**Note:** main-thread fallback — usage limit

## Checklist

| Check | Pass? | Note |
|-------|-------|------|
| Aligns with 01-idea + Gate A locks | yes | Offline first; Local gone; Watch+contract |
| Aligns with 01b + approved HTML | yes | Two chips; Cloud URL default |
| Honors 02-skim constraints | yes | App Group ≠ store; no Offline API |
| System design / patterns teach OK | yes | Event log + protocol |
| Sequence + contracts present | yes | CloudKit CareEvent |
| Tasks TDD-ready | yes | Red-first on 1–3,5 |
| Security (secrets) | yes | No token in CK/App Group |
| Scope honest (no companion UI) | yes | |

## API contract review

**Skipped** — Has API = no.

## DB design review

**Result:** ok  
**Skill lens:** database-and-data-model (isolated section; main-thread)

| Check | Pass? | Note |
|-------|-------|------|
| Schema explicit | yes | CareEvent fields + schemaVersion |
| Ownership | yes | Private CloudKit; Watch writer this pass |
| Indexes / query | yes | sort by `at` DESC + limit |
| No secrets in store | yes | Forbidden |
| Migrations | yes | schemaVersion field; v1 only |
| Design↔tasks match | yes | Tasks 3–4 |

Findings: none Critical/Major.

## Findings

None.

## Fix ask

None — Result **ok**.

## Round notes

- Round 1: clean (no Critical/Major/Enhancement). Container id locked provisional `iCloud.vn.in4.MyBaby`. Projector vital fields covered in Task 3 Acceptance. Proceed to TDD review / Gate B.

