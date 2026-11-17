import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/kitchen/presentation/collection_detail_screen.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('My collections', 'مجموعاتي'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCollection(context),
        icon: Icon(Icons.create_new_folder_outlined),
        label: Text(appStrings(context).label('New collection', 'مجموعة جديدة')),
      ),
      body: state.collections.isEmpty
          ? Center(child: Text(appStrings(context).label('Create a collection for recipes you love.', 'أنشئ مجموعة للوصفات التي تحبها.')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: state.collections.entries.map((entry) => Card(
                child: ListTile(
                  leading: Icon(Icons.folder_open, color: AppTheme.terracotta),
                  title: Text(state.collectionNames[entry.key] ?? appStrings(context).label('Collection', 'مجموعة')),
                  subtitle: Text(appStrings(context).label('${entry.value.length} recipes', '${entry.value.length} وصفات')),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') _renameCollection(context, entry.key);
                      if (value == 'delete') {
                        state.deleteCollection(entry.key);
                        PlannerScope.refresh(context);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text(appStrings(context).label('Rename', 'إعادة تسمية'))),
                      PopupMenuItem(value: 'delete', child: Text(appStrings(context).label('Delete', 'حذف'))),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CollectionDetailScreen(collectionId: entry.key))),
                ),
              )).toList(),
            ),
    );
  }

  Future<void> _createCollection(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(appStrings(context).label('New collection', 'مجموعة جديدة')),
      content: TextField(controller: controller, autofocus: true,
          decoration: InputDecoration(labelText: appStrings(context).label('Collection name', 'اسم المجموعة'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: Text(appStrings(context).label('Create', 'إنشاء'))),
      ],
    ));
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    PlannerScope.of(context).createCollection(name);
    PlannerScope.refresh(context);
  }

  Future<void> _renameCollection(BuildContext context, String id) async {
    final state = PlannerScope.of(context);
    final controller = TextEditingController(text: state.collectionNames[id]);
    final name = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(appStrings(context).label('Rename collection', 'إعادة تسمية المجموعة')),
      content: TextField(controller: controller, decoration: InputDecoration(labelText: appStrings(context).label('Collection name', 'اسم المجموعة'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: Text(appStrings(context).label('Save', 'حفظ'))),
      ],
    ));
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    state.renameCollection(id, name);
    PlannerScope.refresh(context);
  }
}
