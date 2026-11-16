import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';

void main() {
  group('Recipe favourites', () {
    test('adds and removes a recipe from favourites', () {
      final state = PlannerState();

      expect(state.isFavorite('recipe-1'), isFalse);

      state.toggleFavorite('recipe-1');
      expect(state.isFavorite('recipe-1'), isTrue);

      state.toggleFavorite('recipe-1');
      expect(state.isFavorite('recipe-1'), isFalse);
    });

    test('persists favourites when planner state is restored', () {
      final state = PlannerState()
        ..toggleFavorite('recipe-1')
        ..toggleFavorite('recipe-2');

      final restored = PlannerState.fromJson(state.toJson());

      expect(restored.favorites, containsAll(['recipe-1', 'recipe-2']));
      expect(restored.isFavorite('recipe-1'), isTrue);

      restored.toggleFavorite('recipe-1');
      expect(restored.isFavorite('recipe-1'), isFalse);
      expect(restored.isFavorite('recipe-2'), isTrue);
    });
  });
}
