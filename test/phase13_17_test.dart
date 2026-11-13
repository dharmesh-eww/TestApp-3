import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/ingredient_matcher.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

void main() {
  group('Phase 13–17 planning improvements', () {
    test('moves a planned meal and preserves servings without overwriting', () {
      final state = PlannerState()
        ..assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'soup', servings: 4)
        ..assignMeal(day: 'Tuesday', slot: MealSlot.dinner, recipeId: 'pasta', servings: 2);

      expect(state.moveMeal(fromDay: 'Monday', fromSlot: MealSlot.dinner,
        toDay: 'Wednesday', toSlot: MealSlot.lunch), isTrue);
      expect(state.mealsFor('Monday'), isEmpty);
      expect(state.mealsFor('Wednesday').single.recipeId, 'soup');
      expect(state.mealsFor('Wednesday').single.servings, 4);
      expect(state.moveMeal(fromDay: 'Tuesday', fromSlot: MealSlot.dinner,
        toDay: 'Wednesday', toSlot: MealSlot.lunch), isFalse);
      expect(state.mealsFor('Wednesday').single.recipeId, 'soup');
    });

    test('creates named grocery lists and assigns generated item identities', () {
      final state = PlannerState();
      final id = state.createGroceryList('Saturday market');
      state.assignGroceryItem(id, 'tomato|g');
      expect(state.groceryListNames[id], 'Saturday market');
      expect(state.groceryLists[id], contains('tomato|g'));
      state.renameGroceryList(id, 'Sunday market');
      expect(state.groceryListNames[id], 'Sunday market');
      state.removeGroceryItemFromList(id, 'tomato|g');
      expect(state.groceryLists[id], isEmpty);
      state.deleteGroceryList(id);
      expect(state.groceryLists, isEmpty);
    });

    test('tracks pantry expiry and returns items expiring within seven days', () {
      final state = PlannerState()..upsertPantryItem(name: 'Spinach', amount: 1, unit: 'bag');
      final item = state.pantry.values.single;
      state.setPantryExpiry(item.id, DateTime.now().add(const Duration(days: 3)));
      expect(state.expiringPantryItems.map((entry) => entry.id), contains(item.id));
      state.setPantryExpiry(item.id, DateTime.now().add(const Duration(days: 30)));
      expect(state.expiringPantryItems, isEmpty);
      state.removePantryItem(item.id);
      expect(state.pantryExpiryDates.containsKey(item.id), isFalse);
    });

    test('matches common regional ingredient aliases', () {
      const recipe = Recipe(
        id: 'aubergine-recipe', title: 'Aubergine roast', subtitle: '', image: '',
        minutes: 10, difficulty: 'Easy', category: 'Dinner', calories: 0, servings: 1,
        ingredients: [Ingredient('Eggplant', 1, 'whole')], steps: [],
      );
      final matches = IngredientMatcher.rank([recipe], available: {'aubergine'});
      expect(matches.single.matchPercent, 100);
      expect(matches.single.isExactMatch, isTrue);
    });

    test('persists onboarding, theme and reduced-motion preferences', () {
      final state = PlannerState()
        ..onboardingComplete = true
        ..themePreference = 'dark'
        ..reduceMotion = true;
      final restored = PlannerState.fromJson(state.toJson());
      expect(restored.onboardingComplete, isTrue);
      expect(restored.themePreference, 'dark');
      expect(restored.reduceMotion, isTrue);
    });
  });

  testWidgets('first-run onboarding completes into the recipe planner', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp(showOnboarding: true));
    expect(find.text('A gentler way to gather.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-get-started')));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
  });
}
