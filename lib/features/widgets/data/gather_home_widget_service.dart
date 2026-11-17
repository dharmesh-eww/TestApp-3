import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

/// Publishes a rolling meal snapshot so Android can advance the widget date
/// during its periodic native refresh, even when Gather is not open.
class GatherHomeWidgetService {
  GatherHomeWidgetService._();

  static const androidWidgetName = 'GatherMealWidgetProvider';

  static Future<void> sync(PlannerState state, Iterable<Recipe> catalog) async {
    final now = DateTime.now();
    final recipesById = {for (final recipe in catalog) recipe.id: recipe};
    final mealsByDate = <String, String>{};

    for (var offset = 0; offset <= 92; offset++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: offset));
      final key = _dateKey(date);
      final datedMeals = state.mealsFor(key);
      final weekdayKey = const [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
      ][date.weekday - 1];
      final templateMeals = state.mealsFor(weekdayKey);
      final meals = [
        ...templateMeals.where((template) =>
            !datedMeals.any((dated) => dated.slot == template.slot)),
        ...datedMeals,
      ];

      final lines = <String>[];
      for (final meal in meals) {
        final recipe = recipesById[meal.recipeId];
        if (recipe == null) continue;
        final allergyBlocked = state.allergies.isNotEmpty &&
            (!recipe.allergensVerified ||
                recipe.verifiedAllergens.any((value) =>
                    state.allergies.contains(value.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' '))));
        final slot = meal.slot.name;
        final label = '${slot[0].toUpperCase()}${slot.substring(1)}';
        lines.add('${allergyBlocked ? '⚠ ' : ''}$label · ${recipe.title}');
      }
      mealsByDate[key] = lines.isEmpty
          ? 'No meals planned. Open Gather to plan your day.'
          : lines.join('\\n');
    }

    try {
      await HomeWidget.saveWidgetData<String>('today_title', 'Today in Gather');
      await HomeWidget.saveWidgetData<String>('today_date', _dateKey(now));
      await HomeWidget.saveWidgetData<String>('today_meals', mealsByDate[_dateKey(now)]);
      await HomeWidget.saveWidgetData<String>('meal_calendar', jsonEncode(mealsByDate));
      await HomeWidget.updateWidget(androidName: androidWidgetName);
    } catch (error) {
      debugPrint('Gather home widget update skipped: $error');
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
