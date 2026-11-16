import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import '../core/navigation/animated_page_route.dart';
import '../core/theme/app_theme.dart';
import '../features/recipes/domain/recipe.dart';
import '../features/recipes/domain/recipe_catalog.dart';
import '../features/planning/domain/meal_plan.dart';
import '../features/recipes/data/recipe_catalog_loader.dart';
import '../features/recipes/data/static_recipe_content_updater.dart';
import '../data/local/planner_repository.dart';
import '../features/cooking/presentation/cooking_mode_screen.dart';
import '../features/kitchen/presentation/kitchen_tools_screen.dart';
import '../features/groceries/presentation/grocery_lists_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../localization/app_localizations.dart';
import 'app_dependencies.dart';
import 'planner_scope.dart';
import 'recipe_catalog_scope.dart';

class RecipePlannerApp extends StatefulWidget {
  const RecipePlannerApp({super.key, this.repository, this.showOnboarding = false});
  final PlannerRepository? repository;
  final bool showOnboarding;

  @override
  State<RecipePlannerApp> createState() => _RecipePlannerAppState();
}

class _RecipePlannerAppState extends State<RecipePlannerApp> {
  final AppDependencies dependencies = AppDependencies();
  Timer? _cookingPersistTimer;
  Locale _locale = const Locale('en');
  List<Recipe> _catalogRecipes = recipes;
  String _contentVersion = 'bundled';
  StaticRecipeContentUpdater? _contentUpdater;

  @override
  void initState() {
    super.initState();
    dependencies.cookingSession.addListener(_onCookingChanged);
    unawaited(_initializeLocalData());
  }

  Future<void> _initializeLocalData() async {
    try {
      final cached = await widget.repository?.loadCatalog();
      if (cached != null) {
        final document = RecipeCatalogLoader.decode(cached.payload);
        if (mounted) setState(() { _catalogRecipes = document.recipes; _contentVersion = cached.contentVersion; });
      } else {
        final document = await RecipeCatalogLoader.load();
        if (!mounted) return;
        setState(() => _catalogRecipes = document.recipes);
      }
      final restored = await widget.repository?.loadPlannerState();
      if (restored != null && mounted) {
        dependencies.plannerState.restoreFromJson(restored.toJson());
        setState(() => _locale = Locale(dependencies.plannerState.localeCode));
      }
      final cookingSnapshot = await widget.repository?.loadCookingSession();
      if (cookingSnapshot != null && mounted) {
        dependencies.cookingSession.restoreFromJson(cookingSnapshot);
      }
    } on CatalogLoadException {
      // Keep the in-code catalog active if the bundled document is invalid.
    } catch (_) {
      // Database or asset failures must not block the in-memory starter experience.
    }
  }

  void _onPlannerChanged() {
    setState(() {});
    final store = widget.repository;
    if (store != null) unawaited(store.savePlannerState(dependencies.plannerState).catchError((_) {}));
  }

  void _onCookingChanged() {
    if (_cookingPersistTimer != null) return;
    _cookingPersistTimer = Timer(const Duration(seconds: 1), () {
      _cookingPersistTimer = null;
      final store = widget.repository;
      if (store != null) {
        unawaited(store.saveCookingSession(dependencies.cookingSession.toJson()).catchError((_) {}));
      }
    });
  }

  Future<bool> _checkForContentUpdates() async {
    final uri = Uri.parse('https://raw.githubusercontent.com/dharmesh-eww/TestApp-3/main/content/manifest.json');
    try {
      final update = await (_contentUpdater ??= StaticRecipeContentUpdater()).checkAndDownload(uri);
      if (update.contentVersion == _contentVersion) return false;
      await widget.repository?.activateCatalog(contentVersion: update.contentVersion, payload: update.payload);
      if (!mounted) return false;
      setState(() { _catalogRecipes = update.document.recipes; _contentVersion = update.contentVersion; });
      return true;
    } on ContentUpdateException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _cookingPersistTimer?.cancel();
    dependencies.cookingSession.removeListener(_onCookingChanged);
    final store = widget.repository;
    if (store != null) {
      unawaited(store.saveCookingSession(dependencies.cookingSession.toJson()).catchError((_) {}));
    }
    _contentUpdater?.close();
    dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme.setDarkMode(dependencies.plannerState.themePreference == 'dark' ||
        (dependencies.plannerState.themePreference == 'system' && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark));
    return PlannerScope(
      state: dependencies.plannerState,
      cookingSession: dependencies.cookingSession,
      onChanged: _onPlannerChanged,
      child: RecipeCatalogScope(
        recipes: _catalogRecipes,
        contentVersion: _contentVersion,
        onCheckForUpdates: _checkForContentUpdates,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gather — Recipe Planner',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: switch (dependencies.plannerState.themePreference) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          locale: _locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: (!widget.showOnboarding || dependencies.plannerState.onboardingComplete)
              ? AppShell(
            locale: _locale,
            onLocaleChanged: (locale) {
            dependencies.plannerState.localeCode = locale.languageCode;
            setState(() => _locale = locale);
            _onPlannerChanged();
          },
          )
              : OnboardingScreen(onComplete: () {
                  dependencies.plannerState.onboardingComplete = true;
                  _onPlannerChanged();
                }),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.locale, required this.onLocaleChanged});
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selected = 0;
  final pages = const [
    TodayScreen(), DiscoverScreen(), PlanScreen(), GroceryScreen(), KitchenScreen(),
  ];

  void selectTab(int index) {
    if (index < 0 || index >= pages.length || index == selected) return;
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12, top: 4),
                child: Semantics(
                  button: true,
                  label: appStrings(context).language,
                  child: TextButton.icon(
                    key: const Key('locale-toggle'),
                    onPressed: () => widget.onLocaleChanged(
                      widget.locale.languageCode == 'en'
                          ? const Locale('ar')
                          : const Locale('en'),
                    ),
                    icon: Icon(Icons.language, size: 18),
                    label: Text(widget.locale.languageCode == 'en' ? 'العربية' : 'English'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: PlannerScope.of(context).reduceMotion ? Duration.zero : AppMotion.page,
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
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (value) => setState(() => selected = value),
        destinations: [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: appStrings(context).today),
          NavigationDestination(icon: Icon(Icons.search), label: appStrings(context).recipes),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: appStrings(context).plan),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: appStrings(context).groceries),
          NavigationDestination(icon: Icon(Icons.shelves), label: appStrings(context).kitchen),
        ],
      ),
    );
  }
}


