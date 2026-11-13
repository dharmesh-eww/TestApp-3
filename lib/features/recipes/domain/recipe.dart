enum FoodType { vegetarian, vegan, eggetarian, nonVegetarian, pescatarian }
enum RecipeDifficulty { easy, medium, hard }
enum IngredientAmountType { quantity, toTaste, asNeeded }

class RecipeCategory {
  const RecipeCategory({required this.id, required this.name, this.description = ''});
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

  int get totalMinutes =>
      prepMinutes + cookMinutes == 0 ? minutes : prepMinutes + cookMinutes;

  List<RecipeStep> get instructions => [
        for (var i = 0; i < steps.length; i++)
          RecipeStep(step: i + 1, text: steps[i]),
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
        'nutrition': null,
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

  String display(int servings, int baseServings) {
    if (amount == null || amountType != IngredientAmountType.quantity) {
      return amountType == IngredientAmountType.toTaste ? 'to taste' : 'as needed';
    }
    final value = amount! * servings / baseServings;
    final shown = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$shown $unit';
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
