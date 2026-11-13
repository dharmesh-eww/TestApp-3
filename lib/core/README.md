# App foundation

This folder contains the app-wide foundation. Feature code should depend on
these shared primitives rather than defining its own colors, spacing, or motion.

## State updates

The app intentionally uses Flutter's built-in `StatefulWidget` and `setState`.
No state-management package is used. The root app state owns the in-memory
planner model and exposes a small inherited scope so feature widgets can read
the model and request a root rebuild after mutations.

## Structure

- `core/theme`: semantic colors, typography, component themes and motion tokens.
- `features`: feature modules (recipes, planning, groceries and kitchen).
- `shared`: reusable widgets and utilities shared by features.

Feature extraction and persistence are intentionally staged for later phases.
