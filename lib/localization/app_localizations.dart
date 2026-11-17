import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  bool get isArabic => locale.languageCode == 'ar';
  bool get isHindi => locale.languageCode == 'hi';
  bool get isGujarati => locale.languageCode == 'gu';
  bool get isRtl => isArabic;
  String get languageName => switch (locale.languageCode) { 'ar' => 'العربية', 'hi' => 'हिन्दी', 'gu' => 'ગુજરાતી', _ => 'English' };
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  static const LocalizationsDelegate<AppLocalizations> delegate = _Delegate();

  String label(String english, String arabic) {
    if (isArabic) return arabic;
    if (isHindi) {
      return const <String, String>{
        'Today': 'आज', 'Recipes': 'व्यंजन', 'Favourites': 'पसंदीदा',
        'Plan': 'योजना', 'Groceries': 'किराने का सामान', 'Kitchen': 'रसोई',
        'Change language': 'भाषा बदलें', 'Language': 'भाषा',
        'Settings': 'सेटिंग्स', 'CHOOSE YOUR LANGUAGE': 'अपनी भाषा चुनें',
        'YOUR LITTLE COOKBOOK': 'आपकी छोटी रेसिपी किताब',
        'Your kitchen,\\nyour rhythm.': 'आपकी रसोई,\\nआपकी लय।',
        'Collections': 'संग्रह', 'Cooking history': 'पकाने का इतिहास',
        'Recently viewed': 'हाल ही में देखे गए', 'Your saved recipes': 'आपकी सहेजी गई रेसिपी',
        'Saved recipes': 'सहेजी गई रेसिपी', 'Meals planned': 'नियोजित भोजन',
        'Recipe library': 'रेसिपी लाइब्रेरी', 'Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.': 'चुनी हुई रेसिपी के अपडेट देखें। आपकी भोजन योजनाएँ, पेंट्री और सहेजी गई रेसिपी इसी डिवाइस पर रहती हैं।',
        'MEASUREMENTS': 'माप की इकाइयाँ', 'Measurement system': 'माप प्रणाली',
        'Metric (g, kg, ml, L)': 'मीट्रिक (g, kg, ml, L)',
        'US customary (oz, lb, cups)': 'अमेरिकी (oz, lb, cups)',
        'WEEKLY PLANNER': 'साप्ताहिक योजनाकार', 'First day of week': 'सप्ताह का पहला दिन',
        'Monday': 'सोमवार', 'Sunday': 'रविवार', 'APPEARANCE': 'दिखावट',
        'Theme': 'थीम', 'Use device setting': 'डिवाइस सेटिंग का उपयोग करें',
        'Light': 'लाइट', 'Dark': 'डार्क', 'Reduce motion': 'गतिशीलता कम करें',
        'PERSONAL DISCOVERY': 'व्यक्तिगत खोज',
        'LOCAL DATA': 'स्थानीय डेटा', 'Reset personal data': 'व्यक्तिगत डेटा रीसेट करें',
        'Cancel': 'रद्द करें', 'Save': 'सहेजें', 'Create': 'बनाएँ',
        'Delete': 'हटाएँ', 'Rename': 'नाम बदलें', 'Add recipes': 'रेसिपी जोड़ें',
        'Breakfast': 'नाश्ता', 'Lunch': 'दोपहर का भोजन', 'Dinner': 'रात का भोजन', 'Snack': 'हल्का नाश्ता',
        'Plant based': 'पौधों पर आधारित', 'Gluten free': 'ग्लूटेन मुक्त',
        'Dairy free': 'डेयरी मुक्त', 'High protein': 'उच्च प्रोटीन',
      }[english] ?? english;
    }
    if (isGujarati) {
      return const <String, String>{
        'Today': 'આજે', 'Recipes': 'વાનગીઓ', 'Favourites': 'મનપસંદ',
        'Plan': 'આયોજન', 'Groceries': 'કરિયાણું', 'Kitchen': 'રસોડું',
        'Change language': 'ભાષા બદલો', 'Language': 'ભાષા',
        'Settings': 'સેટિંગ્સ', 'CHOOSE YOUR LANGUAGE': 'તમારી ભાષા પસંદ કરો',
        'YOUR LITTLE COOKBOOK': 'તમારી નાની રસોઈપોથી',
        'Your kitchen,\\nyour rhythm.': 'તમારું રસોડું,\\nતમારી લય.',
        'Collections': 'સંગ્રહો', 'Cooking history': 'રસોઈનો ઇતિહાસ',
        'Recently viewed': 'તાજેતરમાં જોયેલી', 'Your saved recipes': 'તમારી સાચવેલી વાનગીઓ',
        'Saved recipes': 'સાચવેલી વાનગીઓ', 'Meals planned': 'આયોજિત ભોજન',
        'Recipe library': 'વાનગીઓની લાઇબ્રેરી', 'Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.': 'પસંદ કરેલી વાનગીઓના અપડેટ તપાસો. તમારી ભોજન યોજનાઓ, પેન્ટ્રી અને સાચવેલી વાનગીઓ આ ઉપકરણમાં જ રહે છે.',
        'MEASUREMENTS': 'માપ', 'Measurement system': 'માપ પદ્ધતિ',
        'Metric (g, kg, ml, L)': 'મેટ્રિક (g, kg, ml, L)',
        'US customary (oz, lb, cups)': 'અમેરિકન (oz, lb, cups)',
        'WEEKLY PLANNER': 'સાપ્તાહિક આયોજન', 'First day of week': 'અઠવાડિયાનો પહેલો દિવસ',
        'Monday': 'સોમવાર', 'Sunday': 'રવિવાર', 'APPEARANCE': 'દેખાવ',
        'Theme': 'થીમ', 'Use device setting': 'ઉપકરણની સેટિંગ વાપરો',
        'Light': 'લાઇટ', 'Dark': 'ડાર્ક', 'Reduce motion': 'એનિમેશન ઘટાડો',
        'PERSONAL DISCOVERY': 'વ્યક્તિગત શોધ',
        'LOCAL DATA': 'સ્થાનિક ડેટા', 'Reset personal data': 'વ્યક્તિગત ડેટા રીસેટ કરો',
        'Cancel': 'રદ કરો', 'Save': 'સાચવો', 'Create': 'બનાવો',
        'Delete': 'કાઢી નાખો', 'Rename': 'નામ બદલો', 'Add recipes': 'વાનગીઓ ઉમેરો',
        'Breakfast': 'નાસ્તો', 'Lunch': 'બપોરનું ભોજન', 'Dinner': 'રાત્રિભોજન', 'Snack': 'હળવો નાસ્તો',
        'Plant based': 'વનસ્પતિ આધારિત', 'Gluten free': 'ગ્લૂટેન મુક્ત',
        'Dairy free': 'ડેરી મુક્ત', 'High protein': 'વધુ પ્રોટીન',
      }[english] ?? english;
    }
    return english;
  }

  String weekday(String day) {
    if (isHindi) return const {'Monday':'सोमवार','Tuesday':'मंगलवार','Wednesday':'बुधवार','Thursday':'गुरुवार','Friday':'शुक्रवार','Saturday':'शनिवार','Sunday':'रविवार'}[day] ?? day;\n    if (isGujarati) return const {'Monday':'સોમવાર','Tuesday':'મંગળવાર','Wednesday':'બુધવાર','Thursday':'ગુરુવાર','Friday':'શુક્રવાર','Saturday':'શનિવાર','Sunday':'રવિવાર'}[day] ?? day;\n    if (!isArabic) return day;
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
    if (isHindi) return const {'Monday':'सो','Tuesday':'मं','Wednesday':'बु','Thursday':'गु','Friday':'शु','Saturday':'श','Sunday':'र'}[day] ?? day.substring(0, 1);\n    if (isGujarati) return const {'Monday':'સો','Tuesday':'મં','Wednesday':'બુ','Thursday':'ગુ','Friday':'શુ','Saturday':'શ','Sunday':'ર'}[day] ?? day.substring(0, 1);\n    if (!isArabic) return day.substring(0, 1);
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

  String get today => isArabic ? 'اليوم' : isHindi ? 'आज' : isGujarati ? 'આજે' : 'Today';
  String get recipes => isArabic ? 'الوصفات' : isHindi ? 'व्यंजन' : isGujarati ? 'વાનગીઓ' : 'Recipes';
  String get favorites => isArabic ? 'المفضلة' : isHindi ? 'पसंदीदा' : isGujarati ? 'મનપસંદ' : 'Favourites';
  String get plan => isArabic ? 'الخطة' : isHindi ? 'योजना' : isGujarati ? 'આયોજન' : 'Plan';
  String get groceries => isArabic ? 'المشتريات' : isHindi ? 'किराने का सामान' : isGujarati ? 'કરિયાણું' : 'Groceries';
  String get kitchen => isArabic ? 'المطبخ' : isHindi ? 'रसोई' : isGujarati ? 'રસોડું' : 'Kitchen';
  String get language => isArabic ? 'تغيير اللغة' : isHindi ? 'भाषा बदलें' : isGujarati ? 'ભાષા બદલો' : 'Change language';
  String get recipeShelf => isArabic ? 'رف الوصفات' : 'THE RECIPE SHELF';
  String get findFavourite => isArabic ? 'اعثر على\nمفضلتك القادمة.' : 'Find your next\nfavourite.';
  String get searchHint => isArabic ? 'ابحث عن وصفة أو مكوّن' : 'Search recipes or ingredients';
  String get emptyShelf => isArabic ? 'لا توجد وصفات هنا' : 'Nothing on this shelf';
  String get emptyShelfHint => isArabic ? 'جرّب مكوّناً آخر أو امسح عوامل التصفية.' : 'Try another ingredient or clear your filters.';
  String get weekEyebrow => isArabic ? 'أسبوع بطعم جميل' : 'A WEEK THAT TASTES GOOD';
  String get mealPlanner => isArabic ? 'مخطط\nوجباتك.' : 'Your meal\nplanner.';
  String get weekDescription => isArabic ? 'سبعة أيام وأربع وجبات يومياً. خطط أسبوعك بطريقتك.' : 'Seven days, four gentle prompts a day. Make the week your own.';

  String category(String id, String fallback) {
    if (isHindi) return const {'all':'सभी व्यंजन','breakfast':'नाश्ता','lunch':'दोपहर का भोजन','dinner':'रात का भोजन','snacks':'हल्के नाश्ते'}[id] ?? fallback;\n    if (isGujarati) return const {'all':'બધી વાનગીઓ','breakfast':'નાસ્તો','lunch':'બપોરનું ભોજન','dinner':'રાત્રિભોજન','snacks':'હળવો નાસ્તો'}[id] ?? fallback;\n    if (!isArabic) return fallback;
    return switch (id) {
      'all' => 'كل الوصفات',
      'breakfast' => 'الإفطار',
      'lunch' => 'الغداء',
      'dinner' => 'العشاء',
      'snacks' => 'وجبات خفيفة',
      _ => fallback,
    };
  }

  String recipeCount(int count) => isArabic ? '$count وصفة للتجربة' : isHindi ? 'आज़माने के लिए $count व्यंजन' : isGujarati ? 'આઝમાવવા માટે $count વાનગીઓ' : '$count ${count == 1 ? 'recipe' : 'recipes'} to try';
}
AppLocalizations appStrings(BuildContext context) => AppLocalizations.of(context);

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale locale) => const {'en', 'ar', 'hi', 'gu'}.contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));
  @override
  bool shouldReload(_Delegate old) => false;
}
