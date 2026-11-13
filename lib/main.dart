import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/local/planner_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlannerRepository? repository;
  try {
    repository = await PlannerRepository.openDefault();
  } catch (_) {
    // SQLite may be unavailable on an unsupported host; continue in memory.
  }
  runApp(RecipePlannerApp(repository: repository));
}
