import 'planner_state.dart';

/// Persistence boundary for the user's meal plan and planner preferences.
abstract interface class MealPlanRepository {
  Future<PlannerState?> loadPlannerState();

  Future<void> savePlannerState(PlannerState state);
}
