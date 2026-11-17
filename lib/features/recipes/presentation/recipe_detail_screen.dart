import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testapp_3/core/navigation/animated_page_route.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/cooking/presentation/cooking_mode_screen.dart';
import 'package:testapp_3/features/planning/presentation/plan_screen.dart';

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppTheme.line)),
    child: Row(children: [Icon(icon, size: 14, color: AppTheme.olive), const SizedBox(width: 5), Text(text, style: TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w600))]),
  );
}

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int servings = 2;
  bool _recordedView = false;

  @override
  void initState() {
    super.initState();
    servings = widget.recipe.servings;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recordedView) {
      _recordedView = true;
      PlannerScope.of(context).recordViewed(widget.recipe);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) PlannerScope.refresh(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final state = PlannerScope.of(context);
    final favorite = state.isFavorite(recipe.id);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280, pinned: true, backgroundColor: AppTheme.paper,
          actions: [
            IconButton(
              tooltip: favorite
                  ? appStrings(context).label('Remove from favourites', 'إزالة من المفضلة')
                  : appStrings(context).label('Add to favourites', 'إضافة إلى المفضلة'),
              onPressed: () {
                state.toggleFavorite(recipe.id);
                PlannerScope.refresh(context);
              },
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? AppTheme.terracotta : AppTheme.ink),
              style: IconButton.styleFrom(backgroundColor: AppTheme.card),
            ),
            IconButton(
              tooltip: appStrings(context).label('Copy recipe', 'نسخ الوصفة'),
              onPressed: () async {
                final text = '${recipe.title}\n\n${recipe.subtitle}\n\nIngredients:\n${recipe.ingredients.map((item) => '• ${item.name}: ${item.amount ?? item.amountType.name} ${item.unit}').join('\n')}\n\nInstructions:\n${recipe.steps.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}';
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Recipe copied to clipboard.', 'تم نسخ الوصفة.'))));
              },
              icon: const Icon(Icons.copy_outlined),
              style: IconButton.styleFrom(backgroundColor: AppTheme.card),
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Image(image: CachedNetworkImageProvider(recipe.image), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE6DED1), child: Icon(Icons.restaurant, size: 48))),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.category.toUpperCase(), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
            const SizedBox(height: 8),
            Text(recipe.title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(recipe.subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.muted)),
            const SizedBox(height: 18),
            Row(children: [
              _MetaPill(icon: Icons.schedule, text: '${recipe.minutes} min'),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.signal_cellular_alt, text: recipe.difficulty),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.local_fire_department_outlined, text: '${recipe.calories} kcal'),
            ]),
            const SizedBox(height: 26),
            Row(children: [
              Expanded(child: Text(appStrings(context).label('Ingredients', 'المكونات'), style: Theme.of(context).textTheme.headlineMedium)),
              IconButton(onPressed: servings > 1 ? () => setState(() => servings--) : null, icon: Icon(Icons.remove_circle_outline)),
              Text(appStrings(context).label('$servings servings', '$servings حصص'), style: TextStyle(fontWeight: FontWeight.w700)),
              IconButton(onPressed: () => setState(() => servings++), icon: Icon(Icons.add_circle_outline)),
            ]),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Icon(Icons.circle, size: 7, color: AppTheme.olive),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: TextStyle(color: AppTheme.ink))),
                Text(item.display(servings, recipe.servings, measurementSystem: state.measurementSystem), style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ]),
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('schedule-recipe-button'),
                onPressed: () => showRecipeScheduleDialog(context, recipe, servings),
                icon: const Icon(Icons.event_available_outlined),
                label: Text(appStrings(context).label('Plan this recipe', 'خطط لهذه الوصفة')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {
                state.addIngredients(recipe, servings);
                PlannerScope.refresh(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Ingredients added to your grocery list', 'تمت إضافة المكونات إلى قائمة المشتريات'))));
              },
              icon: Icon(Icons.add_shopping_cart), label: Text(appStrings(context).label('Add ingredients to grocery list', 'إضافة المكونات إلى قائمة المشتريات')),
            )),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('start-cooking-button'),
                onPressed: () {
                  PlannerScope.cookingOf(context).setServings(recipe.id, servings);
                  Navigator.push(
                    context,
                    AnimatedPageRoute(builder: (_) => CookingModeScreen(recipe: recipe)),
                  );
                },
                icon: Icon(Icons.restaurant_menu),
                label: Text(appStrings(context).label('Start cooking', 'ابدأ الطهي')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  minimumSize: const Size(0, 54),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(appStrings(context).label('Let’s make it', 'هيا نبدأ التحضير'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            ...List.generate(recipe.steps.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.terracotta.withOpacity(.13), child: Text('${index + 1}', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(child: Text(recipe.steps[index], style: Theme.of(context).textTheme.bodyLarge)),
              ]),
            )),
          ]),
        )),
      ]),
    );
  }
}
