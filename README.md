# Gather — Recipe Planner

A Flutter recipe-planning app being implemented from the three product plans in
[dharmesh-eww/planning](https://github.com/dharmesh-eww/planning/tree/main/recipe%20planner).

## Product direction

The implementation combines:
- **App-1:** detailed recipe, cooking, weekly planning and grocery workflows.
- **App-2:** calm utility-first interaction patterns, global-ready UX and accessibility.
- **App-3:** Modern Heritage Kitchen visual identity and resilient offline content principles.

## Current implementation

The first app milestone includes:
- Five-section navigation: Today, Recipes, Plan, Groceries and Kitchen.
- Editorial Today screen with featured and suggested recipes.
- Recipe discovery with search and meal-category filters.
- Recipe details, adjustable servings and ingredient quantity scaling.
- Add recipe ingredients to a consolidated grocery checklist.
- Weekly meal planning and saved recipes.
- Warm paper, espresso, terracotta and olive visual foundation.

The current milestone uses in-memory sample data so the main user journeys can be
reviewed before persistence and remote content are introduced.

## Planned implementation sequence

1. Foundation: app architecture, design system, navigation and shared state.
2. Recipes: canonical recipe schema, remote catalog, search, details and filters.
3. Cooking: guided cooking mode, step timers and background-safe timer lifecycle.
4. Planning: persistent weekly plan, serving-aware grocery generation and pantry.
5. Offline/global: SQLite persistence, content manifest validation, localization,
   RTL, measurement preferences, accessibility and data integrity.
6. Quality: automated tests, performance, privacy review and release readiness.

## Run

```bash
flutter pub get
flutter run
```
