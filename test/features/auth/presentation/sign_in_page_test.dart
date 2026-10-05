import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/core/widgets/voltry_nav_bar.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../helpers/pump_voltry_app.dart';

void main() {
  Finder continueButton() => find.text('Continue with Google');

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
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

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
