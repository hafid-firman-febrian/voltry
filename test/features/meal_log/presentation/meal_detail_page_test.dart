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
    proteinG: 20,
    carbsG: 80,
    fatG: 25,
    createdAt: DateTime(2026, 10, 1, 12, 30),
  );

  testWidgets('opens from Home and shows the saved estimate', (tester) async {
    await pumpVoltryApp(tester, repository: FakeMealLogRepository([lunch]));

    await tester.tap(find.text('Nasi goreng'));
    await tester.pumpAndSettle();

    expect(find.text('Today · 12:30 PM'), findsOneWidget);
    expect(find.text('AI ESTIMATE'), findsOneWidget);
    expect(find.text('650'), findsOneWidget);
    expect(find.text('Protein 20 g'), findsOneWidget);
    expect(find.text('Carbs 80 g'), findsOneWidget);
    expect(find.text('Fat 25 g'), findsOneWidget);
  });

  testWidgets('Delete asks first, then removes the meal and its photo', (
    tester,
  ) async {
    final repository = FakeMealLogRepository([lunch]);
    final photos = FakePhotoStorage();
    await pumpVoltryApp(tester, repository: repository, photos: photos);
    await tester.tap(find.text('Nasi goreng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this meal?'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(repository.logs, isEmpty);
    expect(photos.deleted, ['lunch.jpg']);
    expect(find.text('Snap your first meal of the day.'), findsOneWidget);
  });

  testWidgets('Cancel keeps the meal', (tester) async {
    final repository = FakeMealLogRepository([lunch]);
    await pumpVoltryApp(tester, repository: repository);
    await tester.tap(find.text('Nasi goreng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.logs, [lunch]);
    expect(find.text('Delete this meal?'), findsNothing);
  });
}
