import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/kitchen/presentation/collections_screen.dart';
import 'package:testapp_3/features/kitchen/presentation/cooking_history_screen.dart';
import 'package:testapp_3/features/kitchen/presentation/settings_screen.dart';
import 'package:testapp_3/features/recipes/presentation/custom_recipe_editor_screen.dart';
import 'package:testapp_3/features/recipes/presentation/custom_recipes_screen.dart';
import 'package:testapp_3/app/app_widgets.dart';
import 'package:testapp_3/app/gather_visuals.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key, required this.onLocaleChanged});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final catalog = RecipeCatalogScope.of(context);
    final saved = catalog.where((recipe) => state.favorites.contains(recipe.id)).toList();
    final recent = state.recentlyViewed.take(5).map((entry) =>
      catalog.where((item) => item.id == entry['recipe_id']).firstOrNull,
    ).whereType<dynamic>().toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Text(appStrings(context).label('YOUR LITTLE COOKBOOK', 'كتاب وصفاتك الصغير'),
          style: TextStyle(color: AppTheme.terracotta, fontSize: 10,
            fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: Text(
            appStrings(context).label('Your kitchen,\\nyour rhythm.', 'مطبخك،\\nإيقاعك الخاص.'),
            style: TextStyle(fontFamily: 'Georgia', fontSize: 31,
              height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold),
          )),
          GatherVisuals.foodMotion(size: 82),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(color: AppTheme.ink, borderRadius: BorderRadius.circular(21)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appStrings(context).label('YOUR COOKBOOK AT A GLANCE', 'ملخص كتاب وصفاتك'),
                style: TextStyle(color: Colors.white70, fontSize: 9,
                  letterSpacing: 1.1, fontWeight: FontWeight.w800)),
              const SizedBox(height: 9),
              Text(appStrings(context).label('A place for every good idea.', 'مكان لكل فكرة لذيذة.'),
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(appStrings(context).label(
                'Keep favourites, personal recipes and cooking memories together.',
                'احتفظ بوصفاتك المفضلة ووصفاتك الخاصة وذكريات الطهي في مكان واحد.'),
                style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
            ])),
            const SizedBox(width: 8),
            Column(children: [
              _KitchenStat(value: '${saved.length}', label: appStrings(context).label('Saved', 'محفوظ')),
              const SizedBox(height: 10),
              _KitchenStat(value: '${state.plannedMealCount}', label: appStrings(context).label('Planned', 'مخطط')),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(child: Text(appStrings(context).label('Your kitchen space', 'مساحة مطبخك'),
            style: Theme.of(context).textTheme.titleLarge)),
          Text(appStrings(context).label('5 spaces', '5 أقسام'),
            style: TextStyle(color: AppTheme.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 11),
        _KitchenDestinationCard(
          icon: Icons.menu_book_rounded,
          title: appStrings(context).label('My recipes', 'وصفاتي'),
          subtitle: appStrings(context).label('Your personal recipe book', 'دفتر وصفاتك الشخصي'),
          tint: const Color(0xFFF4E4D8),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomRecipesScreen())),
        ),
        const SizedBox(height: 9),
        _KitchenDestinationCard(
          icon: Icons.edit_note_rounded,
          title: appStrings(context).label('Create a recipe', 'إنشاء وصفة'),
          subtitle: appStrings(context).label('Save a recipe of your own', 'احفظ وصفة من ابتكارك'),
          tint: const Color(0xFFE9EEDC),
          key: const Key('create-custom-recipe'),
          trailing: Icon(Icons.add_circle_outline, color: AppTheme.terracotta),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomRecipeEditorScreen())),
        ),
        const SizedBox(height: 9),
        _KitchenDestinationCard(
          icon: Icons.collections_bookmark_outlined,
          title: appStrings(context).label('Collections', 'المجموعات'),
          subtitle: appStrings(context).label('Organise recipes by mood or moment', 'نظّم الوصفات حسب المناسبة أو المزاج'),
          tint: const Color(0xFFE7EBE5),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionsScreen())),
        ),
        const SizedBox(height: 9),
        _KitchenDestinationCard(
          icon: Icons.history_rounded,
          title: appStrings(context).label('Cooking history', 'سجل الطهي'),
          subtitle: appStrings(context).label('Revisit what you have cooked', 'ارجع إلى ما قمت بطهيه'),
          tint: const Color(0xFFF5EEDC),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CookingHistoryScreen())),
        ),
        const SizedBox(height: 9),
        _KitchenDestinationCard(
          icon: Icons.tune_rounded,
          title: appStrings(context).label('Kitchen settings', 'إعدادات المطبخ'),
          subtitle: appStrings(context).label('Diet, preferences and app options', 'النظام الغذائي والتفضيلات وخيارات التطبيق'),
          tint: const Color(0xFFECE8F1),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => SettingsScreen(onLocaleChanged: onLocaleChanged))),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Text(appStrings(context).label('Recently viewed', 'شوهدت مؤخرًا'),
            style: Theme.of(context).textTheme.titleLarge)),
          if (recent.isNotEmpty)
            Text('${recent.length}', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          _KitchenEmptyHint(
            icon: Icons.auto_stories_outlined,
            text: appStrings(context).label('Recipes you open will show up here.', 'ستظهر هنا الوصفات التي تفتحها.'),
          )
        else
          for (final recipe in recent)
            Padding(padding: const EdgeInsets.only(bottom: 9),
              child: RecipeListTile(recipe: recipe)),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(child: Text(appStrings(context).label('Saved recipes', 'وصفاتك المحفوظة'),
            style: Theme.of(context).textTheme.titleLarge)),
          Text('${saved.length}', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        if (saved.isEmpty)
          Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(color: AppTheme.card,
                borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
              child: Column(children: [
                GatherVisuals.emptyKitchenIllustration(width: 190, height: 132),
                const SizedBox(height: 8),
                Text(appStrings(context).label('Your next favourite starts with a bookmark.',
                  'تبدأ وصفتك المفضلة التالية بعلامة حفظ.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted, fontSize: 12)),
              ]),
            ),
          ])
        else
          for (final recipe in saved)
            Padding(padding: const EdgeInsets.only(bottom: 10),
              child: RecipeListTile(recipe: recipe)),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card,
            borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.library_books_outlined, color: AppTheme.olive),
              const SizedBox(width: 9),
              Expanded(child: Text(appStrings(context).label('Recipe library', 'مكتبة الوصفات'),
                style: Theme.of(context).textTheme.titleMedium)),
              Text('v${RecipeCatalogScope.versionOf(context)}',
                style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            ]),
            const SizedBox(height: 7),
            Text(appStrings(context).label(
              'Check for curated recipe updates. Your plans, pantry and saved recipes stay on this device.',
              'تحقق من تحديثات الوصفات المختارة. تظل خططك ومخزنك ووصفاتك المحفوظة على هذا الجهاز.'),
              style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.45)),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: const Key('check-recipe-updates'),
                onPressed: RecipeCatalogScope.canCheckForUpdates(context) ? () async {
                  final updated = await RecipeCatalogScope.checkForUpdates(context);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(updated ? 'Recipe library updated.' : 'No update available. Current library kept.'),
                  ));
                } : null,
                icon: Icon(Icons.sync_rounded),
                label: Text(appStrings(context).label('Check for updates', 'التحقق من التحديثات')),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _KitchenStat extends StatelessWidget {
  const _KitchenStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
    Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
  ]);
}

class _KitchenDestinationCard extends StatelessWidget {
  const _KitchenDestinationCard({
    super.key, required this.icon, required this.title, required this.subtitle,
    required this.tint, required this.onTap, this.trailing,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.card,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppTheme.line)),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppTheme.ink, size: 23)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
          ])),
          trailing ?? Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        ]),
      ),
    ),
  );
}

class _KitchenEmptyHint extends StatelessWidget {
  const _KitchenEmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppTheme.line)),
    child: Row(children: [
      Icon(icon, color: AppTheme.olive),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(color: AppTheme.muted, fontSize: 12))),
    ]),
  );
}
