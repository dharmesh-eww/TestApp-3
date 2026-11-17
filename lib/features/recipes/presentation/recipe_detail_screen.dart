import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testapp_3/core/navigation/animated_page_route.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';
import 'package:testapp_3/features/recipes/domain/ingredient_substitution_service.dart';
import 'package:testapp_3/features/recipes/presentation/custom_recipe_editor_screen.dart';
import 'package:testapp_3/features/recipes/presentation/recipe_video_screen.dart';
import 'package:testapp_3/features/cooking/presentation/cooking_mode_screen.dart';
import 'package:testapp_3/features/planning/presentation/plan_screen.dart';

String vitaminLabel(String key) {
  final normalized = key.toLowerCase().replaceAll('_mg', '').replaceAll('_mcg', '').replaceAll('_ug', '').replaceAll('_', ' ');
  if (normalized.startsWith('vitamin ')) return normalized.replaceFirst('vitamin ', 'Vit. ').toUpperCase();
  return 'Vit. ${normalized.toUpperCase()}';
}

String seasonLabel(String season) => switch (season.toLowerCase()) { 'rainy' || 'monsoon' => 'Rainy season', 'winter' => 'Winter', 'summer' => 'Summer', 'spring' => 'Spring', 'autumn' || 'fall' => 'Autumn', _ => season };

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
  late final TextEditingController _noteController;
  bool _loadedNote = false;

  @override
  void initState() {
    super.initState();
    servings = widget.recipe.servings;
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
    if (!_loadedNote) {
      _noteController.text = state.recipeNotes[recipe.id] ?? '';
      _loadedNote = true;
    }
    final rating = state.recipeRatings[recipe.id] ?? 0;
    final allergyBlocked = RecipeCatalog.search([recipe], allergies: state.allergies).isEmpty;
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
            if (widget.recipe.id.startsWith('custom-'))
              IconButton(
                tooltip: appStrings(context).label('Edit recipe', 'تعديل الوصفة'),
                onPressed: () async {
                  final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CustomRecipeEditorScreen(recipe: widget.recipe)));
                  if (saved == true && mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.edit_outlined),
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
            if (allergyBlocked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withOpacity(.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(.3))),
                child: Text(appStrings(context).label('Blocked by your allergy settings or missing verified allergen data. Do not prepare this recipe until you have checked every ingredient.', 'تم حظر الوصفة بسبب إعدادات الحساسية أو نقص بيانات مسببات الحساسية الموثقة. لا تحضّر هذه الوصفة قبل التحقق من جميع المكونات.'), style: const TextStyle(color: Colors.red)),
              ),
            ],
            const SizedBox(height: 18),
            Row(children: [
              _MetaPill(icon: Icons.schedule, text: '${recipe.minutes} min'),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.signal_cellular_alt, text: recipe.difficulty),
              const SizedBox(width: 8),
              if (recipe.calories > 0) _MetaPill(icon: Icons.local_fire_department_outlined, text: '${recipe.calories} kcal'),
            ]),
            if (recipe.proteinGrams > 0 || recipe.carbsGrams > 0 || recipe.fatGrams > 0) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                if (recipe.proteinGrams > 0) _MetaPill(icon: Icons.fitness_center, text: 'P ${recipe.proteinGrams.round()} g'),
                if (recipe.carbsGrams > 0) _MetaPill(icon: Icons.grain, text: 'C ${recipe.carbsGrams.round()} g'),
                if (recipe.fatGrams > 0) _MetaPill(icon: Icons.water_drop_outlined, text: 'F ${recipe.fatGrams.round()} g'),
              ]),
            ],
            if (recipe.youtubeVideoUrl != null) ...[
              const SizedBox(height: 22),
              Text(appStrings(context).recipeLabel('Recipe video'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(appStrings(context).recipeLabel('Watch the step-by-step video for this recipe.'), style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 12),
              RecipeYoutubeEmbed(videoUrl: recipe.youtubeVideoUrl!, title: recipe.title),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  key: const Key('open-recipe-youtube-video'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RecipeVideoScreen(recipeTitle: recipe.title, videoUrl: recipe.youtubeVideoUrl!),
                  )),
                  icon: const Icon(Icons.fullscreen),
                  label: Text(appStrings(context).recipeLabel('Watch full video')),
                ),
              ),
            ],
            if (recipe.fiberGrams != null || recipe.vitamins.isNotEmpty || recipe.healthBenefits.isNotEmpty || recipe.seasons.isNotEmpty) ...[
              const SizedBox(height: 20),
              if (recipe.fiberGrams != null || recipe.vitamins.isNotEmpty) ...[
                Text(appStrings(context).recipeLabel('Nutrition details'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  if (recipe.fiberGrams != null) _MetaPill(icon: Icons.grass_outlined, text: '${appStrings(context).recipeLabel('Fiber')} ${recipe.fiberGrams!.toStringAsFixed(1)} g'),
                  for (final vitamin in recipe.vitamins.entries) _MetaPill(icon: Icons.local_florist_outlined, text: '${vitaminLabel(vitamin.key)} ${vitamin.value.toStringAsFixed(1)}'),
                ]),
              ],
              if (recipe.healthBenefits.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(appStrings(context).recipeLabel('Health benefits'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...recipe.healthBenefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.check_circle_outline, size: 17, color: AppTheme.olive),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit, style: TextStyle(color: AppTheme.ink))),
                  ]),
                )),
              ],
              if (recipe.seasons.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(appStrings(context).recipeLabel('Seasonal suitability'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: recipe.seasons.map((season) => Chip(
                  label: Text(appStrings(context).recipeLabel(seasonLabel(season))),
                  visualDensity: VisualDensity.compact,
                )).toList()),
              ],
            ],
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(appStrings(context).label('Your rating', 'تقييمك'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(children: [
                    for (var star = 1; star <= 5; star++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () { state.setRecipeRating(recipe.id, star); PlannerScope.refresh(context); },
                        icon: Icon(star <= rating ? Icons.star : Icons.star_border, color: AppTheme.terracotta),
                      ),
                    if (rating > 0) Text('$rating/5', style: TextStyle(color: AppTheme.muted)),
                  ]),
                  TextField(
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: appStrings(context).label('Personal cooking notes', 'ملاحظاتك الخاصة للطهي')),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () { state.setRecipeNote(recipe.id, _noteController.text); PlannerScope.refresh(context); },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(appStrings(context).label('Save note', 'حفظ الملاحظة')),
                    ),
                  ),
                ]),
              ),
            ),
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
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _showSubstitutions(context, recipe),
                icon: const Icon(Icons.swap_horiz),
                label: Text(appStrings(context).label('Ingredient substitutions', 'بدائل المكونات')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('schedule-recipe-button'),
                onPressed: allergyBlocked ? null : () => showRecipeScheduleDialog(context, recipe, servings),
                icon: const Icon(Icons.event_available_outlined),
                label: Text(appStrings(context).label('Plan this recipe', 'خطط لهذه الوصفة')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: allergyBlocked ? null : () {
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
                onPressed: allergyBlocked ? null : () {
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

  Future<void> _showSubstitutions(BuildContext context, Recipe recipe) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * .65,
            child: ListView(
              children: [
                Text(appStrings(context).label('Ingredient substitutions', 'بدائل المكونات'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(appStrings(context).label('Suggestions may change flavour or texture. Check all labels and allergy warnings before using a substitute.', 'قد تغير الاقتراحات النكهة أو القوام. تحقق من الملصقات وتحذيرات الحساسية قبل استخدام أي بديل.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                const SizedBox(height: 14),
                for (final ingredient in recipe.ingredients) ...[
                  Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  if (IngredientSubstitutionService.alternativesFor(ingredient.name).isEmpty)
                    Text(appStrings(context).label('No curated suggestion available.', 'لا يوجد اقتراح بديل متاح.'), style: TextStyle(color: AppTheme.muted, fontSize: 12))
                  else
                    for (final alternative in IngredientSubstitutionService.alternativesFor(ingredient.name))
                      Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $alternative')),
                  const Divider(height: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
