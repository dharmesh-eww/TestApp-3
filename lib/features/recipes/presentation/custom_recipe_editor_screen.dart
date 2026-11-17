import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class CustomRecipeEditorScreen extends StatefulWidget {
  const CustomRecipeEditorScreen({super.key, this.recipe});
  final Recipe? recipe;

  @override
  State<CustomRecipeEditorScreen> createState() => _CustomRecipeEditorScreenState();
}

class _CustomRecipeEditorScreenState extends State<CustomRecipeEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _servings;
  late final TextEditingController _prep;
  late final TextEditingController _cook;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _ingredients;
  late final TextEditingController _steps;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _title = TextEditingController(text: recipe?.title ?? '');
    _description = TextEditingController(text: recipe?.subtitle ?? '');
    _category = TextEditingController(text: recipe?.category ?? 'Dinner');
    _servings = TextEditingController(text: '${recipe?.servings ?? 2}');
    _prep = TextEditingController(text: '${recipe?.prepMinutes ?? 10}');
    _cook = TextEditingController(text: '${recipe?.cookMinutes ?? 20}');
    _calories = TextEditingController(text: '${recipe?.calories ?? 0}');
    _protein = TextEditingController(text: '${recipe?.proteinGrams ?? 0}');
    _carbs = TextEditingController(text: '${recipe?.carbsGrams ?? 0}');
    _fat = TextEditingController(text: '${recipe?.fatGrams ?? 0}');
    _ingredients = TextEditingController(text: recipe == null ? '' : recipe.ingredients.map((item) => '${item.name}|${item.amount ?? ''}|${item.unit}').join('\n'));
    _steps = TextEditingController(text: recipe?.steps.join('\n') ?? '');
  }

  @override
  void dispose() {
    for (final controller in [_title, _description, _category, _servings, _prep, _cook, _calories, _protein, _carbs, _fat, _ingredients, _steps]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.label(widget.recipe == null ? 'Create recipe' : 'Edit recipe', widget.recipe == null ? 'إنشاء وصفة' : 'تعديل الوصفة'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _title, decoration: InputDecoration(labelText: strings.label('Recipe name *', 'اسم الوصفة *'))),
          const SizedBox(height: 12),
          TextField(controller: _description, maxLines: 2, decoration: InputDecoration(labelText: strings.label('Description', 'الوصف'))),
          const SizedBox(height: 12),
          TextField(controller: _category, decoration: InputDecoration(labelText: strings.label('Category', 'الفئة'))),
          const SizedBox(height: 18),
          Text(strings.label('TIME & SERVINGS', 'الوقت والحصص'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _numberField(_servings, 'Servings')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(_prep, 'Prep min')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(_cook, 'Cook min')),
          ]),
          const SizedBox(height: 18),
          Text(strings.label('NUTRITION PER SERVING', 'القيم الغذائية للحصة'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _numberField(_calories, 'kcal')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(_protein, 'Protein g')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(_carbs, 'Carbs g')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(_fat, 'Fat g')),
          ]),
          const SizedBox(height: 18),
          Text(strings.label('INGREDIENTS', 'المكونات'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(strings.label('One ingredient per line: name | amount | unit. Leave amount blank for “to taste”.', 'مكوّن واحد في كل سطر: الاسم | الكمية | الوحدة. اترك الكمية فارغة لعبارة «حسب الرغبة».'),
            style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(controller: _ingredients, minLines: 4, maxLines: 8, decoration: const InputDecoration(hintText: 'Tomatoes | 2 | whole\nOlive oil | 1 | tbsp')),
          const SizedBox(height: 18),
          Text(strings.label('COOKING INSTRUCTIONS', 'تعليمات الطهي'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          TextField(controller: _steps, minLines: 4, maxLines: 10, decoration: InputDecoration(hintText: strings.label('One step per line', 'خطوة واحدة في كل سطر'))),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('save-custom-recipe'),
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(strings.label('Save recipe', 'حفظ الوصفة')),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.terracotta, minimumSize: const Size(0, 52)),
          ),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
  );

  void _save() {
    final title = _title.text.trim();
    final servings = int.tryParse(_servings.text.trim()) ?? 0;
    final prep = int.tryParse(_prep.text.trim()) ?? 0;
    final cook = int.tryParse(_cook.text.trim()) ?? 0;
    final calories = int.tryParse(_calories.text.trim()) ?? 0;
    final protein = double.tryParse(_protein.text.trim()) ?? 0;
    final carbs = double.tryParse(_carbs.text.trim()) ?? 0;
    final fat = double.tryParse(_fat.text.trim()) ?? 0;
    final steps = _steps.text.split('\n').map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
    if (title.isEmpty || servings < 1 || prep < 0 || cook < 0 || calories < 0 || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Add a name, valid servings and at least one instruction.', 'أدخل اسمًا وعدد حصص صالحًا وتعليمات واحدة على الأقل.'))));
      return;
    }
    final ingredients = <Ingredient>[];
    for (final line in _ingredients.text.split('\n')) {
      final clean = line.trim();
      if (clean.isEmpty) continue;
      final parts = clean.split('|').map((part) => part.trim()).toList();
      final name = parts.first;
      final amount = parts.length > 1 && parts[1].isNotEmpty ? double.tryParse(parts[1]) : null;
      final unit = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : 'item';
      if (name.isEmpty || (parts.length > 1 && parts[1].isNotEmpty && (amount == null || amount < 0))) continue;
      ingredients.add(Ingredient(name, amount, unit,
        amountType: amount == null ? IngredientAmountType.toTaste : IngredientAmountType.quantity));
    }
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Add at least one ingredient.', 'أضف مكوّنًا واحدًا على الأقل.'))));
      return;
    }
    final previous = widget.recipe;
    final recipe = Recipe(
      id: previous?.id ?? 'custom-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      subtitle: _description.text.trim(),
      image: previous?.image ?? '',
      minutes: prep + cook,
      prepMinutes: prep,
      cookMinutes: cook,
      difficulty: previous?.difficulty ?? 'Easy',
      category: _category.text.trim().isEmpty ? 'Other' : _category.text.trim(),
      categoryIds: [_category.text.trim().toLowerCase().replaceAll(' ', '_')],
      cuisineIds: previous?.cuisineIds ?? const [],
      foodType: previous?.foodType ?? FoodType.vegetarian,
      dietaryTags: previous?.dietaryTags ?? const [],
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      servings: servings,
      ingredients: ingredients,
      steps: steps,
      stepDetails: [for (var i = 0; i < steps.length; i++) RecipeStep(step: i + 1, text: steps[i])],
      tags: previous?.tags ?? const [],
      isPublished: true,
      allergensVerified: false,
      verifiedAllergens: const [],
    );
    PlannerScope.of(context).saveCustomRecipe(recipe);
    PlannerScope.refresh(context);
    Navigator.pop(context);
  }
}
