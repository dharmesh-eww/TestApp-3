import 'core/theme/app_theme.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const RecipePlannerApp());
}

class RecipePlannerApp extends StatefulWidget {
  const RecipePlannerApp({super.key});

  @override
  State<RecipePlannerApp> createState() => _RecipePlannerAppState();
}

class _RecipePlannerAppState extends State<RecipePlannerApp> {
  final PlannerState state = PlannerState();

  @override
  Widget build(BuildContext context) {
    return PlannerScope(
      state: state,
      onChanged: () => setState(() {}),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gather — Recipe Planner',
        theme: AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}

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

class PlannerScope extends InheritedWidget {
  const PlannerScope({
    super.key,
    required this.state,
    required this.onChanged,
    required super.child,
  });

  final PlannerState state;
  final VoidCallback onChanged;

  static PlannerState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.state;
  }

  static void refresh(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.onChanged();
  }

  @override
  bool updateShouldNotify(covariant PlannerScope oldWidget) => true;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selected = 0;
  final pages = const [
    TodayScreen(), DiscoverScreen(), PlanScreen(), GroceryScreen(), KitchenScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppMotion.page,
          switchInCurve: AppMotion.enter,
          switchOutCurve: AppMotion.exit,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .018),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(selected),
            child: pages[selected],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (value) => setState(() => selected = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Recipes'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: 'Groceries'),
          NavigationDestination(icon: Icon(Icons.shelves), label: 'Kitchen'),
        ],
      ),
    );
  }
}

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = recipes[0];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MONDAY, AT YOUR PACE', style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            SizedBox(height: 7),
            Text('A little more joy\nin the kitchen.', style: TextStyle(fontFamily: 'Georgia', fontSize: 31, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
          ])),
          CircleAvatar(radius: 24, backgroundColor: const Color(0xFFE9E4D8), child: const Icon(Icons.spa_outlined, color: AppTheme.olive)),
        ]),
        const SizedBox(height: 24),
        _SectionHeading(title: 'Today’s inspiration', action: 'See all', onTap: () => _goTab(context, 1)),
        const SizedBox(height: 12),
        _FeaturedRecipe(recipe: featured),
        const SizedBox(height: 26),
        _SectionHeading(title: 'Made for your week', action: 'Open plan', onTap: () => _goTab(context, 2)),
        const SizedBox(height: 12),
        const _WeekStrip(),
        const SizedBox(height: 26),
        _SectionHeading(title: 'A few good ideas', action: 'Explore', onTap: () => _goTab(context, 1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length - 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(width: 174, child: _RecipeTile(recipe: recipes[index + 1])),
          ),
        ),
      ],
    );
  }
}

