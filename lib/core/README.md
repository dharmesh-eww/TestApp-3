# App foundation

This folder contains app-wide primitives shared by feature modules.

## Dependency direction

- Presentation widgets depend on feature/domain contracts and inherited scopes.
- Domain code does not depend on Flutter widgets or SQLite.
- main.dart composes the app with an AppRepository implementation.
- core/data/app_repository.dart composes the feature repository interfaces;
  data/local/planner_repository.dart is the current SQLite adapter.

## State and persistence

The app intentionally uses Flutter's built-in StatefulWidget, setState and
small inherited scopes; no state-management package is required. The root owns
the in-memory planner model. Persistence is injected through repository
interfaces, so widgets do not need to know whether data is local or eventually
synchronized.

Meal plans, pantry and grocery data currently share one versioned planner
snapshot to preserve atomic cross-feature updates. Keep that shared aggregate
until a transactional migration to dedicated stores is designed.

## Structure

- core/theme: semantic colors, typography, component themes and motion tokens.
- core/data: app-level repository composition contracts.
- features: feature modules and their domain repository interfaces.
- shared: reusable widgets and utilities shared by features.
- localization/app_locale.dart: canonical supported locale configuration.
