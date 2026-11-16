import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

Recipe _recipe(String id, double amount, String unit) => Recipe(
      id: id,
      title: id,
      subtitle: '',
      image: '',
      minutes: 1,
      difficulty: 'Easy',
      category: 'Dinner',
      calories: 100,
      servings: 1,
      ingredients: [Ingredient('Flour', amount, unit, id: 'flour')],
      steps: const [],
    );

void main() {
  test('merges mass quantities expressed in grams and kilograms', () {
    final state = PlannerState();
    final grams = _recipe('grams', 500, 'g');
    final kilograms = _recipe('kilograms', .5, 'kg');
    state.assignMeal(day: '2026-11-16', slot: MealSlot.breakfast,
        recipeId: grams.id, servings: 1);
    state.assignMeal(day: '2026-11-17', slot: MealSlot.lunch,
        recipeId: kilograms.id, servings: 1);

    final items = state.buildGroceryList([grams, kilograms]);

    expect(items, hasLength(1));
    expect(items.single.unit, 'kg');
    expect(items.single.amount, closeTo(1, .0001));
  });

  test('compatible pantry mass offsets planned recipe quantities', () {
    final state = PlannerState();
    final grams = _recipe('grams', 1000, 'g');
    state.assignMeal(day: '2026-11-16', slot: MealSlot.breakfast,
        recipeId: grams.id, servings: 1);
    state.upsertPantryItem(name: 'Flour', amount: .5, unit: 'kg');

    final item = state.buildGroceryList([grams]).single;

    expect(item.unit, 'kg');
    expect(item.amount, closeTo(1, .0001));
    expect(item.ownedAmount, closeTo(.5, .0001));
    expect(item.toBuyAmount, closeTo(.5, .0001));
  });

  test('owned and to-buy quantities use the same displayed unit', () {
    final state = PlannerState()..measurementSystem = 'us';
    final recipe = _recipe('mass', 400, 'g');
    state.assignMeal(day: '2026-11-16', slot: MealSlot.breakfast,
        recipeId: recipe.id, servings: 1);
    state.upsertPantryItem(name: 'Flour', amount: 200, unit: 'g');

    final item = state.buildGroceryList([recipe]).single;

    expect(item.unit, 'oz');
    expect(item.ownedAmount, closeTo(200 / 28.349523125, .001));
    expect(item.toBuyAmount, closeTo(200 / 28.349523125, .001));
  });

  test('checked custom groceries clear after their units are normalized', () {
    final state = PlannerState();
    state.addCustomGroceryItem(name: 'Sugar', amount: .5, unit: 'kg');
    final item = state.buildGroceryList(const []).single;

    expect(item.isCustom, isTrue);
    state.setGroceryChecked(item.key, true);
    state.clearCheckedCustomGroceryItems();

    expect(state.buildGroceryList(const []), isEmpty);
  });

  test('does not combine mass and volume quantities', () {
    final state = PlannerState();
    final mass = _recipe('mass', 200, 'g');
    final volume = _recipe('volume', 200, 'ml');
    state.assignMeal(day: '2026-11-16', slot: MealSlot.breakfast,
        recipeId: mass.id, servings: 1);
    state.assignMeal(day: '2026-11-17', slot: MealSlot.lunch,
        recipeId: volume.id, servings: 1);

    final items = state.buildGroceryList([mass, volume]);

    expect(items, hasLength(2));
    expect(items.map((item) => item.unit).toSet(), {'g', 'ml'});
  });
}
