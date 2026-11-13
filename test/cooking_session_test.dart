import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/cooking/domain/cooking_session.dart';
import 'package:testapp_3/features/recipes/domain/recipe_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cooking session', () {
    test('stores step progress and servings per recipe', () {
      final session = CookingSession();
      addTearDown(session.dispose);
      session.setStep('recipe-a', 2, 4);
      session.setStep('recipe-b', 1, 3);
      session.setServings('recipe-a', 4);
      expect(session.stepFor('recipe-a'), 2);
      expect(session.stepFor('recipe-b'), 1);
      expect(session.servingsFor('recipe-a', 2), 4);
      expect(session.servingsFor('recipe-b', 2), 2);
    });

    test('clamps step progress to available steps', () {
      final session = CookingSession();
      addTearDown(session.dispose);
      session.setStep('recipe-a', 99, 3);
      expect(session.stepFor('recipe-a'), 2);
    });

    test('supports start, pause, resume and reset for multiple timers', () async {
      final session = CookingSession();
      addTearDown(session.dispose);
      final first = session.addTimer('Steam dhokla', const Duration(seconds: 2));
      final second = session.addTimer('Rest sauce', const Duration(seconds: 3));
      session.startTimer(first.id);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      session.pauseTimer(first.id);
      final paused = first.remaining;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(first.remaining, paused);
      expect(first.isRunning, isFalse);
      session.startTimer(first.id);
      expect(first.isRunning, isTrue);
      expect(second.isRunning, isFalse);
      session.resetTimer(first.id);
      expect(first.remaining, const Duration(seconds: 2));
      expect(first.isRunning, isFalse);
    });

    test('marks a timer complete after its deadline', () async {
      final session = CookingSession();
      addTearDown(session.dispose);
      final timer = session.addTimer('Quick test', const Duration(milliseconds: 60));
      session.startTimer(timer.id);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      session.refresh();
      expect(timer.isComplete, isTrue);
      expect(timer.remaining, Duration.zero);
      expect(timer.isRunning, isFalse);
    });

    test('scales quantified ingredient amounts with servings', () {
      final recipe = recipes.first;
      final ingredient = recipe.ingredients.first;
      expect(
        ingredient.display(recipe.servings * 2, recipe.servings),
        isNot(ingredient.display(recipe.servings, recipe.servings)),
      );
    });
  });
}
