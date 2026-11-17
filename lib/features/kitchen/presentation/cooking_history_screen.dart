import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class CookingHistoryScreen extends StatelessWidget {
  const CookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = PlannerScope.of(context).cookingHistory;
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Cooking history', 'سجل الطهي'))),
      body: history.isEmpty
          ? Center(child: Text(appStrings(context).label('Recipes you finish cooking will appear here.', 'ستظهر هنا الوصفات التي تنتهي من طهيها.')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final date = DateTime.tryParse(item['completed_at'] ?? '');
                return ListTile(
                  leading: CircleAvatar(child: Icon(Icons.restaurant_menu)),
                  title: Text(item['title'] ?? 'Recipe'),
                  subtitle: Text(date == null ? '' : MaterialLocalizations.of(context).formatMediumDate(date)),
                );
              },
            ),
    );
  }
}
