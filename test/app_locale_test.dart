import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:testapp_3/localization/app_locale.dart';

void main() {
  test('app and recipe locale configuration exposes the same supported codes', () {
    expect(
      AppLocale.supportedLocales.map((locale) => locale.languageCode).toSet(),
      AppLocale.supportedLanguageCodes,
    );
  });

  test('unsupported persisted locale safely falls back to English', () {
    expect(AppLocale.normalizeCode('fr'), 'en');
    expect(AppLocale.normalize(const Locale('fr')), const Locale('en'));
  });

  test('all supported locales remain selectable', () {
    for (final code in AppLocale.supportedLanguageCodes) {
      expect(AppLocale.normalizeCode(code), code);
      expect(AppLocale.isSupported(code), isTrue);
    }
  });
}
