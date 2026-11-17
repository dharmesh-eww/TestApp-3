import 'package:testapp_3/features/cooking/domain/cooking_assist_service.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe.dart';

/// Reconciles planned-meal and pantry-expiry reminders with Android AlarmManager.
/// Notifications remain opt-in and use local device time.
class SmartReminderService {
  SmartReminderService._();

  static String? _lastFingerprint;

  static void invalidate() => _lastFingerprint = null;

  static Future<void> sync(PlannerState state, Iterable<Recipe> catalog, {DateTime? now, bool force = false}) async {
    final recipesById = {for (final recipe in catalog) recipe.id: recipe};
    final currentTime = now ?? DateTime.now();
    final fingerprint = _fingerprint(state, recipesById, currentTime);
    if (!force && fingerprint == _lastFingerprint) return;

    final previous = state.activeReminderKeys.toList(growable: false);
    for (final key in previous) {
      await CookingAssistService.cancelTimerNotification(key);
    }
    state.activeReminderKeys.clear();

    if (!state.mealRemindersEnabled && !state.pantryExpiryRemindersEnabled) {
      _lastFingerprint = fingerprint;
      return;
    }
    await CookingAssistService.requestNotificationPermission();

    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final mealEnd = today.add(const Duration(days: 92));
    final pantryEnd = now.add(const Duration(days: 365));

    if (state.mealRemindersEnabled) {
      const weekdayNumbers = {
        'Monday': DateTime.monday, 'Tuesday': DateTime.tuesday,
        'Wednesday': DateTime.wednesday, 'Thursday': DateTime.thursday,
        'Friday': DateTime.friday, 'Saturday': DateTime.saturday,
        'Sunday': DateTime.sunday,
      };
      for (final entry in state.mealPlan.entries) {
        final parsedDate = DateTime.tryParse(entry.key);
        final isWeekdayTemplate = parsedDate == null;
        final occurrences = <DateTime>[];
        if (parsedDate != null) {
          occurrences.add(parsedDate);
        } else {
          final weekday = weekdayNumbers[entry.key];
          if (weekday == null) continue;

          // Weekday templates represent recurring meals, not a one-time meal
          // in the current week. Schedule every upcoming occurrence in the
          // same three-month planning horizon as the planner.
          for (var date = today; !date.isAfter(mealEnd); date = date.add(const Duration(days: 1))) {
            if (date.weekday == weekday) occurrences.add(date);
          }
        }

        for (final date in occurrences) {
          for (final meal in entry.value.values) {
            final recipe = recipesById[meal.recipeId];
            if (recipe == null) continue;
            if (state.allergies.isNotEmpty) {
              final blocked = state.allergies.map((value) => value.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ')).toSet();
              final declared = recipe.verifiedAllergens.map((value) => value.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ')).toSet();
              if (!recipe.allergensVerified || declared.any(blocked.contains)) continue;
            }
            final time = switch (meal.slot.name) {
              'breakfast' => (hour: 8, minute: 0),
              'lunch' => (hour: 12, minute: 0),
              'snack' => (hour: 15, minute: 0),
              _ => (hour: 18, minute: 0),
            };
            final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            if (isWeekdayTemplate && state.mealsFor(dateKey).any((dated) => dated.slot == meal.slot)) continue;
            final plannedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            final fireAt = plannedAt.subtract(Duration(minutes: state.mealReminderMinutes));
            if (!fireAt.isAfter(currentTime) || fireAt.isAfter(mealEnd)) continue;
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
        if (!fireAt.isAfter(currentTime) || fireAt.isAfter(pantryEnd)) continue;
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
    _lastFingerprint = fingerprint;
  }

  static String _fingerprint(PlannerState state, Map<String, Recipe> recipesById, DateTime now) {
    final buffer = StringBuffer()
      ..write(state.mealRemindersEnabled)
      ..write('|')
      ..write(state.pantryExpiryRemindersEnabled)
      ..write('|')
      ..write(state.mealReminderMinutes)
      ..write('|')
      ..write('${now.year}-${now.month}-${now.day}')
      ..write('|')
      ..write(state.allergies.toList()..sort());
    final days = state.mealPlan.keys.toList()..sort();
    for (final day in days) {
      final meals = state.mealPlan[day]!.values.toList()..sort((a, b) => a.slot.name.compareTo(b.slot.name));
      for (final meal in meals) {
        final recipe = recipesById[meal.recipeId];
        final allergens = recipe == null ? const <String>[] : (recipe.verifiedAllergens.toList()..sort());
        buffer.write('|$day:${meal.slot.name}:${meal.recipeId}:${recipe?.title ?? ''}:${recipe?.allergensVerified ?? false}:$allergens');
      }
    }
    final pantryIds = state.pantry.keys.toList()..sort();
    for (final id in pantryIds) {
      final expiry = state.pantryExpiryDates[id];
      buffer.write('|$id:${state.pantry[id]?.name ?? ''}:${expiry?.toIso8601String() ?? ''}');
    }
    return buffer.toString();
  }
}
