# Test log: watch-connect-presets-pairing

## Smoke

**Result:** smoke-pass  
**Updated:** 2026-09-26  
**Note:** main-thread Build + smoke (usage limit)

### Commands

```bash
# my-apps
node --import tsx --test lib/watch-pairing-service.test.ts components/watch-pairing-settings.test.ts
# → 9 pass

# MyBaby Watch
xcodebuild test -scheme "MyBaby Watch App" \
  -destination 'id=AE5F3398-AAB0-4956-8316-926DE142CE77' \
  -only-testing:"MyBaby Watch AppTests/BabyAPIConfigTests" \
  -only-testing:"MyBaby Watch AppTests/WatchPairRequestBuilderTests"
# → TEST SUCCEEDED
```

### Notes

- Migration `0044_watch_pairing_code.sql` not applied in this smoke (run `pnpm db:migrate` before live mint).
- ui-refs still concept-draft (replace after manual UI screenshots).

## Full / lite test

**Result:** success (focused)  
**Updated:** 2026-09-26

- my-apps pairing unit tests: 8 pass (re-run after redeem fix)
- Watch focused suites: TEST SUCCEEDED (BabyAPIConfigTests + WatchPairRequestBuilderTests)
- Full monorepo e2e / coverage not re-run this pass (pairing-focused smoke + review)

Next: Gate C human merge approve.