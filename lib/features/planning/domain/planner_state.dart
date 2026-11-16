import '../../recipes/domain/recipe.dart';
import '../../recipes/domain/measurement_units.dart';
import 'meal_plan.dart';

class PlannerState {
  PlannerState();

  final Set<String> favorites = {};
  final Map<String, Map<MealSlot, PlannedMeal>> mealPlan = {};
  final Map<String, bool> groceryChecks = {};
  final Map<String, PantryItem> pantry = {};
  final Map<String, GroceryEdit> groceryEdits = {};
  final Map<String, Set<String>> collections = {};
  final Map<String, String> collectionNames = {};
  final List<Map<String, String>> cookingHistory = [];
  final List<Map<String, String>> recentlyViewed = [];
  final Set<String> preferredDietaryTags = {};
  final Set<String> preferredCuisines = {};
  String measurementSystem = 'metric';
  int weekStartsOn = 1;
  String localeCode = 'en';
  final Map<String, double> _manualAmounts = {};
  final Map<String, String> _manualNames = {};
  final Map<String, GroceryEdit> customGroceryItems = {};
  final Map<String, Set<String>> groceryLists = {};
  final Map<String, String> groceryListNames = {};
  final Map<String, DateTime?> pantryExpiryDates = {};
  bool onboardingComplete = false;
  bool reduceMotion = false;
  String themePreference = 'system';

  Map<String, Object?> toJson() => {
    'schema_version': 4,
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
    'custom_grocery_items': {
      for (final entry in customGroceryItems.entries)
        entry.key: {'name': entry.value.name, 'amount': entry.value.amount},
    },
    'grocery_lists': {for (final entry in groceryLists.entries) entry.key: entry.value.toList()..sort()},
    'grocery_list_names': groceryListNames,
    'pantry_expiry_dates': {for (final entry in pantryExpiryDates.entries) entry.key: entry.value?.toIso8601String()},
    'collections': {
      for (final entry in collections.entries) entry.key: entry.value.toList()..sort(),
    },
    'collection_names': collectionNames,
    'cooking_history': cookingHistory,
    'recently_viewed': recentlyViewed,
    'preferences': {
      'dietary_tags': preferredDietaryTags.toList()..sort(),
      'cuisines': preferredCuisines.toList()..sort(),
      'measurement_system': measurementSystem,
      'week_starts_on': weekStartsOn,
      'locale_code': localeCode,
      'theme_preference': themePreference,
      'reduce_motion': reduceMotion,
      'onboarding_complete': onboardingComplete,
    },
  };

  factory PlannerState.fromJson(Map<String, dynamic> json) {
    final state = PlannerState();
    state.restoreFromJson(json);
    return state;
  }

