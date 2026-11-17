import '../../features/cooking/domain/cooking_session_repository.dart';
import '../../features/groceries/domain/grocery_repository.dart';
import '../../features/kitchen/domain/pantry_repository.dart';
import '../../features/planning/domain/meal_plan_repository.dart';
import '../../features/recipes/domain/recipe_repository.dart';

/// Composition of feature-level persistence contracts used by the app.
///
/// The UI depends on these interfaces rather than on SQLite. A future
/// synchronized implementation can replace the local adapter at composition
/// time while preserving the same feature contracts.
abstract interface class AppRepository
    implements
        RecipeRepository,
        MealPlanRepository,
        PantryRepository,
        GroceryRepository,
        CookingSessionRepository {}
