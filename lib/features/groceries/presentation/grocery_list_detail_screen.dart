import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/features/notifications/domain/reminder_series.dart';

class GroceryListDetailScreen extends StatelessWidget {
  const GroceryListDetailScreen({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final items = state.buildGroceryList(RecipeCatalogScope.of(context));
    final selected = state.groceryLists[listId] ?? <String>{};
    return Scaffold(
      appBar: AppBar(title: Text(state.groceryListNames[listId] ?? 'Shopping list')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(appStrings(context).label('Set shopping reminder', 'تعيين تذكير للتسوق')),
              onPressed: () => _setShoppingReminder(context),
            ),
          ),
          Text(appStrings(context).label('Choose items from your planner’s combined grocery list. Changes stay on this device.', 'اختر عناصر من قائمة المشتريات المجمعة في مخططك. تُحفظ التغييرات على هذا الجهاز.'),
            style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 12),
          if (items.isEmpty) Text(appStrings(context).label('Add ingredients from recipes or planned meals first.', 'أضف المكونات من الوصفات أو الوجبات المخططة أولاً.')),
          for (final item in items)
            CheckboxListTile(
              value: selected.contains(item.key),
              title: Text(item.name),
              subtitle: Text(item.isQuantified ? '${item.amount} ${item.unit}' : 'Check pantry before shopping'),
              onChanged: (value) {
                if (value == true) state.assignGroceryItem(listId, item.key);
                else state.removeGroceryItemFromList(listId, item.key);
                PlannerScope.refresh(context);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _setShoppingReminder(BuildContext context) async {
    final state = PlannerScope.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    var offset = ReminderOffset.previousDay;
    var time = const TimeOfDay(hour: 18, minute: 0);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(appStrings(context).label('Shopping reminder', 'تذكير التسوق')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<ReminderOffset>(
            value: offset,
            decoration: InputDecoration(labelText: appStrings(context).label('Remind me', 'ذكرني')),
            items: [
              DropdownMenuItem(value: ReminderOffset.sameDay, child: Text(appStrings(context).label('Same day', 'في نفس اليوم'))),
              DropdownMenuItem(value: ReminderOffset.previousDay, child: Text(appStrings(context).label('Previous day', 'في اليوم السابق'))),
            ],
            onChanged: (value) => setDialogState(() => offset = value ?? offset),
          ),
          ListTile(
            title: Text(appStrings(context).label('Notification time', 'وقت الإشعار')),
            subtitle: Text(time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: dialogContext, initialTime: time);
              if (picked != null) setDialogState(() => time = picked);
            },
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Save', 'حفظ'))),
        ],
      )),
    );
    if (saved != true || !context.mounted) return;
    final series = ReminderSeries(
      id: 'shopping:$listId',
      sourceType: ReminderType.shopping,
      sourceId: listId,
      title: state.groceryListNames[listId] ?? 'Shopping list',
      description: appStrings(context).label('Your shopping is scheduled.', 'موعد التسوق الخاص بك.'),
      startDate: date,
      recurrence: ReminderRecurrence.once,
      offset: offset,
      hour: time.hour,
      minute: time.minute,
      isEnabled: true,
      createdAt: DateTime.now(),
    );
    state.saveReminderSeries(series);
    PlannerScope.refresh(context);
  }
}
