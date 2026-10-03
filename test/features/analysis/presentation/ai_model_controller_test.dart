import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/core/providers/core_providers.dart';
import 'package:voltry/features/analysis/data/ai_model_repository.dart';
import 'package:voltry/features/analysis/data/gemini_food_analyzer.dart';
import 'package:voltry/features/analysis/domain/ai_model.dart';
import 'package:voltry/features/analysis/presentation/controllers/ai_model_controller.dart';

import '../../../fakes/fake_ai_model_repository.dart';

void main() {
  Future<ProviderContainer> containerWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer.test(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  test('starts from the stored model and saves a new choice', () async {
    final container = await containerWith({
      AiModelRepository.key: 'gemini-3.6-flash',
    });

    expect(container.read(aiModelControllerProvider), AiModel.gemini36Flash);

    await container
        .read(aiModelControllerProvider.notifier)
        .select(AiModel.gemini38Flash);

    expect(container.read(aiModelControllerProvider), AiModel.gemini38Flash);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AiModelRepository.key), 'gemini-3.8-flash');
  });

  test('keeps the old model when saving fails', () async {
    final repository = FakeAiModelRepository()
      ..failWith = const StorageException('disk full');
    final container = ProviderContainer.test(
      overrides: [aiModelRepositoryProvider.overrideWithValue(repository)],
    );

    await expectLater(
      container
          .read(aiModelControllerProvider.notifier)
          .select(AiModel.gemini38Flash),
      throwsA(isA<StorageException>()),
    );

    expect(container.read(aiModelControllerProvider), AiModel.gemini37Flash);
  });

  test('foodAnalyzerProvider follows the chosen model', () async {
    final container = await containerWith({});
    String analyzerModel() =>
        (container.read(foodAnalyzerProvider) as GeminiFoodAnalyzer).modelName;

    expect(analyzerModel(), 'gemini-3.7-flash');

    await container
        .read(aiModelControllerProvider.notifier)
        .select(AiModel.gemini35FlashLite);

    expect(analyzerModel(), 'gemini-3.5-flash-lite');
  });
}
