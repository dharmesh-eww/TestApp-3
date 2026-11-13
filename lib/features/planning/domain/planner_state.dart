import '../../recipes/domain/recipe.dart';
import 'meal_plan.dart';

class PlannerState {
  PlannerState();
  final Set<String> favorites = {};
  final Map<String, Map<MealSlot, PlannedMeal>> mealPlan = {};
  final Map<String, bool> groceryChecks = {};
  final Map<String, PantryItem> pantry = {};
  final Map<String, GroceryEdit> groceryEdits = {};
  final Map<String, double> _manualAmounts = {};
  final Map<String, String> _manualNames = {};

  /// Stable JSON snapshot used by the local persistence repository.
  Map<String, Object?> toJson() => {
    'schema_version': 1,
    'favorites': favorites.toList()..sort(),
    'meals': [
      for (final slots in mealPlan.values)
        for (final meal in slots.values)
          {'day': meal.day, 'slot': meal.slot.name, 'recipe_id': meal.recipeId, 'servings': meal.servings},
    ],
    'grocery_checks': groceryChecks,
    'pantry': [
      for (final item in pantry.values)
        {'id': item.id, 'name': item.name, 'amount': item.amount, 'unit': item.unit},
    ],
    'grocery_edits': {
      for (final entry in groceryEdits.entries)
        entry.key: {'name': entry.value.name, 'amount': entry.value.amount},
    },
    'manual_amounts': _manualAmounts,
    'manual_names': _manualNames,
  };

  factory PlannerState.fromJson(Map<String, dynamic> json) {
    final state = PlannerState();
    state.restoreFromJson(json);
    return state;
  }

  /// Replaces user-owned state from a validated local snapshot.
  void restoreFromJson(Map<String, dynamic> json) {
    favorites.clear(); mealPlan.clear(); groceryChecks.clear(); pantry.clear();
    groceryEdits.clear(); _manualAmounts.clear(); _manualNames.clear();
    if (json['schema_version'] != 1) return;
    final rawFavorites = json['favorites'];
    if (rawFavorites is List) favorites.addAll(rawFavorites.whereType<String>().where((id) => id.isNotEmpty));
    final rawMeals = json['meals'];
    if (rawMeals is List) {
      for (final raw in rawMeals.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        final day = map['day'], recipeId = map['recipe_id'], slotName = map['slot'];
        if (day is! String || day.isEmpty || recipeId is! String || recipeId.isEmpty || slotName is! String) continue;
        MealSlot? slot;
        for (final candidate in MealSlot.values) { if (candidate.name == slotName) slot = candidate; }
        final servings = map['servings'];
        if (slot == null || servings is! num || servings < 1) continue;
        assignMeal(day: day, slot: slot, recipeId: recipeId, servings: servings.toInt());
      }
    }
    final rawChecks = json['grocery_checks'];
    if (rawChecks is Map) {
      for (final entry in rawChecks.entries) {
        if (entry.key is String && entry.value is bool) groceryChecks[entry.key as String] = entry.value as bool;
      }
    }
    final rawPantry = json['pantry'];
    if (rawPantry is List) {
      for (final raw in rawPantry.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        final name = map['name'], unit = map['unit'], amount = map['amount'];
        if (name is String && unit is String && amount is num) {
          upsertPantryItem(name: name, unit: unit, amount: amount.toDouble());
        }
      }
    }
    final rawEdits = json['grocery_edits'];
    if (rawEdits is Map) {
      for (final entry in rawEdits.entries) {
        if (entry.key is! String || entry.value is! Map) continue;
        final value = Map<String, dynamic>.from(entry.value as Map);
        if (value['name'] is String && value['amount'] is num) {
          final name = (value['name'] as String).trim(), amount = (value['amount'] as num).toDouble();
          if (name.isNotEmpty && amount >= 0) groceryEdits[entry.key as String] = GroceryEdit(name: name, amount: amount);
        }
      }
    }
    _restoreStringDoubleMap(json['manual_amounts'], _manualAmounts);
    _restoreStringStringMap(json['manual_names'], _manualNames);
  }

  void _restoreStringDoubleMap(Object? source, Map<String, double> target) {
    if (source is! Map) return;
    for (final entry in source.entries) {
      if (entry.key is String && entry.value is num && (entry.value as num) >= 0) target[entry.key as String] = (entry.value as num).toDouble();
    }
  }

  void _restoreStringStringMap(Object? source, Map<String, String> target) {
    if (source is! Map) return;
    for (final entry in source.entries) {
      if (entry.key is String && entry.value is String) target[entry.key as String] = entry.value as String;
    }
  }

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
