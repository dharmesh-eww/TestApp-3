import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/groceries/presentation/grocery_lists_screen.dart';
import 'package:testapp_3/features/notifications/domain/reminder_series.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});
  @override State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool _groupByStore = false;
  @override Widget build(BuildContext context){
    final state=PlannerScope.of(context),entries=state.buildGroceryList(RecipeCatalogScope.of(context));
    final checked=entries.where((item)=>item.isChecked).length;
    final grouped = <String, List<GroceryItem>>{};
    for (final item in entries) {
      final group = _groupByStore ? (state.groceryStores[item.key] ?? 'No store assigned') : _groceryAisle(item.name);
      grouped.putIfAbsent(group, () => []).add(item);
    }
    final estimatedTotal = entries.fold<double>(0, (sum, item) => sum + (state.groceryPrices[item.key] ?? 0));
    return ListView(padding:const EdgeInsets.fromLTRB(20,20,20,28),children:[
      Text(appStrings(context).label('THE MARKET LIST', 'قائمة المشتريات'),style:TextStyle(color:AppTheme.terracotta,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.5)),const SizedBox(height:8),
      Text(appStrings(context).label('Good things\\nto pick up.', 'أشياء جيدة\\nلشرائها.'),style:TextStyle(fontFamily:'Georgia',fontSize:32,height:1.08,color:AppTheme.ink,fontWeight:FontWeight.bold)),const SizedBox(height:8),
      Text(entries.isEmpty?appStrings(context).label('Your planned meals will gather ingredients here.', 'ستظهر مكونات وجباتك المخططة هنا.') : appStrings(context).label('$checked of ${entries.length} items checked · ${entries.where((e)=>e.toBuyAmount>0||!e.isQuantified).length} to buy', 'تم تحديد $checked من ${entries.length} عناصر · ${entries.where((e)=>e.toBuyAmount>0||!e.isQuantified).length} للشراء'),style:TextStyle(color:AppTheme.muted)),
      const SizedBox(height:12),
      Align(alignment:AlignmentDirectional.centerStart,child:Wrap(spacing:8,children:[
        OutlinedButton.icon(key:const Key('add-custom-grocery-item'),onPressed:()=>_showCustomGroceryEditor(context),icon:Icon(Icons.add),label:Text(appStrings(context).label('Add item', 'إضافة عنصر'))),
        OutlinedButton.icon(onPressed:()=>Navigator.push(context, MaterialPageRoute(builder: (_) => const GroceryListsScreen())),icon:Icon(Icons.list_alt),label:Text(appStrings(context).label('Shopping lists', 'قوائم التسوق'))),
        OutlinedButton.icon(onPressed:()=>_setGeneratedGroceryReminder(context),icon:const Icon(Icons.notifications_active_outlined),label:Text(appStrings(context).label('Shopping reminder', 'تذكير التسوق'))),
        OutlinedButton.icon(onPressed:()=>setState(()=>_groupByStore=!_groupByStore),icon:const Icon(Icons.storefront_outlined),label:Text(_groupByStore ? appStrings(context).label('Group by aisle', 'التجميع حسب القسم') : appStrings(context).label('Group by store', 'التجميع حسب المتجر'))),
        OutlinedButton.icon(onPressed:()=>_editBudget(context),icon:const Icon(Icons.account_balance_wallet_outlined),label:Text(appStrings(context).label('Budget', 'الميزانية'))),
        OutlinedButton.icon(onPressed:()=>_copyList(context, entries),icon:const Icon(Icons.copy_outlined),label:Text(appStrings(context).label('Copy list', 'نسخ القائمة'))),
        if(entries.any((item)=>item.isCustom && item.isChecked)) TextButton(onPressed:(){ state.clearCheckedCustomGroceryItems(); PlannerScope.refresh(context); },child:Text(appStrings(context).label('Clear checked custom items', 'مسح العناصر المخصصة المحددة'))),
      ])),
      const SizedBox(height:8),
      Card(child: ListTile(
        leading: Icon(Icons.payments_outlined, color: AppTheme.olive),
        title: Text(appStrings(context).label('Estimated total', 'الإجمالي التقديري')),
        subtitle: Text(state.groceryBudget == null ? appStrings(context).label('No budget set', 'لم يتم تحديد ميزانية') : appStrings(context).label('Budget: ${state.groceryBudget!.toStringAsFixed(2)}', 'الميزانية: ${state.groceryBudget!.toStringAsFixed(2)}')),
        trailing: Text(estimatedTotal.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w800, color: state.groceryBudget != null && estimatedTotal > state.groceryBudget! ? Colors.red : AppTheme.ink)),
      )),
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
                  if (state.groceryPrices[item.key] != null || state.groceryStores[item.key] != null)
                    Text('${state.groceryPrices[item.key]?.toStringAsFixed(2) ?? '—'} · ${state.groceryStores[item.key] ?? 'No store'}', style: TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              )),
              PopupMenuButton<String>(
                tooltip: appStrings(context).label('Item actions', 'إجراءات العنصر'),
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
  Future<void> _setGeneratedGroceryReminder(BuildContext context) async {
    final state = PlannerScope.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(context: context, initialDate: today, firstDate: today, lastDate: today.add(const Duration(days: 365)));
    if (date == null || !context.mounted) return;
    var offset = ReminderOffset.previousDay;
    var frequency = 'once';
    var weekday = date.weekday;
    var monthDay = date.day;
    var time = const TimeOfDay(hour: 18, minute: 0);
    final saved = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(appStrings(context).label('Shopping reminder', 'تذكير التسوق')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: frequency,
            decoration: InputDecoration(labelText: appStrings(context).label('Repeat', 'التكرار')),
            items: [
              DropdownMenuItem(value: 'once', child: Text(appStrings(context).label('Just once', 'مرة واحدة'))),
              DropdownMenuItem(value: 'weekly', child: Text(appStrings(context).label('Every week', 'كل أسبوع'))),
              DropdownMenuItem(value: 'monthly', child: Text(appStrings(context).label('Every month', 'كل شهر'))),
            ],
            onChanged: (value) => setDialogState(() => frequency = value ?? frequency),
          ),
          if (frequency == 'weekly')
            DropdownButtonFormField<int>(
              value: weekday,
              decoration: InputDecoration(labelText: appStrings(context).label('Weekday', 'يوم الأسبوع')),
              items: List.generate(7, (index) => DropdownMenuItem(value: index + 1, child: Text(MaterialLocalizations.of(context).narrowWeekdays[index]))),
              onChanged: (value) => setDialogState(() => weekday = value ?? weekday),
            ),
          if (frequency == 'monthly')
            DropdownButtonFormField<int>(
              value: monthDay,
              decoration: InputDecoration(labelText: appStrings(context).label('Day of month', 'يوم الشهر')),
              items: List.generate(31, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}'))),
              onChanged: (value) => setDialogState(() => monthDay = value ?? monthDay),
            ),
          DropdownButtonFormField<ReminderOffset>(
            value: offset,
            decoration: InputDecoration(labelText: appStrings(context).label('Remind me', 'ذكرني')),
            items: [
              DropdownMenuItem(value: ReminderOffset.sameDay, child: Text(appStrings(context).label('Same day', 'في نفس اليوم'))),
              DropdownMenuItem(value: ReminderOffset.previousDay, child: Text(appStrings(context).label('Previous day', 'في اليوم السابق'))),
            ],
            onChanged: (value) => setDialogState(() => offset = value ?? offset),
          ),
          ListTile(title: Text(appStrings(context).label('Notification time', 'وقت الإشعار')), subtitle: Text(time.format(context)),
            onTap: () async { final picked = await showTimePicker(context: dialogContext, initialTime: time); if (picked != null) setDialogState(() => time = picked); }),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Save', 'حفظ'))),
        ],
      ),
    ));
    if (saved != true || !context.mounted) return;
    state.saveReminderSeries(ReminderSeries(
      id: 'shopping:generated-grocery',
      sourceType: ReminderType.ingredient,
      sourceId: 'generated-grocery',
      title: appStrings(context).label('Grocery shopping', 'تسوق البقالة'),
      description: appStrings(context).label('Your generated ingredient list is ready for shopping.', 'قائمة المكونات الخاصة بك جاهزة للتسوق.'),
      startDate: date,
      recurrence: switch (frequency) { 'weekly' => ReminderRecurrence.weekly, 'monthly' => ReminderRecurrence.monthly, _ => ReminderRecurrence.once },
      weekday: frequency == 'weekly' ? weekday : null,
      monthDay: frequency == 'monthly' ? monthDay : null,
      offset: offset,
      hour: time.hour,
      minute: time.minute,
      isEnabled: true,
      createdAt: DateTime.now(),
    ));
    PlannerScope.refresh(context);
  }

  Future<void> _editBudget(BuildContext context) async {
    final controller = TextEditingController(text: PlannerScope.of(context).groceryBudget?.toString() ?? '');
    final value = await showDialog<double?>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(appStrings(context).label('Shopping budget', 'ميزانية التسوق')),
      content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: appStrings(context).label('Budget amount', 'مبلغ الميزانية'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, null), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
        TextButton(onPressed: () => Navigator.pop(dialogContext, -1), child: Text(appStrings(context).label('Clear', 'مسح'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, double.tryParse(controller.text.trim())), child: Text(appStrings(context).label('Save', 'حفظ'))),
      ],
    ));
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
    final saved = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(appStrings(context).label('Price and store', 'السعر والمتجر')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: appStrings(context).label('Item total price', 'السعر الإجمالي للعنصر'))),
        TextField(controller: store, decoration: InputDecoration(labelText: appStrings(context).label('Store / shop', 'المتجر / المحل'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Save', 'حفظ'))),
      ],
    ));
    if (saved == true && context.mounted) {
      final rawPrice = price.text.trim();
      final parsed = rawPrice.isEmpty ? null : double.tryParse(rawPrice);
      if (rawPrice.isEmpty) {
        state.setGroceryPrice(item.key, null);
      } else if (parsed != null && parsed >= 0) {
        state.setGroceryPrice(item.key, parsed);
      }
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
