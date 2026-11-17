import '../../planning/domain/planner_state.dart';

/// Persistence boundary for pantry data.
///
/// Pantry currently lives in the planner's versioned aggregate snapshot. This
/// contract deliberately keeps that atomic boundary while allowing a future
/// dedicated pantry store to be introduced without changing the UI.
abstract interface class PantryRepository {
  Future<PlannerState?> loadPantryState();

  Future<void> savePantryState(PlannerState state);
}
