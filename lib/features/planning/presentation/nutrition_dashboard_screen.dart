import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() => _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  String get _dateKey => '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final catalog = RecipeCatalogScope.of(context);
    var calories = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0;
    final planned = <Recipe>[];
    final dateMeals = state.mealsFor(_dateKey);
    final weekdayNames = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = DateUtils.dateOnly(DateTime.now());
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final selectedWeekStart = _date.subtract(Duration(days: _date.weekday - 1));
    final isCurrentWeek = DateUtils.isSameDay(currentWeekStart, selectedWeekStart);
    final templateMeals = isCurrentWeek ? state.mealsFor(weekdayNames[_date.weekday - 1]) : const [];
    final mealsForSelectedDate = [
      ...templateMeals.where((template) => !dateMeals.any((dated) => dated.slot == template.slot)),
      ...dateMeals,
    ];
    for (final meal in mealsForSelectedDate) {
      final recipe = catalog.where((item) => item.id == meal.recipeId).firstOrNull;
      if (recipe == null) continue;
      final factor = meal.servings / (recipe.servings < 1 ? 1 : recipe.servings);
      calories += recipe.calories * factor;
      protein += recipe.proteinGrams * factor;
      carbs += recipe.carbsGrams * factor;
      fat += recipe.fatGrams * factor;
      planned.add(recipe);
    }
    const weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weekStart = _date.subtract(Duration(days: _date.weekday - 1));
    final weekCalories = List.generate(7, (index) => _caloriesForDate(state, catalog, weekStart.add(Duration(days: index))));
    final weeklyTotal = weekCalories.fold<double>(0, (sum, value) => sum + value);
    final strings = appStrings(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.label('Nutrition', 'التغذية')),
        actions: [
          IconButton(
            tooltip: strings.label('Set daily goals', 'تحديد الأهداف اليومية'),
            onPressed: () => _editGoals(context, state),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            Expanded(child: Text(strings.label('Planned nutrition', 'التغذية المخططة'), style: Theme.of(context).textTheme.titleLarge)),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (picked != null) setState(() => _date = DateUtils.dateOnly(picked));
              },
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(MaterialLocalizations.of(context).formatShortDate(_date)),
            ),
          ]),
          const SizedBox(height: 14),
          _goalCard(
            title: strings.label('Calories', 'السعرات الحرارية'),
            value: calories,
            target: state.dailyCalorieTarget.toDouble(),
            unit: 'kcal',
            icon: Icons.local_fire_department_outlined,
          ),
          const SizedBox(height: 10),
          _goalCard(title: strings.label('Protein', 'البروتين'), value: protein, target: state.dailyProteinTargetGrams, unit: 'g', icon: Icons.fitness_center),
          const SizedBox(height: 18),
          Text(strings.label('Macronutrients', 'المغذيات الكبرى'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _macroCard('Carbs', carbs, 'g')),
            const SizedBox(width: 8),
            Expanded(child: _macroCard('Protein', protein, 'g')),
            const SizedBox(width: 8),
            Expanded(child: _macroCard('Fat', fat, 'g')),
          ]),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: Text(strings.label('This week', 'هذا الأسبوع'), style: Theme.of(context).textTheme.titleLarge)),
            Text('${weeklyTotal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.terracotta)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (var index = 0; index < 7; index++)
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(children: [
                  Text(weekdayInitials[index], style: TextStyle(color: AppTheme.muted, fontSize: 10)),
                  const SizedBox(height: 5),
                  RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                      width: 44,
                      height: 7,
                      child: LinearProgressIndicator(
                        value: state.dailyCalorieTarget <= 0 ? 0 : (weekCalories[index] / state.dailyCalorieTarget).clamp(0.0, 1.0).toDouble(),
                        backgroundColor: AppTheme.line,
                        color: AppTheme.terracotta,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(weekCalories[index].round().toString(), style: const TextStyle(fontSize: 9)),
                ]),
              )),
          ]),
          const SizedBox(height: 22),
          Text(strings.label('Meals included', 'الوجبات المدرجة'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (planned.isEmpty)
            Text(strings.label('No meals planned for this date yet.', 'لا توجد وجبات مخططة لهذا التاريخ بعد.'), style: TextStyle(color: AppTheme.muted))
          else
            for (final recipe in planned)
              Card(child: ListTile(
                leading: Icon(Icons.restaurant_menu, color: AppTheme.olive),
                title: Text(recipe.title),
                subtitle: Text('${recipe.calories} kcal · ${recipe.totalMinutes} min'),
              )),
          const SizedBox(height: 18),
          Text(strings.label('Nutrition values are estimates based on recipe data and planned servings. Missing macro data is shown as zero; verify labels for dietary decisions.', 'القيم الغذائية تقديرية وتعتمد على بيانات الوصفة والحصص المخططة. تظهر بيانات المغذيات غير المتوفرة كصفر؛ تحقق من الملصقات لاتخاذ القرارات الغذائية.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        ],
      ),
    );
  }

  double _caloriesForDate(dynamic state, List<Recipe> catalog, DateTime date) {
    final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final datedMeals = state.mealsFor(key);
    final weekdays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = DateUtils.dateOnly(DateTime.now());
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final selectedWeekStart = date.subtract(Duration(days: date.weekday - 1));
    final isCurrentWeek = DateUtils.isSameDay(currentWeekStart, selectedWeekStart);
    final templateMeals = isCurrentWeek ? state.mealsFor(weekdays[date.weekday - 1]) : const [];
    final meals = [
      ...templateMeals.where((template) => !datedMeals.any((dated) => dated.slot == template.slot)),
      ...datedMeals,
    ];
    var total = 0.0;
    for (final meal in meals) {
      final recipe = catalog.where((item) => item.id == meal.recipeId).firstOrNull;
      if (recipe == null) continue;
      total += recipe.calories * meal.servings / (recipe.servings < 1 ? 1 : recipe.servings);
    }
    return total;
  }

  Widget _goalCard({required String title, required double value, required double target, required String unit, required IconData icon}) {
    final progress = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppTheme.terracotta),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text('${value.round()} / ${target.round()} $unit', style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 9, color: AppTheme.terracotta, backgroundColor: AppTheme.line)),
        ]),
      ),
    );
  }

  Widget _macroCard(String label, double value, String unit) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
      const SizedBox(height: 5),
      Text('${value.round()} $unit', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    ]),
  );

  Future<void> _editGoals(BuildContext context, dynamic state) async {
    final calories = TextEditingController(text: '${state.dailyCalorieTarget}');
    final protein = TextEditingController(text: '${state.dailyProteinTargetGrams.round()}');
    final saved = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.olive.withOpacity(.12), borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.monitor_heart_outlined, color: AppTheme.olive)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appStrings(sheetContext).label('Daily nutrition goals', 'الأهداف الغذائية اليومية'), style: Theme.of(sheetContext).textTheme.titleLarge),
              Text(appStrings(sheetContext).label('Adjust your daily targets.', 'اضبط أهدافك اليومية.'), style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
            ])),
          ]),
          const SizedBox(height: 16),
          TextField(controller: calories, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories (kcal)', prefixIcon: Icon(Icons.local_fire_department_outlined))),
          const SizedBox(height: 10),
          TextField(controller: protein, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Protein (g)', prefixIcon: Icon(Icons.fitness_center_outlined))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, false), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Save goals', 'حفظ الأهداف')))),
          ]),
        ]),
      ),
    );
    if (saved == true && context.mounted) {
      final calorieValue = int.tryParse(calories.text.trim());
      final proteinValue = double.tryParse(protein.text.trim());
      if (calorieValue != null && calorieValue > 0) state.dailyCalorieTarget = calorieValue;
      if (proteinValue != null && proteinValue > 0) state.dailyProteinTargetGrams = proteinValue;
      PlannerScope.refresh(context);
    }
    calories.dispose();
    protein.dispose();
  }
}
