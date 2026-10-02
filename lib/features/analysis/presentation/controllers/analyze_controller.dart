import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../meal_log/data/photo_storage.dart';
import '../../../meal_log/domain/meal_log_model.dart';
import '../../../meal_log/presentation/controllers/meal_logs_controller.dart';
import '../../data/gemini_food_analyzer.dart';
import '../../domain/analysis_result.dart';
import '../../domain/image_mime_type.dart';
import '../states/analyze_state.dart';

final analyzeControllerProvider = NotifierProvider.autoDispose
    .family<AnalyzeController, AnalyzeState, XFile>(AnalyzeController.new);

/// One analysis session for one photo. Starts analyzing as soon as the
/// Analyze page watches it, and is disposed when the page closes.
class AnalyzeController extends Notifier<AnalyzeState> {
  AnalyzeController(this.photo);

  final XFile photo;

  @override
  AnalyzeState build() {
    unawaited(_analyze());
    return const AnalyzeLoading();
  }

  Future<void> retry() async {
    state = const AnalyzeLoading();
    await _analyze();
  }

  /// Copies the photo into app storage and adds the meal log. Throws
  /// [AppException] and returns to the result when saving fails.
  Future<void> save() async {
    final current = state;
    if (current is! AnalyzeResult || current.isSaving) return;
    state = AnalyzeResult(current.analysis, isSaving: true);

    final photos = ref.read(photoStorageProvider);
    final mealLogs = ref.read(mealLogsControllerProvider.notifier);
    final id = ref.read(idGeneratorProvider)();
    final now = ref.read(clockProvider)();
    String? fileName;
    try {
      fileName = await photos.save(photo, id);
      final analysis = current.analysis;
      await mealLogs.add(
        MealLog(
          id: id,
          foodName: analysis.foodName,
          calories: analysis.calories,
          proteinG: analysis.proteinG,
          carbsG: analysis.carbsG,
          fatG: analysis.fatG,
          photoFileName: fileName,
          // Millisecond precision, the same as the database column, so the
          // log in memory equals the one read back later.
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch,
            isUtc: true,
          ),
        ),
      );
    } on AppException {
      if (fileName != null) await _discard(photos, fileName);
      if (ref.mounted) state = AnalyzeResult(current.analysis);
      rethrow;
    }
  }

  Future<void> _analyze() async {
    final photos = ref.read(photoStorageProvider);
    final analyzer = ref.read(foodAnalyzerProvider);
    AnalyzeState next;
    try {
      final bytes = await photos.readBytes(photo);
      final result = await analyzer.analyze(
        bytes: bytes,
        mimeType: photo.mimeType ?? imageMimeType(photo.path),
      );
      next = switch (result) {
        FoodFound(:final analysis) => AnalyzeResult(analysis),
        NotFood() => const AnalyzeNotFood(),
      };
    } on AppException catch (error) {
      next = AnalyzeFailure(error);
    }
    // The user may have left the page while Gemini was still thinking.
    if (ref.mounted) state = next;
  }

  Future<void> _discard(PhotoStorage photos, String fileName) async {
    try {
      await photos.delete(fileName);
    } on AppException {
      // The save already failed and the user sees that error. An orphaned
      // file is invisible and harmless, so there is nothing more to report.
    }
  }
}
