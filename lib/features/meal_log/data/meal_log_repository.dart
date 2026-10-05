import '../domain/meal_log_model.dart';

/// The only door to stored meal logs.
abstract interface class MealLogRepository {
  /// All logs, newest first.
  Future<List<MealLog>> fetchAll();

  Future<void> insert(MealLog log);

  Future<void> delete(String id);
}
