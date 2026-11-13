import 'package:flutter/material.dart';

import '../../../app/planner_scope.dart';
import '../../../app/recipe_catalog_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../recipes/domain/ingredient_matcher.dart';
import '../../recipes/domain/recipe.dart';

class IngredientFinderScreen extends StatefulWidget {
  const IngredientFinderScreen({super.key});

  @override
  State<IngredientFinderScreen> createState() => _IngredientFinderScreenState();
}

class _IngredientFinderScreenState extends State<IngredientFinderScreen> {
  final Set<String> _available = {};
  final Set<String> _excluded = {};
  bool _excludeMode = false;

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeCatalogScope.of(context);
    final ingredients = <String, String>{};
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final id = ingredient.id.isEmpty ? ingredient.name.toLowerCase() : ingredient.id;
        ingredients[id] = ingredient.name;
      }
    }
    final results = IngredientMatcher.rank(recipes, available: _available, excluded: _excluded);
    return Scaffold(
      appBar: AppBar(title: const Text('Cook with what you have')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('YOUR INGREDIENT SHELF', style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('What’s in your kitchen?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Choose ingredients you have, or switch to ingredients you want to avoid. Matches show what is still missing.',
              style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('I have'), icon: Icon(Icons.check_circle_outline)),
              ButtonSegment(value: true, label: Text('Exclude'), icon: Icon(Icons.block_outlined)),
            ],
            selected: {_excludeMode},
            onSelectionChanged: (value) => setState(() => _excludeMode = value.first),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ingredients.entries.map((entry) {
            final selected = _excludeMode ? _excluded.contains(entry.key) : _available.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (value) => setState(() {
                final target = _excludeMode ? _excluded : _available;
                final other = _excludeMode ? _available : _excluded;
                if (value) { target.add(entry.key); other.remove(entry.key); }
                else { target.remove(entry.key); }
              }),
            );
          }).toList()),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Text('Recipe matches', style: Theme.of(context).textTheme.titleLarge)),
            Text('${results.length} found', style: const TextStyle(color: AppTheme.muted)),
          ]),
          const SizedBox(height: 10),
          if (_available.isEmpty)
            const Text('Select at least one ingredient to see match percentages.',
                style: TextStyle(color: AppTheme.muted)),
          for (final match in results)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(match.recipe.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Text('${match.matchPercent}%', style: const TextStyle(color: AppTheme.olive, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 5),
                  Text(match.isExactMatch
                      ? 'You have every listed ingredient'
                      : 'Missing: ${match.missingIngredients.map((item) => item.name).join(', ')}',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, match.recipe),
                      child: const Text('View recipe'),
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My collections')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCollection(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New collection'),
      ),
      body: state.collections.isEmpty
          ? const Center(child: Text('Create a collection for recipes you love.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: state.collections.entries.map((entry) => Card(
                child: ListTile(
                  leading: const Icon(Icons.folder_open, color: AppTheme.terracotta),
                  title: Text(state.collectionNames[entry.key] ?? 'Collection'),
                  subtitle: Text('${entry.value.length} recipes'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') _renameCollection(context, entry.key);
                      if (value == 'delete') {
                        state.deleteCollection(entry.key);
                        PlannerScope.refresh(context);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
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
      title: const Text('New collection'),
      content: TextField(controller: controller, autofocus: true,
          decoration: const InputDecoration(labelText: 'Collection name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Create')),
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
      title: const Text('Rename collection'),
      content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Collection name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Save')),
      ],
    ));
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    state.renameCollection(id, name);
    PlannerScope.refresh(context);
  }
}

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
      appBar: AppBar(title: Text(state.collectionNames[collectionId] ?? 'Collection')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRecipes(context, catalog),
        icon: const Icon(Icons.add),
        label: const Text('Add recipes'),
      ),
      body: recipes.isEmpty
          ? const Center(child: Text('This collection is ready for your recipes.'))
          : ListView(padding: const EdgeInsets.all(16), children: recipes.map((recipe) => ListTile(
              title: Text(recipe.title),
              subtitle: Text('${recipe.totalMinutes} min · ${recipe.category}'),
              trailing: IconButton(
                tooltip: 'Remove from collection',
                onPressed: () {
                  state.toggleRecipeInCollection(collectionId, recipe.id);
                  PlannerScope.refresh(context);
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
            )).toList()),
    );
  }

  Future<void> _addRecipes(BuildContext context, List<Recipe> catalog) async {
    final state = PlannerScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheetState) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .7,
          child: ListView(
            children: catalog.map((recipe) => CheckboxListTile(
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
            )).toList(),
          ),
        ),
      )),
    );
  }
}

