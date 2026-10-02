import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltry/core/providers/core_providers.dart';
import 'package:voltry/features/calorie_target/data/calorie_target_repository.dart';
import 'package:voltry/features/calorie_target/presentation/controllers/calorie_target_controller.dart';

void main() {
  test('starts from the stored target and updates it', () async {
    SharedPreferences.setMockInitialValues({CalorieTargetRepository.key: 2400});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer.test(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    expect(container.read(calorieTargetControllerProvider), 2400);

    await container.read(calorieTargetControllerProvider.notifier).update(1900);

    expect(container.read(calorieTargetControllerProvider), 1900);
    expect(prefs.getInt(CalorieTargetRepository.key), 1900);
  });
}
