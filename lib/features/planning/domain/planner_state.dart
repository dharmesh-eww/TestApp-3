import '../../recipes/domain/recipe.dart';
import 'meal_plan.dart';

class PlannerState {
  final Set<String> favorites = {};
  final Map<String, Map<MealSlot, PlannedMeal>> mealPlan = {};
  final Map<String, bool> groceryChecks = {};
  final Map<String, PantryItem> pantry = {};
  final Map<String, GroceryEdit> groceryEdits = {};
  final Map<String, double> _manualAmounts = {};
  final Map<String, String> _manualNames = {};

  bool isFavorite(String id) => favorites.contains(id);
  void toggleFavorite(String id) { if (!favorites.add(id)) favorites.remove(id); }

  void assignMeal({required String day, required MealSlot slot, required String recipeId, required int servings}) {
    mealPlan.putIfAbsent(day, () => <MealSlot, PlannedMeal>{})[slot] =
      PlannedMeal(day: day, slot: slot, recipeId: recipeId, servings: servings < 1 ? 1 : servings);
  }
  void removeMeal(String day, MealSlot slot) {
    final slots = mealPlan[day]; slots?.remove(slot);
    if (slots != null && slots.isEmpty) mealPlan.remove(day);
  }
  List<PlannedMeal> mealsFor(String day) => List.unmodifiable(mealPlan[day]?.values ?? const <PlannedMeal>[]);
  int get plannedMealCount => mealPlan.values.fold(0, (sum, slots) => sum + slots.length);

  void addIngredients(Recipe recipe, int servings) {
    for (final item in recipe.ingredients) {
      if (item.amount == null || item.amountType != IngredientAmountType.quantity) continue;
      final key = _key(item.name, item.unit);
      final value = item.amount! * servings / _safeServings(recipe);
      _manualAmounts.update(key, (old) => old + value, ifAbsent: () => value);
      _manualNames[key] = item.name;
    }
  }

  List<GroceryItem> buildGroceryList(Iterable<Recipe> catalog) {
    final byId = {for (final recipe in catalog) recipe.id: recipe};
    final totals = <String, double>{}, names = <String, String>{}, units = <String, String>{};
    final qualifiers = <String>{};
    void add(Ingredient item, int servings, int baseServings) {
      final key = _key(item.name, item.unit);
      names.putIfAbsent(key, () => item.name); units.putIfAbsent(key, () => item.unit);
      if (item.amount == null || item.amountType != IngredientAmountType.quantity) { qualifiers.add(key); return; }
      final value = item.amount! * servings / (baseServings < 1 ? 1 : baseServings);
      totals.update(key, (old) => old + value, ifAbsent: () => value);
    }
    for (final slots in mealPlan.values) {
      for (final meal in slots.values) {
        final recipe = byId[meal.recipeId]; if (recipe == null) continue;
        for (final item in recipe.ingredients) { add(item, meal.servings, recipe.servings); }
      }
    }
    for (final entry in _manualAmounts.entries) {
      totals.update(entry.key, (old) => old + entry.value, ifAbsent: () => entry.value);
      names.putIfAbsent(entry.key, () => _manualNames[entry.key] ?? entry.key);
      units.putIfAbsent(entry.key, () => entry.key.split('|').last);
    }
    final keys = {...totals.keys, ...qualifiers}.toList()..sort();
    return keys.map((key) {
      final originalAmount = totals[key] ?? 0, owned = pantry[key]?.amount ?? 0;
      final edit = groceryEdits[key];
      final needed = edit?.amount ?? originalAmount;
      final quantified = totals.containsKey(key);
      return GroceryItem(key: key, name: edit?.name ?? names[key] ?? key, unit: units[key] ?? '',
        amount: needed, ownedAmount: owned,
        toBuyAmount: quantified ? (needed - owned).clamp(0, double.infinity).toDouble() : 0,
        isQuantified: quantified, isChecked: groceryChecks[key] ?? false);
    }).toList();
  }

  void updateGroceryItem(String key, {required String name, required double amount}) {
    if (name.trim().isEmpty || amount < 0) return;
    groceryEdits[key] = GroceryEdit(name: name.trim(), amount: amount);
  }
  void toggleGrocery(String key) => groceryChecks[key] = !(groceryChecks[key] ?? false);
  void setGroceryChecked(String key, bool checked) => groceryChecks[key] = checked;

  void upsertPantryItem({required String name, required double amount, required String unit}) {
    final cleanName = name.trim(), cleanUnit = unit.trim();
    if (cleanName.isEmpty || cleanUnit.isEmpty || amount < 0) return;
    final key = _key(cleanName, cleanUnit);
    pantry[key] = PantryItem(id: key, name: cleanName, amount: amount, unit: cleanUnit);
  }
  void removePantryItem(String id) => pantry.remove(id);

  static int _safeServings(Recipe recipe) => recipe.servings < 1 ? 1 : recipe.servings;
  static String _key(String name, String unit) => '${name.trim().toLowerCase()}|${unit.trim().toLowerCase()}';
}
