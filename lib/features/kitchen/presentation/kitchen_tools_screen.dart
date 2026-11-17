import 'package:flutter/material.dart';

import '../../../app/planner_scope.dart';
import '../../../app/recipe_catalog_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../recipes/domain/ingredient_matcher.dart';
import '../../recipes/domain/recipe.dart';
import '../../../localization/app_localizations.dart';

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
          const SizedBox(height: 16),
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
          if (_available.isEmpty)
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
      appBar: AppBar(title: Text(appStrings(context).label('Cooking history', 'سجل الطهي'))),
      body: history.isEmpty
          ? Center(child: Text(appStrings(context).label('Recipes you finish cooking will appear here.', 'ستظهر هنا الوصفات التي تنتهي من طهيها.')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final date = DateTime.tryParse(item['completed_at'] ?? '');
                return ListTile(
                  leading: CircleAvatar(child: Icon(Icons.restaurant_menu)),
                  title: Text(item['title'] ?? 'Recipe'),
                  subtitle: Text(date == null ? '' : MaterialLocalizations.of(context).formatMediumDate(date)),
                );
              },
            ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLocaleChanged});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Settings', 'الإعدادات'))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(
          child: ListTile(
            key: const Key('open-language-selection'),
            leading: const Icon(Icons.language),
            title: Text(appStrings(context).label('Language', 'اللغة')),
            subtitle: Text(appStrings(context).languageName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LanguageSelectionScreen(
                  locale: currentLocale,
                  onLocaleChanged: onLocaleChanged,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('MEASUREMENTS', 'وحدات القياس'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.measurementSystem,
          decoration: InputDecoration(labelText: appStrings(context).label('Measurement system', 'نظام القياس')),
          items: [
            DropdownMenuItem(value: 'metric', child: Text(appStrings(context).label('Metric (g, kg, ml, L)', 'النظام المتري (g، kg، ml، L)'))),
            DropdownMenuItem(value: 'us', child: Text(appStrings(context).label('US customary (oz, lb, cups)', 'النظام الأمريكي (oz، lb، cups)'))),
          ],
          onChanged: (value) {
            if (value == null) return;
            state.measurementSystem = value;
            PlannerScope.refresh(context);
          },
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('WEEKLY PLANNER', 'مخطط الأسبوع'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: state.weekStartsOn,
          decoration: InputDecoration(labelText: appStrings(context).label('First day of week', 'أول يوم في الأسبوع')),
          items: [
            DropdownMenuItem(value: 1, child: Text(appStrings(context).label('Monday', 'الإثنين'))),
            DropdownMenuItem(value: 7, child: Text(appStrings(context).label('Sunday', 'الأحد'))),
          ],
          onChanged: (value) {
            if (value == null) return;
            state.weekStartsOn = value;
            PlannerScope.refresh(context);
          },
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('APPEARANCE', 'المظهر'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.themePreference,
          decoration: InputDecoration(labelText: appStrings(context).label('Theme', 'السمة')),
          items: [
            DropdownMenuItem(value: 'system', child: Text(appStrings(context).label('Use device setting', 'استخدام إعداد الجهاز'))),
            DropdownMenuItem(value: 'light', child: Text(appStrings(context).label('Light', 'فاتح'))),
            DropdownMenuItem(value: 'dark', child: Text(appStrings(context).label('Dark', 'داكن'))),
          ],
          onChanged: (value) { if (value == null) return; state.themePreference = value; PlannerScope.refresh(context); },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(appStrings(context).label('Reduce motion', 'تقليل الحركة')),
          subtitle: Text(appStrings(context).label('Use simpler transitions throughout the app.', 'استخدام انتقالات أبسط في التطبيق.')),
          value: state.reduceMotion,
          onChanged: (value) { state.reduceMotion = value; PlannerScope.refresh(context); },
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('PERSONAL DISCOVERY', 'اكتشاف مخصص'), style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(appStrings(context).label('Prefer recipes with these dietary tags. Discover will apply every selected tag.', 'فضّل الوصفات التي تحمل هذه التصنيفات الغذائية. سيطبق قسم الاكتشاف جميع التصنيفات المحددة.'), style: TextStyle(color: AppTheme.muted)),
        for (final option in const {'plant_based': 'Plant based', 'gluten_free': 'Gluten free', 'dairy_free': 'Dairy free', 'high_protein': 'High protein'}.entries)
          CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(appStrings(context).dietaryTag(option.key)), value: state.preferredDietaryTags.contains(option.key),
            onChanged: (selected) { if (selected == true) { state.preferredDietaryTags.add(option.key); } else { state.preferredDietaryTags.remove(option.key); } PlannerScope.refresh(context); }),
        const SizedBox(height: 16),
        Text(appStrings(context).label('Conversions are shown only within compatible dimensions. Mass is never converted to volume without ingredient-specific density.', 'تُعرض التحويلات بين الوحدات المتوافقة فقط. لا يتم تحويل الكتلة إلى حجم دون معرفة كثافة المكوّن.'), style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 28),
        Text(appStrings(context).label('LOCAL DATA', 'البيانات المحلية'), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.terracotta, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(appStrings(context).label('Favorites, meal plans, groceries, pantry, collections, history and preferences are stored on this device. Resetting clears personal data but keeps the downloaded recipe library.', 'تُخزّن المفضلة وخطط الوجبات والمشتريات والمخزن والمجموعات والسجل والتفضيلات على هذا الجهاز. يؤدي إعادة الضبط إلى مسح بياناتك الشخصية مع الاحتفاظ بمكتبة الوصفات التي تم تنزيلها.'), style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 10),
        OutlinedButton.icon(key: const Key('reset-local-data'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red), icon: Icon(Icons.delete_outline), label: Text(appStrings(context).label('Reset personal data', 'إعادة ضبط البيانات الشخصية')),
          onPressed: () async {
            final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
              title: Text(appStrings(context).label('Reset personal data?', 'هل تريد إعادة ضبط البيانات الشخصية؟')),
              content: Text(appStrings(context).label('Favorites, meal plans, groceries, pantry, collections, history and preferences will be cleared from this device. Your recipe catalog stays available.', 'سيتم مسح المفضلة وخطط الوجبات والمشتريات والمخزن والمجموعات والسجل والتفضيلات من هذا الجهاز. ستظل مكتبة الوصفات متاحة.')),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Reset data', 'إعادة ضبط البيانات')))],
            ));
            if (confirmed != true || !context.mounted) return;
            state.clearPersonalData();
            PlannerScope.cookingOf(context).clearSession();
            PlannerScope.refresh(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Personal data cleared from this device.', 'تم مسح البيانات الشخصية من هذا الجهاز.'))));
          }),
      ]),
    );
  }
}


class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings(context).label('Language', 'اللغة')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            appStrings(context).label('CHOOSE YOUR LANGUAGE', 'اختر لغتك'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.terracotta,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-english'),
              value: 'en',
              groupValue: locale.languageCode,
              title: const Text('English'),
              secondary: const Text('EN'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-hindi'),
              value: 'hi',
              groupValue: locale.languageCode,
              title: const Text('हिन्दी'),
              secondary: const Text('HI'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('hi'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-gujarati'),
              value: 'gu',
              groupValue: locale.languageCode,
              title: const Text('ગુજરાતી'),
              secondary: const Text('GU'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('gu'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-arabic'),
              value: 'ar',
              groupValue: locale.languageCode,
              title: const Text('العربية'),
              secondary: const Text('AR'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
