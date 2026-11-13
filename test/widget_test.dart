import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';

void main() {
  testWidgets('shows the Gather recipe planner home', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());

    expect(find.text('A little more joy\nin the kitchen.'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    expect(find.text('Find your next\nfavourite.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('recipe-search-field')), 'chickpeas');
    await tester.pumpAndSettle();
    expect(find.text('Roasted harvest bowl'), findsOneWidget);
    expect(find.text('Lemon ricotta pasta'), findsNothing);

    await tester.tap(find.byKey(const Key('category-breakfast')));
    await tester.pumpAndSettle();
    expect(find.text('Overnight berry oats'), findsNothing);
    expect(find.text('Nothing on this shelf'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Overnight berry oats'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('A little more joy\nin the kitchen.'), findsOneWidget);
  });
}
