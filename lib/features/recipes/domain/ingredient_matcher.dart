import 'recipe.dart';

class IngredientMatch {
  const IngredientMatch({
    required this.recipe,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.matchPercent,
  });

  final Recipe recipe;
  final List<Ingredient> matchedIngredients;
  final List<Ingredient> missingIngredients;
  final int matchPercent;
  bool get isExactMatch => missingIngredients.isEmpty;
}

class IngredientMatcher {
  const IngredientMatcher._();

  static List<IngredientMatch> rank(
    Iterable<Recipe> recipes, {
    required Set<String> available,
    Set<String> excluded = const {},
  }) {
    final normalizedAvailable = available.map(_normalize).where((v) => v.isNotEmpty).toSet();
    final normalizedExcluded = excluded.map(_normalize).where((v) => v.isNotEmpty).toSet();
    final results = <IngredientMatch>[];
    for (final recipe in recipes.where((item) => item.isPublished)) {
      bool matchesAny(Ingredient ingredient, Set<String> values) {
        final id = _normalize(ingredient.id);
        final name = _normalize(ingredient.name);
        return values.any((value) =>
            value == id || value == name ||
            (value.length > 2 && (name.contains(value) || value.contains(name))));
      }

      if (recipe.ingredients.any((item) => matchesAny(item, normalizedExcluded))) {
        continue;
      }
      final matched = recipe.ingredients
          .where((item) => matchesAny(item, normalizedAvailable))
          .toList(growable: false);
      final missing = recipe.ingredients
          .where((item) => !matchesAny(item, normalizedAvailable))
          .toList(growable: false);
      if (normalizedAvailable.isEmpty) {
        results.add(IngredientMatch(
          recipe: recipe,
          matchedIngredients: const [],
          missingIngredients: recipe.ingredients,
          matchPercent: 0,
        ));
      } else {
        final percent = recipe.ingredients.isEmpty
            ? 0
            : (matched.length * 100 / recipe.ingredients.length).round();
        results.add(IngredientMatch(
          recipe: recipe,
          matchedIngredients: matched,
          missingIngredients: missing,
          matchPercent: percent,
        ));
      }
    }
    results.sort((a, b) {
      final percent = b.matchPercent.compareTo(a.matchPercent);
      if (percent != 0) return percent;
      final missing = a.missingIngredients.length.compareTo(b.missingIngredients.length);
      return missing != 0 ? missing : a.recipe.title.compareTo(b.recipe.title);
    });
    return results;
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}
