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

  /// Common regional and grocery-label variants. IDs remain the preferred key;
  /// aliases only improve name-based discovery and are not food-safety rules.
  static const Map<String, Set<String>> _aliases = {
    'chickpea': {'chana', 'garbanzo', 'garbanzo bean'},
    'coriander': {'cilantro', 'dhaniya'},
    'eggplant': {'aubergine', 'brinjal', 'baingan'},
    'bell pepper': {'capsicum', 'shimla mirch'},
    'yogurt': {'curd', 'dahi'},
    'okra': {'lady finger', 'bhindi'},
    'cumin': {'jeera'},
    'turmeric': {'haldi'},
    'red lentil': {'masoor dal', 'masoor'},
    'mung bean': {'moong dal', 'moong'},
  };

  static Set<String> _names(String value) {
    final normalized = _normalize(value);
    final result = <String>{normalized};
    for (final entry in _aliases.entries) {
      final canonical = _normalize(entry.key);
      final aliases = entry.value.map(_normalize).toSet();
      if (normalized == canonical || aliases.contains(normalized)) {
        result.add(canonical);
        result.addAll(aliases);
      }
    }
    return result;
  }

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
        final names = _names(ingredient.name);
        return values.any((value) {
          final aliases = _names(value);
          if (aliases.any((alias) => names.contains(alias)) || value == id) return true;
          return aliases.any((alias) => names.any((name) =>
              alias.length > 2 && (name.contains(alias) || alias.contains(name))));
        });
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
