import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/photo_picker.dart';
import 'package:voltry/features/analysis/domain/analysis_result.dart';
import 'package:voltry/features/analysis/domain/nutrition_analysis_model.dart';

import '../../../fakes/fake_food_analyzer.dart';
import '../../../fakes/fake_meal_log_repository.dart';
import '../../../fakes/fake_photo_picker.dart';
import '../../../fakes/fake_photo_storage.dart';
import '../../../helpers/pump_voltry_app.dart';

void main() {
  const nasiGoreng = NutritionAnalysis(
    foodName: 'Nasi goreng',
    calories: 650,
    proteinG: 20,
    carbsG: 80,
    fatG: 25,
  );

  late FakeMealLogRepository repository;
  late FakePhotoStorage photos;
  late FakePhotoPicker picker;

  setUp(() {
    repository = FakeMealLogRepository();
    photos = FakePhotoStorage();
    picker = FakePhotoPicker(photo: XFile('/tmp/image_picker_1.jpg'));
  });

  Future<void> start(WidgetTester tester, FakeFoodAnalyzer analyzer) =>
      pumpVoltryApp(
        tester,
        repository: repository,
        photos: photos,
        analyzer: analyzer,
        picker: picker,
      );

  Future<void> snapWithCamera(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Snap a meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    // Not pumpAndSettle: the loading spinner never settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('snap, see the estimate, save, and Home adds it to today', (
    tester,
  ) async {
    final analyzer = FakeFoodAnalyzer([const FoodFound(nasiGoreng)])
      ..gate = Completer();
    await start(tester, analyzer);

    await snapWithCamera(tester);
    expect(find.text('Analyzing your meal…'), findsOneWidget);
    expect(picker.sources, [PhotoSource.camera]);

    analyzer.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('AI ESTIMATE'), findsOneWidget);
    expect(find.text('Nasi goreng'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('650'), findsOneWidget);
    expect(find.text('Nasi goreng'), findsOneWidget);
    expect(repository.logs.single.id, 'new-meal');
    expect(photos.saved, ['new-meal.jpg']);
  });

  testWidgets(
    'a photo without food offers Retake, which opens the picker again',
    (tester) async {
      await start(tester, FakeFoodAnalyzer([const NotFood()]));

      await snapWithCamera(tester);
      await tester.pumpAndSettle();
      expect(find.text('No food found in this photo.'), findsOneWidget);

      await tester.tap(find.text('Retake'));
      await tester.pumpAndSettle();

      expect(find.text('Take photo'), findsOneWidget);
      expect(repository.logs, isEmpty);
    },
  );

  testWidgets('an offline failure offers Try again', (tester) async {
    await start(
      tester,
      FakeFoodAnalyzer([
        const NetworkException('offline'),
        const FoodFound(nasiGoreng),
      ]),
    );

    await snapWithCamera(tester);
    await tester.pumpAndSettle();
    expect(
      find.text(
        "You're offline or the connection is slow. Check it and try again.",
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Nasi goreng'), findsOneWidget);
  });

  testWidgets('a failed save keeps the estimate on screen and explains why', (
    tester,
  ) async {
    await start(tester, FakeFoodAnalyzer([const FoodFound(nasiGoreng)]));
    await snapWithCamera(tester);
    await tester.pumpAndSettle();
    repository.failWith = const StorageException('disk full');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't access your data on this device. Please try again."),
      findsOneWidget,
    );
    expect(find.text('AI ESTIMATE'), findsOneWidget);
    expect(photos.deleted, ['new-meal.jpg']);
  });

  testWidgets('leaving while Gemini is still thinking saves nothing', (
    tester,
  ) async {
    final analyzer = FakeFoodAnalyzer([const FoodFound(nasiGoreng)])
      ..gate = Completer();
    await start(tester, analyzer);
    await snapWithCamera(tester);
    expect(find.text('Analyzing your meal…'), findsOneWidget);
    expect(analyzer.requests, hasLength(1));

    await tester.tap(find.byType(BackButton));
    await tester.pump(const Duration(milliseconds: 400));
    analyzer.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Snap your first meal of the day.'), findsOneWidget);
    expect(repository.logs, isEmpty);
  });

  testWidgets('a used-up AI quota says so instead of a generic error', (
    tester,
  ) async {
    await start(
      tester,
      FakeFoodAnalyzer([const AiQuotaException('429 quota exceeded')]),
    );

    await snapWithCamera(tester);
    await tester.pumpAndSettle();

    expect(
      find.text("You've reached today's AI limit. Please try again later."),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });
}
