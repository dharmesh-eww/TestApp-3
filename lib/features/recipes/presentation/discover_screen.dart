import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/navigation/animated_page_route.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/kitchen/presentation/ingredient_finder_screen.dart';
import 'package:testapp_3/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:testapp_3/app/app_widgets.dart';
import 'package:testapp_3/app/gather_visuals.dart';
import 'package:testapp_3/features/recipes/presentation/favorites_screen.dart';

class _DiscoveryFilterBar extends StatelessWidget {
  const _DiscoveryFilterBar({required this.cuisineIds, required this.foodTypeId, required this.difficulty, required this.minMinutes, required this.maxMinutes, required this.cuisines, required this.onChanged});
  final Set<String> cuisineIds;
  final String foodTypeId, difficulty;
  final int minMinutes, maxMinutes;
  final List<String> cuisines;
  final void Function(Set<String>, String, String, int, int) onChanged;

  static const cuisineLabels = <String, String>{
    'indian':'Indian', 'north_indian':'North Indian', 'south_indian':'South Indian',
    'gujarati':'Gujarati', 'chinese':'Chinese', 'japanese':'Japanese', 'italian':'Italian',
    'korean':'Korean', 'mexican':'Mexican', 'american':'American', 'thai':'Thai',
    'mediterranean':'Mediterranean', 'vietnamese':'Vietnamese', 'greek':'Greek',
    'french':'French', 'spanish':'Spanish', 'middle_eastern':'Middle Eastern',
    'turkish':'Turkish', 'african':'African', 'british':'British',
    'other':'Other', 'global':'Global / Fusion',
  };