void _goTab(BuildContext context, int index) {
  final shell = context.findAncestorStateOfType<_AppShellState>();
  shell?.setState(() => shell.selected = index);
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String query = '';
  String category = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Breakfast', 'Lunch', 'Dinner'];
    final filtered = recipes.where((recipe) {
      final matchesQuery = recipe.title.toLowerCase().contains(query.toLowerCase()) ||
          recipe.subtitle.toLowerCase().contains(query.toLowerCase());
      return matchesQuery && (category == 'All' || recipe.category == category);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text('THE RECIPE SHELF', style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text('Find your next\nfavourite.', style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Search recipes or ingredients',
            prefixIcon: const Icon(Icons.search),
            filled: true, fillColor: AppTheme.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.line)),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: categories.map((item) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item), selected: category == item,
              onSelected: (_) => setState(() => category = item),
              selectedColor: AppTheme.terracotta.withOpacity(.16),
              side: BorderSide(color: category == item ? AppTheme.terracotta : AppTheme.line),
              labelStyle: TextStyle(color: category == item ? AppTheme.terracotta : AppTheme.muted, fontWeight: FontWeight.w600),
            ),
          )).toList()),
        ),
        const SizedBox(height: 18),
        Text('${filtered.length} recipes to try', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Padding(padding: EdgeInsets.all(30), child: Text('No recipes found. Try another search.'))
        else
          ...filtered.map((recipe) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecipeListTile(recipe: recipe),
          )),
      ],
    );
  }
}

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  static const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text('A WEEK THAT TASTES GOOD', style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text('Your meal\nplanner.', style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('A flexible plan. Change it whenever life does.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 22),
        ...days.map((day) {
          final ids = state.mealPlan[day] ?? [];
          final planned = recipes.where((recipe) => ids.contains(recipe.id)).toList();
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.card, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(day, style: Theme.of(context).textTheme.titleMedium)),
                TextButton.icon(
                  onPressed: () => _showPlanPicker(context, day),
                  icon: const Icon(Icons.add, size: 17), label: const Text('Add meal'),
                ),
              ]),
              if (planned.isEmpty)
                const Text('Nothing planned yet', style: TextStyle(color: AppTheme.muted, fontSize: 12))
              else
                ...planned.map((recipe) => Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Row(children: [
                    const Icon(Icons.restaurant, size: 16, color: AppTheme.olive),
                    const SizedBox(width: 8),
                    Expanded(child: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text('${recipe.minutes} min', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ]),
                )),
            ]),
          );
        }),
      ],
    );
  }

  void _showPlanPicker(BuildContext context, String day) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add a meal to $day', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            ...recipes.map((recipe) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(recipe.title),
              subtitle: Text('${recipe.minutes} min · ${recipe.category}'),
              trailing: const Icon(Icons.add_circle_outline, color: AppTheme.terracotta),
              onTap: () {
                PlannerScope.of(context).addToPlan(day, recipe.id);
                PlannerScope.refresh(context);
                Navigator.pop(context);
              },
            )),
          ]),
        ),
      ),
    );
  }
}

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final entries = state.groceryNames.entries.toList();
    final checked = entries.where((entry) => state.groceryChecks[entry.key] == true).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text('THE MARKET LIST', style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text('Good things\nto pick up.', style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(entries.isEmpty ? 'Add ingredients from any recipe.' : '$checked of ${entries.length} items picked up', style: const TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 20),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
            child: const Column(children: [
              Icon(Icons.shopping_basket_outlined, size: 36, color: AppTheme.olive),
              SizedBox(height: 10),
              Text('Your list is waiting', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
              SizedBox(height: 5),
              Text('Open a recipe and tap “Add ingredients” to start your shopping list.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)),
            ]),
          )
        else
          ...entries.map((entry) {
            final parts = entry.value.split('|');
            final isChecked = state.groceryChecks[entry.key] ?? false;
            return CheckboxListTile(
              value: isChecked,
              onChanged: (_) {
                state.toggleGrocery(entry.key);
                PlannerScope.refresh(context);
              },
              activeColor: AppTheme.olive,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(parts.length > 2 ? parts[2] : entry.key, style: TextStyle(decoration: isChecked ? TextDecoration.lineThrough : null, color: isChecked ? AppTheme.muted : AppTheme.ink)),
              subtitle: Text(parts.length > 1 ? '${parts[0]} ${parts[1]}' : parts.first),
            );
          }),
      ],
    );
  }
}

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final saved = recipes.where((recipe) => state.favorites.contains(recipe.id)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text('YOUR LITTLE COOKBOOK', style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text('Your kitchen,\nyour rhythm.', style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(children: [
          _StatCard(value: '${saved.length}', label: 'Saved recipes', icon: Icons.bookmark_outline),
          const SizedBox(width: 10),
          _StatCard(value: '${state.mealPlan.values.fold<int>(0, (sum, list) => sum + list.length)}', label: 'Meals planned', icon: Icons.calendar_month_outlined),
        ]),
        const SizedBox(height: 24),
        Text('Your saved recipes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (saved.isEmpty)
          const Text('Recipes you save will live here. Tap the bookmark on any recipe you love.', style: TextStyle(color: AppTheme.muted))
        else
          ...saved.map((recipe) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecipeListTile(recipe: recipe),
          )),
      ],
    );
  }
}

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int servings = 2;

  @override
  void initState() {
    super.initState();
    servings = widget.recipe.servings;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final state = PlannerScope.of(context);
    final favorite = state.isFavorite(recipe.id);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280, pinned: true, backgroundColor: AppTheme.paper,
          actions: [
            IconButton(
              onPressed: () {
                state.toggleFavorite(recipe.id);
                PlannerScope.refresh(context);
              },
              icon: Icon(favorite ? Icons.bookmark : Icons.bookmark_border, color: favorite ? AppTheme.terracotta : AppTheme.ink),
              style: IconButton.styleFrom(backgroundColor: AppTheme.card),
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(recipe.image, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE6DED1), child: const Icon(Icons.restaurant, size: 48))),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.category.toUpperCase(), style: const TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
            const SizedBox(height: 8),
            Text(recipe.title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(recipe.subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.muted)),
            const SizedBox(height: 18),
            Row(children: [
              _MetaPill(icon: Icons.schedule, text: '${recipe.minutes} min'),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.signal_cellular_alt, text: recipe.difficulty),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.local_fire_department_outlined, text: '${recipe.calories} kcal'),
            ]),
            const SizedBox(height: 26),
            Row(children: [
              Expanded(child: Text('Ingredients', style: Theme.of(context).textTheme.headlineMedium)),
              IconButton(onPressed: servings > 1 ? () => setState(() => servings--) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$servings servings', style: const TextStyle(fontWeight: FontWeight.w700)),
              IconButton(onPressed: () => setState(() => servings++), icon: const Icon(Icons.add_circle_outline)),
            ]),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                const Icon(Icons.circle, size: 7, color: AppTheme.olive),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: const TextStyle(color: AppTheme.ink))),
                Text(item.display(servings, recipe.servings), style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ]),
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {
                state.addIngredients(recipe, servings);
                PlannerScope.refresh(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredients added to your grocery list')));
              },
              icon: const Icon(Icons.add_shopping_cart), label: const Text('Add ingredients to grocery list'),
            )),
            const SizedBox(height: 28),
            Text('Let’s make it', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            ...List.generate(recipe.steps.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.terracotta.withOpacity(.13), child: Text('${index + 1}', style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(child: Text(recipe.steps[index], style: Theme.of(context).textTheme.bodyLarge)),
              ]),
            )),
          ]),
        )),
      ]),
    );
  }
}

