import 'package:flutter/widgets.dart';

class AppTabNavigation extends InheritedWidget {
  const AppTabNavigation({
    super.key,
    required this.onSelect,
    required super.child,
  });

  final ValueChanged<int> onSelect;

  static void select(BuildContext context, int index) {
    context.dependOnInheritedWidgetOfExactType<AppTabNavigation>()?.onSelect(index);
  }

  @override
  bool updateShouldNotify(AppTabNavigation oldWidget) => onSelect != oldWidget.onSelect;
}

void goToAppTab(BuildContext context, int index) => AppTabNavigation.select(context, index);
