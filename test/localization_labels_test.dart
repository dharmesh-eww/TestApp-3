import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/localization/app_localizations.dart';

void main() {
  test('shared labels return the selected language', () {
    expect(AppLocalizations(const Locale('en')).label('Kitchen timers', 'مؤقتات المطبخ'),
        'Kitchen timers');
    expect(AppLocalizations(const Locale('ar')).label('Kitchen timers', 'مؤقتات المطبخ'),
        'مؤقتات المطبخ');
  });

  test('Hindi and Gujarati labels, weekdays and meal slots are localized', () {
    final hindi = AppLocalizations(const Locale('hi'));
    expect(hindi.label('Today', 'اليوم'), 'आज');
    expect(hindi.weekday('Sunday'), 'रविवार');
    expect(hindi.mealSlot('dinner'), 'रात का भोजन');
    final gujarati = AppLocalizations(const Locale('gu'));
    expect(gujarati.label('Today', 'اليوم'), 'આજે');
    expect(gujarati.weekday('Sunday'), 'રવિવાર');
    expect(gujarati.mealSlot('dinner'), 'રાત્રિભોજન');
  });

  test('weekdays and meal slots are localized', () {
    final arabic = AppLocalizations(const Locale('ar'));
    expect(arabic.weekday('Monday'), 'الإثنين');
    expect(arabic.mealSlot('dinner'), 'العشاء');
    expect(arabic.dietaryTag('gluten_free'), 'خالٍ من الغلوتين');
  });

  test('cooking step progress is localized', () {
    expect(AppLocalizations(const Locale('en')).stepOf(2, 5), 'STEP 2 OF 5');
    expect(AppLocalizations(const Locale('ar')).stepOf(2, 5), 'الخطوة 2 من 5');
  });
}
