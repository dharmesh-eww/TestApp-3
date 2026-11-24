import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/core/navigation/animated_page_route.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:testapp_3/app/gather_visuals.dart';

class FeaturedRecipe extends StatelessWidget {
  const FeaturedRecipe({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
        child: Container(
          height: 312,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            Image(
              image: CachedNetworkImageProvider(recipe.image),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => GatherVisuals.heroIllustration(),
            ),
            const DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x001A1713), Color(0x241A1713), Color(0xE61A1713)],
                stops: [0, .42, 1],
              ),
            )),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xEFFFFFFF), borderRadius: BorderRadius.circular(30)),
                child: Text(
                  appStrings(context).label('EDITOR’S PICK', 'اختيار المحرر'),
                  style: const TextStyle(color: AppTheme.terracotta, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 27, height: 1.08, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(recipe.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFE9E1D7), fontSize: 12, height: 1.4)),
                const SizedBox(height: 13),
                Row(children: [
                  const Icon(Icons.schedule_rounded, color: Colors.white70, size: 15),
                  const SizedBox(width: 5),
                  Text(appStrings(context).label('${recipe.minutes} min', '${recipe.minutes} دقيقة'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 13),
                  const Icon(Icons.circle, color: Color(0xFFB8C18F), size: 7),
                  const SizedBox(width: 5),
                  Text(recipe.difficulty, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(color: AppTheme.terracotta, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 520.ms).slideY(begin: .07, end: 0, curve: Curves.easeOutCubic);
  }
}

class RecipeTile extends StatelessWidget {
  const RecipeTile({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image(
              image: CachedNetworkImageProvider(recipe.image),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => GatherVisuals.heroIllustration(),
            ),
          )),
          const SizedBox(height: 10),
          Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 3),
          Text(appStrings(context).label('${recipe.minutes} min · ${recipe.category}', '${recipe.minutes} دقيقة · ${recipe.category}'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
        ]),
      ),
    ).animate().fadeIn(duration: 420.ms).slideY(begin: .04, end: 0);
  }
}

class RecipeListTile extends StatelessWidget {
  const RecipeListTile({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, AnimatedPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image(
                image: CachedNetworkImageProvider(recipe.image),
                width: 100,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(width: 100, height: 96, child: GatherVisuals.heroIllustration()),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.category.toUpperCase(), style: const TextStyle(color: AppTheme.terracotta, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 14, height: 1.2)),
              const SizedBox(height: 5),
              Text(recipe.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.35)),
              const SizedBox(height: 7),
              Text(appStrings(context).label('${recipe.minutes} min · ${recipe.difficulty}', '${recipe.minutes} دقيقة · ${recipe.difficulty}'), style: TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w800)),
            ])),
            const SizedBox(width: 4),
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
                icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? AppTheme.terracotta : AppTheme.muted),
              );
            }),
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 360.ms).slideY(begin: .035, end: 0, curve: Curves.easeOut);
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
    TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w700))),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(children: List.generate(7, (index) {
        final count = state.mealsFor(names[index]).length;
        return Expanded(child: Column(children: [
          Text(appStrings(context).weekdayShort(names[index]), style: TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          AnimatedContainer(
            duration: AppMotion.quick,
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: count > 0 ? AppTheme.olive.withOpacity(.16) : AppTheme.paper,
              shape: BoxShape.circle,
              border: Border.all(color: count > 0 ? AppTheme.olive.withOpacity(.35) : AppTheme.line),
            ),
            alignment: Alignment.center,
            child: Text('$count', style: TextStyle(color: count > 0 ? AppTheme.olive : AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
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
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppTheme.line),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 18, offset: const Offset(0, 7))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: AppTheme.olive.withOpacity(.13), borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: AppTheme.olive, size: 20),
      ),
      const SizedBox(height: 14),
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.3)),
    ]),
  ));
}
