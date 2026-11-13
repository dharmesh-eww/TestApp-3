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

  test('excluded ingredients remove recipes from results', () {
    final results = IngredientMatcher.rank(recipes,
        available: {'tomatoes'}, excluded: {'cream'});
    expect(results.any((item) => item.recipe.id == 'tomato-soup'), isFalse);
  });
}
