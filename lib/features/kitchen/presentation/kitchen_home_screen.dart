import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/features/kitchen/presentation/collections_screen.dart';
import 'package:testapp_3/features/kitchen/presentation/cooking_history_screen.dart';
import 'package:testapp_3/features/kitchen/presentation/settings_screen.dart';
import 'package:testapp_3/app/app_widgets.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key, required this.onLocaleChanged});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final saved = RecipeCatalogScope.of(context).where((recipe) => state.favorites.contains(recipe.id)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(appStrings(context).label('YOUR LITTLE COOKBOOK', 'كتاب وصفاتك الصغير'), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(appStrings(context).label('Your kitchen,\nyour rhythm.', 'مطبخك،\nإيقاعك الخاص.'), style: TextStyle(fontFamily: 'Georgia', fontSize: 32, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(children: [
          StatCard(value: '${saved.length}', label: 'Saved recipes', icon: Icons.bookmark_outline),
          const SizedBox(width: 10),
          StatCard(value: '${state.plannedMealCount}', label: 'Meals planned', icon: Icons.calendar_month_outlined),
        ]),
        const SizedBox(height: 20),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionsScreen())),
            icon: Icon(Icons.folder_open), label: Text(appStrings(context).label('Collections', 'المجموعات')),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CookingHistoryScreen())),
            icon: Icon(Icons.history), label: Text(appStrings(context).label('Cooking history', 'سجل الطهي')),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(onLocaleChanged: onLocaleChanged))),
            icon: Icon(Icons.tune), label: Text(appStrings(context).label('Settings', 'الإعدادات')),
          ),
        ]),
        const SizedBox(height: 20),
        Text(appStrings(context).label('Recently viewed', 'شوهدت مؤخرًا'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (state.recentlyViewed.isEmpty)
          Text(appStrings(context).label('Recipes you open will appear here.', 'ستظهر هنا الوصفات التي تفتحها.'), style: TextStyle(color: AppTheme.muted))
        else
          ...state.recentlyViewed.take(5).map((entry) {
            final recipe = RecipeCatalogScope.of(context).where((item) => item.id == entry['recipe_id']).firstOrNull;
            if (recipe == null) return const SizedBox.shrink();
            return Padding(padding: const EdgeInsets.only(bottom: 8), child: RecipeListTile(recipe: recipe));
          }),
        const SizedBox(height: 22),
        Text(appStrings(context).label('Your saved recipes', 'وصفاتك المحفوظة'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appStrings(context).label('Recipe library', 'مكتبة الوصفات'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(appStrings(context).label('Content version: ${RecipeCatalogScope.versionOf(context)}', 'إصدار المحتوى: ${RecipeCatalogScope.versionOf(context)}'), style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 8),
              Text(appStrings(context).label('Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.', 'تحقق من تحديثات الوصفات المختارة. تظل خطط وجباتك ومخزنك ووصفاتك المحفوظة على هذا الجهاز.'), style: TextStyle(color: AppTheme.muted)),
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
                  icon: Icon(Icons.sync),
                  label: Text(appStrings(context).label('Check for updates', 'التحقق من التحديثات')),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 12),
        if (saved.isEmpty)
          Text(appStrings(context).label('Recipes you save will live here. Tap the bookmark on any recipe you love.', 'ستظهر هنا الوصفات التي تحفظها. اضغط علامة الحفظ على أي وصفة تعجبك.'), style: TextStyle(color: AppTheme.muted))
        else
          ...saved.map((recipe) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RecipeListTile(recipe: recipe),
          )),
      ],
    );
  }
}
