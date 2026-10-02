import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/meal_log/domain/daily_summary.dart';

import '../../../fixtures/meal_log_fixtures.dart';

void main() {
  group('summarizeDay', () {
    test('adds up calories and macros', () {
      final summary = summarizeDay([
        mealLog(id: 'a', calories: 650, proteinG: 20, carbsG: 80, fatG: 25),
        mealLog(id: 'b', calories: 300, proteinG: 10, carbsG: 40, fatG: 9),
      ]);

      expect(
        summary,
        const DailySummary(calories: 950, proteinG: 30, carbsG: 120, fatG: 34),
      );
    });

    test('is empty for no logs', () {
      expect(summarizeDay([]), DailySummary.empty);
    });
  });

  group('logsOnDay', () {
    test('keeps only logs from the local day of now, newest first', () {
      final now = DateTime(2026, 10, 1, 20);
      final breakfast = mealLog(
        id: 'breakfast',
        createdAt: DateTime(2026, 10, 1, 0, 10),
      );
      final lunch = mealLog(id: 'lunch', createdAt: DateTime(2026, 10, 1, 12));
      final lateSnack = mealLog(
        id: 'yesterday',
        createdAt: DateTime(2026, 9, 30, 23, 50),
      );

      expect(logsOnDay([breakfast, lateSnack, lunch], now), [lunch, breakfast]);
    });
  });

  group('groupByDay', () {
    test('groups by local day with days and logs newest first', () {
      final oct1Lunch = mealLog(
        id: 'oct1-lunch',
        createdAt: DateTime(2026, 10, 1, 12),
      );
      final oct1Dinner = mealLog(
        id: 'oct1-dinner',
        createdAt: DateTime(2026, 10, 1, 19),
      );
      final sep28 = mealLog(id: 'sep28', createdAt: DateTime(2026, 9, 28, 8));

      final groups = groupByDay([sep28, oct1Lunch, oct1Dinner]);

      expect(groups.map((group) => group.day), [
        DateTime(2026, 10, 1),
        DateTime(2026, 9, 28),
      ]);
      expect(groups.first.logs, [oct1Dinner, oct1Lunch]);
      expect(groups.first.summary.calories, 1300);
      expect(groups.last.logs, [sep28]);
    });

    test('returns no groups for no logs', () {
      expect(groupByDay([]), isEmpty);
    });
  });
}