  /// Reads v1-v4 snapshots. The next save always writes v4.
  void restoreFromJson(Map<String, dynamic> json) {
    favorites.clear();
    mealPlan.clear();
    groceryChecks.clear();
    pantry.clear();
    groceryEdits.clear();
    _manualAmounts.clear();
    _manualNames.clear();
    customGroceryItems.clear();
    groceryLists.clear();
    groceryListNames.clear();
    pantryExpiryDates.clear();
    onboardingComplete = false;
    reduceMotion = false;
    themePreference = 'system';
    collections.clear();
    collectionNames.clear();
    cookingHistory.clear();
    recentlyViewed.clear();
    preferredDietaryTags.clear();
    preferredCuisines.clear();
    measurementSystem = 'metric';
    weekStartsOn = 1;
    localeCode = 'en';
    final version = json['schema_version'];
    if (version != 1 && version != 2 && version != 3 && version != 4) return;

    final rawFavorites = json['favorites'];
    if (rawFavorites is List) {
      favorites.addAll(rawFavorites.whereType<String>().where((id) => id.isNotEmpty));
    }
    final rawMeals = json['meals'];
    if (rawMeals is List) {
      for (final raw in rawMeals.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        final day = map['day'], recipeId = map['recipe_id'], slotName = map['slot'];
        if (day is! String || day.isEmpty || recipeId is! String || recipeId.isEmpty || slotName is! String) continue;
        MealSlot? slot;
        for (final candidate in MealSlot.values) {
          if (candidate.name == slotName) slot = candidate;
        }
        final servings = map['servings'];
        if (slot == null || servings is! num || servings < 1) continue;
        assignMeal(day: day, slot: slot, recipeId: recipeId, servings: servings.toInt());
      }
    }
    final rawChecks = json['grocery_checks'];
    if (rawChecks is Map) {
      for (final entry in rawChecks.entries) {
        if (entry.key is String && entry.value is bool) {
          groceryChecks[entry.key as String] = entry.value as bool;
        }
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
          final name = (value['name'] as String).trim();
          final amount = (value['amount'] as num).toDouble();
          if (name.isNotEmpty && amount >= 0) {
            groceryEdits[entry.key as String] = GroceryEdit(name: name, amount: amount);
          }
        }
      }
    }
    _restoreStringDoubleMap(json['manual_amounts'], _manualAmounts);
    _restoreStringStringMap(json['manual_names'], _manualNames);
    final rawCustomGroceries = json['custom_grocery_items'];
    if (rawCustomGroceries is Map) {
      for (final entry in rawCustomGroceries.entries) {
        if (entry.key is! String || entry.value is! Map) continue;
        final item = Map<String, dynamic>.from(entry.value as Map);
        if (item['name'] is String && item['amount'] is num && (item['amount'] as num) >= 0) {
          customGroceryItems[entry.key as String] = GroceryEdit(
            name: (item['name'] as String).trim(), amount: (item['amount'] as num).toDouble());
        }
      }
    }

