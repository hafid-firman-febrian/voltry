import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/analysis/domain/nutrition_analysis_model.dart';
import 'package:voltry/features/meal_log/domain/meal_log_model.dart';

import '../../../fixtures/meal_log_fixtures.dart';

void main() {
  test('toRow and fromRow round-trip every field', () {
    final log = mealLog(createdAt: DateTime.utc(2026, 10, 1, 5, 30, 12, 345));

    expect(MealLog.fromRow(log.toRow()), log);
  });

  test('stores created_at as epoch milliseconds and reads it back as UTC', () {
    final log = mealLog(createdAt: DateTime.utc(2026, 10, 1, 5, 30));
    final row = log.toRow();

    expect(
      row['created_at'],
      DateTime.utc(2026, 10, 1, 5, 30).millisecondsSinceEpoch,
    );
    expect(MealLog.fromRow(row).createdAt.isUtc, isTrue);
  });

  test('nutrition exposes the values as a NutritionAnalysis', () {
    final log = mealLog(
      foodName: 'Soto ayam',
      calories: 400,
      proteinG: 25,
      carbsG: 30,
      fatG: 18,
    );

    expect(
      log.nutrition,
      const NutritionAnalysis(
        foodName: 'Soto ayam',
        calories: 400,
        proteinG: 25,
        carbsG: 30,
        fatG: 18,
      ),
    );
  });
}
