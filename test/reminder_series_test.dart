import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/notifications/domain/reminder_series.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';

void main() {
  group('ReminderSeries', () {
    test('generates previous-day weekly occurrences with stable IDs', () {
      final series = ReminderSeries(
        id: 'weekly-meal',
        sourceType: ReminderType.recipe,
        sourceId: 'recipe-1',
        title: 'Pasta',
        description: 'Prepare ingredients',
        startDate: DateTime(2026, 11, 29),
        recurrence: ReminderRecurrence.weekly,
        offset: ReminderOffset.previousDay,
        hour: 19,
        minute: 30,
        isEnabled: true,
        createdAt: DateTime(2026, 11, 1),
        weekday: DateTime.sunday,
      );
      final first = series.generateOccurrences(
        from: DateTime(2026, 11, 25),
        through: DateTime(2026, 12, 15),
      );
      final second = series.generateOccurrences(
        from: DateTime(2026, 11, 25),
        through: DateTime(2026, 12, 15),
      );
      expect(first, hasLength(3));
      expect(first.first.notificationDate, DateTime(2026, 11, 28, 19, 30));
      expect(first.map((item) => item.id), second.map((item) => item.id));
    });

    test('skips monthly dates that do not exist', () {
      final series = ReminderSeries(
        id: 'monthly',
        sourceType: ReminderType.shopping,
        sourceId: 'list-1',
        title: 'Shopping',
        description: '',
        startDate: DateTime(2026, 1, 31),
        recurrence: ReminderRecurrence.monthly,
        offset: ReminderOffset.sameDay,
        hour: 9,
        minute: 0,
        isEnabled: true,
        createdAt: DateTime(2026, 1, 1),
        monthDay: 31,
      );
      final occurrences = series.generateOccurrences(
        from: DateTime(2026, 1, 1),
        through: DateTime(2026, 4, 30),
      );
      expect(occurrences.map((item) => item.scheduledDate.month), [1, 3]);
    });


    test('excludes a single date without breaking the recurring series', () {
      final series = ReminderSeries(
        id: 'weekly-exception',
        sourceType: ReminderType.recipe,
        sourceId: 'recipe-2',
        title: 'Soup',
        description: '',
        startDate: DateTime(2026, 11, 29),
        recurrence: ReminderRecurrence.weekly,
        offset: ReminderOffset.sameDay,
        hour: 9,
        minute: 0,
        isEnabled: true,
        createdAt: DateTime(2026, 11, 1),
        weekday: DateTime.sunday,
        excludedDates: {'2026-12-06'},
      );
      final dates = series.generateOccurrences(
        from: DateTime(2026, 11, 29),
        through: DateTime(2026, 12, 13),
      ).map((item) => item.scheduledDate.day).toList();
      expect(dates, [29, 13]);
    });

    test('round trips series and occurrence persistence', () {
      final state = PlannerState();
      final series = ReminderSeries(
        id: 'once',
        sourceType: ReminderType.recipe,
        sourceId: 'r1',
        title: 'Dinner',
        description: 'Ready',
        startDate: DateTime(2026, 11, 30),
        recurrence: ReminderRecurrence.once,
        offset: ReminderOffset.sameDay,
        hour: 18,
        minute: 0,
        isEnabled: true,
        createdAt: DateTime(2026, 11, 1),
      );
      state.saveReminderSeries(series);
      final occurrence = series.generateOccurrences(
        from: DateTime(2026, 11, 30),
        through: DateTime(2026, 11, 30),
      ).single;
      state.reminderOccurrences[occurrence.id] = occurrence;
      final restored = PlannerState.fromJson(state.toJson());
      expect(restored.reminderSeries[series.id]?.title, 'Dinner');
      expect(restored.reminderOccurrences[occurrence.id]?.notificationId, occurrence.notificationId);
    });

    test('migrates opted-in v6 global meal reminders', () {
      final state = PlannerState.fromJson({
        'schema_version': 6,
        'meals': [
          {'day': '2026-12-01', 'slot': 'dinner', 'recipe_id': 'recipe-1', 'servings': 2},
        ],
        'notification_preferences': {
          'meal_reminders_enabled': true,
          'meal_reminder_minutes': 60,
        },
      });
      expect(state.mealRemindersEnabled, isFalse);
      expect(state.reminderSeries, hasLength(1));
      expect(state.reminderSeries.values.single.hour, 17);
    });
  });
}
