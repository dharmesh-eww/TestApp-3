import 'package:flutter/material.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/recipes/domain/ingredient_matcher.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class IngredientFinderScreen extends StatefulWidget {
  const IngredientFinderScreen({super.key});

  @override
  State<IngredientFinderScreen> createState() => _IngredientFinderScreenState();
}

class _IngredientFinderScreenState extends State<IngredientFinderScreen> {
  final Set<String> _available = {};
  final Set<String> _excluded = {};
  bool _excludeMode = false;
  bool _usePantry = true;

  @override
  Widget build(BuildContext context) {
    final planner = PlannerScope.of(context);
    final recipes = RecipeCatalog.search(RecipeCatalogScope.of(context), allergies: planner.allergies);
    final availableNames = <String>{..._available, if (_usePantry) ...planner.pantry.values.map((item) => item.name)};
    final availableQuantities = <String, ({double amount, String unit})>{
      if (_usePantry) for (final item in planner.pantry.values) item.name: (amount: item.amount, unit: item.unit),
    };
    final ingredients = <String, String>{};
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final id = ingredient.id.isEmpty ? ingredient.name.toLowerCase() : ingredient.id;
        ingredients[id] = ingredient.name;
      }
    }
    final results = IngredientMatcher.rank(recipes, available: availableNames, excluded: _excluded, availableQuantities: availableQuantities);
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Cook with what you have', 'اطبخ بالمكونات المتوفرة لديك'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appStrings(context).label('YOUR INGREDIENT SHELF', 'رف مكوناتك'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(appStrings(context).label('What’s in your kitchen?', 'ماذا يوجد في مطبخك؟'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(appStrings(context).label('Choose ingredients you have, or switch to ingredients you want to avoid. Matches show what is still missing.', 'اختر المكونات المتوفرة لديك أو المكونات التي تريد تجنبها. تعرض النتائج المكونات الناقصة.'), style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(appStrings(context).label('Use my pantry inventory', 'استخدم مخزون مخزني')),
            subtitle: Text(appStrings(context).label('Only count quantities you have recorded. Insufficient amounts stay in the missing list.', 'احتسب الكميات المسجلة فقط. ستظل الكميات غير الكافية ضمن قائمة النواقص.')),
            value: _usePantry,
            onChanged: (value) => setState(() => _usePantry = value),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(appStrings(context).label('I have', 'متوفر لدي')), icon: Icon(Icons.check_circle_outline)),
              ButtonSegment(value: true, label: Text(appStrings(context).label('Exclude', 'استبعاد')), icon: Icon(Icons.block_outlined)),
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
            Expanded(child: Text(appStrings(context).label('Recipe matches', 'الوصفات المطابقة'), style: Theme.of(context).textTheme.titleLarge)),
            Text(appStrings(context).label('${results.length} found', 'تم العثور على ${results.length}'), style: TextStyle(color: AppTheme.muted)),
          ]),
          const SizedBox(height: 10),
          if (availableNames.isEmpty)
            Text(appStrings(context).label('Select at least one ingredient to see match percentages.', 'اختر مكونًا واحدًا على الأقل لعرض نسبة التطابق.'),
                style: TextStyle(color: AppTheme.muted)),
          for (final match in results)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(match.recipe.title, style: TextStyle(fontWeight: FontWeight.w700))),
                    Text('${match.matchPercent}%', style: TextStyle(color: AppTheme.olive, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 5),
                  Text(match.isExactMatch
                      ? appStrings(context).label('You have every listed ingredient', 'لديك جميع المكونات المذكورة')
                      : appStrings(context).label('Missing: ${match.missingIngredients.map((item) => item.name).join(', ')}', 'المكونات الناقصة: ${match.missingIngredients.map((item) => item.name).join('، ')}'),
                    style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, match.recipe),
                      child: Text(appStrings(context).label('View recipe', 'عرض الوصفة')),
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
