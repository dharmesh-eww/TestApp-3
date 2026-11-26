import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/groceries/presentation/grocery_lists_screen.dart';
import 'package:testapp_3/app/gather_visuals.dart';
import 'package:testapp_3/features/cooking/domain/cooking_assist_service.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});
  @override State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool _groupByStore = false;
  String _pantryQuery = '';
  bool _expiringFirst = false;
  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final entries = state.buildGroceryList(RecipeCatalogScope.of(context));
    final checked = entries.where((item) => item.isChecked).length;
    final remaining = entries.length - checked;
    final grouped = <String, List<GroceryItem>>{};
    for (final item in entries) {
      final group = _groupByStore
          ? (state.groceryStores[item.key]?.trim().isNotEmpty == true
              ? state.groceryStores[item.key]!
              : 'No store assigned')
          : _groceryAisle(item.name);
      grouped.putIfAbsent(group, () => []).add(item);
    }
    final estimatedTotal = entries.fold<double>(
      0, (sum, item) => sum + (state.groceryPrices[item.key] ?? 0),
    );
    final pantryItems = state.pantry.values.where((item) => item.name.toLowerCase().contains(_pantryQuery.toLowerCase())).toList()
      ..sort((a, b) {
        if (_expiringFirst) {
          final aDate = state.pantryExpiryDates[a.id] ?? DateTime(9999);
          final bDate = state.pantryExpiryDates[b.id] ?? DateTime(9999);
          final byExpiry = aDate.compareTo(bDate);
          if (byExpiry != 0) return byExpiry;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final budget = state.groceryBudget;
    final overBudget = budget != null && estimatedTotal > budget;
    final progress = entries.isEmpty ? 0.0 : checked / entries.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Text(
          appStrings(context).label('THE MARKET LIST', 'قائمة المشتريات'),
          style: TextStyle(color: AppTheme.terracotta, fontSize: 10,
            fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text(
            appStrings(context).label('A little plan.\\nA smoother shop.', 'خطة صغيرة.\\nوتسوق أسهل.'),
            style: TextStyle(fontFamily: 'Georgia', fontSize: 30,
              height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold),
          )),
          GatherVisuals.foodMotion(size: 76),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('schedule-shopping-reminder'),
          onPressed: () => _scheduleShoppingReminder(context),
          icon: const Icon(Icons.notifications_active_outlined),
          label: Text(appStrings(context).label('Schedule shopping reminder', 'جدولة تذكير التسوق')),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(
                appStrings(context).label('Shopping progress', 'تقدم التسوق'),
                style: TextStyle(color: Colors.white70, fontSize: 12),
              )),
              Text('$checked / ${entries.length}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress, minHeight: 8,
                backgroundColor: Colors.white24, color: AppTheme.olive,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entries.isEmpty
                  ? appStrings(context).label('Your next shop starts here.', 'تبدأ رحلة التسوق التالية من هنا.')
                  : appStrings(context).label('$remaining items left to pick up', 'تبقى $remaining عناصر للشراء'),
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _GroceryMetric(
            icon: Icons.shopping_basket_outlined,
            label: appStrings(context).label('To buy', 'للشراء'),
            value: '$remaining',
          )),
          const SizedBox(width: 10),
          Expanded(child: _GroceryMetric(
            icon: Icons.payments_outlined,
            label: appStrings(context).label('Estimated', 'تقديري'),
            value: estimatedTotal.toStringAsFixed(2),
            alert: overBudget,
          )),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appStrings(context).label('LIST TOOLS', 'أدوات القائمة'),
              style: TextStyle(color: AppTheme.muted, fontSize: 10,
                fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _GroceryAction(
                icon: Icons.add_rounded,
                title: appStrings(context).label('Add item', 'إضافة عنصر'),
                onTap: () => _showCustomGroceryEditor(context),
                key: const Key('add-custom-grocery-item'),
              )),
              const SizedBox(width: 8),
              Expanded(child: _GroceryAction(
                icon: Icons.list_alt_rounded,
                title: appStrings(context).label('My lists', 'قوائمي'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroceryListsScreen())),
              )),
              const SizedBox(width: 8),
              Expanded(child: _GroceryAction(
                icon: Icons.copy_rounded,
                title: appStrings(context).label('Copy', 'نسخ'),
                onTap: () => _copyList(context, entries),
              )),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => setState(() => _groupByStore = !_groupByStore),
                icon: Icon(Icons.storefront_outlined, size: 17),
                label: Text(_groupByStore
                  ? appStrings(context).label('Grouped by store', 'حسب المتجر')
                  : appStrings(context).label('Group by store', 'التجميع حسب المتجر')),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _editBudget(context),
                icon: Icon(Icons.account_balance_wallet_outlined, size: 17),
                label: Text(appStrings(context).label('Set budget', 'تحديد الميزانية')),
              )),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        if (budget != null)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: overBudget ? const Color(0xFFFFE9E4) : AppTheme.olive.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Icon(overBudget ? Icons.warning_amber_rounded : Icons.savings_outlined,
                color: overBudget ? AppTheme.terracotta : AppTheme.olive),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(appStrings(context).label('Shopping budget', 'ميزانية التسوق'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                Text(
                  appStrings(context).label(
                    '${estimatedTotal.toStringAsFixed(2)} spent of ${budget.toStringAsFixed(2)}',
                    '${estimatedTotal.toStringAsFixed(2)} من ${budget.toStringAsFixed(2)}',
                  ),
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ])),
              TextButton(onPressed: () => _editBudget(context),
                child: Text(appStrings(context).label('Edit', 'تعديل'))),
            ]),
          ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Text(appStrings(context).label('Shopping list', 'قائمة التسوق'),
            style: Theme.of(context).textTheme.titleLarge)),
          TextButton(
            onPressed: () => setState(() => _groupByStore = !_groupByStore),
            child: Text(_groupByStore
              ? appStrings(context).label('By aisle', 'حسب القسم')
              : appStrings(context).label('By store', 'حسب المتجر')),
          ),
        ]),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: AppTheme.card,
              borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
            child: Column(children: [
              GatherVisuals.emptyBasketMotion(width: 180, height: 142),
              const SizedBox(height: 10),
              Text(appStrings(context).label('Your list is waiting', 'قائمتك بانتظارك'),
                style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
              const SizedBox(height: 5),
              Text(appStrings(context).label(
                'Add ingredients from a recipe or create your own shopping item.',
                'أضف مكونات من وصفة أو أنشئ عنصر تسوق جديدًا.'),
                textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _showCustomGroceryEditor(context),
                icon: Icon(Icons.add), label: Text(appStrings(context).label('Add first item', 'أضف أول عنصر')),
              ),
            ]),
          )
        else
          for (final group in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(children: [
                Expanded(child: Text(group.key.toUpperCase(),
                  style: TextStyle(color: AppTheme.terracotta, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1.2))),
                Text('${group.value.length} items',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11)),
              ]),
            ),
            for (final item in group.value)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: AppTheme.card,
                  borderRadius: BorderRadius.circular(15), border: Border.all(color: AppTheme.line)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(children: [
                    Checkbox(
                      value: item.isChecked, activeColor: AppTheme.olive,
                      onChanged: (value) {
                        state.setGroceryChecked(item.key, value ?? false);
                        PlannerScope.refresh(context);
                      },
                    ),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: TextStyle(
                        decoration: item.isChecked ? TextDecoration.lineThrough : null,
                        color: item.isChecked ? AppTheme.muted : AppTheme.ink,
                        fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(item.isQuantified
                        ? '${_formatAmount(item.toBuyAmount)} ${item.unit} to buy · ${_formatAmount(item.ownedAmount)} owned'
                        : appStrings(context).label('Check pantry quantity', 'تحقق من كمية المخزن'),
                        style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                      if (state.groceryPrices[item.key] != null || state.groceryStores[item.key] != null)
                        Text('${state.groceryPrices[item.key]?.toStringAsFixed(2) ?? 'No price'} · ${state.groceryStores[item.key] ?? 'No store'}',
                          style: TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700)),
                    ])),
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'price') _editItemPrice(context, item);
                        if (action == 'edit') _showGroceryEditor(context, item);
                        if (action == 'remove' && item.isCustom) {
                          state.removeCustomGroceryItem(item.key);
                          PlannerScope.refresh(context);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'price', child: Text(appStrings(context).label('Price and store', 'السعر والمتجر'))),
                        PopupMenuItem(value: 'edit', child: Text(appStrings(context).label('Edit item', 'تعديل العنصر'))),
                        if (item.isCustom) PopupMenuItem(value: 'remove', child: Text(appStrings(context).label('Remove item', 'إزالة العنصر'))),
                      ],
                    ),
                  ]),
                ),
              ),
          ],
        if (entries.any((item) => item.isCustom && item.isChecked))
          Align(alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () {
                state.clearCheckedCustomGroceryItems();
                PlannerScope.refresh(context);
              },
              icon: Icon(Icons.cleaning_services_outlined, size: 17),
              label: Text(appStrings(context).label('Clear checked custom items', 'مسح العناصر المحددة')),
            )),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Text(appStrings(context).label('Your pantry', 'مخزنك'),
            style: Theme.of(context).textTheme.titleLarge)),
          TextButton.icon(onPressed: () => _showPantryEditor(context),
            icon: Icon(Icons.add, size: 17),
            label: Text(appStrings(context).label('Add item', 'إضافة عنصر'))),
        ]),
        Text(appStrings(context).label(
          'What you already own is deducted from your shopping quantities.',
          'يتم خصم ما تملكه بالفعل من كميات التسوق المطلوبة.'),
          style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        if (state.expiringPantryItems.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 8),
            child: Text(appStrings(context).label(
              '${state.expiringPantryItems.length} pantry item(s) expire within seven days.',
              'ستنتهي صلاحية ${state.expiringPantryItems.length} من عناصر المخزن خلال سبعة أيام.'),
              style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w700))),
        const SizedBox(height: 10),
        if (state.pantry.isNotEmpty) ...[
          TextField(
            key: const Key('pantry-search'),
            onChanged: (value) => setState(() => _pantryQuery = value),
            decoration: InputDecoration(
              hintText: appStrings(context).label('Search pantry items', 'ابحث في المخزن'),
              prefixIcon: Icon(Icons.search),
              isDense: true,
              suffixIcon: _pantryQuery.isEmpty ? null : IconButton(onPressed: () => setState(() => _pantryQuery = ''), icon: Icon(Icons.close)),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => setState(() => _expiringFirst = !_expiringFirst),
              icon: Icon(_expiringFirst ? Icons.sort : Icons.event_available_outlined, size: 17),
              label: Text(_expiringFirst
                ? appStrings(context).label('Sorted by expiry', 'مرتبة حسب الصلاحية')
                : appStrings(context).label('Sort by expiry', 'ترتيب حسب الصلاحية')),
            ),
          ),
        ],
        if (state.pantry.isEmpty)
          Text(appStrings(context).label('Your pantry is empty for now.', 'مخزنك فارغ حاليًا.'))
        else if (pantryItems.isEmpty)
          Text(appStrings(context).label('No pantry items match your search.', 'لا توجد عناصر تطابق بحثك.'), style: TextStyle(color: AppTheme.muted))
        else
          for (final item in pantryItems)
            Container(
              margin: const EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.line)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: CircleAvatar(backgroundColor: Color(0xFFE8EBDD),
                  child: Icon(Icons.inventory_2_outlined, color: AppTheme.olive)),
                title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${_formatAmount(item.amount)} ${item.unit}${state.pantryExpiryDates[item.id] == null ? '' : ' · Expires ${MaterialLocalizations.of(context).formatMediumDate(state.pantryExpiryDates[item.id]!)}'}'),
                trailing: Wrap(children: [
                  IconButton(tooltip: appStrings(context).label('Set expiry date', 'تحديد تاريخ الصلاحية'),
                    onPressed: () async {
                      final current = state.pantryExpiryDates[item.id];
                      final picked = await showDatePicker(context: context,
                        initialDate: current ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)));
                      if (picked != null) { state.setPantryExpiry(item.id, picked); PlannerScope.refresh(context); }
                    }, icon: Icon(Icons.event_outlined)),
                  IconButton(tooltip: appStrings(context).label('Remove pantry item', 'إزالة عنصر من المخزن'),
                    onPressed: () { state.removePantryItem(item.id); PlannerScope.refresh(context); },
                    icon: Icon(Icons.close)),
                ]),
              ),
            ),
      ],
    );
  }


  Future<void> _scheduleShoppingReminder(BuildContext context) async {
    final state = PlannerScope.of(context);
    var enabled = state.groceryReminderDefaultEnabled;
    var mode = 'before';
    var leadMinutes = state.groceryReminderLeadMinutes;
    var shoppingAt = DateTime.now().add(const Duration(days: 1));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(appStrings(dialogContext).label('Shopping reminder', 'تذكير التسوق')),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(appStrings(dialogContext).label('Enable reminder', 'تفعيل التذكير')),
              value: enabled,
              onChanged: (value) => setDialogState(() => enabled = value),
            ),
            if (enabled) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(appStrings(dialogContext).label('Shopping date and time', 'تاريخ ووقت التسوق')),
                subtitle: Text(MaterialLocalizations.of(dialogContext).formatMediumDate(shoppingAt) + ' · ' + MaterialLocalizations.of(dialogContext).formatTimeOfDay(TimeOfDay.fromDateTime(shoppingAt))),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final date = await showDatePicker(context: dialogContext, initialDate: shoppingAt, firstDate: DateUtils.dateOnly(DateTime.now()), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date == null || !dialogContext.mounted) return;
                  final time = await showTimePicker(context: dialogContext, initialTime: TimeOfDay.fromDateTime(shoppingAt));
                  if (time != null) setDialogState(() => shoppingAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                },
              ),
              DropdownButtonFormField<String>(
                value: mode,
                decoration: InputDecoration(labelText: appStrings(dialogContext).label('Reminder timing', 'توقيت التذكير')),
                items: [
                  DropdownMenuItem(value: 'before', child: Text(appStrings(dialogContext).label('Before shopping', 'قبل التسوق'))),
                  DropdownMenuItem(value: 'specific', child: Text(appStrings(dialogContext).label('At this date and time', 'في هذا التاريخ والوقت'))),
                ],
                onChanged: (value) => setDialogState(() => mode = value ?? mode),
              ),
              if (mode == 'before')
                DropdownButtonFormField<int>(
                  value: leadMinutes,
                  decoration: InputDecoration(labelText: appStrings(dialogContext).label('Remind me before', 'ذكرني قبل')),
                  items: [5, 10, 15, 30, 60, 120, 1440, 2880, 10080].map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value < 60 ? '$value minutes' : value < 1440 ? '${value ~/ 60} hours' : '${value ~/ 1440} days'),
                  )).toList(),
                  onChanged: (value) => setDialogState(() => leadMinutes = value ?? leadMinutes),
                ),
            ],
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(dialogContext).label('Cancel', 'إلغاء'))),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(dialogContext).label('Save reminder', 'حفظ التذكير'))),
          ],
        ),
      ),
    );
    if (confirmed != true || !enabled || !context.mounted) return;
    final fireAt = mode == 'before' ? shoppingAt.subtract(Duration(minutes: leadMinutes)) : shoppingAt;
    if (!fireAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Choose a future reminder time.', 'اختر وقت تذكير في المستقبل.'))));
      return;
    }
    await CookingAssistService.requestNotificationPermission();
    final scheduled = await CookingAssistService.scheduleTimerNotification(
      id: 'shopping:${shoppingAt.millisecondsSinceEpoch}',
      title: 'Shopping reminder',
      body: 'It is time for your shopping list.',
      fireAt: fireAt,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(scheduled
        ? appStrings(context).label('Shopping reminder scheduled.', 'تمت جدولة تذكير التسوق.')
        : appStrings(context).label('Could not schedule the reminder. Check notification permission.', 'تعذر جدولة التذكير. تحقق من إذن الإشعارات.'))));
    }
  }

  Future<void> _editBudget(BuildContext context) async {
    final controller = TextEditingController(text: PlannerScope.of(context).groceryBudget?.toString() ?? '');
    final value = await showModalBottomSheet<double?>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Shopping budget', 'ميزانية التسوق'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(appStrings(sheetContext).label('Set a spending limit for this list.', 'حدد حد الإنفاق لهذه القائمة.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(controller: controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: appStrings(sheetContext).label('Budget amount', 'مبلغ الميزانية'), prefixIcon: Icon(Icons.payments_outlined))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, null), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 8),
            Expanded(child: TextButton(onPressed: () => Navigator.pop(sheetContext, -1), child: Text(appStrings(sheetContext).label('Clear', 'مسح')))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, double.tryParse(controller.text.trim())),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Save', 'حفظ')))),
          ]),
        ]),
      ),
    );
    controller.dispose();
    if (!context.mounted || value == null) return;
    final state = PlannerScope.of(context);
    state.groceryBudget = value < 0 ? null : value;
    PlannerScope.refresh(context);
  }

  Future<void> _editItemPrice(BuildContext context, GroceryItem item) async {
    final state = PlannerScope.of(context);
    final price = TextEditingController(text: state.groceryPrices[item.key]?.toString() ?? '');
    final store = TextEditingController(text: state.groceryStores[item.key] ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Price and store', 'السعر والمتجر'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(item.name, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: appStrings(sheetContext).label('Item total price', 'السعر الإجمالي للعنصر'), prefixIcon: Icon(Icons.payments_outlined))),
          const SizedBox(height: 10),
          TextField(controller: store, decoration: InputDecoration(labelText: appStrings(sheetContext).label('Store / shop', 'المتجر / المحل'), prefixIcon: Icon(Icons.storefront_outlined))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, false), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, true), style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta),
              child: Text(appStrings(sheetContext).label('Save details', 'حفظ التفاصيل')))),
          ]),
        ]),
      ),
    );
    if (saved == true && context.mounted) {
      final rawPrice = price.text.trim();
      final parsed = rawPrice.isEmpty ? null : double.tryParse(rawPrice);
      if (rawPrice.isEmpty) state.setGroceryPrice(item.key, null);
      else if (parsed != null && parsed >= 0) state.setGroceryPrice(item.key, parsed);
      state.setGroceryStore(item.key, store.text);
      PlannerScope.refresh(context);
    }
    price.dispose();
    store.dispose();
  }

  Future<void> _copyList(BuildContext context, List<GroceryItem> entries) async {
    final state = PlannerScope.of(context);
    final lines = entries.map((item) => '- ${item.name}: ${item.isQuantified ? '${_formatAmount(item.toBuyAmount)} ${item.unit}' : 'check quantity'}${state.groceryStores[item.key] == null ? '' : ' · ${state.groceryStores[item.key]}'}').join('\n');
    await Clipboard.setData(ClipboardData(text: 'Gather shopping list\n$lines'));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Shopping list copied.', 'تم نسخ قائمة التسوق.'))));
  }

  Future<void> _showCustomGroceryEditor(BuildContext context) async {
    final name = TextEditingController();
    final amount = TextEditingController(text: '1');
    final unit = TextEditingController(text: 'item');
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Add a grocery item', 'إضافة عنصر للمشتريات'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: name, autofocus: true, decoration: InputDecoration(labelText: appStrings(sheetContext).label('Item', 'العنصر'), prefixIcon: Icon(Icons.shopping_basket_outlined))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: appStrings(sheetContext).label('Quantity', 'الكمية')))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: unit, decoration: InputDecoration(labelText: appStrings(sheetContext).label('Unit', 'الوحدة')))),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () {
              final quantity = double.tryParse(amount.text.trim());
              if (name.text.trim().isEmpty || unit.text.trim().isEmpty || quantity == null || quantity < 0) return;
              PlannerScope.of(context).addCustomGroceryItem(name: name.text, amount: quantity, unit: unit.text);
              PlannerScope.refresh(context);
              Navigator.pop(sheetContext);
            }, style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Add item', 'إضافة العنصر')))),
          ]),
        ]),
      ),
    );
    name.dispose(); amount.dispose(); unit.dispose();
  }

  Future<void> _showGroceryEditor(BuildContext context, GroceryItem item) async {
    final name = TextEditingController(text: item.name);
    final amount = TextEditingController(text: item.isQuantified ? _formatAmount(item.amount) : '');
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Edit grocery item', 'تعديل عنصر المشتريات'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: name, decoration: InputDecoration(labelText: appStrings(sheetContext).label('Ingredient', 'المكوّن'))),
          if (item.isQuantified) ...[
            const SizedBox(height: 10),
            TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: appStrings(sheetContext).label('Amount (${item.unit})', 'الكمية (${item.unit})'))),
          ],
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () {
              final parsed = item.isQuantified ? double.tryParse(amount.text.trim()) : item.amount;
              if (parsed == null || parsed < 0 || name.text.trim().isEmpty) return;
              PlannerScope.of(context).updateGroceryItem(item.key, name: name.text, amount: parsed);
              PlannerScope.refresh(context);
              Navigator.pop(sheetContext);
            }, style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Save changes', 'حفظ التغييرات')))),
          ]),
        ]),
      ),
    );
    name.dispose(); amount.dispose();
  }

  Future<void> _showPantryEditor(BuildContext context) async {
    final name = TextEditingController();
    final amount = TextEditingController(text: '1');
    final unit = TextEditingController(text: 'g');
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Add to your pantry', 'إضافة إلى المخزن'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: name, autofocus: true, decoration: InputDecoration(labelText: appStrings(sheetContext).label('Ingredient', 'المكوّن'))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: appStrings(sheetContext).label('Quantity', 'الكمية')))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: unit, decoration: InputDecoration(labelText: appStrings(sheetContext).label('Unit (g, ml, whole…)', 'الوحدة (g، ml، كامل…)')))),
          ]),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () {
            final value = double.tryParse(amount.text.trim());
            if (value == null || value < 0 || name.text.trim().isEmpty || unit.text.trim().isEmpty) return;
            PlannerScope.of(context).upsertPantryItem(name: name.text, amount: value, unit: unit.text);
            PlannerScope.refresh(context);
            Navigator.pop(sheetContext);
          }, style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta),
            child: Text(appStrings(sheetContext).label('Save pantry item', 'حفظ عنصر المخزن')))),
        ]),
      ),
    );
    name.dispose(); amount.dispose(); unit.dispose();
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


class _GroceryMetric extends StatelessWidget {
  const _GroceryMetric({required this.icon, required this.label, required this.value, this.alert = false});
  final IconData icon;
  final String label;
  final String value;
  final bool alert;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.line)),
    child: Row(children: [
      Icon(icon, color: alert ? AppTheme.terracotta : AppTheme.olive, size: 20),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
        Text(value, style: TextStyle(color: alert ? AppTheme.terracotta : AppTheme.ink,
          fontWeight: FontWeight.w800, fontSize: 17)),
      ])),
    ]),
  );
}

class _GroceryAction extends StatelessWidget {
  const _GroceryAction({super.key, required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.paper, borderRadius: BorderRadius.circular(13),
    child: InkWell(
      borderRadius: BorderRadius.circular(13), onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(children: [
          Icon(icon, color: AppTheme.terracotta, size: 21),
          const SizedBox(height: 6),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        ]),
      ),
    ),
  );
}
