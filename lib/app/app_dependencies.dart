import '../features/planning/domain/planner_state.dart';
import '../features/cooking/domain/cooking_session.dart';

/// Lightweight dependency container; no DI package is required.
class AppDependencies {
  AppDependencies({PlannerState? plannerState, CookingSession? cookingSession})
      : plannerState = plannerState ?? PlannerState(),
        cookingSession = cookingSession ?? CookingSession();

  final PlannerState plannerState;
  final CookingSession cookingSession;

  void dispose() => cookingSession.dispose();
}
