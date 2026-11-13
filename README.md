# Gather — Recipe Planner

A Flutter recipe-planning app combining the three product plans in
[dharmesh-eww/planning](https://github.com/dharmesh-eww/planning/tree/main/recipe%20planner).

## Product direction

- **App-1:** detailed recipe, cooking, weekly planning and grocery workflows.
- **App-2:** calm utility-first interaction patterns, global-ready UX and accessibility.
- **App-3:** Modern Heritage Kitchen visual identity and resilient offline content principles.

## Phase 1 — Foundation

The foundation now includes:

- Material 3 app setup and a centralized editorial design theme.
- Shared semantic colors, typography, component styling, spacing and motion tokens.
- A consistent fade-and-slide transition between bottom-navigation destinations.
- A reusable fade-and-slide route transition for recipe detail pages.
- A lightweight app-level state scope built with Flutter primitives.
- **No state-management package:** the root `StatefulWidget` owns planner state and calls `setState` to refresh the UI.
- Feature-oriented folder boundaries for recipes, planning, groceries and kitchen.
- A widget test covering the home screen and bottom-navigation changes.

### State management rule

Do not add Provider, Riverpod, Bloc, GetX, or another state-management dependency.
Use `StatefulWidget`, `setState`, and Flutter's built-in widgets for UI updates.
Keep state ownership explicit and move persistence into a repository layer in a
later phase without changing this requirement.


## Phase 2 — Recipe domain, catalog and discovery

Phase 2 standardizes the catalog around one Dart domain model while keeping the
existing Gather screens and planner interactions intact.

- Canonical recipe fields cover stable IDs/slugs, display text, category and
  cuisine IDs, food/dietary types, prep/cook minutes, servings, ingredients
  with explicit units and quantity qualifiers, equipment, instructions, tags,
  image attribution and verified-allergen metadata.
- Recipe serialization emits a shared snake_case catalog representation
  inspired by the three planning specifications. Ingredient quantities preserve
  their original units; non-quantified entries such as “to taste” remain
  qualifiers.
- A curated local RecipeCatalog is the single source for Today, discovery,
  recipe details, favourites and weekly planning. It currently includes five
  sample recipes.
- Discovery searches titles, descriptions, categories, cuisines, tags and
  ingredient names; filters by meal category; and sorts by recommended order,
  total cooking time or title. Clear-search and empty-result states are included.
- Recipe details and serving-scaled grocery additions use the same ingredient
  objects. Non-quantified ingredients are not added as zero-quantity grocery
  items.
- Added domain tests for serialization/search/filter/sort and widget coverage
  for discovery search and category filters.
- No state-management package was introduced. UI state remains in
  StatefulWidget and is updated with setState.

Remote manifests, checksums, atomic content activation and durable database
storage remain later-phase work; this catalog is intentionally local.

## Current product prototype

- Five-section navigation: Today, Recipes, Plan, Groceries and Kitchen.
- Editorial Today screen with featured and suggested recipes.
- Recipe discovery with search and meal-category filters.
- Recipe details, adjustable servings and ingredient quantity scaling.
- Add recipe ingredients to a consolidated grocery checklist.
- Weekly meal planning and saved recipes.

The prototype currently uses in-memory sample data. Persistence, remote content,
offline synchronization and the full feature-level architecture are planned for
subsequent phases.

## Planned sequence

1. Foundation and design system.
2. Recipe models, catalog and discovery.
3. Guided cooking and timers.
4. Weekly planning, grocery generation and pantry.
5. Offline content, localization and accessibility.
6. Testing, optimization and release readiness.
7. Local persistence and static content updates.
8. Personal library and ingredient finder.
9. Global settings and measurement.
10. Cooking continuity and release hardening.
11. Discovery and personalization.
12. Grocery workflow and privacy polish.

## Run

```bash
flutter pub get
flutter run
``

Run the automated checks with:

```bash
flutter analyze
flutter test
``

## Phase 3 — Guided cooking and timers

- Added a focused, distraction-free cooking mode with one instruction at a time,
  step progress, large readable text and previous/next/finish controls.
- Cooking progress and serving preference are retained per recipe in the
  app-scoped in-memory cooking session, including when leaving and reopening
  the cooking route during the same app run.
- Added serving-aware ingredient quantities to the cooking view.
- Added multiple independently labelled kitchen timers with start, pause,
  resume, reset and remove actions.
- Timer countdowns are derived from absolute end times and refreshed on app
  resume, so elapsed time remains logically correct when the operating system
  throttles background Dart timers. In-app completion is shown when the app is
  active; platform notifications and process-death persistence are not included.
- Cooking session uses Flutter-native ChangeNotifier/StatefulWidget patterns;
  no state-management package was added.
- Added unit coverage for timer lifecycle and ingredient scaling, plus widget
  coverage for entering cooking mode and moving between steps.

## Phase 4 — Weekly planning, groceries and pantry

- Replaced the loose day-to-recipe list with a seven-day planner and four
  explicit meal slots per day: breakfast, lunch, dinner and snack.
- Recipes can be assigned to a slot, replaced, and removed independently.
  Each planned meal stores its serving count.
- Grocery requirements are derived from all planned meals and scaled servings.
  Matching ingredient names and units combine deterministically; different
  units remain separate. Non-quantified ingredients remain visible as
  check-before-shopping entries rather than zero-quantity rows.
- Existing recipe-detail grocery additions remain supported.
- Added an editable in-memory pantry with ingredient, amount and unit. Matching
  pantry quantities are deducted from quantified grocery needs.
- Grocery items can be renamed, have their needed quantity edited, and be checked off; the planner links directly to the list.
- State remains local and in-memory through PlannerState and PlannerScope. No
  backend, persistence dependency or state-management package was introduced.
- Added tests for slot assignment/removal, serving-scaled aggregation,
  non-quantified ingredients, pantry matching and planner navigation.


## Phase 5 — Offline content, localization and accessibility

- Added a versioned JSON asset catalog with a dedicated parser and deterministic validation errors for schema versions, required collections, duplicate identifiers, ingredient names, serving counts and cooking instructions.
- The app loads the bundled catalog through a Flutter-native inherited scope. If the asset is missing or invalid, the existing in-code catalog remains active; planner, pantry and grocery state are not reset.
- Added English and Arabic locale support using Flutter localization delegates. Arabic uses Flutter's RTL directionality, with translated navigation, discovery, category and weekly-planner entry copy and a visible language switch.
- Added screen-reader labels for the language control. Existing cooking-step live announcements and adjustable instruction text remain supported.
- Added catalog validation and locale/RTL widget tests. No backend, cloud sync, login or state-management package was introduced.
- Flutter analyze/test execution must be confirmed in an environment with Flutter installed before reporting checks as passed.


## Phase 6 — Testing, optimization and release readiness

- Added a GitHub Actions quality gate for dependency resolution, Flutter static analysis and the complete automated test suite on pushes, pull requests and manual runs.
- Added regression coverage for empty search, unknown recipe references, pantry overstock, invalid pantry values, favorite toggling and stable grocery check identity.
- Added a release-readiness checklist covering device sizes, accessibility, offline fallback, localization, timer limitations, licences, signing and store metadata.
- CI is configured but must execute on GitHub before a green result can be claimed. Local Flutter/Dart CLI was unavailable during implementation; no local test or analyzer pass is claimed.


## Phase 7 — Local persistence and static content updates

- Added a SQLite repository for planner snapshots and the active recipe catalog cache. The app restores the cached catalog and personal planner state on launch when the database is available; it falls back to the bundled starter catalog and in-memory state if local storage cannot be opened.
- Favorites, meal slots and servings, pantry quantities, grocery check states, manual grocery additions and grocery edits are serialized in a versioned snapshot and saved locally after planner interactions.
- Added a read-only static GitHub content updater. It validates the manifest schema and relative paths, downloads the recipe index, verifies SHA-256 and optional byte size, then validates the catalog before activation.
- Catalog payload and content version are activated together in a SQLite transaction. Failed network, checksum or schema validation leaves the previous active catalog untouched.
- Published the starter catalog as a static content index with a versioned manifest. No user-owned data is sent to GitHub.
- Added planner snapshot round-trip and malformed-snapshot tests, plus SQLite FFI integration and schema migration coverage in Phase 10. Static updater tests cover valid downloads, checksum failures and path traversal. Android/iOS device validation remains a manual release check.
- No account, backend, Firebase, cloud sync or state-management package.


## Phase 8 — Personal library and ingredient finder

- Added local recipe collections with create, rename, delete, and recipe membership controls.
- Added an ingredient finder that ranks recipes by the share of listed ingredients available, supports excluded ingredients, and clearly lists missing ingredients.
- Collections are included in the versioned SQLite-backed planner snapshot.

## Phase 9 — Global settings and measurement

- Added persisted metric/US customary preference and Monday/Sunday week-start preference.
- Added safe mass-to-mass and volume-to-volume conversion. Cross-dimension conversions are never attempted; unknown and count-based units remain unchanged.
- Recipe detail and cooking mode display approximate converted quantities when a conversion is available.
- The weekly planner and Today summary follow the selected week start; language preference is persisted locally.

## Phase 10 — Cooking continuity and release hardening

- Cooking step, serving preference, and timer state can be restored from local storage. Running timers retain absolute deadlines so elapsed time remains accurate after relaunch.
- Added SQLite schema version 2 migration for cooking-session snapshots without discarding existing planner or catalog data.
- Added SQLite FFI integration tests for snapshot persistence and v1-to-v2 migration.
- Added a CI integrity test for the checked-in static recipe manifest checksum and byte size.
- Completed cooking sessions are recorded in a local cooking history.

The implementation remains offline-first and account-free. No backend, Firebase, cloud sync, social features, or state-management package has been added. Native text-to-speech, platform timer notifications, keep-screen-awake behavior, and physical-device QA remain optional follow-up work.


## Phase 11 — Discovery and personalization

- Expanded recipe search filters to combine cuisine, food type, difficulty, maximum preparation/cooking time, and saved dietary preferences alongside category and text search.
- Added persistent dietary discovery preferences in local planner settings.
- Added a recently viewed recipe shelf in Kitchen, recorded on recipe detail entry and retained locally.
- Upgraded planner snapshot schema to v3 while preserving v1/v2 restore compatibility.

## Phase 12 — Grocery workflow and privacy polish

- Grouped generated and custom grocery entries into practical aisle sections (produce, chilled, pantry, other).
- Added custom grocery entries with editable quantity/unit, merge-by-normalized ingredient identity, and individual removal.
- Added a clear action for checked custom grocery entries.
- Added a confirmed local-data reset that clears favorites, plans, groceries, pantry, collections, history, recent views and discovery preferences while retaining the cached recipe catalog.
- Added regression tests for advanced filters, snapshot v3 compatibility, custom grocery items and personal-data reset.

No personal data is uploaded. Dietary preferences are used only to filter the local recipe catalog; they are not health or allergen guarantees. Aisle assignment is a convenience heuristic and can be corrected by editing/removing the item.
