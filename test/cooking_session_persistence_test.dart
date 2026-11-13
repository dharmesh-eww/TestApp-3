import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/cooking/domain/cooking_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cooking progress, servings and timers survive snapshot restoration', () {
    final session = CookingSession();
    session.setStep('recipe-a', 2, 5);
    session.setServings('recipe-a', 4);
    final timer = session.addTimer('Simmer', const Duration(minutes: 8));
    session.startTimer(timer.id);
    final snapshot = session.toJson();

    final restored = CookingSession();
    restored.restoreFromJson(Map<String, dynamic>.from(snapshot));

    expect(restored.stepFor('recipe-a'), 2);
    expect(restored.servingsFor('recipe-a', 2), 4);
    expect(restored.timers, hasLength(1));
    expect(restored.timers.single.label, 'Simmer');
    expect(restored.timers.single.isRunning, isTrue);
    session.dispose();
    restored.dispose();
  });
}
