import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/notifications/domain/reminder_series.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/app/app_tab_navigation.dart';
import 'package:testapp_3/features/planning/presentation/meal_calendar_screen.dart';
import 'package:testapp_3/features/planning/presentation/nutrition_dashboard_screen.dart';

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
      const SizedBox(height:16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('schedule-recipe-from-plan'),
          onPressed: () => _showSchedulePicker(context),
          icon: const Icon(Icons.event_available_outlined),
          label: Text(appStrings(context).label('Schedule a recipe', 'جدولة وصفة')),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta, minimumSize: const Size(0, 50)),
        ),
      ),
      const SizedBox(height:12),
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          key: const Key('open-meal-calendar'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealCalendarScreen())),
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(appStrings(context).label('Calendar', 'التقويم')),
        )),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(
          key: const Key('open-nutrition-dashboard'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionDashboardScreen())),
          icon: const Icon(Icons.monitor_heart_outlined),
          label: Text(appStrings(context).label('Nutrition', 'التغذية')),
        )),
      ]),
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
      Row(children: [Expanded(child: Text(appStrings(context).weekday(day), style: Theme.of(context).textTheme.titleLarge)), Text(appStrings(context).label('${meals.length}/4 planned', 'تم التخطيط لـ ${meals.length}/4'), style: TextStyle(color: AppTheme.muted, fontSize: 12))]),
      const SizedBox(height:10),
      for(final slot in MealSlot.values)
        _MealSlotCard(key: ValueKey('meal-slot-$day-${slot.name}'), day:day,slot:slot,meal:meals.where((m)=>m.slot==slot).firstOrNull,
          onAdd:()=>_showPlanPicker(context,day,slot),onRemove:(){state.removeMeal(day,slot);PlannerScope.refresh(context);},onMove:()=>_showMoveMeal(context,day,slot)),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:()=>goToAppTab(context,3),icon:Icon(Icons.shopping_basket_outlined),label:Text(appStrings(context).label('Build your grocery list', 'أنشئ قائمة مشترياتك')),style:OutlinedButton.styleFrom(minimumSize:const Size(0,50))),
      const SizedBox(height:28),
      Row(children: [
        Expanded(child: Text(appStrings(context).label('Upcoming scheduled meals', 'الوجبات المجدولة القادمة'), style: Theme.of(context).textTheme.titleLarge)),
        Text(appStrings(context).label('Next 3 months', 'الأشهر الثلاثة القادمة'), style: TextStyle(color: AppTheme.muted, fontSize: 11)),
      ]),
      const SizedBox(height:10),
      ..._buildUpcomingMealWidgets(context, state),
    ]);
  }
  Future<void> _showSchedulePicker(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    Recipe? selectedRecipe;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PlanRecipePicker(
        day: _dateKey(today),
        slot: MealSlot.dinner,
        onSelected: (recipe) => selectedRecipe = recipe,
      ),
    );
    if (selectedRecipe != null && context.mounted) {
      await showRecipeScheduleDialog(context, selectedRecipe!, selectedRecipe!.servings);
    }
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
            items: days.map((day) => DropdownMenuItem(value: day, child: Text(appStrings(context).weekday(day)))).toList(),
            onChanged: (value) => setDialogState(() => targetDay = value ?? fromDay)),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealSlot>(value: targetSlot, decoration: InputDecoration(labelText: appStrings(context).label('Meal', 'الوجبة')),
            items: MealSlot.values.map((slot) => DropdownMenuItem(value: slot, child: Text(appStrings(context).mealSlot(slot.name)))).toList(),
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
      useSafeArea: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PlanRecipePicker(
        day: day,
        slot: slot,
        onSelected: (recipe) {
          PlannerScope.of(context).assignMeal(day: day, slot: slot, recipeId: recipe.id, servings: recipe.servings);
          PlannerScope.refresh(context);
        },
      ),
    );
  }
}
String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime _addCalendarMonths(DateTime date, int months) {
  final firstOfTarget = DateTime(date.year, date.month + months, 1);
  final lastDay = DateTime(firstOfTarget.year, firstOfTarget.month + 1, 0).day;
  return DateTime(firstOfTarget.year, firstOfTarget.month, date.day.clamp(1, lastDay).toInt());
}

