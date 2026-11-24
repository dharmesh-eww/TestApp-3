import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});
  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final catalog = RecipeCatalogScope.of(context);
    final ids = state.collections[collectionId] ?? <String>{};
    final recipes = catalog.where((recipe) => ids.contains(recipe.id)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(state.collectionNames[collectionId] ?? appStrings(context).label('Collection', 'مجموعة'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRecipes(context, catalog),
        icon: Icon(Icons.add),
        label: Text(appStrings(context).label('Add recipes', 'إضافة وصفات')),
      ),
      body: recipes.isEmpty
          ? Center(child: Text(appStrings(context).label('This collection is ready for your recipes.', 'هذه المجموعة جاهزة لوصفاتك.')))
          : ListView(padding: const EdgeInsets.all(16), children: recipes.map((recipe) => ListTile(
              title: Text(recipe.title),
              subtitle: Text(appStrings(context).label('${recipe.totalMinutes} min · ${recipe.category}', '${recipe.totalMinutes} دقيقة · ${recipe.category}')),
              trailing: IconButton(
                tooltip: appStrings(context).label('Remove from collection', 'إزالة من المجموعة'),
                onPressed: () {
                  state.toggleRecipeInCollection(collectionId, recipe.id);
                  PlannerScope.refresh(context);
                },
                icon: Icon(Icons.remove_circle_outline),
              ),
            )).toList()),
    );
  }

  Future<void> _addRecipes(BuildContext context, List<Recipe> catalog) async {
    final state = PlannerScope.of(context);
    var query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheetState) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .7,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              TextField(
                key: const Key('collection-recipe-search'),
                onChanged: (value) => setSheetState(() => query = value),
                decoration: InputDecoration(
                  hintText: appStrings(sheetContext).label('Search recipes to add', 'ابحث عن وصفات لإضافتها'),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              ...catalog.where((recipe) => recipe.matches(query)).map((recipe) => CheckboxListTile(
              value: state.collections[collectionId]?.contains(recipe.id) ?? false,
              title: Text(recipe.title),
              onChanged: (selected) {
                final included = state.collections[collectionId]?.contains(recipe.id) ?? false;
                if ((selected ?? false) != included) {
                  state.toggleRecipeInCollection(collectionId, recipe.id);
                  PlannerScope.refresh(context);
                  setSheetState(() {});
                }
              },
            )),
            ],
          ),
        ),
      )),
    );
  }
}
