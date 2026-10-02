import 'nutrition_analysis_model.dart';

/// What the analyzer found. "Not food" is a normal outcome, not an error.
sealed class AnalysisResult {
  const AnalysisResult();
}

final class FoodFound extends AnalysisResult {
  const FoodFound(this.analysis);

  final NutritionAnalysis analysis;
}

final class NotFood extends AnalysisResult {
  const NotFood();
}
