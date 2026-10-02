import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltry/features/calorie_target/data/calorie_target_repository.dart';

void main() {
  Future<CalorieTargetRepository> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return CalorieTargetRepository(await SharedPreferences.getInstance());
  }

  test('read falls back to 2000 when nothing is stored', () async {
    expect((await repositoryWith({})).read(), 2000);
  });

  test('read ignores a stored value outside 800 to 5000', () async {
    expect(
      (await repositoryWith({CalorieTargetRepository.key: 99999})).read(),
      2000,
    );
  });

  test('write then read returns the new target', () async {
    final repository = await repositoryWith({});

    await repository.write(1800);

    expect(repository.read(), 1800);
  });
}
