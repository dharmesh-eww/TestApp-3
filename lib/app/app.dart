import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/navigation/animated_page_route.dart';
import '../core/theme/app_theme.dart';
import '../features/recipes/domain/recipe.dart';
import '../features/recipes/domain/recipe_catalog.dart';
import '../features/planning/domain/meal_plan.dart';
import '../features/recipes/data/recipe_catalog_loader.dart';
import '../features/recipes/data/static_recipe_content_updater.dart';
import '../data/local/planner_repository.dart';
import '../features/cooking/presentation/cooking_mode_screen.dart';
import '../localization/app_localizations.dart';
import 'app_dependencies.dart';
import 'planner_scope.dart';
import 'recipe_catalog_scope.dart';

class RecipePlannerApp extends StatefulWidget {
  const RecipePlannerApp({super.key, this.repository});
  final PlannerRepository? repository;

  @override
  State<RecipePlannerApp> createState() => _RecipePlannerAppState();
}

class _RecipePlannerAppState extends State<RecipePlannerApp> {
  final AppDependencies dependencies = AppDependencies();
  Locale _locale = const Locale('en');
  List<Recipe> _catalogRecipes = recipes;
  String _contentVersion = 'bundled';
  StaticRecipeContentUpdater? _contentUpdater;

  @override
  void initState() {
    super.initState();
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
        setState(() {});
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
    _contentUpdater?.close();
    dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          locale: _locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AppShell(
            locale: _locale,
            onLocaleChanged: (locale) => setState(() => _locale = locale),
          ),
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
                    icon: const Icon(Icons.language, size: 18),
                    label: Text(widget.locale.languageCode == 'en' ? 'العربية' : 'English'),
                  ),
                ),
              ),
            ),
            Expanded(
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
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty ? null : IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              icon: const Icon(Icons.close),
            ),
          ),
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
              style: const TextStyle(color: AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: RecipeSort.recommended, child: Text('Recommended')),
                DropdownMenuItem(value: RecipeSort.quickest, child: Text('Quickest')),
                DropdownMenuItem(value: RecipeSort.title, child: Text('A–Z')),
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
    final state = PlannerScope.of(context), day = PlanScreen.days[selectedDay];
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
          final name=PlanScreen.days[index], count=state.mealsFor(name).length;
          return Expanded(child:InkWell(borderRadius:BorderRadius.circular(14),onTap:()=>setState(()=>selectedDay=index),
            child:AnimatedContainer(duration:AppMotion.quick,padding:const EdgeInsets.symmetric(vertical:9),decoration:BoxDecoration(color:selectedDay==index?AppTheme.terracotta.withOpacity(.12):Colors.transparent,borderRadius:BorderRadius.circular(12)),
              child:Column(children:[Text(name.substring(0,1),style:TextStyle(color:selectedDay==index?AppTheme.terracotta:AppTheme.muted,fontSize:11,fontWeight:FontWeight.w800)),const SizedBox(height:5),Text('$count',style:TextStyle(color:selectedDay==index?AppTheme.terracotta:AppTheme.ink,fontWeight:FontWeight.w800))]))));
        }))),
      const SizedBox(height:18),
      Row(children:[Expanded(child:Text(day,style:Theme.of(context).textTheme.titleLarge)),Text('${meals.length}/4 planned',style:const TextStyle(color:AppTheme.muted,fontSize:12))]),
      const SizedBox(height:10),
      for(final slot in MealSlot.values)
        _MealSlotCard(key: ValueKey('meal-slot-$day-${slot.name}'), day:day,slot:slot,meal:meals.where((m)=>m.slot==slot).firstOrNull,
          onAdd:()=>_showPlanPicker(context,day,slot),onRemove:(){state.removeMeal(day,slot);PlannerScope.refresh(context);}),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:()=>_goTab(context,3),icon:const Icon(Icons.shopping_basket_outlined),label:const Text('Build your grocery list'),style:OutlinedButton.styleFrom(minimumSize:const Size(0,50))),
    ]);
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
                style: const TextStyle(color: AppTheme.muted),
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
                      trailing: const Icon(
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
  const _MealSlotCard({super.key, required this.day,required this.slot,required this.meal,required this.onAdd,required this.onRemove});
  final String day;final MealSlot slot;final PlannedMeal? meal;final VoidCallback onAdd,onRemove;
  @override Widget build(BuildContext context){
    final recipe=meal==null?null:RecipeCatalogScope.of(context).where((r)=>r.id==meal!.recipeId).firstOrNull;
    return Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppTheme.card,border:Border.all(color:AppTheme.line),borderRadius:BorderRadius.circular(16)),
      child:Row(children:[
        Container(width:40,height:40,decoration:BoxDecoration(color:AppTheme.olive.withOpacity(.12),borderRadius:BorderRadius.circular(12)),child:Icon(switch(slot){MealSlot.breakfast=>Icons.wb_twilight,MealSlot.lunch=>Icons.wb_sunny_outlined,MealSlot.dinner=>Icons.nightlight_outlined,MealSlot.snack=>Icons.cookie_outlined},color:AppTheme.olive)),
        const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(slot.label.toUpperCase(),style:const TextStyle(color:AppTheme.terracotta,fontSize:9,letterSpacing:1.1,fontWeight:FontWeight.w800)),const SizedBox(height:4),
          Text(recipe?.title??'Nothing planned yet',style:TextStyle(color:recipe==null?AppTheme.muted:AppTheme.ink,fontWeight:FontWeight.w700)),
          if(meal!=null)Text('${meal!.servings} servings · ${recipe?.minutes??0} min',style:const TextStyle(color:AppTheme.muted,fontSize:11)),
        ])),
        if(meal==null)IconButton(key:Key('add-${day}-${slot.name}'),tooltip:'Add ${slot.label}',onPressed:onAdd,icon:const Icon(Icons.add_circle_outline,color:AppTheme.terracotta))
        else IconButton(key:Key('remove-${day}-${slot.name}'),tooltip:'Remove ${slot.label}',onPressed:onRemove,icon:const Icon(Icons.close,color:AppTheme.muted)),
      ]));
  }
}


