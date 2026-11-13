# Phases 13–17 implementation record

This implementation extends the existing 12-phase Gather app without introducing a backend, account, cloud sync or state-management package.

## Phase 13 — Core workflow completion

Implemented:
- First-run introduction with locally persisted completion.
- Safe meal moves between day/slot destinations; occupied destinations are not overwritten.
- Named shopping lists with create, rename, delete and generated-item membership.
- Pantry expiry dates, persistence and a seven-day expiry query.
- Planner snapshot v4 with v1–v3 backward-compatible restore.

## Phase 14 — Advanced cooking

Implemented:
- Optional Android TTS for the current instruction.
- Android keep-screen-awake toggle, cleared when cooking mode is disposed.
- Current-step timer label shortcut.
- Confirmation before leaving cooking mode while a timer is running.
- Android timer notifications with a local alarm, notification channel, cancellation and Android 13+ runtime permission flow.
- In-app timer remains the source of truth; notifications are best-effort OS delivery.

## Phase 15 — Global UX and accessibility

Implemented:
- System/light/dark appearance preference.
- Palette tokens adapt to the selected appearance.
- Persisted reduced-motion setting for primary route transitions.
- Regional ingredient aliases in the ingredient finder.
- Existing English/Arabic and RTL support retained.

Not yet complete:
- Full reviewed translations for additional locales.
- Reduced-motion coverage for every micro-animation and all third-party/platform transitions.
- Device-level accessibility verification.

## Phase 16 — Content and notifications

Implemented:
- Android native timer notification bridge.
- Static recipe update pipeline remains checksum/schema validated and retains the prior catalog on failure.

Not yet complete:
- iOS native bridge. No `ios/Runner` project currently exists in this repository, so iOS TTS, timer notifications and keep-screen-awake cannot be honestly marked implemented.
- User-facing download byte progress and a detailed update result/retry history.
- Broader curated recipe catalog and licensed production photography. Existing attribution fields and manifest validation remain available.

## Phase 17 — Release polish

Implemented:
- Regression tests for newly added domain workflows and preference persistence.
- CI Android debug build to compile the Kotlin bridge and validate manifest integration.

Still required before production:
- Android and iOS physical-device QA, notification permission/denial testing, background/Doze behavior and alarm delivery checks.
- iOS platform scaffold and equivalent native implementation.
- Screen-reader, contrast, RTL, large text and reduced-motion review on devices.
- Production application ID, signing keys, release builds, store assets and privacy disclosures.
- Content licensing and a larger reviewed recipe catalog.

## Architecture constraints retained

- Flutter-native state ownership (`StatefulWidget`, `setState`, `PlannerScope`).
- SQLite local storage for personal planner data.
- Static GitHub-hosted catalog updates only.
- No login, custom backend, Firebase, analytics upload or cloud synchronization.
- Pantry expiry is a reminder only; it is not a food-safety judgment.
- Dietary tags and ingredient aliases are discovery aids, not allergen or medical suitability guarantees.
