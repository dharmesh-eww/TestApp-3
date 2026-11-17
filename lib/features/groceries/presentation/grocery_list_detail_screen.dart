import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class GroceryListDetailScreen extends StatelessWidget {
  const GroceryListDetailScreen({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final items = state.buildGroceryList(RecipeCatalogScope.of(context));
    final selected = state.groceryLists[listId] ?? <String>{};
    return Scaffold(
      appBar: AppBar(title: Text(state.groceryListNames[listId] ?? 'Shopping list')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(appStrings(context).label('Choose items from your planner’s combined grocery list. Changes stay on this device.', 'اختر عناصر من قائمة المشتريات المجمعة في مخططك. تُحفظ التغييرات على هذا الجهاز.'),
            style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 12),
          if (items.isEmpty) Text(appStrings(context).label('Add ingredients from recipes or planned meals first.', 'أضف المكونات من الوصفات أو الوجبات المخططة أولاً.')),
          for (final item in items)
            CheckboxListTile(
              value: selected.contains(item.key),
              title: Text(item.name),
              subtitle: Text(item.isQuantified ? '${item.amount} ${item.unit}' : 'Check pantry before shopping'),
              onChanged: (value) {
                if (value == true) state.assignGroceryItem(listId, item.key);
                else state.removeGroceryItemFromList(listId, item.key);
                PlannerScope.refresh(context);
              },
            ),
        ],
      ),
    );
  }
}
