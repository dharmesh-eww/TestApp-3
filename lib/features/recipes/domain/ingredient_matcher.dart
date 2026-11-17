import 'recipe.dart';
import 'measurement_units.dart';

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
    Map<String, ({double amount, String unit})> availableQuantities = const {},
  }) {
    final normalizedAvailable = {
      ...available.map(_normalize).where((v) => v.isNotEmpty),
      ...availableQuantities.keys.map(_normalize).where((v) => v.isNotEmpty),
    };
    final normalizedExcluded = excluded.map(_normalize).where((v) => v.isNotEmpty).toSet();
    final results = <IngredientMatch>[];
    for (final recipe in recipes.where((item) => item.isPublished)) {
      bool matchesAny(Ingredient ingredient, Set<String> values) {
        final id = _normalize(ingredient.id);
        final names = _names(ingredient.name);
        return values.any((value) {
          final aliases = _names(value);
          if (aliases.any((alias) => names.contains(alias)) || value == id) return true;
          // Ingredient names must match exactly after normalization/alias
          // expansion. Substring matching makes "ham" match "chamomile",
          // and "rice" match "rice vinegar", which overstates pantry coverage.
          return false;
        });
      }

      if (recipe.ingredients.any((item) => matchesAny(item, normalizedExcluded))) {
        continue;
      }
      bool quantityAvailable(Ingredient ingredient) {
        if (ingredient.amount == null || ingredient.amountType != IngredientAmountType.quantity) return true;
        final candidates = availableQuantities.entries.where((entry) {
          final names = _names(entry.key);
          return names.any((name) => _names(ingredient.name).contains(name)) ||
              _normalize(entry.key) == _normalize(ingredient.id);
        });
        if (candidates.isEmpty) return true;
        final requiredAmount = _toBase(ingredient.amount!, ingredient.unit);
        for (final entry in candidates) {
          final availableAmount = _toBase(entry.value.amount, entry.value.unit);
          if (requiredAmount != null && availableAmount != null && requiredAmount.unit == availableAmount.unit) {
            if (availableAmount.amount >= requiredAmount.amount) return true;
          } else if (entry.value.unit.toLowerCase() == ingredient.unit.toLowerCase() &&
              entry.value.amount >= ingredient.amount!) {
            return true;
          }
        }
        return false;
      }

      final matched = recipe.ingredients
          .where((item) => matchesAny(item, normalizedAvailable) && quantityAvailable(item))
          .toList(growable: false);
      final missing = recipe.ingredients
          .where((item) => !matchesAny(item, normalizedAvailable) || !quantityAvailable(item))
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

  static ({double amount, String unit})? _toBase(double amount, String unit) {
    final converted = MeasurementUnits.convert(amount, unit, 'metric');
    if (converted == null) return null;
    final normalizedUnit = converted.unit.toLowerCase();
    if (normalizedUnit == 'kg') return (amount: converted.amount * 1000, unit: 'g');
    if (normalizedUnit == 'l') return (amount: converted.amount * 1000, unit: 'ml');
    return (amount: converted.amount, unit: normalizedUnit);
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[.,;:!?()_\-\[\]{}"“”‘’/\\|]+'), ' ')
      .trim();
}
