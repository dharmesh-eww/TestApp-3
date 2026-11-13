import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  group('Recipe catalog', () {
    test('searches ingredient names and tags case-insensitively', () {
      final result = RecipeCatalog.search(recipes, query: 'CHICKPEAS');
      expect(result.map((recipe) => recipe.id), contains('roasted-bowl'));
    });

    test('filters by category ID, including multi-category recipes', () {
      final result = RecipeCatalog.search(recipes, categoryId: 'snacks');
      expect(result.map((recipe) => recipe.id), ['gujarati-dhokla']);
    });

    test('sorts by total prep and cook time', () {
      final result = RecipeCatalog.search(recipes, sort: RecipeSort.quickest);
      expect(result.first.id, 'berry-oats');
      expect(result.last.id, 'tomato-soup');
    });

    test('omits unpublished recipes from discovery', () {
      final hidden = Recipe(
        id: 'hidden', title: 'Hidden', subtitle: '', image: '',
        minutes: 1, difficulty: 'Easy', category: 'Lunch', calories: 0,
        servings: 1, ingredients: const [], steps: const [],
        isPublished: false,
      );
      expect(RecipeCatalog.search([hidden]), isEmpty);
    });

    test('serializes canonical fields and ingredient quantities', () {
      final json = recipes.first.toJson();
      expect(json['prep_minutes'], 5);
      expect(json['cook_minutes'], 15);
      expect(json['category_ids'], ['dinner']);
      final ingredient = (json['ingredients'] as List).first as Map;
      expect(ingredient['ingredient_id'], 'pasta');
      expect(ingredient['quantity'], {'amount': 200.0, 'unit': 'g'});
    });

    test('round-trips the canonical recipe JSON representation', () {
      final original = recipes.first;
      final restored = Recipe.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.totalMinutes, original.totalMinutes);
      expect(restored.ingredients.first.amount, original.ingredients.first.amount);
    });

    test('preserves non-quantified ingredient qualifiers', () {
      const ingredient = Ingredient(
        'Salt', null, '', id: 'salt',
        amountType: IngredientAmountType.toTaste,
      );
      expect(ingredient.display(2, 2), 'to taste');
      expect(ingredient.toJson()['quantity'], {'qualifier': 'to_taste'});
    });
  });
}
