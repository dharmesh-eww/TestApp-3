import '../../recipes/domain/recipe.dart';

class PlannerState {
  final Set<String> favorites = {};
  final Map<String, List<String>> mealPlan = {};
  final Map<String, bool> groceryChecks = {};
  final Map<String, String> groceryNames = {};

  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    if (!favorites.add(id)) favorites.remove(id);
  }

  void addToPlan(String day, String recipeId) {
    final items = mealPlan.putIfAbsent(day, () => <String>[]);
    if (!items.contains(recipeId)) items.add(recipeId);
  }

  void addIngredients(Recipe recipe, int servings) {
    for (final ingredient in recipe.ingredients) {
      final amount = ingredient.amount * servings / recipe.servings;
      final key = '${ingredient.name.toLowerCase()}|${ingredient.unit}';
      final old = groceryNames[key];
      final nextAmount = old == null
          ? amount
          : (double.tryParse(old.split('|').first) ?? 0) + amount;
      final shown = nextAmount == nextAmount.roundToDouble()
          ? nextAmount.toInt().toString()
          : nextAmount.toStringAsFixed(1);
      groceryNames[key] = '$shown|${ingredient.unit}|${ingredient.name}';
      groceryChecks.putIfAbsent(key, () => false);
    }
  }

  void toggleGrocery(String key) {
    groceryChecks[key] = !(groceryChecks[key] ?? false);
  }
}
