import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/analysis_parser.dart';
import 'package:voltry/features/analysis/domain/analysis_result.dart';
import 'package:voltry/features/analysis/domain/nutrition_analysis_model.dart';

void main() {
  const valid =
      '{"is_food": true, "food_name": "Nasi goreng with egg", "calories": 650,'
      ' "protein_g": 20, "carbs_g": 80, "fat_g": 25}';

  NutritionAnalysis foodFrom(String raw) =>
      (parseAnalysis(raw) as FoodFound).analysis;

  Matcher invalid(String reason) => throwsA(
    isA<AiException>().having(
      (error) => error.detail,
      'detail',
      contains(reason),
    ),
  );

  test('parses a valid reply', () {
    expect(
      foodFrom(valid),
      const NutritionAnalysis(
        foodName: 'Nasi goreng with egg',
        calories: 650,
        proteinG: 20,
        carbsG: 80,
        fatG: 25,
      ),
    );
  });

  test(
    'returns NotFood when is_food is false, whatever the other fields say',
    () {
      expect(
        parseAnalysis('{"is_food": false, "food_name": "", "calories": -1}'),
        isA<NotFood>(),
      );
    },
  );

  test('rounds decimal numbers', () {
    final food = foodFrom(
      valid.replaceFirst('"calories": 650', '"calories": 649.6'),
    );

    expect(food.calories, 650);
  });

  test('trims the name and cuts it to 60 characters', () {
    final longName =
        'Grilled chicken with rice, sambal, fried tofu, tempeh and greens';
    final food = foodFrom(
      valid.replaceFirst('"Nasi goreng with egg"', '"  $longName  "'),
    );

    expect(food.foodName, longName.substring(0, 60).trimRight());
    expect(food.foodName.length, lessThanOrEqualTo(60));
  });

  test('accepts JSON wrapped in a ```json code fence', () {
    expect(foodFrom('```json\n$valid\n```').calories, 650);
  });

  test('rejects an empty or missing reply', () {
    expect(() => parseAnalysis(null), invalid('empty reply'));
    expect(() => parseAnalysis('  '), invalid('empty reply'));
  });

  test('rejects text that is not JSON or not an object', () {
    expect(() => parseAnalysis('Looks like fried rice!'), invalid('not JSON'));
    expect(() => parseAnalysis('[1, 2]'), invalid('not a JSON object'));
  });

  test('rejects a reply without is_food', () {
    expect(
      () => parseAnalysis('{"food_name": "Rice"}'),
      invalid('is_food missing'),
    );
  });

  test('rejects an empty food name', () {
    expect(
      () =>
          parseAnalysis(valid.replaceFirst('"Nasi goreng with egg"', '"   "')),
      invalid('food_name missing'),
    );
  });

  test('rejects missing or non-numeric numbers', () {
    expect(
      () => parseAnalysis(valid.replaceFirst('"fat_g": 25', '"fat_g": "25g"')),
      invalid('fat_g missing'),
    );
    expect(
      () => parseAnalysis(valid.replaceFirst(', "protein_g": 20', '')),
      invalid('protein_g missing'),
    );
  });

  test('rejects negative and out-of-range numbers', () {
    expect(
      () => parseAnalysis(
        valid.replaceFirst('"calories": 650', '"calories": -5'),
      ),
      invalid('calories out of range'),
    );
    expect(
      () => parseAnalysis(
        valid.replaceFirst('"calories": 650', '"calories": 5001'),
      ),
      invalid('calories out of range'),
    );
    expect(
      () =>
          parseAnalysis(valid.replaceFirst('"carbs_g": 80', '"carbs_g": 1200')),
      invalid('carbs_g out of range'),
    );
  });
}