class _DiscoveryFilterBar extends StatelessWidget {
  const _DiscoveryFilterBar({
    required this.cuisineId, required this.foodTypeId, required this.difficulty,
    required this.maxMinutes, required this.cuisines, required this.onChanged,
  });
  final String cuisineId, foodTypeId, difficulty;
  final int? maxMinutes;
  final List<String> cuisines;
  final void Function(String cuisine, String foodType, String difficulty, int? minutes) onChanged;

  @override
  Widget build(BuildContext context) {
    final active = (cuisineId != 'all' ? 1 : 0) + (foodTypeId != 'all' ? 1 : 0) +
        (difficulty != 'all' ? 1 : 0) + (maxMinutes != null ? 1 : 0);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: OutlinedButton.icon(
        key: const Key('open-recipe-filters'),
        icon: Icon(Icons.tune, size: 17),
        label: Text(active == 0 ? 'More filters' : 'More filters ($active)'),
        onPressed: () async {
          var cuisine = cuisineId;
          var foodType = foodTypeId;
          var level = difficulty;
          var minutes = maxMinutes;
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.paper,
            builder: (sheetContext) => StatefulBuilder(
              builder: (sheetContext, setSheetState) => SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appStrings(sheetContext).label('Refine recipes', 'تصفية الوصفات'), style: Theme.of(sheetContext).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: cuisine,
                        decoration: InputDecoration(labelText: appStrings(sheetContext).label('Cuisine', 'المطبخ')),
                        items: [DropdownMenuItem(value: 'all', child: Text(appStrings(sheetContext).label('All cuisines', 'كل المطابخ'))),
                          ...cuisines.map((value) => DropdownMenuItem(value: value, child: Text(value)))],
                        onChanged: (value) => setSheetState(() => cuisine = value ?? 'all'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: foodType,
                        decoration: InputDecoration(labelText: appStrings(sheetContext).label('Food type', 'نوع الطعام')),
                        items: [
                          DropdownMenuItem(value: 'all', child: Text(appStrings(sheetContext).label('All food types', 'كل أنواع الطعام'))),
                          DropdownMenuItem(value: 'vegetarian', child: Text(appStrings(sheetContext).label('Vegetarian', 'نباتي'))),
                          DropdownMenuItem(value: 'vegan', child: Text(appStrings(sheetContext).label('Vegan', 'نباتي صرف'))),
                          DropdownMenuItem(value: 'eggetarian', child: Text(appStrings(sheetContext).label('Eggetarian', 'نباتي مع البيض'))),
                          DropdownMenuItem(value: 'nonVegetarian', child: Text(appStrings(sheetContext).label('Non-vegetarian', 'غير نباتي'))),
                          DropdownMenuItem(value: 'pescatarian', child: Text(appStrings(sheetContext).label('Pescatarian', 'نباتي مع الأسماك'))),
                        ],
                        onChanged: (value) => setSheetState(() => foodType = value ?? 'all'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: level,
                        decoration: InputDecoration(labelText: appStrings(sheetContext).label('Difficulty', 'مستوى الصعوبة')),
                        items: [
                          DropdownMenuItem(value: 'all', child: Text(appStrings(sheetContext).label('Any difficulty', 'أي مستوى'))),
                          DropdownMenuItem(value: 'easy', child: Text(appStrings(sheetContext).label('Easy', 'سهل'))),
                          DropdownMenuItem(value: 'medium', child: Text(appStrings(sheetContext).label('Medium', 'متوسط'))),
                          DropdownMenuItem(value: 'hard', child: Text(appStrings(sheetContext).label('Hard', 'صعب'))),
                        ],
                        onChanged: (value) => setSheetState(() => level = value ?? 'all'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int?>(
                        value: minutes,
                        decoration: InputDecoration(labelText: appStrings(sheetContext).label('Maximum time', 'الوقت الأقصى')),
                        items: [
                          DropdownMenuItem<int?>(value: null, child: Text(appStrings(sheetContext).label('Any time', 'أي وقت'))),
                          DropdownMenuItem<int?>(value: 20, child: Text(appStrings(sheetContext).label('20 minutes', '20 دقيقة'))),
                          DropdownMenuItem<int?>(value: 30, child: Text(appStrings(sheetContext).label('30 minutes', '30 دقيقة'))),
                          DropdownMenuItem<int?>(value: 45, child: Text(appStrings(sheetContext).label('45 minutes', '45 دقيقة'))),
                          DropdownMenuItem<int?>(value: 60, child: Text(appStrings(sheetContext).label('60 minutes', '60 دقيقة'))),
                        ],
                        onChanged: (value) => setSheetState(() => minutes = value),
                      ),
                      const SizedBox(height: 18),
                      Row(children: [
                        TextButton(onPressed: () => setSheetState(() {
                          cuisine = 'all'; foodType = 'all'; level = 'all'; minutes = null;
                        }), child: Text(appStrings(sheetContext).label('Reset', 'إعادة ضبط'))),
                        const Spacer(),
                        FilledButton(onPressed: () {
                          onChanged(cuisine, foodType, level, minutes);
                          Navigator.pop(sheetContext);
                        }, child: Text(appStrings(sheetContext).label('Apply filters', 'تطبيق التصفية'))),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = RecipeCatalogScope.of(context);
    final featured = catalog.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appStrings(context).label('MONDAY, AT YOUR PACE', 'أسبوعك على إيقاعك'), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            SizedBox(height: 7),
            Text(appStrings(context).label('A little more joy\nin the kitchen.', 'مزيد من البهجة\nفي مطبخك.'), style: TextStyle(fontFamily: 'Georgia', fontSize: 31, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
          ])),
          CircleAvatar(radius: 24, backgroundColor: const Color(0xFFE9E4D8), child: Icon(Icons.spa_outlined, color: AppTheme.olive)),
        ]),
        const SizedBox(height: 24),
        _SectionHeading(title: appStrings(context).label('Today’s inspiration', 'إلهام اليوم'), action: appStrings(context).label('See all', 'عرض الكل'), onTap: () => _goTab(context, 1)),
        const SizedBox(height: 12),
        _FeaturedRecipe(recipe: featured),
        const SizedBox(height: 26),
        _SectionHeading(title: appStrings(context).label('Made for your week', 'اختيارات لأسبوعك'), action: appStrings(context).label('Open plan', 'افتح الخطة'), onTap: () => _goTab(context, 2)),
        const SizedBox(height: 12),
        const _WeekStrip(),
        const SizedBox(height: 26),
        _SectionHeading(title: appStrings(context).label('A few good ideas', 'بعض الأفكار الجميلة'), action: appStrings(context).label('Explore', 'استكشف'), onTap: () => _goTab(context, 1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: catalog.length - 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(width: 174, child: _RecipeTile(recipe: catalog[index + 1])),
          ),
        ),
      ],
    );
  }
}

void _goTab(BuildContext context, int index) {
  final shell = context.findAncestorStateOfType<_AppShellState>();
  shell?.selectTab(index);
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
  String _cuisineId = 'all';
  String _foodTypeId = 'all';
  String _difficulty = 'all';
  int? _maxMinutes;

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
      cuisineId: _cuisineId,
      foodType: _foodTypeId == 'all' ? null : FoodType.values.firstWhere((value) => value.name == _foodTypeId),
      difficulty: _difficulty,
      maxMinutes: _maxMinutes,
      dietaryTags: PlannerScope.of(context).preferredDietaryTags,
      sort: _sort,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(strings.recipeShelf, style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
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
        _DiscoveryFilterBar(
          cuisineId: _cuisineId, foodTypeId: _foodTypeId, difficulty: _difficulty,
          maxMinutes: _maxMinutes,
          cuisines: catalog.expand((recipe) => recipe.cuisineIds).toSet().toList()..sort(),
          onChanged: (cuisine, foodType, difficulty, minutes) => setState(() {
            _cuisineId = cuisine; _foodTypeId = foodType; _difficulty = difficulty; _maxMinutes = minutes;
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
              items: const [
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
                        child: _RecipeListTile(recipe: recipe),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  static const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  @override State<PlanScreen> createState() => _PlanScreenState();
}
class _PlanScreenState extends State<PlanScreen> {
  int selectedDay = 0;
  @override Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final days = state.weekStartsOn == 7
        ? ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        : PlanScreen.days;
    final day = days[selectedDay];
    final meals = state.mealsFor(day);
    return ListView(padding: const EdgeInsets.fromLTRB(20,20,20,28), children: [
      Text(appStrings(context).weekEyebrow, style: TextStyle(color: AppTheme.terracotta,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.5)),
      const SizedBox(height:8),
      Text(appStrings(context).mealPlanner,style:TextStyle(fontFamily:'Georgia',fontSize:32,height:1.08,color:AppTheme.ink,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      Text(appStrings(context).weekDescription,style:TextStyle(color:AppTheme.muted)),
      const SizedBox(height:20),
      Container(padding:const EdgeInsets.symmetric(vertical:12,horizontal:8),decoration:BoxDecoration(color:AppTheme.card,borderRadius:BorderRadius.circular(18),border:Border.all(color:AppTheme.line)),
        child:Row(children:List.generate(7,(index){
          final orderedDays = state.weekStartsOn == 7
              ? ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
              : PlanScreen.days;
          final name=orderedDays[index], count=state.mealsFor(name).length;
          return Expanded(child:InkWell(borderRadius:BorderRadius.circular(14),onTap:()=>setState(()=>selectedDay=index),
            child:AnimatedContainer(duration:AppMotion.quick,padding:const EdgeInsets.symmetric(vertical:9),decoration:BoxDecoration(color:selectedDay==index?AppTheme.terracotta.withOpacity(.12):Colors.transparent,borderRadius:BorderRadius.circular(12)),
              child:Column(children:[Text(name.substring(0,1),style:TextStyle(color:selectedDay==index?AppTheme.terracotta:AppTheme.muted,fontSize:11,fontWeight:FontWeight.w800)),const SizedBox(height:5),Text('$count',style:TextStyle(color:selectedDay==index?AppTheme.terracotta:AppTheme.ink,fontWeight:FontWeight.w800))]))));
        }))),
      const SizedBox(height:18),
      Row(children:[Expanded(child:Text(day,style:Theme.of(context).textTheme.titleLarge)),Text(appStrings(context).label('${meals.length}/4 planned', 'تم التخطيط لـ ${meals.length}/4')),style:TextStyle(color:AppTheme.muted,fontSize:12))]),
      const SizedBox(height:10),
      for(final slot in MealSlot.values)
        _MealSlotCard(key: ValueKey('meal-slot-$day-${slot.name}'), day:day,slot:slot,meal:meals.where((m)=>m.slot==slot).firstOrNull,
          onAdd:()=>_showPlanPicker(context,day,slot),onRemove:(){state.removeMeal(day,slot);PlannerScope.refresh(context);},onMove:()=>_showMoveMeal(context,day,slot)),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:()=>_goTab(context,3),icon:Icon(Icons.shopping_basket_outlined),label:Text(appStrings(context).label('Build your grocery list', 'أنشئ قائمة مشترياتك')),style:OutlinedButton.styleFrom(minimumSize:const Size(0,50))),
    ]);
  }
  Future<void> _showMoveMeal(BuildContext context, String fromDay, MealSlot fromSlot) async {
    var targetDay = fromDay;
    var targetSlot = fromSlot;
    final state = PlannerScope.of(context);
    final days = state.weekStartsOn == 7
        ? ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        : PlanScreen.days;
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(appStrings(context).label('Move planned meal', 'نقل الوجبة المخططة')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(value: targetDay, decoration: InputDecoration(labelText: appStrings(context).label('Day', 'اليوم')),
            items: days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
            onChanged: (value) => setDialogState(() => targetDay = value ?? fromDay)),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealSlot>(value: targetSlot, decoration: InputDecoration(labelText: appStrings(context).label('Meal', 'الوجبة')),
            items: MealSlot.values.map((slot) => DropdownMenuItem(value: slot, child: Text(slot.label))).toList(),
            onChanged: (value) => setDialogState(() => targetSlot = value ?? fromSlot)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Move', 'نقل'))),
        ],
      ),
    ));
    if (result != true || !context.mounted) return;
    final moved = state.moveMeal(fromDay: fromDay, fromSlot: fromSlot, toDay: targetDay, toSlot: targetSlot);
    if (moved) PlannerScope.refresh(context);
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('That destination is occupied. Choose an empty meal slot.', 'هذا الموعد مشغول. اختر خانة وجبة فارغة.'))));
  }

  void _showPlanPicker(BuildContext context, String day, MealSlot slot) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan ${slot.label.toLowerCase()}',
                style: Theme.of(sheetContext).textTheme.headlineMedium,
              ),
              Text(
                '$day · Choose a recipe',
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(sheetContext).size.height * .52,
                child: ListView(
                  children: RecipeCatalogScope.of(sheetContext).map((recipe) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(recipe.title),
                      subtitle: Text(
                        '${recipe.minutes} min · ${recipe.category} · serves ${recipe.servings}',
                      ),
                      trailing: Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.terracotta,
                      ),
                      onTap: () {
                        PlannerScope.of(context).assignMeal(
                          day: day,
                          slot: slot,
                          recipeId: recipe.id,
                          servings: recipe.servings,
                        );
                        PlannerScope.refresh(context);
                        Navigator.pop(sheetContext);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _MealSlotCard extends StatelessWidget {
  const _MealSlotCard({super.key, required this.day,required this.slot,required this.meal,required this.onAdd,required this.onRemove,required this.onMove});
  final String day;final MealSlot slot;final PlannedMeal? meal;final VoidCallback onAdd,onRemove,onMove;
  @override Widget build(BuildContext context){
    final recipe=meal==null?null:RecipeCatalogScope.of(context).where((r)=>r.id==meal!.recipeId).firstOrNull;
    return Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppTheme.card,border:Border.all(color:AppTheme.line),borderRadius:BorderRadius.circular(16)),
      child:Row(children:[
        Container(width:40,height:40,decoration:BoxDecoration(color:AppTheme.olive.withOpacity(.12),borderRadius:BorderRadius.circular(12)),child:Icon(switch(slot){MealSlot.breakfast=>Icons.wb_twilight,MealSlot.lunch=>Icons.wb_sunny_outlined,MealSlot.dinner=>Icons.nightlight_outlined,MealSlot.snack=>Icons.cookie_outlined},color:AppTheme.olive)),
        const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(slot.label.toUpperCase(),style:TextStyle(color:AppTheme.terracotta,fontSize:9,letterSpacing:1.1,fontWeight:FontWeight.w800)),const SizedBox(height:4),
          Text(recipe?.title??'Nothing planned yet',style:TextStyle(color:recipe==null?AppTheme.muted:AppTheme.ink,fontWeight:FontWeight.w700)),
          if(meal!=null)Text(appStrings(context).label('${meal!.servings} servings · ${recipe?.minutes??0} min', '${meal!.servings} حصص · ${recipe?.minutes??0} دقيقة'),style:TextStyle(color:AppTheme.muted,fontSize:11)),
        ])),
        if(meal==null)IconButton(key:Key('add-${day}-${slot.name}'),tooltip:'Add ${slot.label}',onPressed:onAdd,icon:Icon(Icons.add_circle_outline,color:AppTheme.terracotta))
        else Row(mainAxisSize:MainAxisSize.min,children:[
          IconButton(tooltip:'Move meal',onPressed:onMove,icon:Icon(Icons.drive_file_move_outline,color:AppTheme.olive)),
          IconButton(key:Key('remove-${day}-${slot.name}'),tooltip:'Remove ${slot.label}',onPressed:onRemove,icon:Icon(Icons.close,color:AppTheme.muted)),
        ]),
      ]));
  }
}


