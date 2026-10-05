import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/ai_model_repository.dart';
import 'package:voltry/features/analysis/domain/ai_model.dart';
import 'package:voltry/features/analysis/presentation/widgets/ai_model_sheet.dart';

import '../../../fakes/fake_ai_model_repository.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeAiModelRepository repository;
  bool? switched;

  setUp(() {
    repository = FakeAiModelRepository(AiModel.gemini36Flash);
    switched = null;
  });

  Future<void> openSheet(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpPage(
      tester,
      Scaffold(
        body: Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () async =>
                switched = await showAiModelSheet(context, ref),
            child: const Text('Open'),
          ),
        ),
      ),
      overrides: [aiModelRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Finder checkOn(String label) => find.descendant(
    of: find.widgetWithText(ListTile, label),
    matching: find.byIcon(Icons.check_rounded),
  );

  testWidgets('lists every model and checks the active one', (tester) async {
    await openSheet(tester);

    expect(find.text('AI model'), findsOneWidget);
    expect(
      find.text('Each model has its own free daily limit.'),
      findsOneWidget,
    );
    for (final model in AiModel.values) {
      expect(find.text(model.label), findsOneWidget);
    }
    expect(checkOn('Gemini 3.6 Flash'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('picking another model saves it, says so, and returns true', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.text('Gemini 3.8 Flash'));
    await tester.pumpAndSettle();

    expect(switched, isTrue);
    expect(repository.stored, AiModel.gemini38Flash);
    expect(find.text('Now using Gemini 3.8 Flash'), findsOneWidget);
  });

  testWidgets('picking the active model again changes nothing', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Gemini 3.6 Flash'));
    await tester.pumpAndSettle();

    expect(switched, isFalse);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('closing the sheet without picking returns false', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(switched, isFalse);
    expect(find.text('Gemini 3.8 Flash'), findsNothing);
  });

  testWidgets('a failed save explains why and keeps the old model', (
    tester,
  ) async {
    repository.failWith = const StorageException('disk full');
    await openSheet(tester);

    await tester.tap(find.text('Gemini 3.8 Flash'));
    await tester.pumpAndSettle();

    expect(switched, isFalse);
    expect(repository.stored, AiModel.gemini36Flash);
    expect(
      find.text("Couldn't access your data. Please try again."),
      findsOneWidget,
    );
  });
}
