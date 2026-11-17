# Application architecture

## Dependency direction

Presentation widgets depend on feature/domain models and inherited scopes. They do
not import SQLite or know which persistence adapter is active. The application
composition root (main.dart / RecipePlannerApp) supplies an AppRepository
implementation through AppDependencies.

## Feature repository contracts

- RecipeRepository: cached recipe catalog reads and activation of downloaded
  catalog versions.
- MealPlanRepository: load/save the versioned planner aggregate.
- PantryRepository: pantry-facing persistence boundary.
- GroceryRepository: grocery-facing persistence boundary.
- CookingSessionRepository: in-progress cooking session snapshots.

AppRepository composes these contracts. PlannerRepository is the current
SQLite adapter. Pantry, grocery and meal-plan data intentionally remain in one
versioned planner snapshot today: this preserves atomic updates across features
and avoids duplicated sources of truth. Their interfaces establish feature
ownership and make a later dedicated or cloud-backed adapter possible without
moving storage code into widgets. When those stores are split, migrate the
snapshot in a transaction and retain the existing schema compatibility tests.

## Local-first and future synchronization

SQLite remains the source of truth for personal data. A future cloud sync should
be introduced as another AppRepository implementation or a decorator, not as
network calls from screens. Keep sync policy (identity, conflict resolution,
retry/offline queue and merge timestamps) behind the repository boundary. Do not
silently change local-first behavior or upload personal data without an explicit
product decision and user consent.

## Localization

AppLocale is the canonical list and normalization policy for supported locale
codes. MaterialApp, the custom AppLocalizations delegate and RecipeCatalogLoader
all use it. Recipe translation decoding receives the same normalized language
code as the selected UI locale, with English as the safe fallback for
unsupported persisted values.

## Testing expectations

- Repository contract tests run against the SQLite adapter using an in-memory
  compatible test driver and a temporary database.
- Migration tests verify existing snapshots survive schema upgrades.
- Locale tests keep the supported UI and recipe locale sets aligned and verify
  unsupported codes fall back to English.
- Domain tests cover recurrence, grocery aggregation, pantry quantity
  deductions and cooking timers independently of the storage adapter.
