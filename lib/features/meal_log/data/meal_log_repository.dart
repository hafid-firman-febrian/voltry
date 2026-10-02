import '../domain/meal_log_model.dart';

/// The only door to stored meal logs. Stage 2 adds a cloud implementation
/// behind this same interface.
abstract interface class MealLogRepository {
  /// All logs, newest first.
  Future<List<MealLog>> fetchAll();

  Future<void> insert(MealLog log);

  Future<void> delete(String id);
}
