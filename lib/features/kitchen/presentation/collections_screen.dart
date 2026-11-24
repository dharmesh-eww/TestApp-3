import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/kitchen/presentation/collection_detail_screen.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});
  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  String _query = '';
  bool _largestFirst = false;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final entries = state.collections.entries.where((entry) =>
      (state.collectionNames[entry.key] ?? '').toLowerCase().contains(_query.toLowerCase())
    ).toList()..sort((a, b) => _largestFirst
      ? b.value.length.compareTo(a.value.length)
      : (state.collectionNames[a.key] ?? '').toLowerCase().compareTo((state.collectionNames[b.key] ?? '').toLowerCase()));
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
              children: [
                TextField(
                  key: const Key('collections-search'),
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: appStrings(context).label('Search collections', 'ابحث في المجموعات'),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () => setState(() => _query = ''), icon: Icon(Icons.close)),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _largestFirst = !_largestFirst),
                    icon: Icon(Icons.sort),
                    label: Text(_largestFirst ? appStrings(context).label('Most recipes first', 'الأكثر وصفات أولاً') : appStrings(context).label('Sort by name', 'ترتيب حسب الاسم')),
                  ),
                ),
                if (entries.isEmpty)
                  Padding(padding: const EdgeInsets.all(24), child: Text(appStrings(context).label('No collections match your search.', 'لا توجد مجموعات تطابق بحثك.')))
                else
                ...entries.map((entry) => Card(
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
              )),
              ],
            ),
    );
  }

  Future<void> _createCollection(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('New collection', 'مجموعة جديدة'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: controller, autofocus: true,
            decoration: InputDecoration(labelText: appStrings(sheetContext).label('Collection name', 'اسم المجموعة'), prefixIcon: const Icon(Icons.collections_bookmark_outlined))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: Text(appStrings(sheetContext).label('Cancel', 'إلغاء')))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, controller.text),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta), child: Text(appStrings(sheetContext).label('Create collection', 'إنشاء المجموعة')))),
          ]),
        ]),
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    PlannerScope.of(context).createCollection(name);
    PlannerScope.refresh(context);
  }

  Future<void> _renameCollection(BuildContext context, String id) async {
    final state = PlannerScope.of(context);
    final controller = TextEditingController(text: state.collectionNames[id]);
    final name = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appStrings(sheetContext).label('Rename collection', 'إعادة تسمية المجموعة'), style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: controller, autofocus: true,
            decoration: InputDecoration(labelText: appStrings(sheetContext).label('Collection name', 'اسم المجموعة'))),
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
    state.renameCollection(id, name);
    PlannerScope.refresh(context);
  }
}