class CookingHistoryScreen extends StatelessWidget {
  const CookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = PlannerScope.of(context).cookingHistory;
    return Scaffold(
      appBar: AppBar(title: const Text('Cooking history')),
      body: history.isEmpty
          ? const Center(child: Text('Recipes you finish cooking will appear here.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final date = DateTime.tryParse(item['completed_at'] ?? '');
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
                  title: Text(item['title'] ?? 'Recipe'),
                  subtitle: Text(date == null ? '' : MaterialLocalizations.of(context).formatMediumDate(date)),
                );
              },
            ),
    );
  }
}

class PlannerSettingsScreen extends StatelessWidget {
  const PlannerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('MEASUREMENTS', style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.measurementSystem,
          decoration: const InputDecoration(labelText: 'Measurement system'),
          items: const [
            DropdownMenuItem(value: 'metric', child: Text('Metric (g, kg, ml, L)')),
            DropdownMenuItem(value: 'us', child: Text('US customary (oz, lb, cups)')),
          ],
          onChanged: (value) {
            if (value == null) return;
            state.measurementSystem = value;
            PlannerScope.refresh(context);
          },
        ),
        const SizedBox(height: 24),
        Text('WEEKLY PLANNER', style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: state.weekStartsOn,
          decoration: const InputDecoration(labelText: 'First day of week'),
          items: const [
            DropdownMenuItem(value: 1, child: Text('Monday')),
            DropdownMenuItem(value: 7, child: Text('Sunday')),
          ],
          onChanged: (value) {
            if (value == null) return;
            state.weekStartsOn = value;
            PlannerScope.refresh(context);
          },
        ),
        const SizedBox(height: 24),
        const Text('PERSONAL DISCOVERY', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        const Text('Prefer recipes with these dietary tags. Discover will apply every selected tag.', style: TextStyle(color: AppTheme.muted)),
        for (final option in const {'plant_based': 'Plant based', 'gluten_free': 'Gluten free', 'dairy_free': 'Dairy free', 'high_protein': 'High protein'}.entries)
          CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(option.value), value: state.preferredDietaryTags.contains(option.key),
            onChanged: (selected) { if (selected == true) { state.preferredDietaryTags.add(option.key); } else { state.preferredDietaryTags.remove(option.key); } PlannerScope.refresh(context); }),
        const SizedBox(height: 16),
        const Text('Conversions are shown only within compatible dimensions. Mass is never converted to volume without ingredient-specific density.',
            style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 28),
        Text('LOCAL DATA', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.terracotta, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        const Text('Favorites, meal plans, groceries, pantry, collections, history and preferences are stored on this device. Resetting clears personal data but keeps the downloaded recipe library.', style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 10),
        OutlinedButton.icon(key: const Key('reset-local-data'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red), icon: const Icon(Icons.delete_outline), label: const Text('Reset personal data'),
          onPressed: () async {
            final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
              title: const Text('Reset personal data?'),
              content: const Text('Favorites, meal plans, groceries, pantry, collections, history and preferences will be cleared from this device. Your recipe catalog stays available.'),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Reset data'))],
            ));
            if (confirmed != true || !context.mounted) return;
            state.clearPersonalData();
            PlannerScope.cookingOf(context).clearSession();
            PlannerScope.refresh(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personal data cleared from this device.')));
          }),
      ]),
    );
  }
}
