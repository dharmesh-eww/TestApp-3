import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/ingredient_matcher.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  group('PlannerState locale persistence', () {
    for (final locale in const ['en', 'hi', 'gu', 'ar', 'ja', 'pt', 'id', 'es', 'zh']) {
      test('restores $locale', () {
        final state = PlannerState.fromJson({
          'schema_version': 5,
          'preferences': {'locale_code': locale},
        });

        expect(state.localeCode, locale);
      });
    }
  });

  test('recipe decoding prefers the requested translation with English fallback', () {
    final recipe = Recipe.fromJson({
      'id': 'localized-recipe',
      'title': 'Original title',
      'description': 'Original description',
      'translations': {
        'ja': {'title': '日本語のタイトル', 'description': '日本語の説明'},
        'en': {'title': 'English title'},
      },
      'servings': 2,
      'ingredients': [
        {
          'ingredient_id': 'tofu',
          'display_name': 'Tofu',
          'translations': {
            'ja': {'name': '豆腐'},
          },
          'quantity': {'amount': 100, 'unit': 'g'},
        },
      ],
      'instructions': [
        {
          'step': 1,
          'text': 'Original instruction',
          'localized_instruction': {
            'ja': '日本語の手順',
            'en': 'English instruction',
          },
        },
      ],
    }, localeCode: 'ja');

    expect(recipe.title, '日本語のタイトル');
    expect(recipe.subtitle, '日本語の説明');
    expect(recipe.ingredients.single.name, '豆腐');
    expect(recipe.steps.single, '日本語の手順');
  });

  test('ingredient matching preserves non-Latin ingredient names', () {
    final recipe = Recipe(
      id: 'tofu-recipe',
      title: 'Tofu bowl',
      subtitle: '',
      image: '',
      minutes: 10,
      difficulty: 'Easy',
      category: 'Lunch',
      calories: 200,
      servings: 1,
      ingredients: const [Ingredient('豆腐', 100, 'g', id: 'tofu')],
      steps: const ['Cook the tofu.'],
    );

    final matches = IngredientMatcher.rank([recipe], available: {'豆腐'});

    expect(matches, hasLength(1));
    expect(matches.single.isExactMatch, isTrue);
    expect(matches.single.matchPercent, 100);
  });

  test('saved cuisine preferences filter recipe discovery', () {
    final matches = RecipeCatalog.search(
      recipes,
      preferredCuisines: {'italian'},
    );

    expect(matches, isNotEmpty);
    expect(matches.every((recipe) => recipe.cuisineIds.contains('italian')), isTrue);
    expect(matches.map((recipe) => recipe.id), contains('lemon-pasta'));
  });
}
