# Performance lens: widgets-security-perf

## Result

**clean**

## Findings

| Area | Finding | Severity |
|------|---------|----------|
| Timeline | Single-entry `.after(nextUpdate)`; timer 15m horizon unchanged | ok |
| Coalesce | 750ms debounce unchanged; existing burst tests green | ok |
| Dual-kind reload | Still both kinds (shared mailbox) — correct | ok |
| Decode cost | One DTO JSON decode per timeline — acceptable | ok |
| Scope | Verify-only per Grill — no surprise staleness | ok |

## Fix ask

None.
