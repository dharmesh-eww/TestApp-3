import 'package:flutter/material.dart';

import '../../../app/planner_scope.dart';
import '../../../app/recipe_catalog_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/planner_state.dart';

class GroceryListsScreen extends StatelessWidget {
  const GroceryListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping lists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, state),
        icon: const Icon(Icons.add),
        label: const Text('New list'),
      ),
      body: state.groceryLists.isEmpty
          ? const Center(child: Text('Create a list for a shop, occasion or week.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: state.groceryLists.entries.map((entry) {
                final selected = entry.value.length;
                return Card(child: ListTile(
                  leading: const Icon(Icons.list_alt, color: AppTheme.terracotta),
                  title: Text(state.groceryListNames[entry.key] ?? 'Shopping list'),
                  subtitle: Text('$selected saved items'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'rename') _rename(context, state, entry.key);
                      if (action == 'delete') {
                        state.deleteGroceryList(entry.key);
                        PlannerScope.refresh(context);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
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
    final name = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Create a shopping list'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'List name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Create')),
      ],
    ));
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    state.createGroceryList(name);
    PlannerScope.refresh(context);
  }

  Future<void> _rename(BuildContext context, PlannerState state, String id) async {
    final controller = TextEditingController(text: state.groceryListNames[id]);
    final name = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Rename shopping list'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Save')),
      ],
    ));
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    state.renameGroceryList(id, name);
    PlannerScope.refresh(context);
  }
}

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
          Text('Choose items from your planner’s combined grocery list. Changes stay on this device.',
            style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 12),
          if (items.isEmpty) const Text('Add ingredients from recipes or planned meals first.'),
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
