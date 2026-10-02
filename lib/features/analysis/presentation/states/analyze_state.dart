import '../../../../core/errors/app_exception.dart';
import '../../domain/nutrition_analysis_model.dart';

sealed class AnalyzeState {
  const AnalyzeState();
}

final class AnalyzeLoading extends AnalyzeState {
  const AnalyzeLoading();
}

final class AnalyzeResult extends AnalyzeState {
  const AnalyzeResult(this.analysis, {this.isSaving = false});

  final NutritionAnalysis analysis;
  final bool isSaving;
}

final class AnalyzeNotFood extends AnalyzeState {
  const AnalyzeNotFood();
}

final class AnalyzeFailure extends AnalyzeState {
  const AnalyzeFailure(this.error);

  final AppException error;
}
