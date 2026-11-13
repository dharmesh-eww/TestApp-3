import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:testapp_3/data/local/planner_repository.dart';
import 'package:testapp_3/features/planning/domain/planner_state.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('SQLite stores planner and cooking snapshots locally', () async {
    final directory = await Directory.systemTemp.createTemp('gather-db-');
    final repository = await PlannerRepository.openAt(p.join(directory.path, 'planner.db'));
    final state = PlannerState()..toggleFavorite('recipe-a');
    await repository.savePlannerState(state);
    await repository.saveCookingSession({
      'schema_version': 1,
      'steps': {'recipe-a': 2},
      'servings': {'recipe-a': 4},
      'timers': [],
    });

    expect((await repository.loadPlannerState())!.isFavorite('recipe-a'), isTrue);
    expect((await repository.loadCookingSession())!['steps'], {'recipe-a': 2});
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('upgrades a Phase 7 version-one database without losing planner data', () async {
    final directory = await Directory.systemTemp.createTemp('gather-migration-');
    final path = p.join(directory.path, 'legacy.db');
    final legacy = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE planner_snapshot (id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
          await db.execute('CREATE TABLE recipe_catalog_cache (id TEXT PRIMARY KEY, content_version TEXT NOT NULL, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
          await db.insert('planner_snapshot', {
            'id': 'primary',
            'payload': '{"schema_version":1,"favorites":["kept-recipe"]}',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        },
      ),
    );
    await legacy.close();

    final upgraded = await PlannerRepository.openAt(path);
    expect((await upgraded.loadPlannerState())!.isFavorite('kept-recipe'), isTrue);
    await upgraded.saveCookingSession({'schema_version': 1, 'steps': {}, 'servings': {}, 'timers': []});
    expect(await upgraded.loadCookingSession(), isNotNull);
    await upgraded.close();
    await directory.delete(recursive: true);
  });
}
