import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/calorie_target_repository.dart';

final calorieTargetControllerProvider =
    AsyncNotifierProvider<CalorieTargetController, int>(
      CalorieTargetController.new,
      // Home shows a failed load with Retry right away, the same way it does
      // for the meal logs, instead of a spinner during Riverpod's backoff.
      retry: (_, _) => null,
    );

class CalorieTargetController extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(calorieTargetRepositoryProvider).read();

  // Not `update`: AsyncNotifier already has an update method.
  Future<void> save(int kcal) async {
    await ref.read(calorieTargetRepositoryProvider).write(kcal);
    state = AsyncData(kcal);
  }
}
