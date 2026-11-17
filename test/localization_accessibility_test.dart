import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';

Future<void> openLanguagePicker(WidgetTester tester) async {
  await tester.tap(find.text('Kitchen'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open-language-selection')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('language settings offer all four supported languages', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await openLanguagePicker(tester);

    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('ગુજરાતી'), findsOneWidget);
  });

  testWidgets('selecting Hindi and Gujarati updates the app locale', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await openLanguagePicker(tester);
    await tester.tap(find.byKey(const Key('language-option-hindi')));
    await tester.pumpAndSettle();
    expect(find.text('भाषा'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('भाषा'))), TextDirection.ltr);

    await tester.tap(find.byKey(const Key('open-language-selection')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-option-gujarati')));
    await tester.pumpAndSettle();
    expect(find.text('ભાષા'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('ભાષા'))), TextDirection.ltr);
  });

  testWidgets('Arabic remains right-to-left after selection', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    await openLanguagePicker(tester);
    await tester.tap(find.byKey(const Key('language-option-arabic')));
    await tester.pumpAndSettle();
    expect(find.text('اللغة'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('اللغة'))), TextDirection.rtl);
  });
}
