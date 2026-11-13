import 'package:flutter/widgets.dart';
import '../features/recipes/domain/recipe.dart';

class RecipeCatalogScope extends InheritedWidget {
  const RecipeCatalogScope({super.key, required this.recipes, required super.child});
  final List<Recipe> recipes;
  static List<Recipe> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RecipeCatalogScope>();
    assert(scope != null, 'RecipeCatalogScope is missing above this context.');
    return scope!.recipes;
  }
  @override
  bool updateShouldNotify(RecipeCatalogScope oldWidget) => !identical(recipes, oldWidget.recipes);
}
