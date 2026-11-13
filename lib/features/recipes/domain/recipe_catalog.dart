import 'recipe.dart';

enum RecipeSort { recommended, quickest, title }

const recipeCategories = <RecipeCategory>[
  RecipeCategory(id: 'all', name: 'All recipes'),
  RecipeCategory(id: 'breakfast', name: 'Breakfast'),
  RecipeCategory(id: 'lunch', name: 'Lunch'),
  RecipeCategory(id: 'dinner', name: 'Dinner'),
  RecipeCategory(id: 'snacks', name: 'Snacks'),
];

/// Curated local catalog shared by home, discovery, planning and favourites.
const recipes = <Recipe>[
  Recipe(
    id: 'lemon-pasta', slug: 'lemon-ricotta-pasta',
    title: 'Lemon ricotta pasta',
    subtitle: 'Silky, bright and ready in twenty minutes',
    image: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=1000',
    minutes: 20, prepMinutes: 5, cookMinutes: 15,
    difficulty: 'Easy', category: 'Dinner', categoryIds: ['dinner'],
    cuisineIds: ['italian'], foodType: FoodType.vegetarian,
    calories: 480, servings: 2, tags: ['pasta', 'weeknight', 'quick'],
    ingredients: [
      Ingredient('Pasta', 200, 'g', id: 'pasta'),
      Ingredient('Ricotta', 120, 'g', id: 'ricotta'),
      Ingredient('Lemon', 1, 'whole', id: 'lemon'),
      Ingredient('Parmesan', 30, 'g', id: 'parmesan'),
      Ingredient('Olive oil', 1, 'tbsp', id: 'olive_oil'),
      Ingredient('Fresh basil', 8, 'leaves', id: 'basil'),
    ],
    steps: [
      'Bring a large pot of salted water to a boil. Cook the pasta until just al dente.',
      'Whisk ricotta, lemon zest, lemon juice, olive oil and a splash of pasta water until creamy.',
      'Add the drained pasta and toss gently. Loosen with more pasta water as needed.',
      'Finish with parmesan, torn basil, black pepper and a little olive oil.',
    ],
  ),
  Recipe(
    id: 'roasted-bowl', slug: 'roasted-harvest-bowl',
    title: 'Roasted harvest bowl',
    subtitle: 'Crisp vegetables, grains and green tahini',
    image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1000',
    minutes: 35, prepMinutes: 10, cookMinutes: 25,
    difficulty: 'Easy', category: 'Lunch', categoryIds: ['lunch'],
    cuisineIds: ['global'], foodType: FoodType.vegan,
    dietaryTags: ['plant_based'], calories: 420, servings: 2,
    tags: ['chickpeas', 'quinoa', 'vegetables'],
    ingredients: [
      Ingredient('Sweet potato', 1, 'large', id: 'sweet_potato'),
      Ingredient('Chickpeas', 240, 'g', id: 'chickpeas'),
      Ingredient('Quinoa', 120, 'g', id: 'quinoa'),
      Ingredient('Tahini', 2, 'tbsp', id: 'tahini'),
      Ingredient('Cucumber', 1, 'whole', id: 'cucumber'),
      Ingredient('Parsley', 10, 'g', id: 'parsley'),
    ],
    steps: [
      'Heat the oven to 220°C. Dice the sweet potato and season with olive oil, salt and pepper.',
      'Roast the sweet potato and chickpeas for 25–30 minutes until golden.',
      'Cook quinoa according to the packet instructions and fluff with a fork.',
      'Stir tahini with lemon juice and water. Build bowls with quinoa, vegetables and sauce.',
    ],
  ),
  Recipe(
    id: 'berry-oats', slug: 'overnight-berry-oats',
    title: 'Overnight berry oats',
    subtitle: 'A make-ahead breakfast with a little crunch',
    image: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=1000',
    minutes: 10, prepMinutes: 10,
    difficulty: 'Easy', category: 'Breakfast', categoryIds: ['breakfast'],
    cuisineIds: ['global'], foodType: FoodType.vegetarian,
    calories: 310, servings: 1, tags: ['oats', 'make ahead', 'berries'],
    ingredients: [
      Ingredient('Rolled oats', 50, 'g', id: 'oats'),
      Ingredient('Milk', 120, 'ml', id: 'milk'),
      Ingredient('Greek yogurt', 60, 'g', id: 'greek_yogurt'),
      Ingredient('Mixed berries', 80, 'g', id: 'berries'),
      Ingredient('Maple syrup', 1, 'tsp', id: 'maple_syrup'),
      Ingredient('Chia seeds', 1, 'tsp', id: 'chia'),
    ],
    steps: [
      'Combine oats, milk, yogurt, chia seeds and maple syrup in a jar.',
      'Stir well, cover and refrigerate overnight or for at least four hours.',
      'Top with berries and a spoonful of yogurt before serving.',
    ],
  ),
  Recipe(
    id: 'tomato-soup', slug: 'slow-sunday-tomato-soup',
    title: 'Slow Sunday tomato soup',
    subtitle: 'A comforting bowl with toasted sourdough',
    image: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=1000',
    minutes: 40, prepMinutes: 10, cookMinutes: 30,
    difficulty: 'Easy', category: 'Lunch', categoryIds: ['lunch'],
    cuisineIds: ['global'], foodType: FoodType.vegetarian,
    calories: 360, servings: 4, tags: ['tomato', 'comfort food'],
    ingredients: [
      Ingredient('Ripe tomatoes', 800, 'g', id: 'tomatoes'),
      Ingredient('Onion', 1, 'whole', id: 'onion'),
      Ingredient('Garlic', 3, 'cloves', id: 'garlic'),
      Ingredient('Vegetable stock', 500, 'ml', id: 'vegetable_stock'),
      Ingredient('Cream', 60, 'ml', id: 'cream'),
      Ingredient('Sourdough', 4, 'slices', id: 'sourdough'),
    ],
    steps: [
      'Soften the onion in olive oil, then add garlic and cook until fragrant.',
      'Add tomatoes and stock. Simmer gently for 25 minutes.',
      'Blend until smooth, stir in cream and season to taste.',
      'Serve hot with toasted sourdough and fresh herbs.',
    ],
  ),
  Recipe(
    id: 'gujarati-dhokla', slug: 'gujarati-dhokla',
    title: 'Gujarati dhokla',
    subtitle: 'Soft, savory steamed dhokla with a light tempering',
    image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=1000',
    minutes: 35, prepMinutes: 15, cookMinutes: 20,
    difficulty: 'Easy', category: 'Breakfast', categoryIds: ['breakfast', 'snacks'],
    cuisineIds: ['gujarati', 'indian'], foodType: FoodType.vegetarian,
    calories: 210, servings: 4, tags: ['steamed', 'besan', 'snack'],
    ingredients: [
      Ingredient('Gram flour', 1, 'cup', id: 'besan'),
      Ingredient('Curd', .5, 'cup', id: 'curd'),
      Ingredient('Ginger', 1, 'tsp', id: 'ginger'),
      Ingredient('Mustard seeds', 1, 'tsp', id: 'mustard_seeds'),
    ],
    steps: [
      'Mix gram flour, curd and water into a smooth batter.',
      'Fold in ginger and seasoning, then rest the batter briefly.',
      'Steam until cooked through and finish with a light tempering.',
    ],
  ),
];

