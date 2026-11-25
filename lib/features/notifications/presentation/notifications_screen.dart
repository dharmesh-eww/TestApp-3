import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/features/notifications/domain/reminder_series.dart';
import 'package:testapp_3/features/notifications/domain/reminder_notification_service.dart';
import 'package:testapp_3/localization/app_localizations.dart';

enum _ReminderFilter { all, upcoming, completed }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _ReminderFilter _filter = _ReminderFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final records = state.reminderOccurrences.values
        .where((item) => item.status != ReminderStatus.cancelled)
        .where((item) => switch (_filter) {
          _ReminderFilter.all => true,
          _ReminderFilter.upcoming => item.status == ReminderStatus.pending,
          _ReminderFilter.completed => item.status == ReminderStatus.completed,
        }).toList()
      ..sort((a, b) {
        if (a.status != b.status) return a.status == ReminderStatus.pending ? -1 : 1;
        return a.notificationDate.compareTo(b.notificationDate);
      });
    final upcomingCount = state.reminderOccurrences.values.where((item) => item.status == ReminderStatus.pending).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings(context).label('Notifications', 'الإشعارات')),
        actions: [Padding(padding: const EdgeInsetsDirectional.only(end: 16), child: Center(child: Text('$upcomingCount')))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SegmentedButton<_ReminderFilter>(
            segments: [
              ButtonSegment(value: _ReminderFilter.all, label: Text(appStrings(context).label('All', 'الكل'))),
              ButtonSegment(value: _ReminderFilter.upcoming, label: Text(appStrings(context).label('Upcoming', 'القادمة'))),
              ButtonSegment(value: _ReminderFilter.completed, label: Text(appStrings(context).label('Completed', 'مكتملة'))),
            ],
            selected: {_filter},
            onSelectionChanged: (value) => setState(() => _filter = value.first),
          ),
        ),
        Expanded(child: records.isEmpty
          ? Center(child: Text(appStrings(context).label('No reminders here yet.', 'لا توجد تذكيرات هنا بعد.')))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final item = records[index];
                final completed = item.status == ReminderStatus.completed;
                final overdue = !completed && item.notificationDate.isBefore(DateTime.now());
                return Card(child: ListTile(
                  leading: Icon(item.sourceType == ReminderType.recipe ? Icons.restaurant : Icons.shopping_basket_outlined),
                  title: Text(item.title),
                  subtitle: Text(
                    '${item.description}\n'
                    '${MaterialLocalizations.of(context).formatMediumDate(item.notificationDate)} · '
                    '${TimeOfDay.fromDateTime(item.notificationDate).format(context)}'
                    '${overdue ? ' · ${appStrings(context).label('Overdue', 'متأخر')}' : ''}'
                    '${completed ? ' · ${appStrings(context).label('Completed', 'مكتمل')}' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'complete') {
                        state.completeReminderOccurrence(item.id);
                        await ReminderNotificationService.cancelOccurrence(state, item.id);
                      } else if (action == 'delete') {
                        await ReminderNotificationService.cancelOccurrence(state, item.id);
                        state.deleteReminderOccurrence(item.id);
                      }
                      if (context.mounted) PlannerScope.refresh(context);
                    },
                    itemBuilder: (_) => [
                      if (!completed) PopupMenuItem(value: 'complete', child: Text(appStrings(context).label('Mark complete', 'تحديد كمكتمل'))),
                      PopupMenuItem(value: 'delete', child: Text(appStrings(context).label('Delete reminder', 'حذف التذكير'))),
                    ],
                  ),
                ));
              },
            )),
      ]),
    );
  }
}
