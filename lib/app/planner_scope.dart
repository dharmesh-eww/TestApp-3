import 'package:flutter/widgets.dart';

import '../features/planning/domain/planner_state.dart';
import '../features/cooking/domain/cooking_session.dart';

class PlannerScope extends InheritedWidget {
  const PlannerScope({
    super.key,
    required this.state,
    required this.cookingSession,
    required this.onChanged,
    required super.child,
  });

  final PlannerState state;
  final CookingSession cookingSession;
  final VoidCallback onChanged;

  static PlannerState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.state;
  }

  static CookingSession cookingOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.cookingSession;
  }

  static void refresh(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.onChanged();
  }

  @override
  bool updateShouldNotify(covariant PlannerScope oldWidget) => state != oldWidget.state || cookingSession != oldWidget.cookingSession;
}
