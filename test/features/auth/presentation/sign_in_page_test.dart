import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/core/widgets/voltry_nav_bar.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../helpers/pump_voltry_app.dart';

void main() {
  Finder continueButton() => find.text('Continue with Google');
  Finder googleButton() => find.ancestor(
    of: continueButton(),
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
  final googleLogo = find.image(
    const AssetImage('assets/images/google-logo.png'),
  );

  // The test font draws every glyph as wide as the font size, so the content
  // only leaves room to spare (and shows how it is laid out) on a wide screen.
  Future<void> pumpOnWideScreen(WidgetTester tester) async {
    await pumpVoltryApp(tester, auth: FakeAuthRepository());
    tester.view.physicalSize = const Size(2400, 2532);
    await tester.pumpAndSettle();
  }

  testWidgets('signed out, the app opens on Sign in without the navbar', (
    tester,
  ) async {
    await pumpVoltryApp(tester, auth: FakeAuthRepository());

    expect(continueButton(), findsOneWidget);
    expect(
      find.text('Snap a meal, get its calories and macros.'),
      findsOneWidget,
    );
    expect(find.byType(VoltryNavBar), findsNothing);
  });

  testWidgets('Sign in shows the app icon with the app name', (tester) async {
    await pumpVoltryApp(tester, auth: FakeAuthRepository());

    expect(
      find.image(const AssetImage('assets/icon/voltry-app-icon.png')),
      findsOneWidget,
    );
    expect(find.text('Voltry'), findsOneWidget);
  });

  testWidgets('the Google button shows the Google logo', (tester) async {
    await pumpVoltryApp(tester, auth: FakeAuthRepository());

    expect(
      find.descendant(of: googleButton(), matching: googleLogo),
      findsOneWidget,
    );
  });

  testWidgets('the Google button is only as wide as its content', (
    tester,
  ) async {
    await pumpOnWideScreen(tester);

    final screenWidth = tester.getSize(find.byType(Scaffold)).width;
    expect(tester.getSize(googleButton()).width, lessThan(screenWidth - 32));
  });

  testWidgets('Sign in centers its content across the screen', (tester) async {
    await pumpOnWideScreen(tester);

    final middle = tester.getCenter(find.byType(Scaffold)).dx;
    for (final finder in [
      find.image(const AssetImage('assets/icon/voltry-app-icon.png')),
      find.text('Voltry'),
      find.text('Snap a meal, get its calories and macros.'),
      googleButton(),
    ]) {
      expect(tester.getCenter(finder).dx, moreOrLessEquals(middle));
    }
  });

  testWidgets('signing in moves on to Home', (tester) async {
    await pumpVoltryApp(tester, auth: FakeAuthRepository());

    await tester.tap(continueButton());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(continueButton(), findsNothing);
  });

  testWidgets('the button shows progress while Google is open', (tester) async {
    final auth = FakeAuthRepository()..gate = Completer<void>();
    await pumpVoltryApp(tester, auth: auth);

    await tester.tap(continueButton());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(googleLogo, findsNothing);
    expect(continueButton(), findsOneWidget);
    expect(tester.widget<ButtonStyleButton>(googleButton()).onPressed, isNull);

    auth.gate!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('closing the account picker stays put without a message', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..nextUser = null;
    await pumpVoltryApp(tester, auth: auth);

    await tester.tap(continueButton());
    await tester.pumpAndSettle();

    expect(continueButton(), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a failed sign in explains and lets the user try again', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..failWith = const AuthException('developer_error');
    await pumpVoltryApp(tester, auth: auth);

    await tester.tap(continueButton());
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't sign in with Google. Please try again."),
      findsOneWidget,
    );

    auth.failWith = null;
    // Straight away, while the snack bar is still up.
    await tester.tap(continueButton());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
  });
}
