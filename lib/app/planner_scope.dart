import 'package:flutter/widgets.dart';

import '../features/planning/domain/planner_state.dart';

class PlannerScope extends InheritedWidget {
  const PlannerScope({
    super.key,
    required this.state,
    required this.onChanged,
    required super.child,
  });

  final PlannerState state;
  final VoidCallback onChanged;

  static PlannerState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.state;
  }

  static void refresh(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.onChanged();
  }

  @override
  bool updateShouldNotify(covariant PlannerScope oldWidget) => true;
}
