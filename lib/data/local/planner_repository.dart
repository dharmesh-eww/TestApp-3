import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../features/planning/domain/planner_state.dart';

/// SQLite-backed local store. Personal data remains on this device.
class PlannerRepository {
  PlannerRepository._(this._database);
  final Database _database;

  static Future<PlannerRepository> openDefault() async {
    final directory = await getDatabasesPath();
    return openAt(p.join(directory, 'gather_planner.db'));
  }

  static Future<PlannerRepository> openAt(String databasePath) async {
    final database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE planner_snapshot (id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
        await db.execute('CREATE TABLE recipe_catalog_cache (id TEXT PRIMARY KEY, content_version TEXT NOT NULL, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
        await db.execute('CREATE TABLE cooking_session_snapshot (id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('CREATE TABLE cooking_session_snapshot (id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
        }
      },
    );
    return PlannerRepository._(database);
  }

  Future<PlannerState?> loadPlannerState() async {
    final rows = await _database.query('planner_snapshot', where: 'id = ?', whereArgs: ['primary'], limit: 1);
    if (rows.isEmpty) return null;
    try {
      final decoded = jsonDecode(rows.first['payload']! as String);
      if (decoded is! Map<String, dynamic>) return null;
      return PlannerState.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> savePlannerState(PlannerState state) async {
    await _database.insert('planner_snapshot', {
      'id': 'primary',
      'payload': jsonEncode(state.toJson()),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> loadCookingSession() async {
    final rows = await _database.query('cooking_session_snapshot',
        where: 'id = ?', whereArgs: ['primary'], limit: 1);
    if (rows.isEmpty) return null;
    try {
      final decoded = jsonDecode(rows.first['payload']! as String);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveCookingSession(Map<String, Object?> snapshot) async {
    await _database.insert('cooking_session_snapshot', {
      'id': 'primary',
      'payload': jsonEncode(snapshot),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<({String contentVersion, String payload})?> loadCatalog() async {
    final rows = await _database.query('recipe_catalog_cache', where: 'id = ?', whereArgs: ['active'], limit: 1);
    if (rows.isEmpty) return null;
    return (contentVersion: rows.first['content_version']! as String, payload: rows.first['payload']! as String);
  }

  Future<void> activateCatalog({required String contentVersion, required String payload}) async {
    await _database.transaction((txn) async {
      await txn.insert('recipe_catalog_cache', {
        'id': 'active',
        'content_version': contentVersion,
        'payload': payload,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> close() => _database.close();
}