    final rawLists = json['grocery_lists'];
    if (rawLists is Map) {
      for (final entry in rawLists.entries) {
        if (entry.key is String && entry.value is List) groceryLists[entry.key as String] = entry.value.whereType<String>().toSet();
      }
    }
    final rawListNames = json['grocery_list_names'];
    if (rawListNames is Map) {
      for (final entry in rawListNames.entries) {
        if (entry.key is String && entry.value is String) groceryListNames[entry.key as String] = entry.value as String;
      }
    }
    final rawExpiry = json['pantry_expiry_dates'];
    if (rawExpiry is Map) {
      for (final entry in rawExpiry.entries) {
        if (entry.key is String && entry.value is String) pantryExpiryDates[entry.key as String] = DateTime.tryParse(entry.value as String);
      }
    }
    final rawCollections = json['collections'];
    if (rawCollections is Map) {
      for (final entry in rawCollections.entries) {
        if (entry.key is String && entry.value is List) {
          collections[entry.key as String] = entry.value.whereType<String>().toSet();
        }
      }
    }
    final rawNames = json['collection_names'];
    if (rawNames is Map) {
      for (final entry in rawNames.entries) {
        if (entry.key is String && entry.value is String) {
          collectionNames[entry.key as String] = entry.value as String;
        }
      }
    }
    final rawHistory = json['cooking_history'];
    if (rawHistory is List) {
      for (final entry in rawHistory.whereType<Map>()) {
        final item = Map<String, dynamic>.from(entry);
        final id = item['recipe_id'], title = item['title'], completedAt = item['completed_at'];
        if (id is String && title is String && completedAt is String) {
          cookingHistory.add({
            'recipe_id': id,
            'title': title,
            'completed_at': completedAt,
          });
        }
      }
      if (cookingHistory.length > 100) {
        cookingHistory.removeRange(100, cookingHistory.length);
      }
    }
    final rawRecent = json['recently_viewed'];
    if (rawRecent is List) {
      for (final entry in rawRecent.whereType<Map>()) {
        final item = Map<String, dynamic>.from(entry);
        final id = item['recipe_id'], title = item['title'], viewedAt = item['viewed_at'];
        if (id is String && title is String && viewedAt is String) {
          recentlyViewed.add({'recipe_id': id, 'title': title, 'viewed_at': viewedAt});
        }
      }
      if (recentlyViewed.length > 30) recentlyViewed.removeRange(30, recentlyViewed.length);
    }
    final preferences = json['preferences'];
    if (preferences is Map) {
      final tags = preferences['dietary_tags'];
      if (tags is List) preferredDietaryTags.addAll(tags.whereType<String>());
      final cuisines = preferences['cuisines'];
      if (cuisines is List) preferredCuisines.addAll(cuisines.whereType<String>());
      final system = preferences['measurement_system'];
      if (system == 'metric' || system == 'us') measurementSystem = system as String;
      final week = preferences['week_starts_on'];
      if (week == 1 || week == 7) weekStartsOn = week as int;
      final locale = preferences['locale_code'];
      if (locale == 'en' || locale == 'ar') localeCode = locale as String;
      final theme = preferences['theme_preference'];
      if (theme == 'system' || theme == 'light' || theme == 'dark') themePreference = theme as String;
      reduceMotion = preferences['reduce_motion'] == true;
      onboardingComplete = preferences['onboarding_complete'] == true;
    }
  }

  void _restoreStringDoubleMap(Object? source, Map<String, double> target) {
    if (source is! Map) return;
    for (final entry in source.entries) {
      if (entry.key is String && entry.value is num && (entry.value as num) >= 0) {
        target[entry.key as String] = (entry.value as num).toDouble();
      }
    }
  }

  void _restoreStringStringMap(Object? source, Map<String, String> target) {
    if (source is! Map) return;
    for (final entry in source.entries) {
      if (entry.key is String && entry.value is String) target[entry.key as String] = entry.value as String;
    }
  }

  void recordViewed(Recipe recipe) {
    recentlyViewed.removeWhere((item) => item['recipe_id'] == recipe.id);
    recentlyViewed.insert(0, {
      'recipe_id': recipe.id,
      'title': recipe.title,
      'viewed_at': DateTime.now().toUtc().toIso8601String(),
    });
    if (recentlyViewed.length > 30) recentlyViewed.removeRange(30, recentlyViewed.length);
  }

  void clearPersonalData() {
    favorites.clear();
    mealPlan.clear();
    groceryChecks.clear();
    pantry.clear();
    groceryEdits.clear();
    _manualAmounts.clear();
    _manualNames.clear();
    customGroceryItems.clear();
    groceryLists.clear();
    groceryListNames.clear();
    pantryExpiryDates.clear();
    collections.clear();
    collectionNames.clear();
    cookingHistory.clear();
    recentlyViewed.clear();
    preferredDietaryTags.clear();
    preferredCuisines.clear();
    measurementSystem = 'metric';
    weekStartsOn = 1;
    localeCode = 'en';
    themePreference = 'system';
    reduceMotion = false;
    onboardingComplete = false;
  }

  bool isFavorite(String id) => favorites.contains(id);
  void toggleFavorite(String id) {
    if (!favorites.add(id)) favorites.remove(id);
  }

  String createCollection(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '';
    final id = 'collection-${DateTime.now().microsecondsSinceEpoch}';
    collections[id] = <String>{};
    collectionNames[id] = clean;
    return id;
  }

  void renameCollection(String id, String name) {
    final clean = name.trim();
    if (collections.containsKey(id) && clean.isNotEmpty) collectionNames[id] = clean;
  }

  void deleteCollection(String id) {
    collections.remove(id);
    collectionNames.remove(id);
  }

  void toggleRecipeInCollection(String collectionId, String recipeId) {
    final recipes = collections[collectionId];
    if (recipes == null || recipeId.isEmpty) return;
    if (!recipes.add(recipeId)) recipes.remove(recipeId);
  }

  void recordCooked(Recipe recipe) {
    cookingHistory.insert(0, {
      'recipe_id': recipe.id,
      'title': recipe.title,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    });
    if (cookingHistory.length > 100) cookingHistory.removeRange(100, cookingHistory.length);
  }

  void assignMeal({required String day, required MealSlot slot, required String recipeId, required int servings}) {
    mealPlan.putIfAbsent(day, () => <MealSlot, PlannedMeal>{})[slot] =
        PlannedMeal(day: day, slot: slot, recipeId: recipeId, servings: servings < 1 ? 1 : servings);
  }

  bool moveMeal({required String fromDay, required MealSlot fromSlot, required String toDay, required MealSlot toSlot}) {
    final source = mealPlan[fromDay]?[fromSlot];
    if (source == null || (fromDay == toDay && fromSlot == toSlot) || mealPlan[toDay]?.containsKey(toSlot) == true) return false;
    removeMeal(fromDay, fromSlot);
    assignMeal(day: toDay, slot: toSlot, recipeId: source.recipeId, servings: source.servings);
    return true;
  }

  void removeMeal(String day, MealSlot slot) {
    final slots = mealPlan[day];
    slots?.remove(slot);
    if (slots != null && slots.isEmpty) mealPlan.remove(day);
  }

  List<PlannedMeal> mealsFor(String day) =>
      List.unmodifiable(mealPlan[day]?.values ?? const <PlannedMeal>[]);
  int get plannedMealCount => mealPlan.values.fold(0, (sum, slots) => sum + slots.length);

  void addCustomGroceryItem({required String name, required double amount, required String unit}) {
    final cleanName = name.trim(), cleanUnit = unit.trim();
    if (cleanName.isEmpty || cleanUnit.isEmpty || amount < 0) return;
    final key = _key(cleanName, cleanUnit);
    final previous = customGroceryItems[key]?.amount ?? 0;
    customGroceryItems[key] = GroceryEdit(name: cleanName, amount: previous + amount);
  }

  void removeCustomGroceryItem(String key) {
    if (customGroceryItems.remove(key) != null) return;
    String? match;
    for (final entry in customGroceryItems.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 2) continue;
      final unit = parts.sublist(1).join('|');
      final converted = MeasurementUnits.convert(entry.value.amount, unit, 'metric');
      var normalizedUnit = converted?.unit.toLowerCase() ?? unit.toLowerCase();
      if (normalizedUnit == 'kg') normalizedUnit = 'g';
      if (normalizedUnit == 'l') normalizedUnit = 'ml';
      if (_key(entry.value.name, normalizedUnit) == key) {
        match = entry.key;
        break;
      }
    }
    if (match != null) customGroceryItems.remove(match);
  }

  String createGroceryList(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '';
    final id = 'grocery-${DateTime.now().microsecondsSinceEpoch}';
    groceryLists[id] = <String>{};
    groceryListNames[id] = clean;
    return id;
  }

  void renameGroceryList(String id, String name) { final clean = name.trim(); if (groceryLists.containsKey(id) && clean.isNotEmpty) groceryListNames[id] = clean; }
  void deleteGroceryList(String id) { groceryLists.remove(id); groceryListNames.remove(id); }
  void assignGroceryItem(String listId, String itemKey) { if (groceryLists.containsKey(listId) && itemKey.isNotEmpty) groceryLists[listId]!.add(itemKey); }
  void removeGroceryItemFromList(String listId, String itemKey) => groceryLists[listId]?.remove(itemKey);
  void setPantryExpiry(String pantryId, DateTime? expiry) { if (pantry.containsKey(pantryId)) pantryExpiryDates[pantryId] = expiry == null ? null : DateTime(expiry.year, expiry.month, expiry.day); }
  List<PantryItem> get expiringPantryItems {
    final now = DateTime.now(); final today = DateTime(now.year, now.month, now.day); final cutoff = today.add(const Duration(days: 7));
    return pantry.values.where((item) { final date = pantryExpiryDates[item.id]; return date != null && !date.isAfter(cutoff); }).toList(growable: false);
  }

  void clearCheckedCustomGroceryItems() {
    final keysToRemove = <String>[];
    for (final entry in customGroceryItems.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 2) continue;
      final unit = parts.sublist(1).join('|');
      final converted = MeasurementUnits.convert(entry.value.amount, unit, 'metric');
      var normalizedUnit = converted?.unit.toLowerCase() ?? unit.toLowerCase();
      if (normalizedUnit == 'kg') normalizedUnit = 'g';
      if (normalizedUnit == 'l') normalizedUnit = 'ml';
      final normalizedKey = _key(entry.value.name, normalizedUnit);
      if (groceryChecks[entry.key] == true || groceryChecks[normalizedKey] == true) {
        keysToRemove.add(entry.key);
        groceryChecks.remove(entry.key);
        groceryChecks.remove(normalizedKey);
        groceryEdits.remove(entry.key);
        groceryEdits.remove(normalizedKey);
      }
    }
    for (final key in keysToRemove) {
      customGroceryItems.remove(key);
    }
  }

  void addIngredients(Recipe recipe, int servings) {
    for (final item in recipe.ingredients) {
      if (item.amount == null || item.amountType != IngredientAmountType.quantity) continue;
      final key = _key(item.name, item.unit);
      final value = item.amount! * servings / _safeServings(recipe);
      _manualAmounts.update(key, (old) => old + value, ifAbsent: () => value);
      _manualNames[key] = item.name;
    }
  }

  /// Aggregates recipe, manually-added and custom grocery quantities by
  /// ingredient and compatible physical unit. Mass and volume are kept apart.
  List<GroceryItem> buildGroceryList(Iterable<Recipe> catalog) {
    final byId = {for (final recipe in catalog) recipe.id: recipe};
    final totals = <String, double>{};
    final names = <String, String>{};
    final baseUnits = <String, String>{};
    final qualifiers = <String>{};
    final ownedTotals = <String, double>{};
    final customKeys = <String>{};
    final sourceKeys = <String, Set<String>>{};

    ({double amount, String unit}) canonical(double amount, String unit) {
      final converted = MeasurementUnits.convert(amount, unit, 'metric');
      if (converted == null) {
        return (amount: amount, unit: unit.trim().toLowerCase());
      }
      final normalizedUnit = converted.unit.toLowerCase();
      if (normalizedUnit == 'kg') {
        return (amount: converted.amount * 1000, unit: 'g');
      }
      if (normalizedUnit == 'l') {
        return (amount: converted.amount * 1000, unit: 'ml');
      }
      return (amount: converted.amount, unit: normalizedUnit);
    }

    ({double amount, String unit}) display(double amount, String unit) {
      final converted = MeasurementUnits.convert(amount, unit, measurementSystem);
      return converted ?? (amount: amount, unit: unit);
    }

    void add(String name, double? amount, String unit, IngredientAmountType type) {
      final cleanName = name.trim();
      if (cleanName.isEmpty) return;
      if (amount == null || type != IngredientAmountType.quantity) {
        final key = _key(cleanName, unit);
        sourceKeys.putIfAbsent(key, () => <String>{}).add(key);
        names.putIfAbsent(key, () => cleanName);
        baseUnits.putIfAbsent(key, () => unit.trim());
        qualifiers.add(key);
        return;
      }
      final normalized = canonical(amount, unit);
      final key = _key(cleanName, normalized.unit);
      sourceKeys.putIfAbsent(key, () => <String>{}).add(_key(cleanName, unit));
      names.putIfAbsent(key, () => cleanName);
      baseUnits.putIfAbsent(key, () => normalized.unit);
      totals.update(key, (old) => old + normalized.amount,
          ifAbsent: () => normalized.amount);
    }

    for (final slots in mealPlan.values) {
      for (final meal in slots.values) {
        final recipe = byId[meal.recipeId];
        if (recipe == null) continue;
        for (final item in recipe.ingredients) {
          final amount = item.amount == null
              ? null
              : item.amount! * meal.servings / _safeServings(recipe);
          add(item.name, amount, item.unit, item.amountType);
        }
      }
    }

    for (final entry in _manualAmounts.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 2) continue;
      add(_manualNames[entry.key] ?? parts.first, entry.value,
          parts.sublist(1).join('|'), IngredientAmountType.quantity);
    }
    for (final entry in customGroceryItems.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 2) continue;
      final unit = parts.sublist(1).join('|');
      final normalized = canonical(entry.value.amount, unit);
      customKeys.add(_key(entry.value.name, normalized.unit));
      add(entry.value.name, entry.value.amount, unit,
          IngredientAmountType.quantity);
    }

    // Pantry quantities are normalized through the same mass/volume base so
    // 0.5 kg can offset 500 g, while 200 g never offsets 200 ml.
    for (final item in pantry.values) {
      final normalized = canonical(item.amount, item.unit);
      final key = _key(item.name, normalized.unit);
      sourceKeys.putIfAbsent(key, () => <String>{}).add(_key(item.name, item.unit));
      ownedTotals.update(key, (old) => old + normalized.amount,
          ifAbsent: () => normalized.amount);
    }

    // Migrate references created by older snapshots (for example flour|kg)
    // to the canonical key (flour|g), preserving checked state and list membership.
    for (final entry in sourceKeys.entries) {
      for (final alias in entry.value) {
        if (alias == entry.key) continue;
        if (groceryChecks.remove(alias) == true) groceryChecks[entry.key] = true;
        final oldEdit = groceryEdits.remove(alias);
        if (oldEdit != null) groceryEdits.putIfAbsent(entry.key, () => oldEdit);
        for (final list in groceryLists.values) {
          if (list.remove(alias)) list.add(entry.key);
        }
      }
    }

    final keys = {...totals.keys, ...qualifiers}.toList()..sort();
    return keys.map((key) {
      final baseUnit = baseUnits[key] ?? key.split('|').last;
      final originalAmount = totals[key] ?? 0;
      final aliases = sourceKeys[key] ?? const <String>{};
      GroceryEdit? edit = groceryEdits[key];
      String? editUnit;
      if (edit != null) {
        editUnit = display(originalAmount, baseUnit).unit;
      } else {
        for (final alias in aliases) {
          if (groceryEdits[alias] != null) {
            edit = groceryEdits[alias];
            editUnit = alias.split('|').last;
            break;
          }
        }
      }
      final edited = edit == null
          ? null
          : canonical(edit.amount, editUnit ?? display(originalAmount, baseUnit).unit);
      final neededBase = edited?.amount ?? originalAmount;
      final ownedBase = ownedTotals[key] ?? 0;
      final shownNeeded = display(neededBase, baseUnit);
      final shownOwned = display(ownedBase, baseUnit);
      final shownToBuy = display(
        (neededBase - ownedBase).clamp(0, double.infinity).toDouble(),
        baseUnit,
      );
      final quantified = totals.containsKey(key);
      return GroceryItem(
        key: key,
        name: edit?.name ?? names[key] ?? key,
        unit: shownNeeded.unit,
        amount: shownNeeded.amount,
        ownedAmount: shownOwned.amount,
        toBuyAmount: quantified ? shownToBuy.amount : 0,
        isQuantified: quantified,
        isChecked: groceryChecks[key] ?? aliases.any((alias) => groceryChecks[alias] == true),
        isCustom: customKeys.contains(key),
      );
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

  void removePantryItem(String id) { pantry.remove(id); pantryExpiryDates.remove(id); }
  static int _safeServings(Recipe recipe) => recipe.servings < 1 ? 1 : recipe.servings;
  static String _key(String name, String unit) => '${name.trim().toLowerCase()}|${unit.trim().toLowerCase()}';
}