List<DateTime> _scheduledDates({
  required DateTime start,
  required DateTime end,
  required String frequency,
  required int weekday,
  required int monthDay,
}) {
  if (frequency == 'once') return [start];
  final dates = <DateTime>[];
  if (frequency == 'weekly') {
    for (var date = start; !date.isAfter(end); date = date.add(const Duration(days: 1))) {
      if (date.weekday == weekday) dates.add(date);
    }
    return dates;
  }
  var month = DateTime(start.year, start.month, 1);
  final finalMonth = DateTime(end.year, end.month, 1);
  while (!month.isAfter(finalMonth)) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    if (monthDay <= lastDay) {
      final date = DateTime(month.year, month.month, monthDay);
      if (!date.isBefore(start) && !date.isAfter(end)) dates.add(date);
    }
    month = DateTime(month.year, month.month + 1, 1);
  }
  return dates;
}

List<Widget> _buildUpcomingMealWidgets(BuildContext context, PlannerState state) {
  final today = DateUtils.dateOnly(DateTime.now());
  final end = _addCalendarMonths(today, 3);
  final entries = state.mealPlan.entries
      .map((entry) => (date: DateTime.tryParse(entry.key), meals: entry.value.values.toList()))
      .where((entry) => entry.date != null && !entry.date!.isBefore(today) && !entry.date!.isAfter(end))
      .toList()
    ..sort((a, b) => a.date!.compareTo(b.date!));
  if (entries.isEmpty) {
    return [
      Text(
        appStrings(context).label('No future dates scheduled yet. Choose a recipe to plan one.', 'لا توجد مواعيد مستقبلية بعد. اختر وصفة لتخطيط موعد.'),
        style: TextStyle(color: AppTheme.muted),
      ),
    ];
  }
  final catalog = RecipeCatalogScope.of(context);
  return [
    for (final entry in entries)
      Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppTheme.card, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            MaterialLocalizations.of(context).formatMediumDate(entry.date!),
            style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          for (final meal in entry.meals)
            Row(children: [
              Expanded(child: Text(
                '${appStrings(context).mealSlot(meal.slot.name)} · ${catalog.where((recipe) => recipe.id == meal.recipeId).firstOrNull?.title ?? appStrings(context).label('Recipe', 'وصفة')}',
                style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w600),
              )),
              IconButton(
                key: Key('remove-scheduled-${_dateKey(entry.date!)}-${meal.slot.name}'),
                tooltip: appStrings(context).label('Remove scheduled meal', 'إزالة الوجبة المجدولة'),
                onPressed: () {
                  state.removeMeal(_dateKey(entry.date!), meal.slot);
                  PlannerScope.refresh(context);
                },
                icon: const Icon(Icons.close, size: 18),
              ),
            ]),
        ]),
      ),
  ];
}

