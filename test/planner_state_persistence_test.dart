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
    final collectionId = original.createCollection('Weeknight favourites');
    original.toggleRecipeInCollection(collectionId, 'lemon-pasta');
    original.measurementSystem = 'us';
    original.weekStartsOn = 7;
    original.localeCode = 'ar';
    original.recordCooked(recipes.first);
    original.recordViewed(recipes.last);
    original.preferredDietaryTags.add('plant_based');
    original.addCustomGroceryItem(name: 'Tea bags', amount: 2, unit: 'boxes');
    final pastaKey = original.buildGroceryList(recipes).singleWhere((item) => item.name == 'Pasta').key;
    original.setGroceryChecked(pastaKey, true);
    original.updateGroceryItem(pastaKey, name: 'Fresh pasta', amount: 450);
    final restored = PlannerState.fromJson(original.toJson());
    expect(restored.isFavorite('lemon-pasta'), isTrue);
    expect(restored.mealsFor('Monday').single.servings, 4);
    expect(restored.pantry.values.single.amount, 100);
    expect(restored.groceryChecks[pastaKey], isTrue);
    expect(restored.groceryEdits[pastaKey]?.name, 'Fresh pasta');
    expect(restored.collections[collectionId], contains('lemon-pasta'));
    expect(restored.collectionNames[collectionId], 'Weeknight favourites');
    expect(restored.measurementSystem, 'us');
    expect(restored.weekStartsOn, 7);
    expect(restored.localeCode, 'ar');
    expect(restored.cookingHistory, hasLength(1));
    expect(restored.recentlyViewed.single['recipe_id'], recipes.last.id);
    expect(restored.preferredDietaryTags, contains('plant_based'));
    expect(restored.buildGroceryList(recipes).any((item) => item.name == 'Tea bags' && item.isCustom), isTrue);
    expect(restored.buildGroceryList(recipes).firstWhere((item) => item.key == pastaKey).amount, 450);
  });

  test('legacy v1 snapshots remain readable after the v3 schema migration', () {
    final restored = PlannerState.fromJson({'schema_version': 1, 'favorites': ['legacy-recipe']});
    expect(restored.isFavorite('legacy-recipe'), isTrue);
    expect(restored.toJson()['schema_version'], 3);
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


test('reset personal data clears local user state without changing catalog', () {
    final state = PlannerState()
      ..toggleFavorite('lemon-pasta')
      ..recordViewed(recipes.first)
      ..addCustomGroceryItem(name: 'Tea', amount: 1, unit: 'box')
      ..preferredDietaryTags.add('plant_based');
    state.clearPersonalData();
    expect(state.favorites, isEmpty);
    expect(state.recentlyViewed, isEmpty);
    expect(state.customGroceryItems, isEmpty);
    expect(state.preferredDietaryTags, isEmpty);
    expect(recipes, isNotEmpty);
  });
}
