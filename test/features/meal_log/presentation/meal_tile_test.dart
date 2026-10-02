import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';
import 'package:voltry/features/meal_log/presentation/widgets/meal_tile.dart';

import '../../../fakes/fake_photo_storage.dart';
import '../../../fixtures/meal_log_fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'shows name, time and calories, with a placeholder for a missing photo',
    (tester) async {
      var tapped = false;
      await pumpThemed(
        tester,
        MealTile(
          log: mealLog(
            foodName: 'Soto ayam',
            calories: 1200,
            createdAt: DateTime(2026, 10, 1, 12, 30),
          ),
          onTap: () => tapped = true,
        ),
        overrides: [photoStorageProvider.overrideWithValue(FakePhotoStorage())],
      );

      expect(find.text('Soto ayam'), findsOneWidget);
      expect(find.text('12:30 PM'), findsOneWidget);
      expect(find.text('1,200 kcal'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);

      await tester.tap(find.text('Soto ayam'));
      expect(tapped, isTrue);
    },
  );
}
