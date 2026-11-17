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
    final end = now.add(const Duration(days: 45));
    final recipesById = {for (final recipe in catalog) recipe.id: recipe};

    if (state.mealRemindersEnabled) {
      for (final entry in state.mealPlan.entries) {
        final date = DateTime.tryParse(entry.key);
        if (date == null) continue; // Ignore legacy weekday-only planner entries.
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
          if (!fireAt.isAfter(now) || fireAt.isAfter(end)) continue;
          final key = 'meal:${entry.key}:${meal.slot.name}:${meal.recipeId}';
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

    if (state.pantryExpiryRemindersEnabled) {
      for (final item in state.pantry.values) {
        final expiry = state.pantryExpiryDates[item.id];
        if (expiry == null) continue;
        final fireAt = DateTime(expiry.year, expiry.month, expiry.day, 9);
        if (!fireAt.isAfter(now) || fireAt.isAfter(end)) continue;
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
