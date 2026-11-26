import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';

/// Global defaults used to prefill reminder controls when creating a plan or shopping task.
class DefaultReminderPreferencesScreen extends StatelessWidget {
  const DefaultReminderPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Default reminder preferences', 'تفضيلات التذكير الافتراضية'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appStrings(context).label(
            'Choose the default reminder behavior. You can still change it whenever you plan a recipe or add shopping items.',
            'اختر إعدادات التذكير الافتراضية. يمكنك تغييرها عند تخطيط وصفة أو إضافة عناصر للتسوق.',
          ), style: TextStyle(color: AppTheme.muted, height: 1.4)),
          const SizedBox(height: 20),
          _ReminderPreferenceSection(
            title: 'Recipe preparation',
            subtitle: 'Remind me before a planned recipe starts.',
            enabled: state.recipePlanReminderDefaultEnabled,
            minutes: state.recipeReminderLeadMinutes,
            onEnabled: (value) { state.recipePlanReminderDefaultEnabled = value; PlannerScope.refresh(context); },
            onMinutes: (value) { state.recipeReminderLeadMinutes = value; PlannerScope.refresh(context); },
          ),
          const SizedBox(height: 12),
          _ReminderPreferenceSection(
            title: 'Grocery shopping',
            subtitle: 'Remind me before my planned shopping time.',
            enabled: state.groceryReminderDefaultEnabled,
            minutes: state.groceryReminderLeadMinutes,
            onEnabled: (value) { state.groceryReminderDefaultEnabled = value; PlannerScope.refresh(context); },
            onMinutes: (value) { state.groceryReminderLeadMinutes = value; PlannerScope.refresh(context); },
          ),
          const SizedBox(height: 12),
          _ReminderPreferenceSection(
            title: 'Ingredients',
            subtitle: 'Remind me before ingredient preparation is due.',
            enabled: state.ingredientReminderDefaultEnabled,
            minutes: state.ingredientReminderLeadMinutes,
            onEnabled: (value) { state.ingredientReminderDefaultEnabled = value; PlannerScope.refresh(context); },
            onMinutes: (value) { state.ingredientReminderLeadMinutes = value; PlannerScope.refresh(context); },
          ),
        ],
      ),
    );
  }
}

class _ReminderPreferenceSection extends StatelessWidget {
  const _ReminderPreferenceSection({
    required this.title, required this.subtitle, required this.enabled,
    required this.minutes, required this.onEnabled, required this.onMinutes,
  });
  final String title, subtitle;
  final bool enabled;
  final int minutes;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<int> onMinutes;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          value: enabled,
          onChanged: onEnabled,
        ),
        if (enabled) ...[
          const Divider(),
          DropdownButtonFormField<int>(
            value: minutes,
            decoration: InputDecoration(
              labelText: appStrings(context).label('Remind me before', 'ذكرني قبل'),
              prefixIcon: const Icon(Icons.notifications_active_outlined),
            ),
            items: const [5, 10, 15, 30, 60, 120, 1440, 2880, 10080]
                .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value < 60 ? '$value minutes' : value < 1440
                    ? '${value ~/ 60} hours'
                    : '${value ~/ 1440} days'),
                )).toList(),
            onChanged: (value) { if (value != null) onMinutes(value); },
          ),
        ],
      ]),
    ),
  );
}
