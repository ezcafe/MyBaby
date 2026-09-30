# UI concept (UI/UX designer): offline-icloud-mode

**Result:** done  
**Updated:** 2026-09-29 (Gate A2 revision)  
**Has UI:** yes  
**Concept depth:** lean  
**Note:** main-thread; Gate A2 feedback applied

## Sources followed

| Source | Applied? | Notes |
|--------|----------|-------|
| Watch `BabyTokens` / `AuthConnectView` | yes | Teal accent, 44pt chips, nested radius 6, “API server” |
| Gate A 80/20 + Gate A2 | yes | Offline first; Local removed; Cloud URL default |
| `02-skim.md` | yes | Extend Connect only |

## Align with Gate A / A2

| Item | Lock | How concept honors it |
|------|------|------------------------|
| #1 | Offline \| Cloud (Offline first) | Two peer chips; Offline left + default on |
| #2 | Start Offline / Save & connect | Mode-specific primary |
| Cloud URL | Default `http://127.0.0.1:3000` | Prefill when Cloud selected |
| Removed | Local chip | Not shown |

## Screen / surface map

| Surface | Purpose | Primary actions |
|---------|---------|-----------------|
| Connect Offline (default) | Start iCloud Offline | Start Offline |
| Connect Cloud | Live API | URL (default local) + pairing → Save & connect |

## UI references (HTML only — Gate A2)

| Surface | Variant | File path | Source | Preview URL |
|---------|---------|-----------|--------|-------------|
| Connect — Offline default | light | `ui-refs/_proposed-connect-offline.html` | html-prototype | http://127.0.0.1:8765/_proposed-connect-offline.html |
| Connect — Cloud + local URL default | light | `ui-refs/_proposed-connect-cloud.html` | html-prototype | http://127.0.0.1:8765/_proposed-connect-cloud.html |

## Layout concept (plain words)

- Headline stays **API server**.
- Chips: **Offline** | **Cloud** only (Offline first). No Local.
- Default selection: Offline → hint + **Start Offline**; hide URL and pairing.
- Cloud → show URL prefilled with `http://127.0.0.1:3000` + pairing code + **Save & connect**.

## States

| State | Behavior |
|-------|----------|
| Offline (default) | Start Offline; no pairing/URL |
| Cloud | URL default local preset; pairing; Save & connect |
| iCloud unavailable on Offline | Error / disable Start (Design) |

## Handoff to Analyze / Design

Build must match both HTML refs: Offline-first two-chip row; Cloud URL default = former `localPreset`.
