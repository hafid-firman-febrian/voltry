import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/calorie_target_repository.dart';

final calorieTargetControllerProvider =
    NotifierProvider<CalorieTargetController, int>(CalorieTargetController.new);

class CalorieTargetController extends Notifier<int> {
  @override
  int build() => ref.watch(calorieTargetRepositoryProvider).read();

  /// Throws StorageException and keeps the old target when saving fails.
  Future<void> update(int kcal) async {
    await ref.read(calorieTargetRepositoryProvider).write(kcal);
    state = kcal;
  }
}
