import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  bool get isArabic => locale.languageCode == 'ar';
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  static const LocalizationsDelegate<AppLocalizations> delegate = _Delegate();

  String label(String english, String arabic) => isArabic ? arabic : english;

  String weekday(String day) {
    if (!isArabic) return day;
    return switch (day) {
      'Monday' => 'الإثنين',
      'Tuesday' => 'الثلاثاء',
      'Wednesday' => 'الأربعاء',
      'Thursday' => 'الخميس',
      'Friday' => 'الجمعة',
      'Saturday' => 'السبت',
      'Sunday' => 'الأحد',
      _ => day,
    };
  }

  String weekdayShort(String day) {
    if (!isArabic) return day.substring(0, 1);
    return switch (day) {
      'Monday' => 'ن',
      'Tuesday' => 'ث',
      'Wednesday' => 'ر',
      'Thursday' => 'خ',
      'Friday' => 'ج',
      'Saturday' => 'س',
      'Sunday' => 'ح',
      _ => day,
    };
  }

  String mealSlot(String slot) {
    if (!isArabic) {
      return switch (slot) {
        'breakfast' => 'Breakfast',
        'lunch' => 'Lunch',
        'dinner' => 'Dinner',
        'snack' => 'Snack',
        _ => slot,
      };
    }
    return switch (slot) {
      'breakfast' => 'الإفطار',
      'lunch' => 'الغداء',
      'dinner' => 'العشاء',
      'snack' => 'وجبة خفيفة',
      _ => slot,
    };
  }

  String dietaryTag(String tag) {
    if (!isArabic) {
      return switch (tag) {
        'plant_based' => 'Plant based',
        'gluten_free' => 'Gluten free',
        'dairy_free' => 'Dairy free',
        'high_protein' => 'High protein',
        _ => tag,
      };
    }
    return switch (tag) {
      'plant_based' => 'نباتي بالكامل',
      'gluten_free' => 'خالٍ من الغلوتين',
      'dairy_free' => 'خالٍ من الألبان',
      'high_protein' => 'غني بالبروتين',
      _ => tag,
    };
  }

  String stepOf(int current, int total) =>
      isArabic ? 'الخطوة $current من $total' : 'STEP $current OF $total';

  String get today => isArabic ? 'اليوم' : 'Today';
  String get recipes => isArabic ? 'الوصفات' : 'Recipes';
  String get plan => isArabic ? 'الخطة' : 'Plan';
  String get groceries => isArabic ? 'المشتريات' : 'Groceries';
  String get kitchen => isArabic ? 'المطبخ' : 'Kitchen';
  String get language => isArabic ? 'تغيير اللغة' : 'Change language';
  String get recipeShelf => isArabic ? 'رف الوصفات' : 'THE RECIPE SHELF';
  String get findFavourite => isArabic ? 'اعثر على\nمفضلتك القادمة.' : 'Find your next\nfavourite.';
  String get searchHint => isArabic ? 'ابحث عن وصفة أو مكوّن' : 'Search recipes or ingredients';
  String get emptyShelf => isArabic ? 'لا توجد وصفات هنا' : 'Nothing on this shelf';
  String get emptyShelfHint => isArabic ? 'جرّب مكوّناً آخر أو امسح عوامل التصفية.' : 'Try another ingredient or clear your filters.';
  String get weekEyebrow => isArabic ? 'أسبوع بطعم جميل' : 'A WEEK THAT TASTES GOOD';
  String get mealPlanner => isArabic ? 'مخطط\nوجباتك.' : 'Your meal\nplanner.';
  String get weekDescription => isArabic ? 'سبعة أيام وأربع وجبات يومياً. خطط أسبوعك بطريقتك.' : 'Seven days, four gentle prompts a day. Make the week your own.';

  String category(String id, String fallback) {
    if (!isArabic) return fallback;
    return switch (id) {
      'all' => 'كل الوصفات',
      'breakfast' => 'الإفطار',
      'lunch' => 'الغداء',
      'dinner' => 'العشاء',
      'snacks' => 'وجبات خفيفة',
      _ => fallback,
    };
  }

  String recipeCount(int count) => isArabic ? '$count وصفة للتجربة' : '$count ${count == 1 ? 'recipe' : 'recipes'} to try';
}
AppLocalizations appStrings(BuildContext context) => AppLocalizations.of(context);

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en' || locale.languageCode == 'ar';
  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));
  @override
  bool shouldReload(_Delegate old) => false;
}
