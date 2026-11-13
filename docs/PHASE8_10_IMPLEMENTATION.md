# Phases 8–10 implementation notes

These phases complete the remaining must-have and selected could-have requirements shared by the three product plans. The implementation retains the Gather visual system, Flutter-native state ownership, SQLite-only personal data, and read-only static GitHub content.

## Phase 8 — Personal library and ingredient finder

- Added create, rename, delete, and recipe membership management for local collections.
- Added an ingredient finder with available/excluded ingredient selection, ranked recipe match percentages, and missing-ingredient explanations.
- Collections and cooking history are stored in the versioned local planner snapshot.
- Added matcher tests and expanded planner snapshot round-trip coverage.

## Phase 9 — Global settings and measurement

- Added persistent metric/US customary and week-start preferences.
- Added dimension-safe conversion for mass and volume. Mass is never converted to volume; unknown and count-based units remain unchanged.
- Recipe detail and cooking mode display converted quantities with an approximation marker.
- Planner day ordering follows the selected Monday/Sunday week start.
- Language preference is persisted with the same local snapshot.

## Phase 10 — Cooking continuity and release hardening

- Cooking step, serving, and timer state can be serialized and restored, including absolute timer deadlines.
- Added a SQLite v1→v2 migration that adds the cooking-session snapshot table without discarding existing planner or catalog rows.
- Added SQLite FFI integration tests for local snapshot storage and migration.
- Added a CI test that verifies the checked-in recipe content manifest checksum and byte size against its payload.
- Added cooking history entries when the user confirms completion of a recipe.

## Boundaries and manual QA

- User data remains on device; there is no account, backend, Firebase, cloud sync, or analytics upload.
- Ingredient matching is based on the curated ingredient IDs/names; it does not claim food-safety or allergen guarantees.
- Unit conversion is limited to recognized units within the same dimension. Ingredient-specific density conversions are intentionally not attempted.
- Native TTS, platform timer notifications, keep-screen-awake behavior, and real-device QA remain optional follow-up work; they are not represented as implemented.
