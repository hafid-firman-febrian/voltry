import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/core/widgets/error_view.dart';
import 'package:voltry/core/widgets/voltry_nav_bar.dart';
import 'package:voltry/features/auth/domain/app_user_model.dart';
import 'package:voltry/features/auth/presentation/widgets/account_avatar.dart';
import 'package:voltry/features/auth/presentation/widgets/account_sheet.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_meal_log_repository.dart';
import '../../../fixtures/app_user_fixtures.dart';
import '../../../fixtures/meal_log_fixtures.dart';
import '../../../helpers/pump_voltry_app.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byType(AccountButton));
    await tester.pumpAndSettle();
  }

  Future<void> tapSignOutAndConfirm(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
  }

  testWidgets('the header shows the initial when there is no photo', (
    tester,
  ) async {
    await pumpVoltryApp(tester);

    expect(
      find.descendant(of: find.byType(AccountButton), matching: find.text('R')),
      findsOneWidget,
    );
  });

  testWidgets('a photo that cannot load falls back to the initial', (
    tester,
  ) async {
    const withPhoto = AppUser(
      uid: 'user-1',
      displayName: 'Rani Putri',
      photoUrl: 'https://example.com/rani.jpg',
    );
    await pumpVoltryApp(tester, auth: FakeAuthRepository(user: withPhoto));
    // Widget tests answer every HTTP request with an error.
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AccountButton), matching: find.text('R')),
      findsOneWidget,
    );
  });

  testWidgets('the sheet names the account and covers the navbar', (
    tester,
  ) async {
    await pumpVoltryApp(tester);
    final history = tester.getCenter(find.bySemanticsLabel('History'));

    await openSheet(tester);

    expect(find.text('Rani Putri'), findsOneWidget);
    expect(find.text('rani@example.com'), findsOneWidget);
    final navBar = tester.renderObject(find.byType(VoltryNavBar));
    final hits = tester.hitTestOnBinding(history).path;
    expect(hits.any((entry) => entry.target == navBar), isFalse);
    expect(find.byType(AccountSheet), findsOneWidget);
  });

  testWidgets('Cancel in the confirmation keeps the user signed in', (
    tester,
  ) async {
    final auth = FakeAuthRepository(user: testUser);
    await pumpVoltryApp(tester, auth: auth);
    await openSheet(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out of Voltry?'), findsOneWidget);
    expect(find.text('Your meals stay in your account.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(auth.user, testUser);
    expect(find.byType(AccountSheet), findsOneWidget);
  });

  testWidgets('signing out goes to Sign in without an error on the way', (
    tester,
  ) async {
    await pumpVoltryApp(
      tester,
      repository: FakeMealLogRepository([mealLog(id: 'lunch')]),
    );
    await openSheet(tester);

    await tapSignOutAndConfirm(tester);
    // Frame by frame through the sheet closing and the page transition.
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(ErrorView), findsNothing);
    }
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);
  });

  testWidgets('signing back in as someone else shows their own meals', (
    tester,
  ) async {
    final auth = FakeAuthRepository(user: testUser)..nextUser = otherUser;
    await pumpVoltryApp(tester, auth: auth);
    await openSheet(tester);
    await tapSignOutAndConfirm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await openSheet(tester);

    expect(find.text('dimas@example.com'), findsOneWidget);
  });

  testWidgets('a failed sign out explains and stays on Home', (tester) async {
    final auth = FakeAuthRepository(user: testUser)
      ..failWith = const NetworkException('offline');
    await pumpVoltryApp(tester, auth: auth);
    await openSheet(tester);

    await tapSignOutAndConfirm(tester);
    await tester.pumpAndSettle();

    expect(
      find.text(
        "You're offline or the connection is slow. Check it and try again.",
      ),
      findsOneWidget,
    );
    expect(find.text('Today'), findsOneWidget);
  });
}
