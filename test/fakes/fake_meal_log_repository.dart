import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/meal_log/data/meal_log_repository.dart';
import 'package:voltry/features/meal_log/domain/daily_summary.dart';
import 'package:voltry/features/meal_log/domain/meal_log_model.dart';

class FakeMealLogRepository implements MealLogRepository {
  FakeMealLogRepository([List<MealLog> initial = const []])
    : logs = [...initial];

  final List<MealLog> logs;

  /// When set, the next call to any method throws it.
  AppException? failWith;

  @override
  Future<List<MealLog>> fetchAll() async {
    _maybeFail();
    return [...logs]..sort(newestFirst);
  }

  @override
  Future<void> insert(MealLog log) async {
    _maybeFail();
    logs.add(log);
  }

  @override
  Future<void> delete(String id) async {
    _maybeFail();
    logs.removeWhere((log) => log.id == id);
  }

  void _maybeFail() {
    final error = failWith;
    if (error != null) throw error;
  }
}
