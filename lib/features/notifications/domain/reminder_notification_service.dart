import 'package:testapp_3/features/cooking/domain/cooking_assist_service.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'reminder_series.dart';

/// Reconciles persisted reminder occurrences with Android local alarms.
class ReminderNotificationService {
  ReminderNotificationService._();
  static const horizonDays = 90;
  static const occurrenceHistoryDays = 365;
  static String? _lastFingerprint;

  static Future<void> sync(PlannerState state, {DateTime? now, bool force = false}) async {
    final current = now ?? DateTime.now();
    final from = DateTime(current.year, current.month, current.day);
    final through = from.add(const Duration(days: occurrenceHistoryDays));
    final scheduleThrough = current.add(const Duration(days: horizonDays));
    final fingerprint = _fingerprint(state, from);
    if (!force && fingerprint == _lastFingerprint) return;

    final generated = <String, ReminderOccurrence>{};
    for (final series in state.reminderSeries.values) {
      if (!series.isEnabled) continue;
      for (final occurrence in series.generateOccurrences(from: from, through: through)) {
        generated[occurrence.id] = occurrence;
      }
    }

    final activeKeys = state.activeReminderKeys.where((key) => key.startsWith('occurrence:')).toList();
    final desiredKeys = generated.keys.map((id) => 'occurrence:$id').toSet();
    for (final key in activeKeys) {
      if (!desiredKeys.contains(key)) {
        await CookingAssistService.cancelTimerNotification(key);
        state.activeReminderKeys.remove(key);
      }
    }

    for (final entry in generated.entries) {
      final existing = state.reminderOccurrences[entry.key];
      if (existing?.status == ReminderStatus.completed || existing?.status == ReminderStatus.cancelled) continue;
      final occurrence = existing ?? entry.value;
      state.reminderOccurrences[entry.key] = occurrence;
      final key = 'occurrence:${occurrence.id}';
      if (!occurrence.notificationDate.isAfter(current)) {
        // A fired notification may still be visible in Android's notification shade.
        // Keep it there; do not cancel its delivered notification while reconciling.
        state.activeReminderKeys.remove(key);
        continue;
      }
      if (occurrence.notificationDate.isAfter(scheduleThrough)) continue;
      await CookingAssistService.scheduleTimerNotification(
        id: key,
        title: occurrence.title,
        body: occurrence.description,
        fireAt: occurrence.notificationDate,
      );
      state.activeReminderKeys.add(key);
    }
    _lastFingerprint = fingerprint;
  }

  static Future<void> cancelOccurrence(PlannerState state, String occurrenceId) async {
    final key = 'occurrence:$occurrenceId';
    await CookingAssistService.cancelTimerNotification(key);
    state.activeReminderKeys.remove(key);
  }


  static Future<void> cancelSeriesAlarms(PlannerState state, String seriesId) async {
    final occurrences = state.reminderOccurrences.values
        .where((item) => item.seriesId == seriesId && item.status == ReminderStatus.pending)
        .toList();
    for (final occurrence in occurrences) {
      final key = 'occurrence:${occurrence.id}';
      await CookingAssistService.cancelTimerNotification(key);
      state.activeReminderKeys.remove(key);
    }
    invalidate();
  }

  static Future<void> cancelSeries(PlannerState state, String seriesId) async {
    final ids = state.reminderOccurrences.values
        .where((item) => item.seriesId == seriesId && item.status == ReminderStatus.pending)
        .map((item) => item.id).toList();
    for (final id in ids) { await cancelOccurrence(state, id); }
    state.deleteReminderSeries(seriesId);
    invalidate();
  }

  static void invalidate() => _lastFingerprint = null;

  static String _fingerprint(PlannerState state, DateTime date) {
    final values = state.reminderSeries.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return '${date.year}-${date.month}-${date.day}|' + values.map((item) =>
      '${item.id}:${item.isEnabled}:${item.startDate}:${item.endDate}:${item.recurrence}:${item.offset}:${item.hour}:${item.minute}:${item.weekday}:${item.monthDay}:${item.excludedDates.toList()..sort()}').join('|');
  }
}
