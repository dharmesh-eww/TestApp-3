import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/core/navigation/animated_page_route.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/features/recipes/presentation/recipe_detail_screen.dart';

class FeaturedRecipe extends StatelessWidget {
  const FeaturedRecipe({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Container(
        height: 300,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: const Color(0xFFE8DFD1)),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image(image: CachedNetworkImageProvider(recipe.image), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE8DFD1))),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC211A16)], stops: [0.35, 1]))),
          Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appStrings(context).label('EDITOR’S PICK', 'اختيار المحرر'), style: TextStyle(color: Color(0xFFFFD5B9), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(recipe.title, style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            Row(children: [
              Icon(Icons.schedule, color: Colors.white70, size: 15),
              const SizedBox(width: 5),
              Text(appStrings(context).label('${recipe.minutes} min', '${recipe.minutes} دقيقة'), style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 12),
              Icon(Icons.circle, color: Color(0xFFB8C18F), size: 7),
              const SizedBox(width: 5),
              Text(recipe.difficulty, style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Icon(Icons.arrow_forward, color: Colors.white),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class RecipeTile extends StatelessWidget {
  const RecipeTile({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(image: CachedNetworkImageProvider(recipe.image), width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE8DFD1), child: Icon(Icons.restaurant))),
        )),
        const SizedBox(height: 8),
        Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700)),
        Text(appStrings(context).label('${recipe.minutes} min · ${recipe.category}', '${recipe.minutes} دقيقة · ${recipe.category}'), style: TextStyle(color: AppTheme.muted, fontSize: 11)),
      ]),
    );
  }
}

class RecipeListTile extends StatelessWidget {
  const RecipeListTile({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.card, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image(
            image: CachedNetworkImageProvider(recipe.image), width: 92, height: 88, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(width: 92, height: 88, child: ColoredBox(color: Color(0xFFE8DFD1), child: Icon(Icons.restaurant))),
          )),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.category.toUpperCase(), style: TextStyle(color: AppTheme.terracotta, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(recipe.title, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(recipe.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            const SizedBox(height: 5),
            Text(appStrings(context).label('${recipe.minutes} min · ${recipe.difficulty}', '${recipe.minutes} دقيقة · ${recipe.difficulty}'), style: TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700)),
          ])),
          Builder(builder: (context) {
            final state = PlannerScope.of(context);
            final favorite = state.isFavorite(recipe.id);
            return IconButton(
              key: Key('toggle-favourite-${recipe.id}'),
              tooltip: favorite
                  ? appStrings(context).label('Remove from favourites', 'إزالة من المفضلة')
                  : appStrings(context).label('Add to favourites', 'إضافة إلى المفضلة'),
              onPressed: () {
                state.toggleFavorite(recipe.id);
                PlannerScope.refresh(context);
              },
              icon: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? AppTheme.terracotta : AppTheme.muted,
              ),
            );
          }),
        ]),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
    TextButton(onPressed: onTap, child: Text(action, style: TextStyle(color: AppTheme.terracotta))),
  ]);
}

class WeekStrip extends StatelessWidget {
  const WeekStrip();

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final names = state.weekStartsOn == 7
        ? ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        : const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
      child: Row(children: List.generate(7, (index) {
        final count = state.mealsFor(names[index]).length;
        return Expanded(child: Column(children: [
          Text(appStrings(context).weekdayShort(names[index]), style: TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          CircleAvatar(radius: 15, backgroundColor: count > 0 ? AppTheme.olive.withOpacity(.15) : AppTheme.paper,
            child: Text('$count', style: TextStyle(color: count > 0 ? AppTheme.olive : AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700))),
        ]));
      })),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppTheme.olive),
      const SizedBox(height: 12),
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
    ]),
  ));
}
