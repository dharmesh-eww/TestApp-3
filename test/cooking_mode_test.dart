import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  testWidgets('enters guided cooking and advances recipe steps', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(recipes.first.title).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('start-cooking-button')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('start-cooking-button')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-cooking-button')));
    await tester.pumpAndSettle();

    expect(find.text('STEP 1 OF ${recipes.first.steps.length}'), findsOneWidget);
    expect(find.text(recipes.first.steps.first), findsOneWidget);
    if (recipes.first.steps.length > 1) {
      await tester.tap(find.text('Next step'));
      await tester.pumpAndSettle();
      expect(find.text('STEP 2 OF ${recipes.first.steps.length}'), findsOneWidget);
    }
  });
}
