import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';

import '../../../fakes/fake_meal_log_repository.dart';
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
  final dinner = mealLog(
    id: 'dinner',
    foodName: 'Soto ayam',
    calories: 800,
    proteinG: 40,
    carbsG: 60,
    fatG: 30,
    createdAt: DateTime(2026, 10, 1, 19),
  );
  final yesterday = mealLog(
    id: 'yesterday',
    foodName: 'Martabak',
    calories: 900,
    createdAt: DateTime(2026, 9, 30, 21),
  );

  testWidgets("shows today's total against the target and only today's meals", (
    tester,
  ) async {
    await pumpVoltryApp(
      tester,
      repository: FakeMealLogRepository([lunch, dinner, yesterday]),
      storedTarget: 2000,
    );

    expect(find.text('Thu, 1 Oct'), findsOneWidget);
    expect(find.text('1,450'), findsOneWidget);
    expect(find.text('of 2,000 kcal'), findsOneWidget);
    expect(find.text('73%'), findsOneWidget);
    expect(find.text('60 g'), findsOneWidget);
    expect(find.text('140 g'), findsOneWidget);
    expect(find.text('55 g'), findsOneWidget);
    expect(find.text('Soto ayam'), findsOneWidget);
    expect(find.text('Nasi goreng'), findsOneWidget);
    expect(find.text('Martabak'), findsNothing);
  });

  testWidgets('says how far over the target the day is', (tester) async {
    await pumpVoltryApp(
      tester,
      repository: FakeMealLogRepository([lunch, dinner]),
      storedTarget: 1200,
    );

    expect(find.text('250 kcal over'), findsOneWidget);
    expect(find.text('121%'), findsOneWidget);
  });

  testWidgets('invites the first snap when nothing was eaten today', (
    tester,
  ) async {
    await pumpVoltryApp(tester, repository: FakeMealLogRepository([yesterday]));

    expect(find.text('Snap your first meal of the day.'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('of 2,000 kcal'), findsOneWidget);
  });

  testWidgets('shows the load error with Retry right away', (tester) async {
    final repository = FakeMealLogRepository([lunch])
      ..failWith = const StorageException('corrupt');
    await pumpVoltryApp(tester, repository: repository, settle: false);
    // Riverpod's default retry would keep a spinner up for ~45 s of backoff.
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text("Couldn't access your data on this device. Please try again."),
      findsOneWidget,
    );

    repository.failWith = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Nasi goreng'), findsOneWidget);
  });

  testWidgets('editing the target updates the hero card', (tester) async {
    await pumpVoltryApp(tester, repository: FakeMealLogRepository([lunch]));

    await tester.tap(find.byTooltip('Edit daily target'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1300');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('of 1,300 kcal'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });
}
