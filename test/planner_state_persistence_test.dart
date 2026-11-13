import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  test('planner state round-trips every user-owned collection', () {
    final original = PlannerState()
      ..toggleFavorite('lemon-pasta')
      ..assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'lemon-pasta', servings: 4)
      ..upsertPantryItem(name: 'Pasta', amount: 100, unit: 'g')
      ..addIngredients(recipes.first, 2);
    final pastaKey = original.buildGroceryList(recipes).first.key;
    original.setGroceryChecked(pastaKey, true);
    original.updateGroceryItem(pastaKey, name: 'Fresh pasta', amount: 450);
    final restored = PlannerState.fromJson(original.toJson());
    expect(restored.isFavorite('lemon-pasta'), isTrue);
    expect(restored.mealsFor('Monday').single.servings, 4);
    expect(restored.pantry.values.single.amount, 100);
    expect(restored.groceryChecks[pastaKey], isTrue);
    expect(restored.groceryEdits[pastaKey]?.name, 'Fresh pasta');
    expect(restored.buildGroceryList(recipes).firstWhere((item) => item.key == pastaKey).amount, 450);
  });

  test('unsupported snapshots restore as an empty safe state', () {
    final restored = PlannerState.fromJson({'schema_version': 99, 'favorites': ['x']});
    expect(restored.favorites, isEmpty);
    expect(restored.mealPlan, isEmpty);
  });

  test('malformed snapshot entries are skipped without losing valid entries', () {
    final restored = PlannerState.fromJson({
      'schema_version': 1,
      'favorites': ['recipe-a', 4, ''],
      'meals': [
        {'day': 'Monday', 'slot': 'dinner', 'recipe_id': 'recipe-a', 'servings': 2},
        {'day': 'Tuesday', 'slot': 'unknown', 'recipe_id': 'recipe-b', 'servings': 2},
        {'day': '', 'slot': 'lunch', 'recipe_id': 'recipe-c', 'servings': 1}
      ]
    });
    expect(restored.favorites, {'recipe-a'});
    expect(restored.mealsFor('Monday'), hasLength(1));
    expect(restored.mealsFor('Tuesday'), isEmpty);
  });
}
