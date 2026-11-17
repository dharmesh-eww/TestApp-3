import 'measurement_units.dart';

enum FoodType { vegetarian, vegan, eggetarian, nonVegetarian, pescatarian }
enum RecipeDifficulty { easy, medium, hard }
enum IngredientAmountType { quantity, toTaste, asNeeded }

class RecipeCategory {
  const RecipeCategory({required this.id, required this.name, this.description = ''});

  factory RecipeCategory.fromJson(Map<String, dynamic> json) => RecipeCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
      );

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'description': description};
  final String id;
  final String name;
  final String description;
}

class Recipe {
  const Recipe({
    required this.id, required this.title, required this.subtitle,
    required this.image, required this.minutes, required this.difficulty,
    required this.category, required this.calories, required this.servings,
    required this.ingredients, required this.steps,
    this.slug = '', this.categoryIds = const [], this.cuisineIds = const [],
    this.foodType = FoodType.vegetarian, this.dietaryTags = const [],
    this.prepMinutes = 0, this.cookMinutes = 0, this.equipment = const [],
    this.tags = const [], this.isPublished = true, this.imageAttribution,
    this.allergensVerified = false, this.verifiedAllergens = const [],
    this.proteinGrams = 0, this.carbsGrams = 0, this.fatGrams = 0,
    this.fiberGrams, this.vitamins = const {}, this.healthBenefits = const [],
    this.seasons = const [], this.stepDetails = const [],
  });

  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String image;
  final int minutes;
  final int prepMinutes;
  final int cookMinutes;
  final String difficulty;
  final String category;
  final List<String> categoryIds;
  final List<String> cuisineIds;
  final FoodType foodType;
  final List<String> dietaryTags;
  final int calories;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String> equipment;
  final List<String> tags;
  final bool isPublished;
  final String? imageAttribution;
  final bool allergensVerified;
  final List<String> verifiedAllergens;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double? fiberGrams;
  final Map<String, double> vitamins;
  final List<String> healthBenefits;
  final List<String> seasons;
  final List<RecipeStep> stepDetails;

  bool get hasNutritionData => calories > 0 || proteinGrams > 0 || carbsGrams > 0 || fatGrams > 0 || (fiberGrams ?? 0) > 0 || vitamins.isNotEmpty;

