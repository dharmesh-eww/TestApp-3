/// Persistence boundary for the curated and downloadable recipe catalog.
///
/// Implementations may use SQLite, files, or a future remote cache without
/// exposing those details to recipe presentation or domain code.
typedef CachedRecipeCatalog = ({String contentVersion, String payload});

abstract interface class RecipeRepository {
  Future<CachedRecipeCatalog?> loadCatalog();

  Future<void> activateCatalog({
    required String contentVersion,
    required String payload,
  });
}
