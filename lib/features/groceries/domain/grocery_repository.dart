import '../../planning/domain/planner_state.dart';

/// Persistence boundary for grocery lists, quantities, prices and stores.
///
/// Grocery data currently shares the planner's versioned aggregate snapshot
/// so cross-feature edits remain consistent. A cloud or dedicated local store
/// can implement this interface later without leaking storage into widgets.
abstract interface class GroceryRepository {
  Future<PlannerState?> loadGroceryState();

  Future<void> saveGroceryState(PlannerState state);
}
