import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/core/providers/core_providers.dart';
import 'package:voltry/features/analysis/data/gemini_food_analyzer.dart';
import 'package:voltry/features/analysis/domain/analysis_result.dart';
import 'package:voltry/features/analysis/domain/nutrition_analysis_model.dart';
import 'package:voltry/features/analysis/presentation/controllers/analyze_controller.dart';
import 'package:voltry/features/analysis/presentation/states/analyze_state.dart';
import 'package:voltry/features/meal_log/data/local_meal_log_repository.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';
import 'package:voltry/features/meal_log/domain/meal_log_model.dart';

import '../../../fakes/fake_food_analyzer.dart';
import '../../../fakes/fake_meal_log_repository.dart';
import '../../../fakes/fake_photo_storage.dart';

void main() {
  const nasiGoreng = NutritionAnalysis(
    foodName: 'Nasi goreng',
    calories: 650,
    proteinG: 20,
    carbsG: 80,
    fatG: 25,
  );
  final photo = XFile('/tmp/image_picker_1.png');

  late FakeMealLogRepository repository;
  late FakePhotoStorage photos;

  ProviderContainer containerWith(FakeFoodAnalyzer analyzer) {
    final container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        foodAnalyzerProvider.overrideWithValue(analyzer),
        mealLogRepositoryProvider.overrideWithValue(repository),
        photoStorageProvider.overrideWithValue(photos),
        clockProvider.overrideWithValue(
          () => DateTime.utc(2026, 10, 1, 5, 30, 0, 0, 999),
        ),
        idGeneratorProvider.overrideWithValue(() => 'meal-1'),
      ],
    );
    // Keep the autoDispose provider alive for the whole test, like the page does.
    container.listen(analyzeControllerProvider(photo), (_, _) {});
    return container;
  }

  AnalyzeState stateOf(ProviderContainer container) =>
      container.read(analyzeControllerProvider(photo));

  AnalyzeController controllerOf(ProviderContainer container) =>
      container.read(analyzeControllerProvider(photo).notifier);

  // The fakes complete right away, so one trip through the event loop lets
  // every pending await finish.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    repository = FakeMealLogRepository();
    photos = FakePhotoStorage();
  });

  test('starts loading, then shows the result', () async {
    final analyzer = FakeFoodAnalyzer([const FoodFound(nasiGoreng)])
      ..gate = Completer();
    final container = containerWith(analyzer);

    expect(stateOf(container), isA<AnalyzeLoading>());

    analyzer.gate!.complete();
    await settle();

    expect(
      stateOf(container),
      isA<AnalyzeResult>().having(
        (state) => state.analysis,
        'analysis',
        nasiGoreng,
      ),
    );
  });

  test('sends the photo bytes with a MIME type from the extension', () async {
    final analyzer = FakeFoodAnalyzer([const FoodFound(nasiGoreng)]);
    containerWith(analyzer);
    await settle();

    expect(analyzer.requests.single.mimeType, 'image/png');
    expect(analyzer.requests.single.bytes, [1, 2, 3]);
  });

  test('shows NotFood when Gemini sees no food', () async {
    final container = containerWith(FakeFoodAnalyzer([const NotFood()]));
    await settle();

    expect(stateOf(container), isA<AnalyzeNotFood>());
  });

  test('shows the failure, and retry runs the analysis again', () async {
    final container = containerWith(
      FakeFoodAnalyzer([
        const NetworkException('offline'),
        const FoodFound(nasiGoreng),
      ]),
    );
    await settle();

    expect(
      stateOf(container),
      isA<AnalyzeFailure>().having(
        (state) => state.error,
        'error',
        isA<NetworkException>(),
      ),
    );

    await controllerOf(container).retry();

    expect(stateOf(container), isA<AnalyzeResult>());
  });

  test(
    'save stores the photo and adds a meal log with a millisecond UTC time',
    () async {
      final container = containerWith(
        FakeFoodAnalyzer([const FoodFound(nasiGoreng)]),
      );
      await settle();

      await controllerOf(container).save();

      expect(photos.saved, ['meal-1.jpg']);
      expect(repository.logs, [
        MealLog(
          id: 'meal-1',
          foodName: 'Nasi goreng',
          calories: 650,
          proteinG: 20,
          carbsG: 80,
          fatG: 25,
          photoFileName: 'meal-1.jpg',
          createdAt: DateTime.utc(2026, 10, 1, 5, 30),
        ),
      ]);
    },
  );

  test(
    'a failed save removes the copied photo, returns to the result and rethrows',
    () async {
      final container = containerWith(
        FakeFoodAnalyzer([const FoodFound(nasiGoreng)]),
      );
      await settle();
      repository.failWith = const StorageException('disk full');

      await expectLater(
        controllerOf(container).save(),
        throwsA(isA<StorageException>()),
      );

      expect(photos.deleted, ['meal-1.jpg']);
      expect(
        stateOf(container),
        isA<AnalyzeResult>().having(
          (state) => state.isSaving,
          'isSaving',
          isFalse,
        ),
      );
    },
  );

  test('save does nothing unless a result is showing', () async {
    final container = containerWith(FakeFoodAnalyzer([const NotFood()]));
    await settle();

    await controllerOf(container).save();

    expect(photos.saved, isEmpty);
    expect(repository.logs, isEmpty);
  });
}
