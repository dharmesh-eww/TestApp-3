import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  group('optional recipe nutrition and seasonal metadata', () {
    test('reads optional nutrition, vitamins, health benefits and seasons', () {
      final recipe = Recipe.fromJson({
        'id': 'winter-lentil-soup',
        'title': 'Winter lentil soup',
        'description': 'A warming lentil soup',
        'image': '',
        'category_ids': ['lunch'],
        'servings': 2,
        'nutrition': {
          'calories_kcal': 250,
          'protein_g': 14,
          'fiber_g': 9.5,
          'vitamins': {'vitamin_c_mg': 12, 'vitamin_a_mcg': 80},
        },
        'health_benefits': ['Provides plant protein', 'Contains dietary fibre'],
        'seasons': ['winter', 'rainy'],
        'ingredients': [],
        'instructions': [],
      });

      expect(recipe.calories, 250);
      expect(recipe.proteinGrams, 14);
      expect(recipe.fiberGrams, 9.5);
      expect(recipe.vitamins['vitamin_c_mg'], 12);
      expect(recipe.healthBenefits, contains('Provides plant protein'));
      expect(recipe.seasons, containsAll(['winter', 'rainy']));
      expect(recipe.hasNutritionData, isTrue);
    });

    test('leaves absent optional data absent instead of displaying zero values', () {
      final recipe = Recipe.fromJson({
        'id': 'simple-recipe',
        'title': 'Simple recipe',
        'description': '',
        'image': '',
        'servings': 1,
        'ingredients': [],
        'instructions': [],
      });

      expect(recipe.fiberGrams, isNull);
      expect(recipe.vitamins, isEmpty);
      expect(recipe.healthBenefits, isEmpty);
      expect(recipe.seasons, isEmpty);
      expect(recipe.hasNutritionData, isFalse);
    });

    test('reads an optional YouTube video URL and ignores invalid URLs', () {
      final recipe = Recipe.fromJson({
        'id': 'video-recipe',
        'title': 'Video recipe',
        'description': '',
        'image': '',
        'servings': 1,
        'youtube_video_url': 'https://www.youtube.com/watch?v=LDR6Kas6zyU',
        'ingredients': [],
        'instructions': ['Cook it'],
      });
      expect(recipe.youtubeVideoUrl, 'https://www.youtube.com/watch?v=LDR6Kas6zyU');

      final invalid = Recipe.fromJson({
        'id': 'invalid-video-recipe',
        'title': 'No video',
        'description': '',
        'image': '',
        'servings': 1,
        'youtube_video_url': 'https://example.com/watch?v=123',
        'ingredients': [],
        'instructions': ['Cook it'],
      });
      expect(invalid.youtubeVideoUrl, isNull);
    });

    test('filters by season and by nutrition data availability', () {
      final seasonal = Recipe.fromJson({
        'id': 'winter-soup',
        'title': 'Winter soup',
        'description': '',
        'image': '',
        'servings': 1,
        'calories_kcal': 200,
        'nutrition': {'protein_g': 8},
        'seasons': ['winter'],
        'ingredients': [],
        'instructions': [],
      });
      final plain = Recipe.fromJson({
        'id': 'plain-recipe',
        'title': 'Plain recipe',
        'description': '',
        'image': '',
        'servings': 1,
        'ingredients': [],
        'instructions': [],
      });

      expect(RecipeCatalog.search([seasonal, plain], season: 'winter').map((r) => r.id), ['winter-soup']);
      expect(RecipeCatalog.search([seasonal, plain], nutritionOnly: true).map((r) => r.id), ['winter-soup']);
    });
  });
}