  factory Recipe.fromJson(Map<String, dynamic> json, {String localeCode = 'en'}) {
    final prep = _asInt(json['prep_minutes'] ?? json['preparation_time_minutes'] ?? json['preparation_time']);
    final cook = _asInt(json['cook_minutes'] ?? json['cooking_time_minutes'] ?? json['cooking_time']);
    final legacyMinutes = _asInt(json['minutes'], prep + cook);
    final categoryIds = _stringList(json['category_ids']);
    final nutrition = json['nutrition'];
    final nutritionMap = nutrition is Map ? nutrition : const <String, dynamic>{};
    final allergens = json['allergens'];
    final allergenMap = allergens is Map ? allergens : const <String, dynamic>{};
    final localized = json['translations'] ?? json['localized'];
    final ingredients = (json['ingredients'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Ingredient.fromJson(Map<String, dynamic>.from(item), localeCode: localeCode))
        .toList();
    final rawSteps = json['instructions'] as List? ?? json['steps'] as List? ?? const [];
    final stepDetails = <RecipeStep>[];
    for (var index = 0; index < rawSteps.length; index++) {
      final item = rawSteps[index];
      if (item is String) {
        if (item.trim().isNotEmpty) {
          stepDetails.add(RecipeStep(step: index + 1, text: item));
        }
      } else if (item is Map) {
        final localizedInstruction = item['localized_instruction'];
        final text = localizedInstruction is Map
            ? (localizedInstruction[localeCode] ?? localizedInstruction['en'] ??
                item['text'] ?? item['instruction'] ?? '').toString()
            : (item['text'] ?? item['instruction'] ?? '').toString();
        if (text.trim().isNotEmpty) {
          stepDetails.add(RecipeStep(
            step: _asInt(item['step'], index + 1),
            text: text,
            durationMinutes: item['duration_minutes'] == null ? null : _asInt(item['duration_minutes']),
            image: item['image'] as String?,
          ));
        }
      }
    }
    final steps = stepDetails.map((step) => step.text).toList();

    return Recipe(
      id: (json['id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      title: _localizedField(json['title'], localized, 'title', localeCode),
      subtitle: _localizedField(json['description'] ?? json['subtitle'], localized, 'description', localeCode),
      image: (json['image'] ?? json['thumbnail'] ?? '').toString(),
      minutes: prep + cook == 0 ? legacyMinutes : prep + cook,
      prepMinutes: prep,
      cookMinutes: cook,
      difficulty: _titleCase((json['difficulty'] ?? 'easy').toString()),
      category: (json['category'] ?? (categoryIds.isEmpty ? 'Other' : categoryIds.first)).toString(),
      categoryIds: categoryIds,
      cuisineIds: _stringList(json['cuisine_ids'] ?? (json['cuisine_id'] == null ? null : [json['cuisine_id']])),
      foodType: _foodTypeFromJson(json['food_type']),
      dietaryTags: _stringList(json['dietary_tags']),
      calories: _asInt(json['calories_kcal'] ?? json['calories'] ?? nutritionMap['calories_kcal']),
      servings: (json['servings'] as num?)?.toInt() ?? 2,
      ingredients: ingredients,
      steps: steps,
      equipment: _stringList(json['equipment']),
      tags: _stringList(json['tags']),
      isPublished: json['is_published'] as bool? ?? true,
      imageAttribution: json['image_attribution'] as String?,
      allergensVerified: allergenMap['verified'] as bool? ?? false,
      verifiedAllergens: _stringList(allergenMap['items']),
      proteinGrams: _asDouble(nutritionMap['protein_g'] ?? json['protein_g']),
      carbsGrams: _asDouble(nutritionMap['carbs_g'] ?? json['carbs_g']),
      fatGrams: _asDouble(nutritionMap['fat_g'] ?? json['fat_g']),
      fiberGrams: _optionalDouble(nutritionMap['fiber_g'] ?? nutritionMap['fibre_g'] ?? json['fiber_g'] ?? json['fibre_g']),
      vitamins: _numericMap(nutritionMap['vitamins'] ?? json['vitamins']),
      healthBenefits: _stringList(json['health_benefits'] ?? json['benefits']),
      seasons: _stringList(json['seasons'] ?? json['seasonal_suitability'] ?? json['season_tags']).map((value) => value.toLowerCase()).toList(),
      stepDetails: stepDetails,
    );
  }

  int get totalMinutes =>
      prepMinutes + cookMinutes == 0 ? minutes : prepMinutes + cookMinutes;

  List<RecipeStep> get instructions => stepDetails.isNotEmpty ? stepDetails : [
        for (var i = 0; i < steps.length; i++) RecipeStep(step: i + 1, text: steps[i]),
      ];

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return <String>[
      title, subtitle, category, ...categoryIds, ...cuisineIds,
      ...dietaryTags, ...tags, ...ingredients.map((item) => item.name),
    ].any((value) => value.toLowerCase().contains(normalized));
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'slug': slug,
        'title': title,
        'description': subtitle,
        'image': image,
        'thumbnail': image,
        'category': category,
        'category_ids': categoryIds.isEmpty ? [category.toLowerCase()] : categoryIds,
        'cuisine_ids': cuisineIds,
        'food_type': foodType.name.replaceAll('nonVegetarian', 'non_vegetarian'),
        'dietary_tags': dietaryTags,
        'difficulty': difficulty.toLowerCase(),
        'prep_minutes': prepMinutes,
        'cook_minutes': cookMinutes == 0 && prepMinutes == 0 ? minutes : cookMinutes,
        'servings': servings,
        'ingredients': ingredients.map((item) => item.toJson()).toList(),
        'equipment': equipment,
        'instructions': instructions.map((step) => step.toJson()).toList(),
        'tags': tags,
        'image_attribution': imageAttribution,
        'nutrition': {'calories_kcal': calories, 'protein_g': proteinGrams, 'carbs_g': carbsGrams, 'fat_g': fatGrams, 'serving_basis': 'per_serving', 'is_estimate': true},
        'allergens': {'verified': allergensVerified, 'items': verifiedAllergens},
        'is_published': isPublished,
      };
}

class Ingredient {
  const Ingredient(this.name, this.amount, this.unit, {
    this.id = '', this.amountType = IngredientAmountType.quantity,
    this.isOptional = false, this.group = 'Ingredients', this.preparationNote,
  });

  final String id;
  final String name;
  final double? amount;
  final String unit;
  final IngredientAmountType amountType;
  final bool isOptional;
  final String group;
  final String? preparationNote;

  factory Ingredient.fromJson(Map<String, dynamic> json, {String localeCode = 'en'}) {
    final quantity = json['quantity'];
    final quantityMap = quantity is Map ? quantity : const <String, dynamic>{};
    final rawAmount = quantityMap['amount'] ?? json['amount'];
    final rawQualifier = (quantityMap['qualifier'] ?? json['amount_type'] ?? 'quantity').toString();
    final amountType = switch (rawQualifier.toLowerCase()) {
      'to_taste' || 'totaste' => IngredientAmountType.toTaste,
      'as_needed' || 'asneeded' => IngredientAmountType.asNeeded,
      _ => IngredientAmountType.quantity,
    };
    return Ingredient(
      _localizedField(json['display_name'] ?? json['name'] ?? json['ingredient_id'] ?? '',
        json['translations'] ?? json['localized'], 'name', localeCode),
      rawAmount is num ? rawAmount.toDouble() : double.tryParse('$rawAmount'),
      (quantityMap['unit'] ?? json['unit_id'] ?? json['unit'] ?? '').toString(),
      id: (json['ingredient_id'] ?? json['id'] ?? '').toString(),
      amountType: amountType,
      isOptional: json['is_optional'] as bool? ?? false,
      group: (json['group'] ?? 'Ingredients').toString(),
      preparationNote: json['preparation_note'] as String?,
    );
  }

  String display(int servings, int baseServings, {String measurementSystem = 'metric'}) {
    if (amount == null || amountType != IngredientAmountType.quantity) {
      return amountType == IngredientAmountType.toTaste ? 'to taste' : 'as needed';
    }
    final value = amount! * servings / baseServings;
    final shown = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    final converted = MeasurementUnits.convert(value, unit, measurementSystem);
    if (converted == null || converted.unit.toLowerCase() == unit.toLowerCase()) {
      return '$shown $unit';
    }
    return '≈ ${MeasurementUnits.format(converted.amount)} ${converted.unit}';
  }

  Map<String, Object?> toJson() => {
        'ingredient_id': id.isEmpty ? _slugify(name) : id,
        'display_name': name,
        'quantity': amount == null
            ? {'qualifier': amountType == IngredientAmountType.toTaste ? 'to_taste' : 'as_needed'}
            : {'amount': amount, 'unit': unit},
        'amount_type': amountType == IngredientAmountType.toTaste
            ? 'to_taste'
            : amountType == IngredientAmountType.asNeeded ? 'as_needed' : 'quantity',
        'is_optional': isOptional,
        'group': group,
        'preparation_note': preparationNote,
      };
}

class RecipeStep {
  const RecipeStep({required this.step, required this.text, this.durationMinutes, this.image});

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
        step: _asInt(json['step'], 1),
        text: (json['text'] ?? json['instruction'] ?? '').toString(),
        durationMinutes: json['duration_minutes'] == null ? null : _asInt(json['duration_minutes']),
        image: json['image'] as String?,
      );
  final int step;
  final String text;
  final int? durationMinutes;
  final String? image;

  Map<String, Object?> toJson() => {
        'step': step, 'text': text,
        'duration_minutes': durationMinutes, 'image': image,
      };
}

String _slugify(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');

int _asInt(dynamic value, [int fallback = 0]) =>
    value is num ? value.round() : int.tryParse('$value') ?? fallback;

double _asDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
double? _optionalDouble(dynamic value) => value == null ? null : (value is num ? value.toDouble() : double.tryParse('$value'));
Map<String, double> _numericMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map((key, amount) => MapEntry(key.toString(), _asDouble(amount)))..removeWhere((key, amount) => amount <= 0);
}

List<String> _stringList(dynamic value) =>
    value is List ? value.map((item) => item.toString()).toList() : <String>[];

FoodType _foodTypeFromJson(dynamic value) {
  switch ((value ?? 'vegetarian').toString().toLowerCase()) {
    case 'vegan':
      return FoodType.vegan;
    case 'eggetarian':
      return FoodType.eggetarian;
    case 'non_vegetarian':
    case 'nonvegetarian':
      return FoodType.nonVegetarian;
    case 'pescatarian':
      return FoodType.pescatarian;
    default:
      return FoodType.vegetarian;
  }
}

String _localizedField(dynamic value, dynamic translations, String key, String localeCode) {
  String? localizedFrom(dynamic source) {
    if (source is! Map) return null;

    final localeValue = source[localeCode];
    if (localeValue is String && localeValue.trim().isNotEmpty) return localeValue;
    if (localeValue is Map && localeValue[key] is String) {
      final translated = localeValue[key] as String;
      if (translated.trim().isNotEmpty) return translated;
    }

    final englishValue = source['en'];
    if (englishValue is String && englishValue.trim().isNotEmpty) return englishValue;
    if (englishValue is Map && englishValue[key] is String) {
      final translated = englishValue[key] as String;
      if (translated.trim().isNotEmpty) return translated;
    }
    if (englishValue is Map && englishValue['localized_$key'] is String) {
      final translated = englishValue['localized_$key'] as String;
      if (translated.trim().isNotEmpty) return translated;
    }
    return null;
  }

  return localizedFrom(translations) ??
      localizedFrom(value) ??
      (value is String ? value : '');
}

String _titleCase(String value) => value.isEmpty
    ? value
    : '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
