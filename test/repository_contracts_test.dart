import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:testapp_3/core/data/app_repository.dart';
import 'package:testapp_3/data/local/planner_repository.dart';
import 'package:testapp_3/features/cooking/domain/cooking_session_repository.dart';
import 'package:testapp_3/features/groceries/domain/grocery_repository.dart';
import 'package:testapp_3/features/kitchen/domain/pantry_repository.dart';
import 'package:testapp_3/features/planning/domain/meal_plan.dart';
import 'package:testapp_3/features/planning/domain/meal_plan_repository.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';
import 'package:testapp_3/features/recipes/domain/recipe_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('SQLite adapter fulfils feature repository contracts', () async {
    final directory = await Directory.systemTemp.createTemp('gather-repositories-');
    final local = await PlannerRepository.openAt(p.join(directory.path, 'repositories.db'));
    final AppRepository repository = local;

    expect(repository, isA<RecipeRepository>());
    expect(repository, isA<MealPlanRepository>());
    expect(repository, isA<PantryRepository>());
    expect(repository, isA<GroceryRepository>());
    expect(repository, isA<CookingSessionRepository>());

    final state = PlannerState()
      ..pantry['rice'] = const PantryItem(id: 'rice', name: 'Rice', amount: 500, unit: 'g')
      ..groceryPrices['rice|g'] = 2.5;
    await repository.savePlannerState(state);

    expect((await repository.loadPlannerState())!.pantry['rice']!.amount, 500);
    expect((await repository.loadPantryState())!.pantry['rice']!.unit, 'g');
    expect((await repository.loadGroceryState())!.groceryPrices['rice|g'], 2.5);

    await repository.activateCatalog(contentVersion: 'test-v1', payload: '{"recipes":[]}');
    expect((await repository.loadCatalog())?.contentVersion, 'test-v1');

    await repository.close();
    await directory.delete(recursive: true);
  });
}
