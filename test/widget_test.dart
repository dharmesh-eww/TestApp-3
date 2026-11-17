import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';

void main() {
  testWidgets('opens expanded cuisine and cooking-time filters in a bottom sheet', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-recipe-filters')));
    await tester.pumpAndSettle();

    expect(find.text('Recipe filters'), findsOneWidget);
    expect(find.byKey(const Key('cuisine-option-north_indian')), findsOneWidget);
    expect(find.byKey(const Key('cuisine-option-south_indian')), findsOneWidget);
    expect(find.byKey(const Key('cuisine-option-chinese')), findsOneWidget);
    expect(find.text('Total cooking time'), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);

    await tester.tap(find.byKey(const Key('cuisine-option-italian')));
    await tester.tap(find.text('Show recipes'));
    await tester.pumpAndSettle();

    expect(find.text('Lemon ricotta pasta'), findsOneWidget);
    expect(find.text('Gujarati dhokla'), findsNothing);
  });

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

  testWidgets('language is changed from Kitchen > Settings > Language', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());

    expect(find.byKey(const Key('locale-toggle')), findsNothing);
    await tester.tap(find.text('Kitchen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const Key('open-language-selection')), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-language-selection')));
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR LANGUAGE'), findsOneWidget);
    final englishOption = find.byKey(const Key('language-option-english'));
    final hindiOption = find.byKey(const Key('language-option-hindi'));
    final gujaratiOption = find.byKey(const Key('language-option-gujarati'));
    final arabicOption = find.byKey(const Key('language-option-arabic'));
    final japaneseOption = find.byKey(const Key('language-option-japanese'));
    final portugueseOption = find.byKey(const Key('language-option-portuguese'));
    final indonesianOption = find.byKey(const Key('language-option-indonesian'));
    final spanishOption = find.byKey(const Key('language-option-spanish'));
    final chineseOption = find.byKey(const Key('language-option-chinese'));
    await tester.drag(find.byType(ListView).last, const Offset(0, -900));
    await tester.pumpAndSettle();
    final orderedOptions = [englishOption, hindiOption, gujaratiOption, arabicOption, japaneseOption, portugueseOption, indonesianOption, spanishOption, chineseOption];
    for (final option in orderedOptions) {
      expect(option, findsOneWidget);
    }
    for (var i = 0; i < orderedOptions.length - 1; i++) {
      expect(tester.getTopLeft(orderedOptions[i]).dy, lessThan(tester.getTopLeft(orderedOptions[i + 1]).dy));
    }

    await tester.tap(japaneseOption);
    await tester.pumpAndSettle();

    expect(find.text('設定'), findsOneWidget);
    expect(find.text('言語'), findsOneWidget);
    expect(find.byKey(const Key('locale-toggle')), findsNothing);
  });

  testWidgets('schedules a recipe on a selected date from the Plan page', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('schedule-recipe-from-plan')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a recipe'), findsOneWidget);
    await tester.tap(find.byKey(const Key('plan-select-recipe-lemon-pasta')));
    await tester.pumpAndSettle();

    expect(find.text('Plan Lemon ricotta pasta'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Start date'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-recipe-schedule')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.textContaining('Dinner · Lemon ricotta pasta'), 250);
    expect(find.textContaining('Dinner · Lemon ricotta pasta'), findsOneWidget);
    expect(find.textContaining('Added 1 date(s)'), findsOneWidget);
  });

  testWidgets('recipe details can schedule the opened recipe', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lemon ricotta pasta').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('schedule-recipe-button')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('schedule-recipe-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('schedule-recipe-button')));
    await tester.pumpAndSettle();
    expect(find.text('Plan Lemon ricotta pasta'), findsOneWidget);
    expect(find.byKey(const Key('confirm-recipe-schedule')), findsOneWidget);
  });
}
