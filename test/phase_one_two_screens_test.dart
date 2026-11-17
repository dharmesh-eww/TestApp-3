import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';

void main() {
  testWidgets('meal planner opens a month calendar with prep checklist', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-meal-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Meal calendar'), findsOneWidget);
    expect(find.text('Nothing planned'), findsWidgets);
    await tester.scrollUntilVisible(find.byKey(const Key('meal-prep-heading')), 250, scrollable: find.descendant(
        of: find.byKey(const Key('meal-calendar-scroll')),
        matching: find.byType(Scrollable),
      ).first);
    expect(find.byKey(const Key('meal-prep-heading')), findsOneWidget);
  });

  testWidgets('meal planner opens nutrition dashboard and daily goals', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-nutrition-dashboard')));
    await tester.pumpAndSettle();

    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Planned nutrition'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Protein'), findsWidgets);
  });
}