class _FeaturedRecipe extends StatelessWidget {
  const _FeaturedRecipe({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Container(
        height: 300,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: const Color(0xFFE8DFD1)),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(recipe.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE8DFD1))),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC211A16)], stops: [0.35, 1]))),
          Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('EDITOR’S PICK', style: TextStyle(color: Color(0xFFFFD5B9), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            Row(children: [
              const Icon(Icons.schedule, color: Colors.white70, size: 15),
              const SizedBox(width: 5),
              Text('${recipe.minutes} min', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.circle, color: Color(0xFFB8C18F), size: 7),
              const SizedBox(width: 5),
              Text(recipe.difficulty, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(recipe.image, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE8DFD1), child: Icon(Icons.restaurant))),
        )),
        const SizedBox(height: 8),
        Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700)),
        Text('${recipe.minutes} min · ${recipe.category}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
      ]),
    );
  }
}

class _RecipeListTile extends StatelessWidget {
  const _RecipeListTile({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.card, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(
            recipe.image, width: 92, height: 88, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(width: 92, height: 88, child: ColoredBox(color: Color(0xFFE8DFD1), child: Icon(Icons.restaurant))),
          )),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.category.toUpperCase(), style: const TextStyle(color: AppTheme.terracotta, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(recipe.title, style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(recipe.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
            const SizedBox(height: 5),
            Text('${recipe.minutes} min · ${recipe.difficulty}', style: const TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700)),
          ])),
          const Icon(Icons.chevron_right, color: AppTheme.muted),
        ]),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
    TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(color: AppTheme.terracotta))),
  ]);
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
      child: Row(children: List.generate(7, (index) {
        final count = state.mealPlan[names[index]]?.length ?? 0;
        return Expanded(child: Column(children: [
          Text(days[index], style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          CircleAvatar(radius: 15, backgroundColor: count > 0 ? AppTheme.olive.withOpacity(.15) : AppTheme.paper,
            child: Text('$count', style: TextStyle(color: count > 0 ? AppTheme.olive : AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700))),
        ]));
      })),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppTheme.line)),
    child: Row(children: [Icon(icon, size: 14, color: AppTheme.olive), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w600))]),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppTheme.olive),
      const SizedBox(height: 12),
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
    ]),
  ));
}
