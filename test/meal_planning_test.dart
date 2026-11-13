import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  group('Weekly meal planning', () {
    test('assigns, replaces and removes individual meal slots', () {
      final state = PlannerState();
      state.assignMeal(day: 'Monday', slot: MealSlot.breakfast, recipeId: 'berry-oats', servings: 2);
      state.assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'lemon-pasta', servings: 3);
      expect(state.mealsFor('Monday'), hasLength(2));

      state.assignMeal(day: 'Monday', slot: MealSlot.breakfast, recipeId: 'gujarati-dhokla', servings: 4);
      expect(state.mealsFor('Monday'), hasLength(2));
      expect(state.mealsFor('Monday').firstWhere((m) => m.slot == MealSlot.breakfast).recipeId, 'gujarati-dhokla');

      state.removeMeal('Monday', MealSlot.dinner);
      expect(state.mealsFor('Monday'), hasLength(1));
      state.removeMeal('Monday', MealSlot.breakfast);
      expect(state.mealPlan.containsKey('Monday'), isFalse);
    });

    test('aggregates matching ingredients across planned meals and servings', () {
      final state = PlannerState();
      state.assignMeal(day: 'Monday', slot: MealSlot.lunch, recipeId: 'lemon-pasta', servings: 2);
      state.assignMeal(day: 'Tuesday', slot: MealSlot.dinner, recipeId: 'lemon-pasta', servings: 4);

      final list = state.buildGroceryList(recipes);
      final pasta = list.singleWhere((item) => item.name == 'Pasta');
      expect(pasta.amount, 600);
      expect(pasta.unit, 'g');
    });

    test('deducts matching pantry stock from the amount to buy', () {
      final state = PlannerState();
      state.assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'lemon-pasta', servings: 2);
      state.upsertPantryItem(name: 'pasta', amount: 125, unit: 'G');

      final pasta = state.buildGroceryList(recipes).singleWhere((item) => item.name == 'Pasta');
      expect(pasta.amount, 200);
      expect(pasta.ownedAmount, 125);
      expect(pasta.toBuyAmount, 75);
    });

    test('supports editing a generated grocery item without changing its identity', () {
      final state = PlannerState()
        ..assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'lemon-pasta', servings: 2);
      final pasta = state.buildGroceryList(recipes).singleWhere((item) => item.name == 'Pasta');
      state.updateGroceryItem(pasta.key, name: 'Fresh pasta', amount: 250);
      final edited = state.buildGroceryList(recipes).singleWhere((item) => item.key == pasta.key);
      expect(edited.name, 'Fresh pasta');
      expect(edited.amount, 250);
    });

    test('keeps non-quantified ingredients without inventing a quantity', () {
      const recipe = Recipe(
        id: 'seasoned', title: 'Seasoned', subtitle: '', image: '', minutes: 1,
        difficulty: 'Easy', category: 'Dinner', calories: 0, servings: 2,
        ingredients: [Ingredient('Salt', null, '', amountType: IngredientAmountType.toTaste)],
        steps: [],
      );
      final state = PlannerState()
        ..assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'seasoned', servings: 2);
      final salt = state.buildGroceryList([recipe]).single;
      expect(salt.name, 'Salt');
      expect(salt.isQuantified, isFalse);
      expect(salt.toBuyAmount, 0);
    });

    test('does not combine equal ingredient names with different units', () {
      const grams = Recipe(id: 'g', title: 'G', subtitle: '', image: '', minutes: 1,
        difficulty: 'Easy', category: 'Dinner', calories: 0, servings: 1,
        ingredients: [Ingredient('Rice', 100, 'g')], steps: []);
      const cups = Recipe(id: 'c', title: 'C', subtitle: '', image: '', minutes: 1,
        difficulty: 'Easy', category: 'Dinner', calories: 0, servings: 1,
        ingredients: [Ingredient('Rice', 1, 'cup')], steps: []);
      final state = PlannerState()
        ..assignMeal(day: 'Monday', slot: MealSlot.lunch, recipeId: 'g', servings: 1)
        ..assignMeal(day: 'Monday', slot: MealSlot.dinner, recipeId: 'c', servings: 1);
      expect(state.buildGroceryList([grams, cups]), hasLength(2));
    });
  });
}
