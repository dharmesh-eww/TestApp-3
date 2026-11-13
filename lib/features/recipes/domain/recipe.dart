class Recipe {
  const Recipe({
    required this.id, required this.title, required this.subtitle,
    required this.image, required this.minutes, required this.difficulty,
    required this.category, required this.calories, required this.servings,
    required this.ingredients, required this.steps,
  });

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final int minutes;
  final String difficulty;
  final String category;
  final int calories;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
}

class Ingredient {
  const Ingredient(this.name, this.amount, this.unit);
  final String name;
  final double amount;
  final String unit;

  String display(int servings, int baseServings) {
    final value = amount * servings / baseServings;
    final shown = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$shown $unit $name';
  }
}

const recipes = <Recipe>[
  Recipe(
    id: 'lemon-pasta',
    title: 'Lemon ricotta pasta',
    subtitle: 'Silky, bright and ready in twenty minutes',
    image: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=1000',
    minutes: 20, difficulty: 'Easy', category: 'Dinner',
    calories: 480, servings: 2,
    ingredients: [
      Ingredient('Pasta', 200, 'g'), Ingredient('Ricotta', 120, 'g'),
      Ingredient('Lemon', 1, 'whole'), Ingredient('Parmesan', 30, 'g'),
      Ingredient('Olive oil', 1, 'tbsp'), Ingredient('Fresh basil', 8, 'leaves'),
    ],
    steps: [
      'Bring a large pot of salted water to a boil. Cook the pasta until just al dente.',
      'Whisk ricotta, lemon zest, lemon juice, olive oil and a splash of pasta water until creamy.',
      'Add the drained pasta and toss gently. Loosen with more pasta water as needed.',
      'Finish with parmesan, torn basil, black pepper and a little olive oil.',
    ],
  ),
  Recipe(
    id: 'roasted-bowl',
    title: 'Roasted harvest bowl',
    subtitle: 'Crisp vegetables, grains and green tahini',
    image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1000',
    minutes: 35, difficulty: 'Easy', category: 'Lunch',
    calories: 420, servings: 2,
    ingredients: [
      Ingredient('Sweet potato', 1, 'large'), Ingredient('Chickpeas', 240, 'g'),
      Ingredient('Quinoa', 120, 'g'), Ingredient('Tahini', 2, 'tbsp'),
      Ingredient('Cucumber', 1, 'whole'), Ingredient('Parsley', 10, 'g'),
    ],
    steps: [
      'Heat the oven to 220°C. Dice the sweet potato and season with olive oil, salt and pepper.',
      'Roast the sweet potato and chickpeas for 25–30 minutes until golden.',
      'Cook quinoa according to the packet instructions and fluff with a fork.',
      'Stir tahini with lemon juice and water. Build bowls with quinoa, vegetables and sauce.',
    ],
  ),
  Recipe(
    id: 'berry-oats',
    title: 'Overnight berry oats',
    subtitle: 'A make-ahead breakfast with a little crunch',
    image: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=1000',
    minutes: 10, difficulty: 'Easy', category: 'Breakfast',
    calories: 310, servings: 1,
    ingredients: [
      Ingredient('Rolled oats', 50, 'g'), Ingredient('Milk', 120, 'ml'),
      Ingredient('Greek yogurt', 60, 'g'), Ingredient('Mixed berries', 80, 'g'),
      Ingredient('Maple syrup', 1, 'tsp'), Ingredient('Chia seeds', 1, 'tsp'),
    ],
    steps: [
      'Combine oats, milk, yogurt, chia seeds and maple syrup in a jar.',
      'Stir well, cover and refrigerate overnight or for at least four hours.',
      'Top with berries and a spoonful of yogurt before serving.',
    ],
  ),
  Recipe(
    id: 'tomato-soup',
    title: 'Slow Sunday tomato soup',
    subtitle: 'A comforting bowl with toasted sourdough',
    image: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=1000',
    minutes: 40, difficulty: 'Easy', category: 'Lunch',
    calories: 360, servings: 4,
    ingredients: [
      Ingredient('Ripe tomatoes', 800, 'g'), Ingredient('Onion', 1, 'whole'),
      Ingredient('Garlic', 3, 'cloves'), Ingredient('Vegetable stock', 500, 'ml'),
      Ingredient('Cream', 60, 'ml'), Ingredient('Sourdough', 4, 'slices'),
    ],
    steps: [
      'Soften the onion in olive oil, then add garlic and cook until fragrant.',
      'Add tomatoes and stock. Simmer gently for 25 minutes.',
      'Blend until smooth, stir in cream and season to taste.',
      'Serve hot with toasted sourdough and fresh herbs.',
    ],
  ),
];
