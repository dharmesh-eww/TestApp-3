import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/notifications/domain/smart_reminder_service.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('weekly meal reminders are expanded through the three-month horizon', () async {
    final state = PlannerState()
      ..mealRemindersEnabled = true
      ..mealReminderMinutes = 60;
    state.assignMeal(
      day: 'Wednesday',
      slot: MealSlot.breakfast,
      recipeId: recipes.first.id,
      servings: recipes.first.servings,
    );

    await SmartReminderService.sync(
      state,
      recipes,
      now: DateTime(2026, 11, 17, 0),
    );

    expect(state.activeReminderKeys, hasLength(14));
    expect(state.activeReminderKeys.every((key) => key.startsWith('meal:')), isTrue);
    expect(state.activeReminderKeys.toSet(), hasLength(14));
  });

  test('dated meal overrides the matching weekly reminder occurrence', () async {
    final state = PlannerState()
      ..mealRemindersEnabled = true
      ..mealReminderMinutes = 60;
    state.assignMeal(
      day: 'Wednesday',
      slot: MealSlot.breakfast,
      recipeId: recipes.first.id,
      servings: recipes.first.servings,
    );
    state.assignMeal(
      day: '2026-11-18',
      slot: MealSlot.breakfast,
      recipeId: recipes.last.id,
      servings: recipes.last.servings,
    );

    await SmartReminderService.sync(
      state,
      recipes,
      now: DateTime(2026, 11, 17, 0),
    );

    expect(state.activeReminderKeys, hasLength(14));
    expect(
      state.activeReminderKeys,
      contains('meal:2026-11-18:breakfast:${recipes.last.id}'),
    );
    expect(
      state.activeReminderKeys,
      isNot(contains('meal:2026-11-18:breakfast:${recipes.first.id}')),
    );
  });
}
