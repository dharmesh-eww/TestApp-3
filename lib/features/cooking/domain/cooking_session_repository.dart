/// Persistence boundary for an in-progress cooking session snapshot.
abstract interface class CookingSessionRepository {
  Future<Map<String, dynamic>?> loadCookingSession();

  Future<void> saveCookingSession(Map<String, Object?> snapshot);
}
