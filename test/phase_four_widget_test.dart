import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';

void main() {
  testWidgets('assigns a recipe to a weekly meal slot and builds groceries', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Monday'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-Monday-breakfast')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overnight berry oats').last);
    await tester.pumpAndSettle();

    expect(find.text('Overnight berry oats'), findsOneWidget);
    final planContext = tester.element(find.text('Overnight berry oats'));
    final planner = PlannerScope.of(planContext);
    expect(planner.plannedMealCount, 1);
    final groceryItems = planner.buildGroceryList(RecipeCatalogScope.of(planContext));
    expect(groceryItems.map((item) => item.name), contains('Rolled oats'));

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    expect(find.text('Rolled oats'), findsOneWidget);
    expect(find.textContaining('50 g needed'), findsOneWidget);
  });

  testWidgets('removes an assigned meal from its slot', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-Monday-breakfast')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overnight berry oats').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('remove-Monday-breakfast')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('meal-slot-Monday-breakfast')),
        matching: find.text('Nothing planned yet'),
      ),
      findsOneWidget,
    );
  });
}
