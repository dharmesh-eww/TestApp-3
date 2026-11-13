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