  @override
  Widget build(BuildContext context) {
    final active = cuisineIds.length + (foodTypeId != 'all' ? 1 : 0) +
        (difficulty != 'all' ? 1 : 0) + ((minMinutes > 0 || maxMinutes < 180) ? 1 : 0);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: OutlinedButton.icon(
        key: const Key('open-recipe-filters'),
        icon: const Icon(Icons.tune, size: 17),
        label: Text(active == 0 ? 'More filters' : 'More filters ($active)'),
        onPressed: () async {
          var selectedCuisines = Set<String>.from(cuisineIds);
          var foodType = foodTypeId;
          var level = difficulty;
          var timeRange = RangeValues(minMinutes.toDouble(), maxMinutes.toDouble());
          final options = <String>{...cuisineLabels.keys, ...cuisines}.toList()
            ..sort((x,y) => (cuisineLabels[x] ?? x).compareTo(cuisineLabels[y] ?? y));
          await showModalBottomSheet<void>(
            context: context, isScrollControlled: true, useSafeArea: true,
            backgroundColor: AppTheme.paper,
            builder: (sheetContext) => StatefulBuilder(
              builder: (sheetContext, setSheetState) => SizedBox(
                height: MediaQuery.of(sheetContext).size.height * .84,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(4)))),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Text(appStrings(sheetContext).label('Recipe filters','فلاتر الوصفات'), style: Theme.of(sheetContext).textTheme.headlineMedium)),
                      TextButton(onPressed: () => setSheetState(() {
                        selectedCuisines.clear(); foodType = 'all'; level = 'all'; timeRange = const RangeValues(0,180);
                      }), child: Text(appStrings(sheetContext).label('Reset all','إعادة ضبط الكل'))),
                    ]),
                    Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(appStrings(sheetContext).label('Cuisine','نوع المطبخ'), style: Theme.of(sheetContext).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final id in options)
                          FilterChip(
                            key: Key('cuisine-option-$id'),
                            label: Text(cuisineLabels[id] ?? id.split('_').map((p)=>p.isEmpty?p:'${p[0].toUpperCase()}${p.substring(1)}').join(' ')),
                            selected: selectedCuisines.contains(id),
                            onSelected: (v) => setSheetState(() { if(v) { selectedCuisines.add(id); } else { selectedCuisines.remove(id); } }),
                            selectedColor: AppTheme.terracotta.withOpacity(.16),
                            side: BorderSide(color: selectedCuisines.contains(id) ? AppTheme.terracotta : AppTheme.line),
                          ),
                      ]),
                      const SizedBox(height: 22),
                      Text(appStrings(sheetContext).label('Food type','نوع الطعام'), style: Theme.of(sheetContext).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final option in const [('all','All','الكل'),('vegetarian','Vegetarian','نباتي'),('vegan','Vegan','نباتي صرف'),('eggetarian','Eggetarian','نباتي مع البيض'),('nonVegetarian','Non-vegetarian','غير نباتي'),('pescatarian','Pescatarian','نباتي مع الأسماك')])
                          ChoiceChip(label: Text(appStrings(sheetContext).label(option.$2, option.$3)), selected: foodType == option.$1, onSelected: (_) => setSheetState(() => foodType=option.$1), selectedColor: AppTheme.terracotta.withOpacity(.16)),
                      ]),
                      const SizedBox(height: 22),
                      Text(appStrings(sheetContext).label('Difficulty','مستوى الصعوبة'), style: Theme.of(sheetContext).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, children: [
                        for (final option in const [('all','Any','أي مستوى'),('easy','Easy','سهل'),('medium','Medium','متوسط'),('hard','Hard','صعب')])
                          ChoiceChip(label: Text(appStrings(sheetContext).label(option.$2, option.$3)), selected: level == option.$1, onSelected: (_) => setSheetState(() => level=option.$1), selectedColor: AppTheme.terracotta.withOpacity(.16)),
                      ]),
                      const SizedBox(height: 22),
                      Row(children: [
                        Expanded(child: Text(appStrings(sheetContext).label('Total cooking time','إجمالي وقت الطهي'), style: Theme.of(sheetContext).textTheme.titleMedium)),
                        Text('${timeRange.start.round()}–${timeRange.end.round()} min', style: TextStyle(color: AppTheme.terracotta,fontWeight:FontWeight.w700)),
                      ]),
                      RangeSlider(min:0,max:180,divisions:36,values:timeRange,labels:RangeLabels('${timeRange.start.round()} min','${timeRange.end.round()} min'),activeColor:AppTheme.terracotta,onChanged:(v)=>setSheetState(()=>timeRange=v)),
                      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                        Text('0 min',style:TextStyle(color:AppTheme.muted,fontSize:11)),
                        Text('180+ min',style:TextStyle(color:AppTheme.muted,fontSize:11)),
                      ]),
                      const SizedBox(height:20),
                    ]))),
                    const SizedBox(height:12),
                    Row(children:[
                      Expanded(child:OutlinedButton(onPressed:(){onChanged(const {},'all','all',0,180);Navigator.pop(sheetContext);},child:Text(appStrings(sheetContext).label('Clear filters','مسح الفلاتر')))),
                      const SizedBox(width:12),
                      Expanded(child:FilledButton(
                        style:FilledButton.styleFrom(backgroundColor:AppTheme.terracotta),
                        onPressed:(){onChanged(selectedCuisines,foodType,level,timeRange.start.round(),timeRange.end.round());Navigator.pop(sheetContext);},
                        child:Text(appStrings(sheetContext).label('Show recipes','عرض الوصفات')),
                      )),
                    ]),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _categoryId = 'all';
  RecipeSort _sort = RecipeSort.recommended;
  Set<String> _cuisineIds = {};
  String _foodTypeId = 'all';
  String _difficulty = 'all';
  int _minMinutes = 0;
  int _maxMinutes = 180;
  String _seasonId = 'all';
  bool _nutritionOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final catalog = RecipeCatalogScope.of(context);
    final filtered = RecipeCatalog.search(
      catalog,
      query: _query,
      categoryId: _categoryId,
      cuisineIds: _cuisineIds,
      foodType: _foodTypeId == 'all' ? null : FoodType.values.firstWhere((value) => value.name == _foodTypeId),
      difficulty: _difficulty,
      minMinutes: _minMinutes == 0 ? null : _minMinutes,
      maxMinutes: _maxMinutes == 180 ? null : _maxMinutes,
      season: _seasonId,
      nutritionOnly: _nutritionOnly,
      dietaryTags: PlannerScope.of(context).preferredDietaryTags,
      preferredCuisines: PlannerScope.of(context).preferredCuisines,
      allergies: PlannerScope.of(context).allergies,
      sort: _sort,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(strings.recipeShelf, style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ),
            GatherVisuals.foodMotion(size: 66),
            IconButton(
              key: const Key('open-favourites-button'),
              tooltip: strings.favorites,
              onPressed: () => Navigator.push(
                context,
                AnimatedPageRoute(builder: (_) => const FavoritesScreen()),
              ),
              icon: const Icon(Icons.favorite_border),
              color: AppTheme.terracotta,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(strings.findFavourite, style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          key: const Key('recipe-search-field'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: strings.searchHint,
            prefixIcon: Icon(Icons.search),
            suffixIcon: _query.isEmpty ? null : IconButton(
              tooltip: appStrings(context).label('Clear search', 'مسح البحث'),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              icon: Icon(Icons.close),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const Key('ingredient-finder-button'),
          onPressed: () async {
            final recipe = await Navigator.push<Recipe>(context, MaterialPageRoute(
              builder: (_) => const IngredientFinderScreen(),
            ));
            if (recipe != null && context.mounted) {
              Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)));
            }
          },
          icon: Icon(Icons.kitchen_outlined),
          label: Text(appStrings(context).label('Cook with what you have', 'اطبخ بالمكونات المتوفرة لديك')),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final category in recipeCategories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: Key('category-${category.id}'),
                  label: Text(strings.category(category.id, category.name)),
                  selected: _categoryId == category.id,
                  onSelected: (_) => setState(() => _categoryId = category.id),
                  selectedColor: AppTheme.terracotta.withOpacity(.16),
                  side: BorderSide(color: _categoryId == category.id ? AppTheme.terracotta : AppTheme.line),
                  labelStyle: TextStyle(
                    color: _categoryId == category.id ? AppTheme.terracotta : AppTheme.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(
            key: const Key('recipe-season-filter'),
            value: _seasonId,
            isExpanded: true,
            decoration: InputDecoration(labelText: appStrings(context).recipeLabel('Season'), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            items: [
              DropdownMenuItem(value: 'all', child: Text(appStrings(context).recipeLabel('All seasons'))),
              DropdownMenuItem(value: 'winter', child: Text(appStrings(context).recipeLabel('Winter'))),
              DropdownMenuItem(value: 'rainy', child: Text(appStrings(context).recipeLabel('Rainy season'))),
              DropdownMenuItem(value: 'summer', child: Text(appStrings(context).recipeLabel('Summer'))),
              DropdownMenuItem(value: 'spring', child: Text(appStrings(context).recipeLabel('Spring'))),
              DropdownMenuItem(value: 'autumn', child: Text(appStrings(context).recipeLabel('Autumn'))),
            ],
            onChanged: (value) => setState(() => _seasonId = value ?? 'all'),
          )),
          const SizedBox(width: 10),
          Expanded(child: FilterChip(
            key: const Key('recipe-nutrition-filter'),
            selected: _nutritionOnly,
            onSelected: (value) => setState(() => _nutritionOnly = value),
            label: Text(appStrings(context).recipeLabel('Nutrition data')),
            avatar: const Icon(Icons.monitor_heart_outlined, size: 17),
          )),
        ]),
        const SizedBox(height: 10),
        _DiscoveryFilterBar(
          cuisineIds: _cuisineIds,
          foodTypeId: _foodTypeId,
          difficulty: _difficulty,
          minMinutes: _minMinutes,
          maxMinutes: _maxMinutes,
          cuisines: catalog.expand((recipe) => recipe.cuisineIds).toSet().toList(),
          onChanged: (cuisines, foodType, difficulty, minMinutes, maxMinutes) => setState(() {
            _cuisineIds = cuisines;
            _foodTypeId = foodType;
            _difficulty = difficulty;
            _minMinutes = minMinutes;
            _maxMinutes = maxMinutes;
          }),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(
            strings.recipeCount(filtered.length),
            style: Theme.of(context).textTheme.titleMedium,
          )),
          DropdownButtonHideUnderline(
            child: DropdownButton<RecipeSort>(
              key: const Key('recipe-sort-dropdown'),
              value: _sort,
              borderRadius: BorderRadius.circular(14),
              style: TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w600),
              items: [
                DropdownMenuItem(value: RecipeSort.recommended, child: Text(appStrings(context).label('Recommended', 'موصى به'))),
                DropdownMenuItem(value: RecipeSort.quickest, child: Text(appStrings(context).label('Quickest', 'الأسرع'))),
                DropdownMenuItem(value: RecipeSort.title, child: Text(appStrings(context).label('A–Z', 'أ–ي'))),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sort = value);
              },
            ),
          ),
        ]),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: AppMotion.quick,
          switchInCurve: AppMotion.enter,
          child: filtered.isEmpty
              ? Container(
                  key: const ValueKey('empty-recipes'),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: Column(children: [
                    Icon(Icons.search_off_rounded, size: 34, color: AppTheme.olive),
                    SizedBox(height: 10),
                    Text(strings.emptyShelf, style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                    SizedBox(height: 5),
                    Text(strings.emptyShelfHint, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                  ]),
                )
              : Column(
                  key: const ValueKey('recipe-results'),
                  children: [
                    for (final recipe in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RecipeListTile(recipe: recipe),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
