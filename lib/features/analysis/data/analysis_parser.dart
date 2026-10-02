import 'dart:convert';

import '../../../core/errors/app_exception.dart';
import '../domain/analysis_result.dart';
import '../domain/nutrition_analysis_model.dart';

const maxFoodNameLength = 60;
const maxCalories = 5000;
const maxMacroGrams = 1000;

/// Turns Gemini's raw reply into an [AnalysisResult]. Every field is checked
/// here, because the model can still return odd values even with a schema.
/// Throws [AiException] when the reply cannot be trusted.
AnalysisResult parseAnalysis(String? rawJson) {
  if (rawJson == null || rawJson.trim().isEmpty) {
    throw const AiException.invalidResponse('empty reply');
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(_stripCodeFence(rawJson));
  } on FormatException {
    throw const AiException.invalidResponse('not JSON');
  }
  if (decoded is! Map<String, Object?>) {
    throw const AiException.invalidResponse('not a JSON object');
  }

  final isFood = decoded['is_food'];
  if (isFood is! bool) {
    throw const AiException.invalidResponse('is_food missing');
  }
  if (!isFood) return const NotFood();

  return FoodFound(
    NutritionAnalysis(
      foodName: _foodName(decoded['food_name']),
      calories: _wholeNumber(decoded, 'calories', maxCalories),
      proteinG: _wholeNumber(decoded, 'protein_g', maxMacroGrams),
      carbsG: _wholeNumber(decoded, 'carbs_g', maxMacroGrams),
      fatG: _wholeNumber(decoded, 'fat_g', maxMacroGrams),
    ),
  );
}

// JSON mode normally returns bare JSON, but a fenced ```json block has been
// seen from Gemini before. Accepting it costs nothing.
String _stripCodeFence(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('```')) return trimmed;
  final firstLineEnd = trimmed.indexOf('\n');
  final withoutOpening = firstLineEnd == -1
      ? ''
      : trimmed.substring(firstLineEnd + 1);
  return withoutOpening.endsWith('```')
      ? withoutOpening.substring(0, withoutOpening.length - 3)
      : withoutOpening;
}

String _foodName(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const AiException.invalidResponse('food_name missing');
  }
  final name = value.trim();
  return name.length <= maxFoodNameLength
      ? name
      : name.substring(0, maxFoodNameLength).trimRight();
}

int _wholeNumber(Map<String, Object?> json, String key, int max) {
  final value = json[key];
  if (value is! num || !value.isFinite) {
    throw AiException.invalidResponse('$key missing');
  }
  final rounded = value.round();
  if (rounded < 0 || rounded > max) {
    throw AiException.invalidResponse('$key out of range: $rounded');
  }
  return rounded;
}
