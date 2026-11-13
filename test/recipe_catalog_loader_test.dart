import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/recipes/data/recipe_catalog_loader.dart';

void main() {
  Map<String, dynamic> sample() => {
    'schema_version': 1,
    'categories': [{'id': 'dinner', 'name': 'Dinner'}],
    'recipes': [{
      'id': 'soup', 'title': 'Tomato soup', 'description': 'A warm bowl',
      'servings': 2, 'prep_minutes': 5, 'cook_minutes': 10,
      'ingredients': [{'ingredient_id': 'tomato', 'display_name': 'Tomato',
        'quantity': {'amount': 2, 'unit': 'whole'}}],
      'instructions': [{'step': 1, 'text': 'Simmer gently.'}]
    }]
  };

  test('parses a valid versioned catalog', () {
    final parsed = RecipeCatalogLoader.decode(jsonEncode(sample()));
    expect(parsed.schemaVersion, 1);
    expect(parsed.recipes.single.id, 'soup');
    expect(parsed.recipes.single.ingredients.single.amount, 2);
  });

  test('uses a stable error for malformed JSON', () {
    expect(() => RecipeCatalogLoader.decode('{bad'),
      throwsA(isA<CatalogLoadException>().having((e) => e.code, 'code', 'invalid_json')));
  });

  test('rejects unsupported schema versions', () {
    final value = sample()..['schema_version'] = 9;
    expect(() => RecipeCatalogLoader.decode(jsonEncode(value)),
      throwsA(isA<CatalogLoadException>().having((e) => e.code, 'code', 'unsupported_schema')));
  });

  test('rejects duplicate recipe identifiers', () {
    final value = sample();
    value['recipes'] = [...value['recipes'], value['recipes'].first];
    expect(() => RecipeCatalogLoader.decode(jsonEncode(value)),
      throwsA(isA<CatalogLoadException>().having((e) => e.code, 'code', 'duplicate_recipe_id')));
  });

  test('rejects recipes without instructions', () {
    final value = sample();
    value['recipes'][0]['instructions'] = [];
    expect(() => RecipeCatalogLoader.decode(jsonEncode(value)),
      throwsA(isA<CatalogLoadException>().having((e) => e.code, 'code', 'invalid_recipe')));
  });
}
