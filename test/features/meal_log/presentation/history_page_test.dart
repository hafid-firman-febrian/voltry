import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_meal_log_repository.dart';
import '../../../fakes/fake_photo_storage.dart';
import '../../../fixtures/meal_log_fixtures.dart';
import '../../../helpers/pump_voltry_app.dart';

void main() {
  final lunch = mealLog(
    id: 'lunch',
    foodName: 'Nasi goreng',
    calories: 650,
    createdAt: DateTime(2026, 10, 1, 12),
  );
  final dinner = mealLog(
    id: 'dinner',
    foodName: 'Soto ayam',
    calories: 800,
    createdAt: DateTime(2026, 10, 1, 19),
  );
  final saturday = mealLog(
    id: 'saturday',
    foodName: 'Martabak',
    calories: 1820,
    createdAt: DateTime(2026, 9, 26, 20),
  );

  Future<void> openHistory(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('History'));
    await tester.pumpAndSettle();
  }

  testWidgets('groups meals by day with each day total', (tester) async {
    await pumpVoltryApp(
      tester,
      repository: FakeMealLogRepository([lunch, dinner, saturday]),
    );
    await openHistory(tester);

    expect(find.text('Today · 1,450 kcal'), findsOneWidget);
    expect(find.text('Sat, 26 Sep · 1,820 kcal'), findsOneWidget);
    expect(find.text('Martabak'), findsOneWidget);
  });

  testWidgets('shows a hint when there is no history yet', (tester) async {
    await pumpVoltryApp(tester);
    await openHistory(tester);

    expect(
      find.text('No meals yet. Snap your first meal from Home.'),
      findsOneWidget,
    );
  });

  testWidgets('swipe deletes a meal and Undo brings it back', (tester) async {
    final repository = FakeMealLogRepository([lunch, dinner]);
    final photos = FakePhotoStorage();
    await pumpVoltryApp(tester, repository: repository, photos: photos);
    await openHistory(tester);

    await tester.drag(find.text('Soto ayam'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Soto ayam'), findsNothing);
    expect(find.text('Today · 650 kcal'), findsOneWidget);
    expect(find.text('Meal deleted'), findsOneWidget);
    expect(repository.logs, [lunch]);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Soto ayam'), findsOneWidget);
    expect(repository.logs, containsAll([lunch, dinner]));
    expect(photos.deleted, isEmpty);
  });

  testWidgets(
    'the photo is removed once the Undo snack bar closes on its own',
    (tester) async {
      final photos = FakePhotoStorage();
      await pumpVoltryApp(
        tester,
        repository: FakeMealLogRepository([lunch]),
        photos: photos,
      );
      await openHistory(tester);

      await tester.drag(find.text('Nasi goreng'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(photos.deleted, isEmpty);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Meal deleted'), findsNothing);
      expect(photos.deleted, ['lunch.jpg']);
    },
  );
}
