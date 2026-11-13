import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/main.dart';

void main() {
  testWidgets('shows the Gather recipe planner home', (tester) async {
    await tester.pumpWidget(const RecipePlannerApp());

    expect(find.text('A little more joy\nin the kitchen.'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
  });
}
