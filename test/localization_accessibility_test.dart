import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/app/app.dart';

void main() {
  testWidgets('switches between English and Arabic and applies RTL', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());
    expect(find.text('Recipes'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byKey(const Key('locale-toggle')))), TextDirection.ltr);

    await tester.tap(find.byKey(const Key('locale-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('الوصفات'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byKey(const Key('locale-toggle')))), TextDirection.rtl);

    await tester.tap(find.byKey(const Key('locale-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Recipes'), findsOneWidget);
  });
}