class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});
  @override Widget build(BuildContext context){
    final state=PlannerScope.of(context),entries=state.buildGroceryList(RecipeCatalogScope.of(context));
    final checked=entries.where((item)=>item.isChecked).length;
    final grouped = <String, List<GroceryItem>>{};
    for (final item in entries) { grouped.putIfAbsent(_groceryAisle(item.name), () => []).add(item); }
    return ListView(padding:const EdgeInsets.fromLTRB(20,20,20,28),children:[
      Text(appStrings(context).label('THE MARKET LIST', 'قائمة المشتريات'),style:TextStyle(color:AppTheme.terracotta,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.5)),const SizedBox(height:8),
      Text(appStrings(context).label('Good things\\nto pick up.', 'أشياء جيدة\\nلشرائها.'),style:TextStyle(fontFamily:'Georgia',fontSize:32,height:1.08,color:AppTheme.ink,fontWeight:FontWeight.bold)),const SizedBox(height:8),
      Text(entries.isEmpty?appStrings(context).label('Your planned meals will gather ingredients here.', 'ستظهر مكونات وجباتك المخططة هنا.') : appStrings(context).label('$checked of ${entries.length} items checked · ${entries.where((e)=>e.toBuyAmount>0||!e.isQuantified).length} to buy', 'تم تحديد $checked من ${entries.length} عناصر · ${entries.where((e)=>e.toBuyAmount>0||!e.isQuantified).length} للشراء'),style:TextStyle(color:AppTheme.muted)),
      const SizedBox(height:12),
      Align(alignment:AlignmentDirectional.centerStart,child:Wrap(spacing:8,children:[
        OutlinedButton.icon(key:const Key('add-custom-grocery-item'),onPressed:()=>_showCustomGroceryEditor(context),icon:Icon(Icons.add),label:Text(appStrings(context).label('Add item', 'إضافة عنصر'))),
        OutlinedButton.icon(onPressed:()=>Navigator.push(context, MaterialPageRoute(builder: (_) => const GroceryListsScreen())),icon:Icon(Icons.list_alt),label:Text(appStrings(context).label('Shopping lists', 'قوائم التسوق'))),
        if(entries.any((item)=>item.isCustom && item.isChecked)) TextButton(onPressed:(){ state.clearCheckedCustomGroceryItems(); PlannerScope.refresh(context); },child:Text(appStrings(context).label('Clear checked custom items', 'مسح العناصر المخصصة المحددة'))),
      ])),
      const SizedBox(height:12),
      if(entries.isEmpty)Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:AppTheme.card,borderRadius:BorderRadius.circular(18),border:Border.all(color:AppTheme.line)),child:Column(children:[Icon(Icons.shopping_basket_outlined,size:36,color:AppTheme.olive),SizedBox(height:10),Text(appStrings(context).label('Your list is waiting', 'قائمتك بانتظارك'),style:TextStyle(fontWeight:FontWeight.w700,color:AppTheme.ink)),SizedBox(height:5),Text(appStrings(context).label('Add meals to your weekly plan or add ingredients from a recipe.', 'أضف وجبات إلى خطتك الأسبوعية أو أضف مكونات من وصفة.'),textAlign:TextAlign.center,style:TextStyle(color:AppTheme.muted))]))
      else for (final aisle in grouped.entries) ...[
        Padding(padding: const EdgeInsets.only(top: 10, bottom: 8), child: Text(aisle.key.toUpperCase(), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3))),
        for (final item in aisle.value) Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.line),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: [
              Checkbox(
                value: item.isChecked,
                activeColor: AppTheme.olive,
                onChanged: (value) {
                  state.setGroceryChecked(item.key, value ?? false);
                  PlannerScope.refresh(context);
                },
              ),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? AppTheme.muted : AppTheme.ink,
                    fontWeight: FontWeight.w600,
                  )),
                  Text(
                    item.isQuantified
                      ? appStrings(context).label('${_formatAmount(item.amount)} ${item.unit} needed · ${_formatAmount(item.ownedAmount)} owned · ${_formatAmount(item.toBuyAmount)} to buy', '${_formatAmount(item.amount)} ${item.unit} مطلوب · ${_formatAmount(item.ownedAmount)} متوفر · ${_formatAmount(item.toBuyAmount)} للشراء')
                      : appStrings(context).label('Non-quantified · check pantry before shopping', 'كمية غير محددة · تحقق من المخزن قبل التسوق'),
                    style: TextStyle(color: AppTheme.muted, fontSize: 11),
                  ),
                ],
              )),
              if (item.isCustom) IconButton(tooltip: appStrings(context).label('Remove custom grocery item', 'إزالة عنصر مخصص'), onPressed: () { state.removeCustomGroceryItem(item.key); PlannerScope.refresh(context); }, icon: Icon(Icons.close, size: 18)),
              IconButton(
                tooltip: appStrings(context).label('Edit grocery item', 'تعديل عنصر المشتريات'),
                onPressed: () => _showGroceryEditor(context, item),
                icon: Icon(Icons.edit_outlined, size: 18, color: AppTheme.muted),
              ),
            ]),
          ),
        ),
      ],
      const SizedBox(height:22),
      Row(children:[Expanded(child:Text(appStrings(context).label('Your pantry', 'مخزنك'),style:Theme.of(context).textTheme.titleLarge)),TextButton.icon(onPressed:()=>_showPantryEditor(context),icon:Icon(Icons.add,size:17),label:Text(appStrings(context).label('Add item', 'إضافة عنصر')))]),
      Text(appStrings(context).label('Items here are deducted from what you need to buy.', 'تُخصم العناصر الموجودة هنا من الكميات التي تحتاج إلى شرائها.'),style:TextStyle(color:AppTheme.muted,fontSize:12)),
      if(state.expiringPantryItems.isNotEmpty) Padding(padding:const EdgeInsets.only(top:8),child:Text(appStrings(context).label('${state.expiringPantryItems.length} pantry item(s) expire within seven days.', 'ستنتهي صلاحية ${state.expiringPantryItems.length} من عناصر المخزن خلال سبعة أيام.'),style:TextStyle(color:AppTheme.terracotta,fontWeight:FontWeight.w700))),
      const SizedBox(height:10),
      if(state.pantry.isEmpty)Text(appStrings(context).label('Your pantry is empty for now.', 'مخزنك فارغ حاليًا.'),style:TextStyle(color:AppTheme.muted))
      else for(final item in state.pantry.values)ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:4),leading:Icon(Icons.inventory_2_outlined,color:AppTheme.olive),title:Text(item.name),subtitle:Text('${_formatAmount(item.amount)} ${item.unit}${state.pantryExpiryDates[item.id] == null ? '' : ' · ${appStrings(context).label('Expires', 'تنتهي الصلاحية')} ${MaterialLocalizations.of(context).formatMediumDate(state.pantryExpiryDates[item.id]!)}'}'),
        trailing:Wrap(children:[
          IconButton(tooltip:appStrings(context).label('Set expiry date', 'تحديد تاريخ الصلاحية'),onPressed:() async {
            final current = state.pantryExpiryDates[item.id];
            final picked = await showDatePicker(context:context,initialDate:current ?? DateTime.now(),firstDate:DateTime.now().subtract(const Duration(days:3650)),lastDate:DateTime.now().add(const Duration(days:3650)));
            if(picked != null){state.setPantryExpiry(item.id,picked);PlannerScope.refresh(context);}
          },icon:Icon(Icons.event_outlined)),
          IconButton(tooltip:appStrings(context).label('Remove pantry item', 'إزالة عنصر من المخزن'),onPressed:(){state.removePantryItem(item.id);PlannerScope.refresh(context);},icon:Icon(Icons.close)),
        ])),
    ]);
  }
  void _showCustomGroceryEditor(BuildContext context) {
    final name = TextEditingController();
    final amount = TextEditingController(text: '1');
    final unit = TextEditingController(text: 'item');
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(appStrings(context).label('Add a grocery item', 'إضافة عنصر للمشتريات')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, autofocus: true, decoration: InputDecoration(labelText: appStrings(context).label('Item', 'العنصر'))),
        TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: appStrings(context).label('Quantity', 'الكمية'))),
        TextField(controller: unit, decoration: InputDecoration(labelText: appStrings(context).label('Unit', 'الوحدة'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
        FilledButton(onPressed: () {
          final quantity = double.tryParse(amount.text.trim());
          if (name.text.trim().isEmpty || unit.text.trim().isEmpty || quantity == null || quantity < 0) return;
          PlannerScope.of(context).addCustomGroceryItem(name: name.text, amount: quantity, unit: unit.text);
          PlannerScope.refresh(context);
          Navigator.pop(dialogContext);
        }, child: Text(appStrings(context).label('Add', 'إضافة'))),
      ],
    )).then((_) { name.dispose(); amount.dispose(); unit.dispose(); });
  }

  void _showGroceryEditor(BuildContext context, GroceryItem item) {
    final name = TextEditingController(text: item.name);
    final amount = TextEditingController(text: item.isQuantified ? _formatAmount(item.amount) : '');
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(appStrings(context).label('Edit grocery item', 'تعديل عنصر المشتريات')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: InputDecoration(labelText: appStrings(context).label('Ingredient', 'المكوّن'))),
        if (item.isQuantified) TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appStrings(context).label('Amount (${item.unit})', 'الكمية (${item.unit})'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
        FilledButton(onPressed: () {
          final parsed = item.isQuantified ? double.tryParse(amount.text.trim()) : item.amount;
          if (parsed == null || parsed < 0 || name.text.trim().isEmpty) return;
          PlannerScope.of(context).updateGroceryItem(item.key, name: name.text, amount: parsed);
          PlannerScope.refresh(context);
          Navigator.pop(dialogContext);
        }, child: Text(appStrings(context).label('Save', 'حفظ'))),
      ],
    )).then((_) { name.dispose(); amount.dispose(); });
  }

  void _showPantryEditor(BuildContext context){
    final name=TextEditingController(),amount=TextEditingController(text:'1'),unit=TextEditingController(text:'g');
    showDialog<void>(context:context,builder:(dialogContext)=>AlertDialog(title:Text(appStrings(context).label('Add to your pantry', 'إضافة إلى المخزن')),content:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,decoration:InputDecoration(labelText:appStrings(context).label('Ingredient', 'المكوّن'))),TextField(controller:amount,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:appStrings(context).label('Quantity', 'الكمية'))),TextField(controller:unit,decoration:InputDecoration(labelText:appStrings(context).label('Unit (g, ml, whole…)', 'الوحدة (g، ml، كامل…)'))),
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:Text(appStrings(context).label('Cancel', 'إلغاء'))),FilledButton(onPressed:(){
      final value=double.tryParse(amount.text.trim());if(value==null||value<0||name.text.trim().isEmpty||unit.text.trim().isEmpty)return;
      PlannerScope.of(context).upsertPantryItem(name:name.text,amount:value,unit:unit.text);PlannerScope.refresh(context);Navigator.pop(dialogContext);
    },child:Text(appStrings(context).label('Save', 'حفظ')))])).then((_){name.dispose();amount.dispose();unit.dispose();});
  }
}
String _groceryAisle(String name) {
  final value = name.toLowerCase();
  if (['tomato','onion','garlic','lemon','cucumber','parsley','basil','sweet potato','berries','ginger'].any((term) => value.contains(term))) return 'Produce';
  if (['milk','yogurt','curd','cream','cheese','ricotta','parmesan','butter'].any(value.contains)) return 'Dairy & chilled';
  if (['bread','sourdough','pasta','oats','quinoa','rice','flour','chickpea','lentil','oil','tahini','spice'].any(value.contains)) return 'Pantry';
  return 'Other';
}

