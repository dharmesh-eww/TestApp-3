import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings(context).label('Language', 'اللغة')),
      ),
      body: ListView(
        cacheExtent: 1000,
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            appStrings(context).label('CHOOSE YOUR LANGUAGE', 'اختر لغتك'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.terracotta,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-english'),
              value: 'en',
              groupValue: locale.languageCode,
              title: const Text('English'),
              secondary: const Text('EN'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-hindi'),
              value: 'hi',
              groupValue: locale.languageCode,
              title: const Text('हिन्दी'),
              secondary: const Text('HI'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('hi'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-gujarati'),
              value: 'gu',
              groupValue: locale.languageCode,
              title: const Text('ગુજરાતી'),
              secondary: const Text('GU'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('gu'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-arabic'),
              value: 'ar',
              groupValue: locale.languageCode,
              title: const Text('العربية'),
              secondary: const Text('AR'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-japanese'),
              value: 'ja',
              groupValue: locale.languageCode,
              title: const Text('日本語'),
              secondary: const Text('JA'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('ja'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-portuguese'),
              value: 'pt',
              groupValue: locale.languageCode,
              title: const Text('Português'),
              secondary: const Text('PT'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('pt'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-indonesian'),
              value: 'id',
              groupValue: locale.languageCode,
              title: const Text('Bahasa Indonesia'),
              secondary: const Text('ID'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('id'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-spanish'),
              value: 'es',
              groupValue: locale.languageCode,
              title: const Text('Español'),
              secondary: const Text('ES'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('es'));
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              key: const Key('language-option-chinese'),
              value: 'zh',
              groupValue: locale.languageCode,
              title: const Text('简体中文'),
              secondary: const Text('ZH'),
              onChanged: (value) {
                if (value == null) return;
                onLocaleChanged(const Locale('zh'));
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