Future<void> showRecipeScheduleDialog(BuildContext context, Recipe recipe, int servings) async {
  final today = DateUtils.dateOnly(DateTime.now());
  final lastAllowedDate = _addCalendarMonths(today, 3);
  var startDate = today;
  var frequency = 'once';
  var slot = MealSlot.dinner;
  var weekday = today.weekday;
  var monthDay = today.day;
  var reminderEnabled = false;
  var reminderOffset = ReminderOffset.previousDay;
  var reminderTime = const TimeOfDay(hour: 19, minute: 0);
  const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(appStrings(context).label('Plan ${recipe.title}', 'خطط لـ ${recipe.title}')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(appStrings(context).label('Start date', 'تاريخ البدء')),
              subtitle: Text(MaterialLocalizations.of(context).formatMediumDate(startDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: dialogContext,
                  initialDate: startDate,
                  firstDate: today,
                  lastDate: lastAllowedDate,
                );
                if (picked != null) setDialogState(() {
                  startDate = DateUtils.dateOnly(picked);
                  weekday = startDate.weekday;
                  monthDay = startDate.day;
                });
              },
            ),
            DropdownButtonFormField<MealSlot>(
              value: slot,
              decoration: InputDecoration(labelText: appStrings(context).label('Meal', 'الوجبة')),
              items: MealSlot.values.map((value) => DropdownMenuItem(value: value, child: Text(appStrings(context).mealSlot(value.name)))).toList(),
              onChanged: (value) => setDialogState(() => slot = value ?? slot),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: frequency,
              decoration: InputDecoration(labelText: appStrings(context).label('Repeat', 'التكرار')),
              items: [
                DropdownMenuItem(value: 'once', child: Text(appStrings(context).label('Just once', 'مرة واحدة'))),
                DropdownMenuItem(value: 'weekly', child: Text(appStrings(context).label('Every week', 'كل أسبوع'))),
                DropdownMenuItem(value: 'monthly', child: Text(appStrings(context).label('Every month', 'كل شهر'))),
              ],
              onChanged: (value) => setDialogState(() => frequency = value ?? 'once'),
            ),
            if (frequency == 'weekly') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: weekday,
                decoration: InputDecoration(labelText: appStrings(context).label('Every', 'كل يوم')),
                items: List.generate(7, (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text(appStrings(context).weekday(weekdays[index])),
                )),
                onChanged: (value) => setDialogState(() => weekday = value ?? weekday),
              ),
            ],
            if (frequency == 'monthly') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: monthDay,
                decoration: InputDecoration(labelText: appStrings(context).label('Day of each month', 'يوم من كل شهر')),
                items: List.generate(31, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}'))),
                onChanged: (value) => setDialogState(() => monthDay = value ?? monthDay),
              ),
              const SizedBox(height: 4),
              Text(appStrings(context).label('Months without this date are skipped.', 'يتم تخطي الأشهر التي لا تحتوي على هذا التاريخ.'), style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            ],
            const Divider(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(appStrings(context).label('Reminder', 'تذكير')),
              subtitle: Text(appStrings(context).label('Notify me before this planned recipe.', 'أرسل لي إشعارًا قبل موعد الوصفة.')),
              value: reminderEnabled,
              onChanged: (value) => setDialogState(() => reminderEnabled = value),
            ),
            if (reminderEnabled) ...[
              DropdownButtonFormField<ReminderOffset>(
                value: reminderOffset,
                decoration: InputDecoration(labelText: appStrings(context).label('Remind me', 'ذكرني')),
                items: [
                  DropdownMenuItem(value: ReminderOffset.sameDay, child: Text(appStrings(context).label('Same day', 'في نفس اليوم'))),
                  DropdownMenuItem(value: ReminderOffset.previousDay, child: Text(appStrings(context).label('Previous day', 'في اليوم السابق'))),
                ],
                onChanged: (value) => setDialogState(() => reminderOffset = value ?? reminderOffset),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(appStrings(context).label('Notification time', 'وقت الإشعار')),
                subtitle: Text(reminderTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(context: dialogContext, initialTime: reminderTime);
                  if (picked != null) setDialogState(() => reminderTime = picked);
                },
              ),
            ],
            const SizedBox(height: 8),
            Text(
              appStrings(context).label('Plans can be scheduled from today through ${MaterialLocalizations.of(context).formatMediumDate(lastAllowedDate)}. Past dates are unavailable.', 'يمكن جدولة الخطط من اليوم حتى ${MaterialLocalizations.of(context).formatMediumDate(lastAllowedDate)}. التواريخ السابقة غير متاحة.'),
              style: TextStyle(color: AppTheme.muted, fontSize: 11),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
          FilledButton(
            key: const Key('confirm-recipe-schedule'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(appStrings(context).label('Add to plan', 'إضافة إلى الخطة')),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final dates = _scheduledDates(
    start: startDate,
    end: lastAllowedDate,
    frequency: frequency,
    weekday: weekday,
    monthDay: monthDay,
  );
  final state = PlannerScope.of(context);
  var added = 0;
  for (final date in dates) {
    final key = _dateKey(date);
    if (state.mealsFor(key).any((meal) => meal.slot == slot)) continue;
    state.assignMeal(day: key, slot: slot, recipeId: recipe.id, servings: servings);
    added++;
  }
  if (added > 0 && reminderEnabled) {
    final series = ReminderSeries(
      id: 'recipe:${recipe.id}:${DateTime.now().microsecondsSinceEpoch}',
      sourceType: ReminderType.recipe,
      sourceId: recipe.id,
      title: recipe.title,
      description: appStrings(context).label('Your planned recipe is coming up.', 'اقترب موعد وصفتك المخططة.'),
      startDate: startDate,
      recurrence: switch (frequency) {
        'weekly' => ReminderRecurrence.weekly,
        'monthly' => ReminderRecurrence.monthly,
        _ => ReminderRecurrence.once,
      },
      offset: reminderOffset,
      hour: reminderTime.hour,
      minute: reminderTime.minute,
      isEnabled: true,
      createdAt: DateTime.now(),
      weekday: frequency == 'weekly' ? weekday : null,
      monthDay: frequency == 'monthly' ? monthDay : null,
    );
    state.saveReminderSeries(series);
  }
  if (added > 0) PlannerScope.refresh(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(added == 0
      ? appStrings(context).label('Those meal slots are already planned.', 'هذه الوجبات مخططة بالفعل.')
      : appStrings(context).label('Added ${added} date(s) to your plan.', 'تمت إضافة ${added} موعد إلى خطتك.')),
  ));
}

class _PlanRecipePicker extends StatefulWidget {
  const _PlanRecipePicker({required this.day, required this.slot, required this.onSelected});
  final String day;
  final MealSlot slot;
  final ValueChanged<Recipe> onSelected;
  @override
  State<_PlanRecipePicker> createState() => _PlanRecipePickerState();
}

class _PlanRecipePickerState extends State<_PlanRecipePicker> {
  final TextEditingController _search = TextEditingController();
  String _category = 'all', _difficulty = 'all', _foodType = 'all', _cuisine = 'all';
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final catalog = RecipeCatalogScope.of(context);
    final filtered = RecipeCatalog.search(catalog, query: _search.text, categoryId: _category,
      cuisineId: _cuisine, difficulty: _difficulty,
      allergies: PlannerScope.of(context).allergies,
      foodType: _foodType == 'all' ? null : FoodType.values.firstWhere((value) => value.name == _foodType));
    final categories = ['all', 'breakfast', 'lunch', 'dinner', 'snacks'];
    final activeFilters = (_difficulty != 'all' ? 1 : 0) + (_foodType != 'all' ? 1 : 0) + (_cuisine != 'all' ? 1 : 0);
    return SizedBox(
      height: MediaQuery.of(context).size.height * .88,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text(appStrings(context).label('Choose a recipe', 'اختر وصفة'), style: Theme.of(context).textTheme.headlineMedium)),
            Text('${filtered.length} ${appStrings(context).label('recipes', 'وصفات')}', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text('${appStrings(context).weekday(widget.day)} · ${appStrings(context).mealSlot(widget.slot.name)}', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 14),
          TextField(
            key: const Key('plan-recipe-search'), controller: _search, onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: appStrings(context).label('Search recipes or ingredients', 'ابحث عن وصفات أو مكونات'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty ? null : IconButton(
                tooltip: appStrings(context).label('Clear search', 'مسح البحث'),
                onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close)),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            for (final category in categories)
              Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: ChoiceChip(
                label: Text(category == 'all' ? appStrings(context).label('All', 'الكل') : appStrings(context).category(category, category == 'snacks' ? 'Snacks' : category[0].toUpperCase() + category.substring(1))),
                selected: _category == category, onSelected: (_) => setState(() => _category = category),
                selectedColor: AppTheme.terracotta.withOpacity(.16),
                side: BorderSide(color: _category == category ? AppTheme.terracotta : AppTheme.line),
              )),
          ])),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero, childrenPadding: const EdgeInsets.only(bottom: 8),
            leading: Icon(Icons.tune, color: AppTheme.olive),
            title: Text(appStrings(context).label('Filters', 'الفلاتر')),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (activeFilters > 0) Text('$activeFilters active', style: TextStyle(color: AppTheme.terracotta, fontSize: 11)),
              const Icon(Icons.expand_more),
            ]),
            children: [
              Align(alignment: AlignmentDirectional.centerStart, child: Text(appStrings(context).label('Cuisine', 'نوع المطبخ'), style: Theme.of(context).textTheme.titleSmall)),
              Wrap(spacing: 7, children: [
                for (final option in const [('all','All'),('indian','Indian'),('italian','Italian'),('chinese','Chinese'),('mexican','Mexican'),('korean','Korean'),('american','American'),('thai','Thai'),('japanese','Japanese')])
                  ChoiceChip(label: Text(option.$2), selected: _cuisine == option.$1, onSelected: (_) => setState(() => _cuisine = option.$1)),
              ]),
              const SizedBox(height: 8),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(appStrings(context).label('Food type', 'نوع الطعام'), style: Theme.of(context).textTheme.titleSmall)),
              Wrap(spacing: 7, children: [
                for (final option in const [('all','All'),('vegetarian','Vegetarian'),('vegan','Vegan'),('eggetarian','Eggetarian'),('nonVegetarian','Non-vegetarian'),('pescatarian','Pescatarian')])
                  ChoiceChip(label: Text(option.$2), selected: _foodType == option.$1, onSelected: (_) => setState(() => _foodType = option.$1)),
              ]),
              const SizedBox(height: 8),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(appStrings(context).label('Difficulty', 'مستوى الصعوبة'), style: Theme.of(context).textTheme.titleSmall)),
              Wrap(spacing: 7, children: [
                for (final option in const [('all','Any'),('easy','Easy'),('medium','Medium'),('hard','Hard')])
                  ChoiceChip(label: Text(option.$2), selected: _difficulty == option.$1, onSelected: (_) => setState(() => _difficulty = option.$1)),
              ]),
              Align(alignment: AlignmentDirectional.centerEnd, child: TextButton(
                onPressed: () => setState(() { _cuisine = 'all'; _foodType = 'all'; _difficulty = 'all'; }),
                child: Text(appStrings(context).label('Clear filters', 'مسح الفلاتر')))),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(child: filtered.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off_rounded, size: 38, color: AppTheme.olive), const SizedBox(height: 8),
                Text(appStrings(context).label('No recipes found', 'لم يتم العثور على وصفات'), style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                Text(appStrings(context).label('Try another search or adjust your filters.', 'جرّب بحثًا آخر أو غيّر الفلاتر.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
              ]))
            : ListView.separated(
                key: const Key('plan-recipe-picker-list'),
                itemCount: filtered.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  return Material(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      key: Key('plan-select-recipe-${recipe.id}'), borderRadius: BorderRadius.circular(15),
                      onTap: () { widget.onSelected(recipe); Navigator.pop(context); },
                      child: Padding(padding: const EdgeInsets.all(9), child: Row(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(11), child: CachedNetworkImage(
                          imageUrl: recipe.image, width: 82, height: 82, fit: BoxFit.cover,
                          placeholder: (_, __) => Container(width: 82, height: 82, color: AppTheme.line, child: const Icon(Icons.restaurant)),
                          errorWidget: (_, __, ___) => Container(width: 82, height: 82, color: AppTheme.line, child: const Icon(Icons.restaurant)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 5),
                          Text(recipe.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                          const SizedBox(height: 7),
                          Wrap(spacing: 9, children: [
                            Text('${recipe.minutes} min', style: TextStyle(color: AppTheme.terracotta, fontSize: 11, fontWeight: FontWeight.w700)),
                            Text(recipe.difficulty, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                            Text('${recipe.servings} servings', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                          ]),
                        ])),
                        const Icon(Icons.add_circle_outline, color: AppTheme.terracotta),
                      ])),
                    ),
                  );
                },
              )),
        ]),
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
          Text(appStrings(context).mealSlot(slot.name).toUpperCase(),style:TextStyle(color:AppTheme.terracotta,fontSize:9,letterSpacing:1.1,fontWeight:FontWeight.w800)),const SizedBox(height:4),
          Text(recipe?.title??appStrings(context).label('Nothing planned yet', 'لا توجد وجبة مخططة بعد'),style:TextStyle(color:recipe==null?AppTheme.muted:AppTheme.ink,fontWeight:FontWeight.w700)),
          if(meal!=null)Text(appStrings(context).label('${meal!.servings} servings · ${recipe?.minutes??0} min', '${meal!.servings} حصص · ${recipe?.minutes??0} دقيقة'),style:TextStyle(color:AppTheme.muted,fontSize:11)),
        ])),
        if(meal==null)IconButton(key:Key('add-${day}-${slot.name}'),tooltip:appStrings(context).label('Add ${slot.label}', 'إضافة ${appStrings(context).mealSlot(slot.name)}'),onPressed:onAdd,icon:Icon(Icons.add_circle_outline,color:AppTheme.terracotta))
        else Row(mainAxisSize:MainAxisSize.min,children:[
          IconButton(tooltip:appStrings(context).label('Move meal', 'نقل الوجبة'),onPressed:onMove,icon:Icon(Icons.drive_file_move_outline,color:AppTheme.olive)),
          IconButton(key:Key('remove-${day}-${slot.name}'),tooltip:appStrings(context).label('Remove ${slot.label}', 'إزالة ${appStrings(context).mealSlot(slot.name)}'),onPressed:onRemove,icon:Icon(Icons.close,color:AppTheme.muted)),
        ]),
      ]));
  }
}
