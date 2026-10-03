import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/analysis/domain/ai_model.dart';

void main() {
  test('lists the four free models, newest first, by their API ids', () {
    expect(AiModel.values.map((model) => model.id), [
      'gemini-3.8-flash',
      'gemini-3.7-flash',
      'gemini-3.6-flash',
      'gemini-3.5-flash-lite',
    ]);
    expect(AiModel.values.map((model) => model.label), [
      'Gemini 3.8 Flash',
      'Gemini 3.7 Flash',
      'Gemini 3.6 Flash',
      'Gemini 3.5 Flash-Lite',
    ]);
  });

  test('fromId finds every model by its id', () {
    for (final model in AiModel.values) {
      expect(AiModel.fromId(model.id), model);
    }
  });

  test('fromId falls back to 3.7 Flash for a missing or retired id', () {
    expect(AiModel.fallback, AiModel.gemini37Flash);
    expect(AiModel.fromId(null), AiModel.gemini37Flash);
    expect(AiModel.fromId('gemini-2.5-flash'), AiModel.gemini37Flash);
  });
}
