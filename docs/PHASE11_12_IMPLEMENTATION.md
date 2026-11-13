# Phases 11–12 implementation

These milestones close remaining daily-use and privacy requirements shared by the App-1, App-2 and App-3 product plans.

## Phase 11 — Discovery and personalization

- Discovery can combine category, query, cuisine, food type, difficulty, maximum total minutes and saved dietary tags.
- Dietary preferences are local-only and editable in Kitchen settings.
- Recipe detail visits are recorded in a 30-entry, most-recent-first history and shown in Kitchen.
- Planner snapshot schema v3 stores recent views and discovery preferences. Restore remains backward-compatible with schema v1 and v2.

## Phase 12 — Grocery workflow and privacy polish

- Grocery items are grouped by a transparent, best-effort aisle heuristic: produce, dairy/chilled, pantry and other.
- Users can add custom grocery items, merge repeated entries by normalized name/unit, edit quantities and remove custom entries.
- Checked custom entries can be cleared without deleting planned-recipe requirements.
- A confirmation-gated personal-data reset clears on-device personal state and cooking session while retaining the cached static recipe catalog.
- Tests cover advanced discovery filters, v3 snapshot persistence, legacy snapshot restoration, custom grocery behavior and reset behavior.

## Explicit limitations

- Dietary tags are discovery metadata only. They do not establish allergen safety, medical suitability or nutritional outcomes.
- Aisle grouping is heuristic and may need user correction for regional shopping habits.
- Recently viewed entries whose recipe has been removed from the active catalog are retained in the snapshot but not rendered as recipe cards.
- No analytics, accounts, backend, cloud sync, advertising SDK or grocery checkout has been introduced.
- Device-level release QA and accessibility review on Android/iOS are still required.
