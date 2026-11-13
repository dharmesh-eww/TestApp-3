import 'package:flutter/widgets.dart';
import '../features/recipes/domain/recipe.dart';

class RecipeCatalogScope extends InheritedWidget {
  const RecipeCatalogScope({super.key, required this.recipes, this.contentVersion = 'bundled', this.onCheckForUpdates, required super.child});
  final List<Recipe> recipes;
  final String contentVersion;
  final Future<bool> Function()? onCheckForUpdates;
  static List<Recipe> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RecipeCatalogScope>();
    assert(scope != null, 'RecipeCatalogScope is missing above this context.');
    return scope!.recipes;
  }
  static String versionOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RecipeCatalogScope>()?.contentVersion ?? 'bundled';
  static Future<bool> checkForUpdates(BuildContext context) async {
    final scope = context.dependOnInheritedWidgetOfExactType<RecipeCatalogScope>();
    return await scope?.onCheckForUpdates?.call() ?? false;
  }
  static bool canCheckForUpdates(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RecipeCatalogScope>()?.onCheckForUpdates != null;
  @override
  bool updateShouldNotify(RecipeCatalogScope oldWidget) =>
      !identical(recipes, oldWidget.recipes) || contentVersion != oldWidget.contentVersion;
}
