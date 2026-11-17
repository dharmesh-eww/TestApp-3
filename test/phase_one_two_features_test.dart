import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/ingredient_matcher.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

Recipe _recipe({
  String id = 'test-recipe',
  List<Ingredient> ingredients = const [],
  bool allergensVerified = true,
  List<String> allergens = const [],
}) => Recipe(
  id: id,
  title: 'Test recipe',
  subtitle: 'A test recipe',
  image: '',
  minutes: 20,
  prepMinutes: 5,
  cookMinutes: 15,
  difficulty: 'Easy',
  category: 'Dinner',
  categoryIds: const ['dinner'],
  calories: 350,
  proteinGrams: 20,
  carbsGrams: 30,
  fatGrams: 12,
  servings: 2,
  ingredients: ingredients,
  steps: const ['Cook the ingredients.'],
  allergensVerified: allergensVerified,
  verifiedAllergens: allergens,
);

void main() {
  group('Phase 1 and 2 local feature persistence', () {
    test('persists custom recipes, allergies, goals, ratings, notes and grocery budget', () {
      final state = PlannerState()
        ..allergies.addAll(['peanuts', 'milk'])
        ..dailyCalorieTarget = 1850
        ..dailyProteinTargetGrams = 115
        ..groceryBudget = 80
        ..mealRemindersEnabled = true
        ..pantryExpiryRemindersEnabled = true
        ..mealReminderMinutes = 30;
      state.saveCustomRecipe(_recipe(id: 'custom-test'));
      state.setRecipeRating('custom-test', 5);
      state.setRecipeNote('custom-test', 'Toast spices first.');
      state.setMealPrepDone('2026-11-18', 'Onions', true);
      state.setGroceryPrice('onions|g', 2.5);
      state.setGroceryStore('onions|g', 'Market');

      final restored = PlannerState.fromJson(state.toJson());

      expect(restored.customRecipes['custom-test']?.title, 'Test recipe');
      expect(restored.allergies, containsAll(['peanuts', 'milk']));
      expect(restored.dailyCalorieTarget, 1850);
      expect(restored.dailyProteinTargetGrams, 115);
      expect(restored.groceryBudget, 80);
      expect(restored.mealRemindersEnabled, isTrue);
      expect(restored.pantryExpiryRemindersEnabled, isTrue);
      expect(restored.mealReminderMinutes, 30);
      expect(restored.recipeRatings['custom-test'], 5);
      expect(restored.recipeNotes['custom-test'], 'Toast spices first.');
      expect(restored.isMealPrepDone('2026-11-18', 'Onions'), isTrue);
      expect(restored.groceryPrices['onions|g'], 2.5);
      expect(restored.groceryStores['onions|g'], 'Market');
    });

    test('custom recipe JSON retains nutrition and step timer metadata', () {
      final recipe = Recipe(
        id: 'custom-step-test',
        title: 'Timed recipe',
        subtitle: 'Includes a timed step',
        image: '',
        minutes: 15,
        difficulty: 'Easy',
        category: 'Dinner',
        calories: 420,
        proteinGrams: 25,
        carbsGrams: 40,
        fatGrams: 14,
        servings: 2,
        ingredients: const [Ingredient('Rice', 1, 'cup')],
        steps: const ['Simmer the rice.'],
        stepDetails: const [
          RecipeStep(step: 1, text: 'Simmer the rice.', durationMinutes: 12, image: 'https://example.com/step.jpg'),
        ],
      );

      final decoded = Recipe.fromJson(recipe.toJson());

      expect(decoded.proteinGrams, 25);
      expect(decoded.carbsGrams, 40);
      expect(decoded.fatGrams, 14);
      expect(decoded.instructions.single.durationMinutes, 12);
      expect(decoded.instructions.single.image, 'https://example.com/step.jpg');
    });
  });

  test('allergy filters exclude unverified recipes and recipes containing selected allergens', () {
    final safe = _recipe(id: 'verified-safe');
    final unsafe = _recipe(id: 'verified-milk', allergens: const ['Milk']);
    final unknown = _recipe(id: 'unknown-allergens', allergensVerified: false);

    final results = RecipeCatalog.search(
      [safe, unsafe, unknown],
      allergies: const {'milk'},
    );

    expect(results.map((recipe) => recipe.id).toList(), ['verified-safe']);
  });

  test('pantry quantity matching leaves insufficient quantities in the missing list', () {
    final recipe = _recipe(
      ingredients: const [Ingredient('Rolled oats', 50, 'g')],
    );

    final insufficient = IngredientMatcher.rank(
      [recipe],
      available: const {'Rolled oats'},
      availableQuantities: const {
        'Rolled oats': (amount: 20, unit: 'g'),
      },
    ).single;
    expect(insufficient.matchPercent, 0);
    expect(insufficient.missingIngredients.single.name, 'Rolled oats');

    final sufficient = IngredientMatcher.rank(
      [recipe],
      available: const {'Rolled oats'},
      availableQuantities: const {
        'Rolled oats': (amount: 60, unit: 'g'),
      },
    ).single;
    expect(sufficient.isExactMatch, isTrue);
    expect(sufficient.matchPercent, 100);
  });
}
