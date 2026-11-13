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