String _formatAmount(double value)=>value==value.roundToDouble()?value.toInt().toString():value.toStringAsFixed(1);


class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final saved = RecipeCatalogScope.of(context).where((recipe) => state.favorites.contains(recipe.id)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(appStrings(context).label('YOUR LITTLE COOKBOOK', 'كتاب وصفاتك الصغير'), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(appStrings(context).label('Your kitchen,\nyour rhythm.', 'مطبخك،\nإيقاعك الخاص.'), style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(children: [
          _StatCard(value: '${saved.length}', label: 'Saved recipes', icon: Icons.bookmark_outline),
          const SizedBox(width: 10),
          _StatCard(value: '${state.plannedMealCount}', label: 'Meals planned', icon: Icons.calendar_month_outlined),
        ]),
        const SizedBox(height: 20),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionsScreen())),
            icon: Icon(Icons.folder_open), label: Text(appStrings(context).label('Collections', 'المجموعات')),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CookingHistoryScreen())),
            icon: Icon(Icons.history), label: Text(appStrings(context).label('Cooking history', 'سجل الطهي')),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerSettingsScreen())),
            icon: Icon(Icons.tune), label: Text(appStrings(context).label('Settings', 'الإعدادات')),
          ),
        ]),
        const SizedBox(height: 20),
        Text(appStrings(context).label('Recently viewed', 'شوهدت مؤخرًا'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (state.recentlyViewed.isEmpty)
          Text(appStrings(context).label('Recipes you open will appear here.', 'ستظهر هنا الوصفات التي تفتحها.'), style: TextStyle(color: AppTheme.muted))
        else
          ...state.recentlyViewed.take(5).map((entry) {
            final recipe = RecipeCatalogScope.of(context).where((item) => item.id == entry['recipe_id']).firstOrNull;
            if (recipe == null) return const SizedBox.shrink();
            return Padding(padding: const EdgeInsets.only(bottom: 8), child: _RecipeListTile(recipe: recipe));
          }),
        const SizedBox(height: 22),
        Text(appStrings(context).label('Your saved recipes', 'وصفاتك المحفوظة'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appStrings(context).label('Recipe library', 'مكتبة الوصفات'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(appStrings(context).label('Content version: ${RecipeCatalogScope.versionOf(context)}', 'إصدار المحتوى: ${RecipeCatalogScope.versionOf(context)}'), style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 8),
              Text(appStrings(context).label('Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.', 'تحقق من تحديثات الوصفات المختارة. تظل خطط وجباتك ومخزنك ووصفاتك المحفوظة على هذا الجهاز.'), style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  key: const Key('check-recipe-updates'),
                  onPressed: RecipeCatalogScope.canCheckForUpdates(context) ? () async {
                    final updated = await RecipeCatalogScope.checkForUpdates(context);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(updated ? 'Recipe library updated.' : 'No update available. Current library kept.'),
                    ));
                  } : null,
                  icon: Icon(Icons.sync),
                  label: Text(appStrings(context).label('Check for updates', 'التحقق من التحديثات')),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 12),
        if (saved.isEmpty)
          Text(appStrings(context).label('Recipes you save will live here. Tap the bookmark on any recipe you love.', 'ستظهر هنا الوصفات التي تحفظها. اضغط علامة الحفظ على أي وصفة تعجبك.'), style: TextStyle(color: AppTheme.muted))
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
  bool _recordedView = false;

  @override
  void initState() {
    super.initState();
    servings = widget.recipe.servings;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recordedView) {
      _recordedView = true;
      PlannerScope.of(context).recordViewed(widget.recipe);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) PlannerScope.refresh(context);
      });
    }
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
            IconButton(
              tooltip: appStrings(context).label('Copy recipe', 'نسخ الوصفة'),
              onPressed: () async {
                final text = '${recipe.title}\n\n${recipe.subtitle}\n\nIngredients:\n${recipe.ingredients.map((item) => '• ${item.name}: ${item.amount ?? item.amountType.name} ${item.unit}').join('\n')}\n\nInstructions:\n${recipe.steps.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}';
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Recipe copied to clipboard.', 'تم نسخ الوصفة.'))));
              },
              icon: const Icon(Icons.copy_outlined),
              style: IconButton.styleFrom(backgroundColor: AppTheme.card),
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Image(image: CachedNetworkImageProvider(recipe.image), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE6DED1), child: Icon(Icons.restaurant, size: 48))),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.category.toUpperCase(), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
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
              Expanded(child: Text(appStrings(context).label('Ingredients', 'المكونات'), style: Theme.of(context).textTheme.headlineMedium)),
              IconButton(onPressed: servings > 1 ? () => setState(() => servings--) : null, icon: Icon(Icons.remove_circle_outline)),
              Text(appStrings(context).label('$servings servings', '$servings حصص'), style: TextStyle(fontWeight: FontWeight.w700)),
              IconButton(onPressed: () => setState(() => servings++), icon: Icon(Icons.add_circle_outline)),
            ]),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Icon(Icons.circle, size: 7, color: AppTheme.olive),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: TextStyle(color: AppTheme.ink))),
                Text(item.display(servings, recipe.servings, measurementSystem: state.measurementSystem), style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ]),
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {
                state.addIngredients(recipe, servings);
                PlannerScope.refresh(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Ingredients added to your grocery list', 'تمت إضافة المكونات إلى قائمة المشتريات'))));
              },
              icon: Icon(Icons.add_shopping_cart), label: Text(appStrings(context).label('Add ingredients to grocery list', 'إضافة المكونات إلى قائمة المشتريات')),
            )),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('start-cooking-button'),
                onPressed: () {
                  PlannerScope.cookingOf(context).setServings(recipe.id, servings);
                  Navigator.push(
                    context,
                    AnimatedPageRoute(builder: (_) => CookingModeScreen(recipe: recipe)),
                  );
                },
                icon: Icon(Icons.restaurant_menu),
                label: Text(appStrings(context).label('Start cooking', 'ابدأ الطهي')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  minimumSize: const Size(0, 54),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(appStrings(context).label('Let’s make it', 'هيا نبدأ التحضير'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            ...List.generate(recipe.steps.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.terracotta.withOpacity(.13), child: Text('${index + 1}', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800))),
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
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Container(
        height: 300,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: const Color(0xFFE8DFD1)),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image(image: CachedNetworkImageProvider(recipe.image), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE8DFD1))),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC211A16)], stops: [0.35, 1]))),
          Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appStrings(context).label('EDITOR’S PICK', 'اختيار المحرر'), style: TextStyle(color: Color(0xFFFFD5B9), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(recipe.title, style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            Row(children: [
              Icon(Icons.schedule, color: Colors.white70, size: 15),
              const SizedBox(width: 5),
              Text(appStrings(context).label('${recipe.minutes} min', '${recipe.minutes} دقيقة'), style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 12),
              Icon(Icons.circle, color: Color(0xFFB8C18F), size: 7),
              const SizedBox(width: 5),
              Text(recipe.difficulty, style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Icon(Icons.arrow_forward, color: Colors.white),
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
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(image: CachedNetworkImageProvider(recipe.image), width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE8DFD1), child: Icon(Icons.restaurant))),
        )),
        const SizedBox(height: 8),
        Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700)),
        Text(appStrings(context).label('${recipe.minutes} min · ${recipe.category}', '${recipe.minutes} دقيقة · ${recipe.category}'), style: TextStyle(color: AppTheme.muted, fontSize: 11)),
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
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.card, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image(
            image: CachedNetworkImageProvider(recipe.image), width: 92, height: 88, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(width: 92, height: 88, child: ColoredBox(color: Color(0xFFE8DFD1), child: Icon(Icons.restaurant))),
          )),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.category.toUpperCase(), style: TextStyle(color: AppTheme.terracotta, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(recipe.title, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(recipe.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            const SizedBox(height: 5),
            Text(appStrings(context).label('${recipe.minutes} min · ${recipe.difficulty}', '${recipe.minutes} دقيقة · ${recipe.difficulty}'), style: TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700)),
          ])),
          Icon(Icons.chevron_right, color: AppTheme.muted),
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
    TextButton(onPressed: onTap, child: Text(action, style: TextStyle(color: AppTheme.terracotta))),
  ]);
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final names = state.weekStartsOn == 7
        ? ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        : PlanScreen.days;
    final days = state.weekStartsOn == 7 ? ['S', 'M', 'T', 'W', 'T', 'F', 'S'] : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
      child: Row(children: List.generate(7, (index) {
        final count = state.mealsFor(names[index]).length;
        return Expanded(child: Column(children: [
          Text(days[index], style: TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700)),
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
    child: Row(children: [Icon(icon, size: 14, color: AppTheme.olive), const SizedBox(width: 5), Text(text, style: TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w600))]),
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
      Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
    ]),
  ));
}
