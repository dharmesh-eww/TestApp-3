import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class MealCalendarScreen extends StatefulWidget {
  const MealCalendarScreen({super.key});

  @override
  State<MealCalendarScreen> createState() => _MealCalendarScreenState();
}

class _MealCalendarScreenState extends State<MealCalendarScreen> {
  DateTime _month = DateUtils.dateOnly(DateTime.now());
  late DateTime _selected = DateUtils.dateOnly(DateTime.now());

  String _key(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final catalog = RecipeCatalogScope.of(context);
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final offset = first.weekday - 1;
    final lastMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final maxMonth = DateTime(DateTime.now().year, DateTime.now().month + 3, 1);
    final selectedKey = _key(_selected);
    final meals = state.mealsFor(selectedKey);
    final prepIngredients = <String, String>{};
    for (final meal in meals) {
      final recipe = catalog.where((item) => item.id == meal.recipeId).firstOrNull;
      if (recipe == null) continue;
      for (final ingredient in recipe.ingredients) {
        prepIngredients.putIfAbsent(ingredient.name, () => ingredient.display(meal.servings, recipe.servings));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Meal calendar', 'تقويم الوجبات'))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(children: [
            IconButton(
              tooltip: appStrings(context).label('Previous month', 'الشهر السابق'),
              onPressed: DateTime(_month.year, _month.month, 1).isAfter(lastMonth) ? () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(child: Text(MaterialLocalizations.of(context).formatMonthYear(_month), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
            IconButton(
              tooltip: appStrings(context).label('Next month', 'الشهر التالي'),
              onPressed: DateTime(_month.year, _month.month, 1).isBefore(maxMonth) ? () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(child: Center(child: Text(day, style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)))),
          ]),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: offset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 5),
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();
              final date = DateTime(_month.year, _month.month, index - offset + 1);
              final key = _key(date);
              final count = state.mealsFor(key).length;
              final isSelected = DateUtils.isSameDay(date, _selected);
              final isPast = date.isBefore(DateUtils.dateOnly(DateTime.now()));
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isPast ? null : () => setState(() => _selected = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.terracotta.withOpacity(.14) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.terracotta : AppTheme.line),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${date.day}', style: TextStyle(color: isPast ? AppTheme.muted.withOpacity(.45) : AppTheme.ink, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
                    const SizedBox(height: 3),
                    if (count > 0) Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppTheme.olive, shape: BoxShape.circle)),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: Text(MaterialLocalizations.of(context).formatMediumDate(_selected), style: Theme.of(context).textTheme.titleLarge)),
            Text('${meals.length}/4', style: TextStyle(color: AppTheme.muted)),
          ]),
          const SizedBox(height: 10),
          for (final slot in MealSlot.values)
            Card(
              child: ListTile(
                leading: Icon(_icon(slot), color: AppTheme.olive),
                title: Text(appStrings(context).mealSlot(slot.name)),
                subtitle: Text(meals.where((item) => item.slot == slot).map((meal) => catalog.where((r) => r.id == meal.recipeId).firstOrNull?.title ?? 'Recipe').firstOrNull ?? appStrings(context).label('Nothing planned', 'لا توجد وجبة مخططة')),
                trailing: meals.any((item) => item.slot == slot)
                    ? IconButton(
                        tooltip: appStrings(context).label('Remove meal', 'إزالة الوجبة'),
                        onPressed: () { state.removeMeal(selectedKey, slot); PlannerScope.refresh(context); },
                        icon: const Icon(Icons.close),
                      )
                    : IconButton(
                        tooltip: appStrings(context).label('Add meal', 'إضافة وجبة'),
                        onPressed: () => _chooseRecipe(context, selectedKey, slot),
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.terracotta),
                      ),
              ),
            ),
          const SizedBox(height: 18),
          Text(appStrings(context).label('Prep ahead', 'التحضير المسبق'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(appStrings(context).label('Tick ingredients you have washed, chopped or portioned for this day.', 'حدد المكونات التي غسلتها أو قطعتها أو جهزتها لهذا اليوم.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          const SizedBox(height: 8),
          if (prepIngredients.isEmpty)
            Text(appStrings(context).label('Add meals to build a prep checklist.', 'أضف وجبات لإنشاء قائمة التحضير.'), style: TextStyle(color: AppTheme.muted))
          else
            for (final entry in prepIngredients.entries)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: state.isMealPrepDone(selectedKey, entry.key),
                title: Text(entry.key),
                subtitle: Text(entry.value),
                onChanged: (value) {
                  state.setMealPrepDone(selectedKey, entry.key, value ?? false);
                  PlannerScope.refresh(context);
                },
              ),
        ],
      ),
    );
  }

  IconData _icon(MealSlot slot) => switch (slot) {
    MealSlot.breakfast => Icons.wb_twilight,
    MealSlot.lunch => Icons.wb_sunny_outlined,
    MealSlot.dinner => Icons.nightlight_outlined,
    MealSlot.snack => Icons.cookie_outlined,
  };

  Future<void> _chooseRecipe(BuildContext context, String day, MealSlot slot) async {
    final recipes = RecipeCatalogScope.of(context);
    final selected = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .75,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(appStrings(context).label('Choose a recipe', 'اختر وصفة'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final recipe in recipes)
                ListTile(
                  title: Text(recipe.title),
                  subtitle: Text('${recipe.totalMinutes} min · ${recipe.servings} servings'),
                  trailing: const Icon(Icons.add),
                  onTap: () => Navigator.pop(sheetContext, recipe),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    PlannerScope.of(context).assignMeal(day: day, slot: slot, recipeId: selected.id, servings: selected.servings);
    PlannerScope.refresh(context);
  }
}
