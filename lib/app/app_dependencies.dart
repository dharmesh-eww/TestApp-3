import '../features/planning/domain/planner_state.dart';

/// Lightweight dependency container; no DI package is required.
class AppDependencies {
  AppDependencies({PlannerState? plannerState})
      : plannerState = plannerState ?? PlannerState();

  final PlannerState plannerState;
}
