import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/app_widgets.dart';
import 'package:testapp_3/app/app_tab_navigation.dart';
import 'package:testapp_3/app/gather_visuals.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  String? _ingredientFilter;

  @override
  Widget build(BuildContext context) {
    final catalog = RecipeCatalogScope.of(context);
    final planner = PlannerScope.of(context);
    final strings = appStrings(context);
    if (catalog.isEmpty) return const SizedBox.shrink();

    final favorites = catalog.where((recipe) => planner.favorites.contains(recipe.id)).toList();
    final viewedIds = planner.recentlyViewed.map((item) => item['recipe_id']).whereType<String>().toSet();
    final recentlyExplored = catalog.where((recipe) => viewedIds.contains(recipe.id)).toList();
    final quickMeals = catalog.where((recipe) => recipe.totalMinutes > 0 && recipe.totalMinutes <= 25).toList()
      ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    final popular = catalog.where((recipe) => planner.recipeRatings.containsKey(recipe.id)).toList()
      ..sort((a, b) => (planner.recipeRatings[b.id] ?? 0).compareTo(planner.recipeRatings[a.id] ?? 0));
    final topPicks = popular.isNotEmpty ? popular : catalog.where((recipe) => recipe.isPublished).take(8).toList();
    final veggiePicks = catalog.where((recipe) => recipe.foodType == FoodType.vegan || recipe.foodType == FoodType.vegetarian).take(8).toList();
    final featured = catalog.first;
    final ingredientNames = <String>[];
    for (final recipe in catalog) {
      for (final ingredient in recipe.ingredients) {
        final name = ingredient.name.trim();
        if (name.isNotEmpty && !ingredientNames.any((item) => item.toLowerCase() == name.toLowerCase())) {
          ingredientNames.add(name);
        }
      }
    }
    ingredientNames.sort();
    const quickFilterIngredients = ['Tomato', 'Potato', 'Chicken', 'Egg', 'Paneer', 'Spinach', 'Rice', 'Avocado'];
    final filterOptions = quickFilterIngredients.where((name) =>
      ingredientNames.any((item) => item.toLowerCase() == name.toLowerCase())).toList();
    final ingredientRecipes = _ingredientFilter == null ? <Recipe>[] : catalog.where((recipe) =>
      recipe.ingredients.any((ingredient) => ingredient.name.toLowerCase() == _ingredientFilter!.toLowerCase())).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(strings.label('MONDAY, AT YOUR PACE', 'أسبوعك على إيقاعك'), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 7),
            Text(strings.label('A little more joy\\nin the kitchen.', 'مزيد من البهجة\\nفي مطبخك.'), style: TextStyle(fontFamily: 'Georgia', fontSize: 31, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
          ])),
          GatherVisuals.foodMotion(size: 88),
        ]),
        const SizedBox(height: 24),
        SectionHeading(title: strings.label('Today’s inspiration', 'إلهام اليوم'), action: strings.label('See all', 'عرض الكل'), onTap: () => goToAppTab(context, 1)),
        const SizedBox(height: 12),
        FeaturedRecipe(recipe: featured),
        const SizedBox(height: 26),
        SectionHeading(title: strings.label('Made for your week', 'اختيارات لأسبوعك'), action: strings.label('Open plan', 'افتح الخطة'), onTap: () => goToAppTab(context, 2)),
        const SizedBox(height: 12),
        const WeekStrip(),
        const SizedBox(height: 26),
        if (favorites.isNotEmpty) ...[
          _RecipeShelf(title: strings.label('Your favourites', 'وصفاتك المفضلة'), recipes: favorites, action: strings.label('See all', 'عرض الكل'), onAction: () => goToAppTab(context, 1)),
          const SizedBox(height: 26),
        ],
        _RecipeShelf(title: strings.label('Popular right now', 'الأكثر رواجًا الآن'), subtitle: strings.label('Recipes people are loving', 'وصفات يحبها الجميع'), recipes: topPicks, action: strings.label('Explore', 'استكشف'), onAction: () => goToAppTab(context, 1)),
        const SizedBox(height: 26),
        if (recentlyExplored.isNotEmpty) ...[
          _RecipeShelf(title: strings.label('Recommended for you', 'موصى به لك'), subtitle: strings.label('Inspired by recipes you recently explored', 'مستوحى من الوصفات التي تصفحتها مؤخرًا'), recipes: recentlyExplored, action: strings.label('Explore', 'استكشف'), onAction: () => goToAppTab(context, 1)),
          const SizedBox(height: 26),
        ],
        _RecipeShelf(title: strings.label('Ready in 25 minutes', 'جاهزة خلال 25 دقيقة'), subtitle: strings.label('Good food, without the wait', 'وجبات شهية دون انتظار'), recipes: quickMeals, action: strings.label('See all', 'عرض الكل'), onAction: () => goToAppTab(context, 1)),
        const SizedBox(height: 26),
        _RecipeShelf(title: strings.label('Plant-powered favourites', 'اختيارات نباتية'), subtitle: strings.label('Fresh ideas packed with goodness', 'أفكار طازجة مليئة بالفائدة'), recipes: veggiePicks, action: strings.label('Explore', 'استكشف'), onAction: () => goToAppTab(context, 1)),
        const SizedBox(height: 26),
        _RecipeShelf(title: strings.label('A few good ideas', 'بعض الأفكار الجميلة'), recipes: catalog.skip(1).take(10).toList(), action: strings.label('Explore', 'استكشف'), onAction: () => goToAppTab(context, 1)),
        const SizedBox(height: 28),
        Text(strings.label('What’s in your kitchen?', 'ماذا يوجد في مطبخك؟'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Georgia', fontWeight: FontWeight.bold, color: AppTheme.ink)),
        const SizedBox(height: 5),
        Text(strings.label('Pick an ingredient to find recipes you can make.', 'اختر مكونًا للعثور على وصفات يمكنك إعدادها.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.separated(
            key: const Key('home-ingredient-filters'),
            scrollDirection: Axis.horizontal,
            itemCount: filterOptions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              if (index == 0) {
                final selected = _ingredientFilter == null;
                return ChoiceChip(
                  key: const Key('home-ingredient-all'),
                  label: Text(strings.label('All', 'الكل')),
                  selected: selected,
                  onSelected: (_) => setState(() => _ingredientFilter = null),
                  showCheckmark: false,
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 9),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  side: BorderSide(color: selected ? AppTheme.terracotta : AppTheme.line),
                  backgroundColor: AppTheme.card,
                  selectedColor: AppTheme.terracotta.withOpacity(.13),
                  labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: selected ? AppTheme.terracotta : AppTheme.ink),
                );
              }
              final ingredient = filterOptions[index - 1];
              final selected = _ingredientFilter == ingredient;
              return ChoiceChip(
                key: Key('home-ingredient-$ingredient'),
                label: Text(ingredient),
                selected: selected,
                onSelected: (value) => setState(() => _ingredientFilter = value ? ingredient : null),
                showCheckmark: false,
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: const EdgeInsets.symmetric(horizontal: 9),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                side: BorderSide(color: selected ? AppTheme.terracotta : AppTheme.line),
                backgroundColor: AppTheme.card,
                selectedColor: AppTheme.terracotta.withOpacity(.13),
                labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: selected ? AppTheme.terracotta : AppTheme.ink),
              );
            },
          ),
        ),
        if (_ingredientFilter != null) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Text(strings.label('Recipes with ', 'وصفات تحتوي على ') + _ingredientFilter!, style: Theme.of(context).textTheme.titleMedium)),
            TextButton(onPressed: () => setState(() => _ingredientFilter = null), child: Text(strings.label('Clear', 'مسح'))),
          ]),
          if (ingredientRecipes.isEmpty)
            Text(strings.label('No recipes found with this ingredient yet.', 'لا توجد وصفات بهذا المكون حاليًا.'), style: TextStyle(color: AppTheme.muted, fontSize: 12))
          else
            SizedBox(
              height: 218,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ingredientRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(width: 174, child: RecipeTile(recipe: ingredientRecipes[index])),
              ),
            ),
        ],
      ],
    );
  }
}

class _RecipeShelf extends StatelessWidget {
  const _RecipeShelf({required this.title, required this.recipes, required this.action, required this.onAction, this.subtitle});
  final String title;
  final String action;
  final String? subtitle;
  final List<Recipe> recipes;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeading(title: title, action: action, onTap: onAction),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle!, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
      ],
      const SizedBox(height: 12),
      SizedBox(
        height: 218,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: recipes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => SizedBox(width: 174, child: RecipeTile(recipe: recipes[index])),
        ),
      ),
    ]);
  }
}
