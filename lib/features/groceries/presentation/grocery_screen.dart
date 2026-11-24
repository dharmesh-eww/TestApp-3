import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/groceries/presentation/grocery_lists_screen.dart';
import 'package:testapp_3/app/gather_visuals.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});
  @override State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool _groupByStore = false;
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
    final budget = state.groceryBudget;
    final overBudget = budget != null && estimatedTotal > budget;
    final progress = entries.isEmpty ? 0.0 : checked / entries.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Text(
          appStrings(context).label('THE MARKET LIST', 'قائمة المشتريات'),
          style: const TextStyle(color: AppTheme.terracotta, fontSize: 10,
            fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text(
            appStrings(context).label('A little plan.\\nA smoother shop.', 'خطة صغيرة.\\nوتسوق أسهل.'),
            style: const TextStyle(fontFamily: 'Georgia', fontSize: 30,
              height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold),
          )),
          GatherVisuals.foodMotion(size: 76),
        ]),
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
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              )),
              Text('$checked / ${entries.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
              style: const TextStyle(color: AppTheme.muted, fontSize: 10,
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
                icon: const Icon(Icons.storefront_outlined, size: 17),
                label: Text(_groupByStore
                  ? appStrings(context).label('Grouped by store', 'حسب المتجر')
                  : appStrings(context).label('Group by store', 'التجميع حسب المتجر')),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _editBudget(context),
                icon: const Icon(Icons.account_balance_wallet_outlined, size: 17),
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
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
                Text(
                  appStrings(context).label(
                    '${estimatedTotal.toStringAsFixed(2)} spent of ${budget.toStringAsFixed(2)}',
                    '${estimatedTotal.toStringAsFixed(2)} من ${budget.toStringAsFixed(2)}',
                  ),
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
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
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
              const SizedBox(height: 5),
              Text(appStrings(context).label(
                'Add ingredients from a recipe or create your own shopping item.',
                'أضف مكونات من وصفة أو أنشئ عنصر تسوق جديدًا.'),
                textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _showCustomGroceryEditor(context),
                icon: const Icon(Icons.add), label: Text(appStrings(context).label('Add first item', 'أضف أول عنصر')),
              ),
            ]),
          )
        else
          for (final group in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(children: [
                Expanded(child: Text(group.key.toUpperCase(),
                  style: const TextStyle(color: AppTheme.terracotta, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1.2))),
                Text('${group.value.length} items',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
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
                        style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                      if (state.groceryPrices[item.key] != null || state.groceryStores[item.key] != null)
                        Text('${state.groceryPrices[item.key]?.toStringAsFixed(2) ?? 'No price'} · ${state.groceryStores[item.key] ?? 'No store'}',
                          style: const TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700)),
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
              icon: const Icon(Icons.cleaning_services_outlined, size: 17),
              label: Text(appStrings(context).label('Clear checked custom items', 'مسح العناصر المحددة')),
            )),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Text(appStrings(context).label('Your pantry', 'مخزنك'),
            style: Theme.of(context).textTheme.titleLarge)),
          TextButton.icon(onPressed: () => _showPantryEditor(context),
            icon: const Icon(Icons.add, size: 17),
            label: Text(appStrings(context).label('Add item', 'إضافة عنصر'))),
        ]),
        Text(appStrings(context).label(
          'What you already own is deducted from your shopping quantities.',
          'يتم خصم ما تملكه بالفعل من كميات التسوق المطلوبة.'),
          style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
        if (state.expiringPantryItems.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 8),
            child: Text(appStrings(context).label(
              '${state.expiringPantryItems.length} pantry item(s) expire within seven days.',
              'ستنتهي صلاحية ${state.expiringPantryItems.length} من عناصر المخزن خلال سبعة أيام.'),
              style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w700))),
        const SizedBox(height: 10),
        if (state.pantry.isEmpty)
          Text(appStrings(context).label('Your pantry is empty for now.', 'مخزنك فارغ حاليًا.'),
            style: const TextStyle(color: AppTheme.muted))
        else
          for (final item in state.pantry.values)
            Container(
              margin: const EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.line)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: const CircleAvatar(backgroundColor: Color(0xFFE8EBDD),
                  child: Icon(Icons.inventory_2_outlined, color: AppTheme.olive)),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                    }, icon: const Icon(Icons.event_outlined)),
                  IconButton(tooltip: appStrings(context).label('Remove pantry item', 'إزالة عنصر من المخزن'),
                    onPressed: () { state.removePantryItem(item.id); PlannerScope.refresh(context); },
                    icon: const Icon(Icons.close)),
                ]),
              ),
            ),
      ],
    );
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
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        ]),
      ),
    ),
  );
}
