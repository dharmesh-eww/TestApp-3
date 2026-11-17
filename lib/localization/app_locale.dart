import 'package:flutter/widgets.dart';

/// The single source of truth for supported app and recipe locales.
abstract final class AppLocale {
  static const List<Locale> supportedLocales = [
    Locale('en'), Locale('hi'), Locale('gu'), Locale('ar'), Locale('ja'),
    Locale('pt'), Locale('id'), Locale('es'), Locale('zh'),
  ];

  static const Set<String> supportedLanguageCodes = {
    'en', 'hi', 'gu', 'ar', 'ja', 'pt', 'id', 'es', 'zh',
  };

  static String normalizeCode(String? languageCode) =>
      supportedLanguageCodes.contains(languageCode) ? languageCode! : 'en';

  static Locale normalize(Locale locale) => Locale(normalizeCode(locale.languageCode));

  static bool isSupported(String languageCode) =>
      supportedLanguageCodes.contains(languageCode);
}