class RecipeCatalog {
  const RecipeCatalog._();

  static List<Recipe> search(
    Iterable<Recipe> source, {
    String query = '',
    String categoryId = 'all',
    String cuisineId = 'all',
    FoodType? foodType,
    String difficulty = 'all',
    int? maxMinutes,
    Set<String> dietaryTags = const {},
    RecipeSort sort = RecipeSort.recommended,
  }) {
    final normalized = query.trim().toLowerCase();
    final result = source.where((recipe) {
      final matchesCategory = categoryId == 'all' ||
          recipe.categoryIds.contains(categoryId) ||
          recipe.category.toLowerCase() == categoryId.toLowerCase();
      final matchesCuisine = cuisineId == 'all' || recipe.cuisineIds.contains(cuisineId);
      final matchesFoodType = foodType == null || recipe.foodType == foodType;
      final matchesDifficulty = difficulty == 'all' || recipe.difficulty.toLowerCase() == difficulty.toLowerCase();
      final matchesTime = maxMinutes == null || recipe.totalMinutes <= maxMinutes;
      final matchesDiet = dietaryTags.isEmpty || dietaryTags.every(recipe.dietaryTags.contains);
      return recipe.isPublished && matchesCategory && matchesCuisine && matchesFoodType &&
          matchesDifficulty && matchesTime && matchesDiet && recipe.matches(normalized);
    }).toList();

    switch (sort) {
      case RecipeSort.recommended:
        break;
      case RecipeSort.quickest:
        result.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
        break;
      case RecipeSort.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return result;
  }
}
