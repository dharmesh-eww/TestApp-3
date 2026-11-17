import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/kitchen/presentation/language_selection_screen.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/features/cooking/domain/cooking_assist_service.dart';
import 'package:testapp_3/features/widgets/data/gather_home_widget_service.dart';
import 'package:testapp_3/features/notifications/domain/smart_reminder_service.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onLocaleChanged});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('Settings', 'الإعدادات'))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Card(
          child: ListTile(
            key: const Key('open-language-selection'),
            leading: const Icon(Icons.language),
            title: Text(appStrings(context).label('Language', 'اللغة')),
            subtitle: Text(appStrings(context).languageName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LanguageSelectionScreen(
                  locale: currentLocale,
                  onLocaleChanged: onLocaleChanged,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('MEASUREMENTS', 'وحدات القياس'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.measurementSystem,
          decoration: InputDecoration(labelText: appStrings(context).label('Measurement system', 'نظام القياس')),
          items: [
            DropdownMenuItem(value: 'metric', child: Text(appStrings(context).label('Metric (g, kg, ml, L)', 'النظام المتري (g، kg، ml، L)'))),
            DropdownMenuItem(value: 'us', child: Text(appStrings(context).label('US customary (oz, lb, cups)', 'النظام الأمريكي (oz، lb، cups)'))),
          ],
          onChanged: (value) {
            if (value == null) return;
            state.measurementSystem = value;
            PlannerScope.refresh(context);
          },
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('WEEKLY PLANNER', 'مخطط الأسبوع'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: state.weekStartsOn,
          decoration: InputDecoration(labelText: appStrings(context).label('First day of week', 'أول يوم في الأسبوع')),
          items: [
            DropdownMenuItem(value: 1, child: Text(appStrings(context).label('Monday', 'الإثنين'))),
            DropdownMenuItem(value: 7, child: Text(appStrings(context).label('Sunday', 'الأحد'))),
          ],
          onChanged: (value) {
            if (value == null) return;
            state.weekStartsOn = value;
            PlannerScope.refresh(context);
          },
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('APPEARANCE', 'المظهر'), style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.terracotta, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.themePreference,
          decoration: InputDecoration(labelText: appStrings(context).label('Theme', 'السمة')),
          items: [
            DropdownMenuItem(value: 'system', child: Text(appStrings(context).label('Use device setting', 'استخدام إعداد الجهاز'))),
            DropdownMenuItem(value: 'light', child: Text(appStrings(context).label('Light', 'فاتح'))),
            DropdownMenuItem(value: 'dark', child: Text(appStrings(context).label('Dark', 'داكن'))),
          ],
          onChanged: (value) { if (value == null) return; state.themePreference = value; PlannerScope.refresh(context); },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(appStrings(context).label('Reduce motion', 'تقليل الحركة')),
          subtitle: Text(appStrings(context).label('Use simpler transitions throughout the app.', 'استخدام انتقالات أبسط في التطبيق.')),
          value: state.reduceMotion,
          onChanged: (value) { state.reduceMotion = value; PlannerScope.refresh(context); },
        ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('PERSONAL DISCOVERY', 'اكتشاف مخصص'), style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(appStrings(context).label('Prefer recipes with these dietary tags. Discover will apply every selected tag.', 'فضّل الوصفات التي تحمل هذه التصنيفات الغذائية. سيطبق قسم الاكتشاف جميع التصنيفات المحددة.'), style: TextStyle(color: AppTheme.muted)),
        for (final option in const {'plant_based': 'Plant based', 'gluten_free': 'Gluten free', 'dairy_free': 'Dairy free', 'high_protein': 'High protein'}.entries)
          CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(appStrings(context).dietaryTag(option.key)), value: state.preferredDietaryTags.contains(option.key),
            onChanged: (selected) { if (selected == true) { state.preferredDietaryTags.add(option.key); } else { state.preferredDietaryTags.remove(option.key); } PlannerScope.refresh(context); }),
        const SizedBox(height: 12),
        Text(appStrings(context).label('Preferred cuisines', 'المطابخ المفضلة'), style: Theme.of(context).textTheme.titleMedium),
        Text(appStrings(context).label('Discover will filter to recipes from the cuisines you select.', 'سيعرض قسم الاكتشاف الوصفات من المطابخ التي تختارها.'), style: TextStyle(color: AppTheme.muted)),
        for (final option in const {
          'indian': 'Indian', 'north_indian': 'North Indian', 'south_indian': 'South Indian',
          'gujarati': 'Gujarati', 'chinese': 'Chinese', 'japanese': 'Japanese',
          'italian': 'Italian', 'korean': 'Korean', 'mexican': 'Mexican',
          'american': 'American', 'thai': 'Thai', 'mediterranean': 'Mediterranean',
          'vietnamese': 'Vietnamese', 'greek': 'Greek', 'french': 'French',
          'spanish': 'Spanish', 'middle_eastern': 'Middle Eastern',
        }.entries)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(appStrings(context).label(option.value, option.value)),
            value: state.preferredCuisines.contains(option.key),
            onChanged: (selected) {
              if (selected == true) {
                state.preferredCuisines.add(option.key);
              } else {
                state.preferredCuisines.remove(option.key);
              }
              PlannerScope.refresh(context);
            },
          ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('ALLERGY SAFETY', 'سلامة الحساسية'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(appStrings(context).label('Select allergens to exclude. When an allergy is active, recipes without verified allergen data are hidden. Always check packaging and confirm ingredients yourself.', 'حدد مسببات الحساسية لاستبعادها. عند تفعيل حساسية، تُخفى الوصفات التي لا تحتوي على بيانات حساسية موثقة. تحقق دائمًا من العبوات والمكونات بنفسك.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        for (final allergen in const {
          'peanuts': 'Peanuts', 'tree nuts': 'Tree nuts', 'milk': 'Milk', 'eggs': 'Eggs',
          'wheat': 'Wheat', 'gluten': 'Gluten', 'soy': 'Soy', 'fish': 'Fish',
          'shellfish': 'Crustaceans / shellfish', 'sesame': 'Sesame', 'mustard': 'Mustard',
          'celery': 'Celery', 'lupin': 'Lupin', 'sulphites': 'Sulphites',
        }.entries)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(appStrings(context).label(allergen.value, allergen.value)),
            value: state.allergies.contains(allergen.key),
            onChanged: (value) {
              if (value == true) { state.allergies.add(allergen.key); }
              else { state.allergies.remove(allergen.key); }
              PlannerScope.refresh(context);
            },
          ),
        const SizedBox(height: 24),
        Text(appStrings(context).label('SMART REMINDERS', 'التذكيرات الذكية'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(appStrings(context).label('Meal reminders', 'تذكيرات الوجبات')),
          subtitle: Text(appStrings(context).label('Get a reminder before each planned meal (default times: breakfast 8:00, lunch 12:00, snack 15:00, dinner 18:00).', 'احصل على تذكير قبل كل وجبة مخططة (الأوقات الافتراضية: الإفطار 8:00، الغداء 12:00، الوجبة الخفيفة 15:00، العشاء 18:00).')),
          value: state.mealRemindersEnabled,
          onChanged: (value) { state.mealRemindersEnabled = value; PlannerScope.refresh(context); },
        ),
        if (state.mealRemindersEnabled)
          DropdownButtonFormField<int>(
            value: state.mealReminderMinutes,
            decoration: InputDecoration(labelText: appStrings(context).label('Remind me before', 'ذكرني قبل')),
            items: const [15, 30, 60, 120].map((value) => DropdownMenuItem(value: value, child: Text('${value} min'))).toList(),
            onChanged: (value) { if (value == null) return; state.mealReminderMinutes = value; PlannerScope.refresh(context); },
          ),
        OutlinedButton.icon(
          onPressed: () async {
            final granted = await CookingAssistService.requestNotificationPermission();
            if (granted && context.mounted) {
              SmartReminderService.invalidate();
              await SmartReminderService.sync(state, RecipeCatalogScope.of(context));
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(granted
              ? appStrings(context).label('Notification permission is available.', 'إذن الإشعارات متاح.')
              : appStrings(context).label('Allow notifications in your Android settings if the prompt does not appear.', 'اسمح بالإشعارات من إعدادات أندرويد إذا لم يظهر الطلب.'))));
          },
          icon: const Icon(Icons.notifications_active_outlined),
          label: Text(appStrings(context).label('Enable notifications', 'تفعيل الإشعارات')),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(appStrings(context).label('Pantry expiry reminders', 'تذكيرات انتهاء صلاحية المخزن')),
          subtitle: Text(appStrings(context).label('Remind me on the day an item is due to expire.', 'ذكرني في يوم انتهاء صلاحية العنصر.')),
          value: state.pantryExpiryRemindersEnabled,
          onChanged: (value) { state.pantryExpiryRemindersEnabled = value; PlannerScope.refresh(context); },
        ),
        const SizedBox(height: 22),
        Text(appStrings(context).label('HOME SCREEN WIDGET', 'أداة الشاشة الرئيسية'), style: const TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(appStrings(context).label('Add the Gather widget from your Android launcher’s widget picker. It shows the meals planned for today and refreshes when your plan changes.', 'أضف أداة Gather من قائمة الأدوات في مشغل أندرويد. تعرض وجبات اليوم وتتحدث عند تغيير خطتك.'), style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () async {
              await GatherHomeWidgetService.sync(state, RecipeCatalogScope.of(context));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Widget data refreshed. Add the widget from your Android launcher if it is not on your home screen.', 'تم تحديث بيانات الأداة. أضف الأداة من مشغل أندرويد إذا لم تكن على الشاشة الرئيسية.'))));
            },
            icon: const Icon(Icons.widgets_outlined),
            label: Text(appStrings(context).label('Refresh widget data', 'تحديث بيانات الأداة')),
          ),
        ),
        const SizedBox(height: 16),
        Text(appStrings(context).label('Conversions are shown only within compatible dimensions. Mass is never converted to volume without ingredient-specific density.', 'تُعرض التحويلات بين الوحدات المتوافقة فقط. لا يتم تحويل الكتلة إلى حجم دون معرفة كثافة المكوّن.'), style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 28),
        Text(appStrings(context).label('LOCAL DATA', 'البيانات المحلية'), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.terracotta, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(appStrings(context).label('Favorites, meal plans, groceries, pantry, collections, history and preferences are stored on this device. Resetting clears personal data but keeps the downloaded recipe library.', 'تُخزّن المفضلة وخطط الوجبات والمشتريات والمخزن والمجموعات والسجل والتفضيلات على هذا الجهاز. يؤدي إعادة الضبط إلى مسح بياناتك الشخصية مع الاحتفاظ بمكتبة الوصفات التي تم تنزيلها.'), style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 10),
        OutlinedButton.icon(key: const Key('reset-local-data'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red), icon: Icon(Icons.delete_outline), label: Text(appStrings(context).label('Reset personal data', 'إعادة ضبط البيانات الشخصية')),
          onPressed: () async {
            final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
              title: Text(appStrings(context).label('Reset personal data?', 'هل تريد إعادة ضبط البيانات الشخصية؟')),
              content: Text(appStrings(context).label('Favorites, meal plans, groceries, pantry, collections, history and preferences will be cleared from this device. Your recipe catalog stays available.', 'سيتم مسح المفضلة وخطط الوجبات والمشتريات والمخزن والمجموعات والسجل والتفضيلات من هذا الجهاز. ستظل مكتبة الوصفات متاحة.')),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Reset data', 'إعادة ضبط البيانات')))],
            ));
            if (confirmed != true || !context.mounted) return;
            state.clearPersonalData();
            PlannerScope.cookingOf(context).clearSession();
            PlannerScope.refresh(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appStrings(context).label('Personal data cleared from this device.', 'تم مسح البيانات الشخصية من هذا الجهاز.'))));
          }),
      ]),
    );
  }
}
