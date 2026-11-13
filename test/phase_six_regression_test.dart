import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  group('Phase 6 regression boundaries', () {
    test('empty search returns all published recipes without mutating source', () {
      final before = recipes.map((recipe) => recipe.id).toList();
      final result = RecipeCatalog.search(recipes, query: '   ');
      expect(result, hasLength(recipes.length));
      expect(recipes.map((recipe) => recipe.id).toList(), before);
    });

    test('unknown planned recipe IDs do not create phantom grocery items', () {
      final state = PlannerState()
        ..assignMeal(
          day: 'Monday',
          slot: MealSlot.dinner,
          recipeId: 'removed-recipe',
          servings: 2,
        );
      expect(state.buildGroceryList(recipes), isEmpty);
    });

    test('pantry overstock clamps amount to buy to zero', () {
      final state = PlannerState()
        ..assignMeal(
          day: 'Monday',
          slot: MealSlot.dinner,
          recipeId: 'lemon-pasta',
          servings: 2,
        )
        ..upsertPantryItem(name: 'Pasta', amount: 500, unit: 'g');
      final pasta = state
          .buildGroceryList(recipes)
          .singleWhere((item) => item.name == 'Pasta');
      expect(pasta.amount, 200);
      expect(pasta.ownedAmount, 500);
      expect(pasta.toBuyAmount, 0);
    });

    test('favorite toggling is idempotent across repeated calls', () {
      final state = PlannerState();
      state.toggleFavorite('lemon-pasta');
      expect(state.isFavorite('lemon-pasta'), isTrue);
      state.toggleFavorite('lemon-pasta');
      expect(state.isFavorite('lemon-pasta'), isFalse);
    });

    test('invalid pantry values are ignored', () {
      final state = PlannerState()
        ..upsertPantryItem(name: '   ', amount: 1, unit: 'g')
        ..upsertPantryItem(name: 'Rice', amount: -1, unit: 'g')
        ..upsertPantryItem(name: 'Rice', amount: 1, unit: ' ');
      expect(state.pantry, isEmpty);
    });

    test('grocery check state remains keyed to the normalized ingredient identity', () {
      final state = PlannerState()
        ..assignMeal(
          day: 'Monday',
          slot: MealSlot.dinner,
          recipeId: 'lemon-pasta',
          servings: 2,
        );
      final pasta = state
          .buildGroceryList(recipes)
          .singleWhere((item) => item.name == 'Pasta');
      state.setGroceryChecked(pasta.key, true);
      expect(
        state.buildGroceryList(recipes)
            .singleWhere((item) => item.key == pasta.key).isChecked,
        isTrue,
      );
    });
  });
}
