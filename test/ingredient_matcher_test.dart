import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/recipes/domain/ingredient_matcher.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  test('ranks recipes by available ingredient coverage and missing items', () {
    final results = IngredientMatcher.rank(recipes,
        available: {'tomatoes', 'onion'});
    expect(results, isNotEmpty);
    expect(results.first.matchPercent, greaterThanOrEqualTo(results.last.matchPercent));
    expect(results.first.missingIngredients, isA<List>());
  });

  test('does not treat a substring as an available ingredient', () {
    const recipe = Recipe(
      id: 'ham-recipe', title: 'Ham plate', subtitle: '', image: '',
      minutes: 1, difficulty: 'Easy', category: 'Lunch', calories: 1,
      servings: 1, ingredients: [Ingredient('Ham', 1, 'g')], steps: [],
    );
    final results = IngredientMatcher.rank([recipe], available: {'chamomile'});
    expect(results.single.matchPercent, 0);
    expect(results.single.missingIngredients, hasLength(1));
  });

  test('matches curated regional aliases exactly', () {
    const recipe = Recipe(
      id: 'chickpea-recipe', title: 'Chickpea bowl', subtitle: '', image: '',
      minutes: 1, difficulty: 'Easy', category: 'Lunch', calories: 1,
      servings: 1, ingredients: [Ingredient('Chickpea', 100, 'g')], steps: [],
    );
    final results = IngredientMatcher.rank([recipe], available: {'chana'});
    expect(results.single.matchPercent, 100);
  });

  test('excluded ingredients remove recipes from results', () {
    final results = IngredientMatcher.rank(recipes,
        available: {'tomatoes'}, excluded: {'cream'});
    expect(results.any((item) => item.recipe.id == 'tomato-soup'), isFalse);
  });
}
