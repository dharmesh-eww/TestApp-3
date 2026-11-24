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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(color: AppTheme.paper,
            border: Border(top: BorderSide(color: AppTheme.line)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14, offset: const Offset(0, -4))]),
          child: Row(children: [
            Expanded(flex: 4, child: OutlinedButton(
              key: const Key('schedule-recipe-button'),
              onPressed: allergyBlocked ? null : () => showRecipeScheduleDialog(context, recipe, servings),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
                side: const BorderSide(color: AppTheme.line), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calendar_month_outlined, size: 18), const SizedBox(height: 3),
                Text(appStrings(context).label('Plan', 'خطط'), maxLines: 1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ]),
            )),
            const SizedBox(width: 8),
            Expanded(flex: 5, child: OutlinedButton(
              onPressed: allergyBlocked ? null : () {
                state.addIngredients(recipe, servings);
                PlannerScope.refresh(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Ingredients added to your grocery list', 'تمت إضافة المكونات إلى قائمة المشتريات'))));
              },
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
                side: const BorderSide(color: AppTheme.olive), foregroundColor: AppTheme.olive,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_shopping_cart_outlined, size: 18), const SizedBox(height: 3),
                Text(appStrings(context).label('Add items', 'أضف'), maxLines: 1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ]),
            )),
            const SizedBox(width: 8),
            Expanded(flex: 7, child: FilledButton(
              key: const Key('start-cooking-button'),
              onPressed: allergyBlocked ? null : () {
                PlannerScope.cookingOf(context).setServings(recipe.id, servings);
                Navigator.push(context, AnimatedPageRoute(builder: (_) => CookingModeScreen(recipe: recipe)));
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta, minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.restaurant_menu_rounded, size: 18), const SizedBox(height: 3),
                Text(appStrings(context).label('Start cooking', 'ابدأ الطهي'), maxLines: 1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
            )),
          ]),
        ),
      ),
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
            const SizedBox(height: 26),
            _buildCookingTips(context, recipe),
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


  Widget _buildCookingTips(BuildContext context, Recipe recipe) {
    final ingredientNames = recipe.ingredients.map((item) => item.name.toLowerCase()).join(' ');
    final instructions = recipe.steps.join(' ').toLowerCase();
    final tips = <(String, String)>[
      (
        appStrings(context).label('Prep before you cook', 'حضّر المكونات قبل الطهي'),
        appStrings(context).label(
          'Read all the steps first, then wash, chop and measure the ingredients. Keep them within reach so you can focus on cooking.',
          'اقرأ جميع الخطوات أولًا، ثم اغسل المكونات وقطّعها وقِس كمياتها. ضعها بالقرب منك لتتمكن من التركيز على الطهي.',
        ),
      ),
      if (ingredientNames.contains('garlic') || ingredientNames.contains('onion'))
        (
          appStrings(context).label('Build flavour gently', 'ابدأ ببناء النكهة بهدوء'),
          appStrings(context).label(
            'Cook the onion until softened before adding garlic. Stir the garlic briefly and avoid letting it brown too much, which can make it taste bitter.',
            'اطهِ البصل حتى يلين قبل إضافة الثوم. قلّب الثوم لفترة قصيرة وتجنب تحميره كثيرًا حتى لا يصبح مذاقه مُرًا.',
          ),
        ),
      if (ingredientNames.contains('chicken') || ingredientNames.contains('salmon') || ingredientNames.contains('fish') || ingredientNames.contains('beef'))
        (
          appStrings(context).label('Give protein room to cook', 'اترك مساحة كافية للبروتين أثناء الطهي'),
          appStrings(context).label(
            'Avoid overcrowding the pan. Cook in batches if needed so the surface browns instead of steaming, and check that it is safely cooked through.',
            'تجنب ازدحام المقلاة. اطهِ المكونات على دفعات عند الحاجة حتى تتحمر بدلًا من أن تتبخر، وتأكد من نضجها بأمان.',
          ),
        ),
      if (ingredientNames.contains('rice') || ingredientNames.contains('pasta') || ingredientNames.contains('noodle'))
        (
          appStrings(context).label('Watch your grains', 'انتبه إلى نضج الحبوب والمعكرونة'),
          appStrings(context).label(
            'Check the rice, pasta or noodles a little before the suggested cooking time. Drain or rest them as appropriate so they keep their texture.',
            'تحقق من الأرز أو المعكرونة أو النودلز قبل موعد النضج المتوقع بقليل. صفِّها أو اتركها لترتاح حسب الحاجة للحفاظ على قوامها.',
          ),
        ),
      if (ingredientNames.contains('lemon') || ingredientNames.contains('lime') || ingredientNames.contains('vinegar'))
        (
          appStrings(context).label('Balance with acidity', 'وازن النكهة بالحموضة'),
          appStrings(context).label(
            'Add citrus juice or vinegar gradually, then taste. A little acidity near the end can brighten rich or savoury flavours.',
            'أضف عصير الحمضيات أو الخل تدريجيًا ثم تذوق. يمكن لكمية صغيرة من الحموضة في النهاية أن تُبرز النكهات الغنية والمالحة.',
          ),
        ),
      if (instructions.contains('simmer') || instructions.contains('sauce') || ingredientNames.contains('coconut milk'))
        (
          appStrings(context).label('Keep sauces under control', 'تحكم في قوام الصلصة'),
          appStrings(context).label(
            'Once the sauce is simmering, lower the heat and stir from time to time. A gentle simmer helps flavours come together without scorching.',
            'بعد بدء غليان الصلصة بهدوء، خفّض الحرارة وقلّب من حين لآخر. يساعد الغليان الخفيف على امتزاج النكهات دون احتراق.',
          ),
        ),
      (
        appStrings(context).label('Taste and adjust at the end', 'تذوق واضبط النكهة في النهاية'),
        appStrings(context).label(
          'Taste before serving. Adjust salt, pepper and herbs a little at a time so the main ingredients remain the star.',
          'تذوق الطعام قبل التقديم. اضبط الملح والفلفل والأعشاب تدريجيًا حتى تبقى المكونات الأساسية هي الأبرز.',
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appStrings(context).label('Cook’s tips', 'نصائح الطهي'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          appStrings(context).label('A few helpful pointers for this recipe', 'إرشادات مفيدة لتحضير هذه الوصفة'),
          style: TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.terracotta, size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.$1, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(tip.$2, style: TextStyle(color: AppTheme.muted, height: 1.4, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _showSubstitutions(BuildContext context, Recipe recipe) async {
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * .78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.olive.withOpacity(.12), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.swap_horiz_rounded, color: AppTheme.olive)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(appStrings(sheetContext).label('Ingredient swaps', 'بدائل المكونات'), style: Theme.of(sheetContext).textTheme.titleLarge),
                Text(appStrings(sheetContext).label('Ideas for what you have on hand', 'أفكار للمكونات المتوفرة لديك'), style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
              ])),
              IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close_rounded)),
            ]),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF1E8), borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.terracotta, size: 18), const SizedBox(width: 9),
                Expanded(child: Text(appStrings(sheetContext).label(
                  'Swaps can change flavour and texture. Always check ingredient labels and allergy warnings before using an alternative.',
                  'قد تغير البدائل النكهة والقوام. تحقق دائمًا من ملصقات المكونات وتحذيرات الحساسية قبل استخدام أي بديل.'),
                  style: const TextStyle(color: AppTheme.ink, fontSize: 11, height: 1.4))),
              ])),
            const SizedBox(height: 14),
            Expanded(child: ListView.separated(
              itemCount: recipe.ingredients.length, separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final ingredient = recipe.ingredients[index];
                final alternatives = IngredientSubstitutionService.alternativesFor(ingredient.name);
                return Container(padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.line)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.restaurant_outlined, color: AppTheme.terracotta, size: 17), const SizedBox(width: 8),
                      Expanded(child: Text(ingredient.name, style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800))),
                      Text('${index + 1}/${recipe.ingredients.length}', style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
                    ]),
                    const SizedBox(height: 9),
                    if (alternatives.isEmpty)
                      Text(appStrings(sheetContext).label('No suggested swaps for this ingredient yet.', 'لا توجد بدائل مقترحة لهذا المكون حاليًا.'),
                        style: const TextStyle(color: AppTheme.muted, fontSize: 11))
                    else Wrap(spacing: 7, runSpacing: 7, children: [
                      for (final alternative in alternatives)
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(color: AppTheme.olive.withOpacity(.10), borderRadius: BorderRadius.circular(20)),
                          child: Text(alternative, style: const TextStyle(color: AppTheme.olive, fontSize: 11, fontWeight: FontWeight.w700))),
                    ]),
                  ]),
                );
              },
            )),
          ]),
        ),
      ),
    );
  }
}
