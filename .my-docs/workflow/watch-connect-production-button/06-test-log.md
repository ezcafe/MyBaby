# Test log: watch-connect-production-button

## Smoke (build + unit)

**Result:** smoke-pass  
**When:** 2026-09-26 ~15:05–15:06  
**Destination:** `platform=watchOS Simulator,id=5A0C27D2-4E3B-4578-9675-94E24716D851`  
**Command:** `xcodebuild -scheme "MyBaby Watch App" -only-testing:"MyBaby Watch AppTests" test`  
**Notes:** Includes new `resolveHostPreset*` cases; **TEST SUCCEEDED**.

## Lite test (Review profile lite)

**Result:** success  
**When:** 2026-09-26  
**Notes:** Reused smoke unit suite (no Watch UI e2e harness for Connect). Targeted `BabyAPIConfigTests` + full `MyBaby Watch AppTests` green.

## Post–Gate C UX tweak (Local default / URL field visibility)

**Result:** pass  
**When:** 2026-09-26 ~15:11  
**Command:** `BabyAPIConfigTests` only — includes `urlFieldVisibleOnlyForProduction`  
**Notes:** On load Local selected + URL hidden; URL field when Production selected.
