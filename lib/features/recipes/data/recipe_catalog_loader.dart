import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/recipe.dart';

class CatalogLoadException implements Exception {
  const CatalogLoadException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => 'CatalogLoadException($code): $message';
}

class RecipeCatalogDocument {
  const RecipeCatalogDocument({required this.schemaVersion, required this.categories, required this.recipes});
  final int schemaVersion;
  final List<RecipeCategory> categories;
  final List<Recipe> recipes;
}

class RecipeCatalogLoader {
  const RecipeCatalogLoader._();
  static const assetPath = 'assets/data/recipes.json';
  static const supportedSchemaVersion = 1;

  static Future<RecipeCatalogDocument> load({AssetBundle? bundle}) async =>
      decode(await (bundle ?? rootBundle).loadString(assetPath));

  static RecipeCatalogDocument decode(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const CatalogLoadException('invalid_json', 'The recipe catalog is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const CatalogLoadException('invalid_document', 'The catalog root must be a JSON object.');
    }
    if (decoded['schema_version'] != supportedSchemaVersion) {
      throw CatalogLoadException('unsupported_schema', 'Expected catalog schema version $supportedSchemaVersion.');
    }
    final rawCategories = decoded['categories'];
    final rawRecipes = decoded['recipes'];
    if (rawCategories is! List || rawRecipes is! List || rawRecipes.isEmpty) {
      throw const CatalogLoadException('missing_collections', 'Catalog categories and a non-empty recipes list are required.');
    }

    final categories = <RecipeCategory>[];
    final categoryIds = <String>{};
    for (var i = 0; i < rawCategories.length; i++) {
      final raw = rawCategories[i];
      if (raw is! Map) throw CatalogLoadException('invalid_category', 'Category at index $i must be an object.');
      final map = Map<String, dynamic>.from(raw);
      final id = map['id'], name = map['name'];
      if (id is! String || id.trim().isEmpty || name is! String || name.trim().isEmpty) {
        throw CatalogLoadException('invalid_category', 'Category at index $i needs a non-empty id and name.');
      }
      if (!categoryIds.add(id)) throw CatalogLoadException('duplicate_category_id', 'Category id "$id" appears more than once.');
      categories.add(RecipeCategory.fromJson(map));
    }

    final ids = <String>{};
    final recipes = <Recipe>[];
    for (var i = 0; i < rawRecipes.length; i++) {
      final raw = rawRecipes[i];
      if (raw is! Map) throw CatalogLoadException('invalid_recipe', 'Recipe at index $i must be an object.');
      final map = Map<String, dynamic>.from(raw);
      final id = map['id'], title = map['title'], servings = map['servings'];
      final ingredients = map['ingredients'];
      final instructions = map['instructions'] ?? map['steps'];
      if (id is! String || id.trim().isEmpty || title is! String || title.trim().isEmpty ||
          servings is! num || servings <= 0 || ingredients is! List ||
          instructions is! List || instructions.isEmpty) {
        throw CatalogLoadException('invalid_recipe', 'Recipe at index $i is missing a valid id, title, servings, ingredients or instructions.');
      }
      if (!ids.add(id)) throw CatalogLoadException('duplicate_recipe_id', 'Recipe id "$id" appears more than once.');
      for (var j = 0; j < ingredients.length; j++) {
        final ingredient = ingredients[j];
        if (ingredient is! Map) throw CatalogLoadException('invalid_ingredient', 'Ingredient $j in recipe "$id" must be an object.');
        final name = ingredient['display_name'] ?? ingredient['name'];
        if (name is! String || name.trim().isEmpty) {
          throw CatalogLoadException('invalid_ingredient', 'Ingredient $j in recipe "$id" needs a name.');
        }
      }
      final recipe = Recipe.fromJson(map);
      if (recipe.steps.isEmpty) throw CatalogLoadException('invalid_recipe_steps', 'Recipe "$id" must contain at least one non-empty instruction.');
      recipes.add(recipe);
    }
    return RecipeCatalogDocument(
      schemaVersion: supportedSchemaVersion,
      categories: List.unmodifiable(categories),
      recipes: List.unmodifiable(recipes),
    );
  }
}
