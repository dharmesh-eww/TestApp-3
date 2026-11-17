import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

/// Pushes today's planned meals into the Android home-screen widget.
class GatherHomeWidgetService {
  GatherHomeWidgetService._();

  static const androidWidgetName = 'GatherMealWidgetProvider';

  static Future<void> sync(PlannerState state, Iterable<Recipe> catalog) async {
    final now = DateTime.now();
    final key = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final meals = state.mealsFor(key);
    final recipesById = {for (final recipe in catalog) recipe.id: recipe};
    final lines = <String>[];
    for (final meal in meals) {
      final recipe = recipesById[meal.recipeId];
      if (recipe == null) continue;
      lines.add('${meal.slot.name[0].toUpperCase()}${meal.slot.name.substring(1)} · ${recipe.title}');
    }
    try {
      await HomeWidget.saveWidgetData<String>('today_title', 'Today in Gather');
      await HomeWidget.saveWidgetData<String>('today_date', key);
      await HomeWidget.saveWidgetData<String>(
        'today_meals',
        lines.isEmpty ? 'No meals planned yet. Open Gather to plan your day.' : lines.join('\n'),
      );
      await HomeWidget.updateWidget(androidName: androidWidgetName);
    } catch (error) {
      debugPrint('Gather home widget update skipped: $error');
    }
  }
}
