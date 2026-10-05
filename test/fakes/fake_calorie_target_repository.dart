import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/calorie_target/data/calorie_target_repository.dart';
import 'package:voltry/features/calorie_target/domain/calorie_target_rules.dart';

class FakeCalorieTargetRepository implements CalorieTargetRepository {
  FakeCalorieTargetRepository([this.stored = CalorieTargetRules.fallback]);

  int stored;

  /// When set, read throws it.
  AppException? failReadWith;

  @override
  Future<int> read() async {
    final failure = failReadWith;
    if (failure != null) throw failure;
    return stored;
  }

  @override
  Future<void> write(int kcal) async => stored = kcal;
}
