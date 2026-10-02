import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/calorie_target/presentation/widgets/calorie_target_dialog.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester, {
    ValueChanged<int?>? onClosed,
  }) async {
    await pumpThemed(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showDialog<int>(
              context: context,
              builder: (_) => const CalorieTargetDialog(initial: 2000),
            );
            onClosed?.call(result);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts with the current target', (tester) async {
    await openDialog(tester);

    expect(find.widgetWithText(TextField, '2000'), findsOneWidget);
  });

  testWidgets('shows an error and disables Save outside 800 to 5000', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), '50');
    await tester.pump();

    expect(
      find.text('Enter a whole number from 800 to 5,000.'),
      findsOneWidget,
    );
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('returns the new target on Save', (tester) async {
    int? result;
    await openDialog(tester, onClosed: (value) => result = value);

    await tester.enterText(find.byType(TextField), '1800');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 1800);
  });
}
