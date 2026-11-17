import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/app/app_widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final favourites = RecipeCatalogScope.of(context)
        .where((recipe) => state.isFavorite(recipe.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings(context).favorites),
        backgroundColor: AppTheme.paper,
      ),
      body: favourites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 52, color: AppTheme.olive),
                    const SizedBox(height: 16),
                    Text(
                      appStrings(context).label('No favourite recipes yet', 'لا توجد وصفات مفضلة بعد'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appStrings(context).label(
                        'Save recipes you love and they’ll appear here.',
                        'احفظ الوصفات التي تحبها وستظهر هنا.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const Key('explore-recipes-from-favourites'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.search),
                      label: Text(appStrings(context).label('Explore recipes', 'استكشف الوصفات')),
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Text(
                  appStrings(context).label(
                    '${favourites.length} saved ${favourites.length == 1 ? 'recipe' : 'recipes'}',
                    '${favourites.length} وصفة محفوظة',
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                for (final recipe in favourites)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecipeListTile(recipe: recipe),
                  ),
              ],
            ),
    );
  }
}