class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});
  @override Widget build(BuildContext context){
    final state=PlannerScope.of(context),entries=state.buildGroceryList(RecipeCatalogScope.of(context));
    final checked=entries.where((item)=>item.isChecked).length;
    return ListView(padding:const EdgeInsets.fromLTRB(20,20,20,28),children:[
      const Text('THE MARKET LIST',style:TextStyle(color:AppTheme.terracotta,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.5)),const SizedBox(height:8),
      const Text('Good things\\nto pick up.',style:TextStyle(fontFamily:'Georgia',fontSize:32,height:1.08,color:AppTheme.ink,fontWeight:FontWeight.bold)),const SizedBox(height:8),
      Text(entries.isEmpty?'Your planned meals will gather ingredients here.':'$checked of ${entries.length} items checked · ${entries.where((e)=>e.toBuyAmount>0||!e.isQuantified).length} to buy',style:const TextStyle(color:AppTheme.muted)),const SizedBox(height:18),
      if(entries.isEmpty)Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:AppTheme.card,borderRadius:BorderRadius.circular(18),border:Border.all(color:AppTheme.line)),child:const Column(children:[Icon(Icons.shopping_basket_outlined,size:36,color:AppTheme.olive),SizedBox(height:10),Text('Your list is waiting',style:TextStyle(fontWeight:FontWeight.w700,color:AppTheme.ink)),SizedBox(height:5),Text('Add meals to your weekly plan or add ingredients from a recipe.',textAlign:TextAlign.center,style:TextStyle(color:AppTheme.muted))]))
      else for(final item in entries)
        Container(
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
                      ? '${_formatAmount(item.amount)} ${item.unit} needed · ${_formatAmount(item.ownedAmount)} owned · ${_formatAmount(item.toBuyAmount)} to buy'
                      : 'Non-quantified · check pantry before shopping',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                  ),
                ],
              )),
              IconButton(
                tooltip: 'Edit grocery item',
                onPressed: () => _showGroceryEditor(context, item),
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.muted),
              ),
            ]),
          ),
        ),
      const SizedBox(height:22),
      Row(children:[Expanded(child:Text('Your pantry',style:Theme.of(context).textTheme.titleLarge)),TextButton.icon(onPressed:()=>_showPantryEditor(context),icon:const Icon(Icons.add,size:17),label:const Text('Add item'))]),
      const Text('Items here are deducted from what you need to buy.',style:TextStyle(color:AppTheme.muted,fontSize:12)),const SizedBox(height:10),
      if(state.pantry.isEmpty)const Text('Your pantry is empty for now.',style:TextStyle(color:AppTheme.muted))
      else for(final item in state.pantry.values)ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:4),leading:const Icon(Icons.inventory_2_outlined,color:AppTheme.olive),title:Text(item.name),subtitle:Text('${_formatAmount(item.amount)} ${item.unit}'),
        trailing:IconButton(tooltip:'Remove pantry item',onPressed:(){state.removePantryItem(item.id);PlannerScope.refresh(context);},icon:const Icon(Icons.close))),
    ]);
  }
  void _showGroceryEditor(BuildContext context, GroceryItem item) {
    final name = TextEditingController(text: item.name);
    final amount = TextEditingController(text: item.isQuantified ? _formatAmount(item.amount) : '');
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Edit grocery item'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Ingredient')),
        if (item.isQuantified) TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount (${item.unit})')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final parsed = item.isQuantified ? double.tryParse(amount.text.trim()) : item.amount;
          if (parsed == null || parsed < 0 || name.text.trim().isEmpty) return;
          PlannerScope.of(context).updateGroceryItem(item.key, name: name.text, amount: parsed);
          PlannerScope.refresh(context);
          Navigator.pop(dialogContext);
        }, child: const Text('Save')),
      ],
    )).then((_) { name.dispose(); amount.dispose(); });
  }

  void _showPantryEditor(BuildContext context){
    final name=TextEditingController(),amount=TextEditingController(text:'1'),unit=TextEditingController(text:'g');
    showDialog<void>(context:context,builder:(dialogContext)=>AlertDialog(title:const Text('Add to your pantry'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,decoration:const InputDecoration(labelText:'Ingredient')),TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Quantity')),TextField(controller:unit,decoration:const InputDecoration(labelText:'Unit (g, ml, whole…)')),
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Cancel')),FilledButton(onPressed:(){
      final value=double.tryParse(amount.text.trim());if(value==null||value<0||name.text.trim().isEmpty||unit.text.trim().isEmpty)return;
      PlannerScope.of(context).upsertPantryItem(name:name.text,amount:value,unit:unit.text);PlannerScope.refresh(context);Navigator.pop(dialogContext);
    },child:const Text('Save'))])).then((_){name.dispose();amount.dispose();unit.dispose();});
  }
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
        const Text('YOUR LITTLE COOKBOOK', style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text('Your kitchen,\nyour rhythm.', style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(children: [
          _StatCard(value: '${saved.length}', label: 'Saved recipes', icon: Icons.bookmark_outline),
          const SizedBox(width: 10),
          _StatCard(value: '${state.plannedMealCount}', label: 'Meals planned', icon: Icons.calendar_month_outlined),
        ]),
        const SizedBox(height: 24),
        Text('Your saved recipes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recipe library', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Content version: ${RecipeCatalogScope.versionOf(context)}', style: const TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 8),
              const Text('Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.', style: TextStyle(color: AppTheme.muted)),
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
                  icon: const Icon(Icons.sync),
                  label: const Text('Check for updates'),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
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
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Start cooking'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  minimumSize: const Size(0, 54),
                ),
              ),
            ),
            const SizedBox(height: 26),
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
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
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
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
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
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
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
        final count = state.mealsFor(names[index]).length;
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
