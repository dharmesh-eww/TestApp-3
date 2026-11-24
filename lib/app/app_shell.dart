import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/recipes/presentation/discover_screen.dart';
import '../features/planning/presentation/plan_screen.dart';
import '../features/groceries/presentation/grocery_screen.dart';
import '../features/kitchen/presentation/kitchen_home_screen.dart';
import '../localization/app_localizations.dart';
import 'app_tab_navigation.dart';
import 'planner_scope.dart';
import 'gather_visuals.dart';

/// Main tab scaffold, kept separate from application startup and persistence.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.onLocaleChanged});
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selected = 0;

  List<Widget> get pages => [
    const TodayScreen(),
    const DiscoverScreen(),
    const PlanScreen(),
    const GroceryScreen(),
    KitchenScreen(onLocaleChanged: widget.onLocaleChanged),
  ];

  void selectTab(int index) {
    if (index < 0 || index >= pages.length || index == selected) return;
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PlannerScope.of(context).reduceMotion;
    return AppTabNavigation(
      onSelect: selectTab,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              PositionedDirectional(
                end: 8,
                top: 4,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: .10,
                    child: GatherVisuals.foodMotion(size: 112),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: reduceMotion ? Duration.zero : AppMotion.page,
                      switchInCurve: AppMotion.enter,
                      switchOutCurve: AppMotion.exit,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, .025),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(selected),
                        child: pages[selected],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: selectTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: const Icon(Icons.wb_sunny_rounded),
              label: appStrings(context).today,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_rounded),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: appStrings(context).recipes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: appStrings(context).plan,
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_basket_outlined),
              selectedIcon: const Icon(Icons.shopping_basket_rounded),
              label: appStrings(context).groceries,
            ),
            NavigationDestination(
              icon: const Icon(Icons.shelves),
              selectedIcon: const Icon(Icons.shelves),
              label: appStrings(context).kitchen,
            ),
          ],
        ),
      ),
    );
  }
}
