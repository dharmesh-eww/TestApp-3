import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/groceries/presentation/grocery_list_detail_screen.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class GroceryListsScreen extends StatelessWidget {
  const GroceryListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Shopping lists', 'قوائم التسوق'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, state),
        icon: const Icon(Icons.add),
        label: Text(appStrings(context).label('New list', 'قائمة جديدة')),
      ),
      body: state.groceryLists.isEmpty
          ? Center(child: Text(appStrings(context).label('Create a list for a shop, occasion or week.', 'أنشئ قائمة لمتجر أو مناسبة أو أسبوع.')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: state.groceryLists.entries.map((entry) {
                final selected = entry.value.length;
                return Card(child: ListTile(
                  leading: const Icon(Icons.list_alt, color: AppTheme.terracotta),
                  title: Text(state.groceryListNames[entry.key] ?? 'Shopping list'),
                  subtitle: Text(appStrings(context).label('$selected saved items', '$selected عناصر محفوظة')),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'rename') _rename(context, state, entry.key);
                      if (action == 'delete') {
                        state.deleteGroceryList(entry.key);
                        PlannerScope.refresh(context);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text(appStrings(context).label('Rename', 'إعادة تسمية'))),
                      PopupMenuItem(value: 'delete', child: Text(appStrings(context).label('Delete', 'حذف'))),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => GroceryListDetailScreen(listId: entry.key),
                  )),
                ));
              }).toList(),
            ),
    );
  }

  Future<void> _create(BuildContext context, PlannerState state) async {
    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Create a shopping list', 'إنشاء قائمة تسوق'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: controller, autofocus: true,
            decoration: InputDecoration(labelText: appStrings(sheetContext).label('List name', 'اسم القائمة'), prefixIcon: const Icon(Icons.list_alt_rounded))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, controller.text),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Create list', 'إنشاء القائمة')))),
          ]),
        ]),
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    state.createGroceryList(name);
    PlannerScope.refresh(context);
  }

  Future<void> _rename(BuildContext context, PlannerState state, String id) async {
    final controller = TextEditingController(text: state.groceryListNames[id]);
    final name = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Rename shopping list', 'إعادة تسمية قائمة التسوق'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: controller, autofocus: true,
            decoration: InputDecoration(labelText: appStrings(sheetContext).label('List name', 'اسم القائمة'))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, controller.text),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Save changes', 'حفظ التغييرات')))),
          ]),
        ]),
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    state.renameGroceryList(id, name);
    PlannerScope.refresh(context);
  }
}
