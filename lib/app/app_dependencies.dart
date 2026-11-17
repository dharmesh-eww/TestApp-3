import '../features/planning/domain/planner_state.dart';
import '../features/cooking/domain/cooking_session.dart';
import '../core/data/app_repository.dart';

/// Lightweight dependency container; no DI package is required.
class AppDependencies {
  AppDependencies({PlannerState? plannerState, CookingSession? cookingSession, this.repository})
      : plannerState = plannerState ?? PlannerState(),
        cookingSession = cookingSession ?? CookingSession();

  final AppRepository? repository;
  final PlannerState plannerState;
  final CookingSession cookingSession;

  void dispose() => cookingSession.dispose();
}
