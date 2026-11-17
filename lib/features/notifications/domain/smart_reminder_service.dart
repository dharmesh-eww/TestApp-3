import 'package:testapp_3/features/cooking/domain/cooking_assist_service.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

/// Reconciles planned-meal and pantry-expiry reminders with Android AlarmManager.
/// Notifications remain opt-in and use local device time.
class SmartReminderService {
  SmartReminderService._();

  static Future<void> sync(PlannerState state, Iterable<Recipe> catalog) async {
    final previous = state.activeReminderKeys.toList(growable: false);
    for (final key in previous) {
      await CookingAssistService.cancelTimerNotification(key);
    }
    state.activeReminderKeys.clear();

    if (!state.mealRemindersEnabled && !state.pantryExpiryRemindersEnabled) return;
    await CookingAssistService.requestNotificationPermission();

    final now = DateTime.now();
    final mealEnd = now.add(const Duration(days: 92));
    final pantryEnd = now.add(const Duration(days: 365));
    final recipesById = {for (final recipe in catalog) recipe.id: recipe};

    if (state.mealRemindersEnabled) {
      const weekdayNumbers = {
        'Monday': DateTime.monday, 'Tuesday': DateTime.tuesday,
        'Wednesday': DateTime.wednesday, 'Thursday': DateTime.thursday,
        'Friday': DateTime.friday, 'Saturday': DateTime.saturday,
        'Sunday': DateTime.sunday,
      };
      for (final entry in state.mealPlan.entries) {
        final parsedDate = DateTime.tryParse(entry.key);
        final occurrences = <DateTime>[];
        if (parsedDate != null) {
          occurrences.add(parsedDate);
        } else {
          final weekday = weekdayNumbers[entry.key];
          if (weekday == null) continue;
          var date = DateTime(now.year, now.month, now.day);
          while (date.weekday != weekday) {
            date = date.add(const Duration(days: 1));
          }
          occurrences.add(date);
          while (occurrences.last.add(const Duration(days: 7)).isBefore(mealEnd)) {
            occurrences.add(occurrences.last.add(const Duration(days: 7)));
          }
        }

        for (final date in occurrences) {
          for (final meal in entry.value.values) {
            final recipe = recipesById[meal.recipeId];
            if (recipe == null) continue;
            final time = switch (meal.slot.name) {
              'breakfast' => (hour: 8, minute: 0),
              'lunch' => (hour: 12, minute: 0),
              'snack' => (hour: 15, minute: 0),
              _ => (hour: 18, minute: 0),
            };
            final plannedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            final fireAt = plannedAt.subtract(Duration(minutes: state.mealReminderMinutes));
            if (!fireAt.isAfter(now) || fireAt.isAfter(mealEnd)) continue;
            final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final key = 'meal:$dateKey:${meal.slot.name}:${meal.recipeId}';
            await CookingAssistService.scheduleTimerNotification(
              id: key,
              title: 'Meal coming up',
              body: '${recipe.title} is planned for ${meal.slot.name}.',
              fireAt: fireAt,
            );
            state.activeReminderKeys.add(key);
          }
        }
      }
    }

    if (state.pantryExpiryRemindersEnabled) {
      for (final item in state.pantry.values) {
        final expiry = state.pantryExpiryDates[item.id];
        if (expiry == null) continue;
        final fireAt = DateTime(expiry.year, expiry.month, expiry.day, 9);
        if (!fireAt.isAfter(now) || fireAt.isAfter(pantryEnd)) continue;
        final key = 'pantry:${item.id}:${expiry.year}-${expiry.month}-${expiry.day}';
        await CookingAssistService.scheduleTimerNotification(
          id: key,
          title: 'Pantry expiry reminder',
          body: '${item.name} is due to expire today.',
          fireAt: fireAt,
        );
        state.activeReminderKeys.add(key);
      }
    }
  }
}
