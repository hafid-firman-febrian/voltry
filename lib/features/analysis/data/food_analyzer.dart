import 'dart:typed_data';

import '../domain/analysis_result.dart';

abstract interface class FoodAnalyzer {
  /// Throws NetworkException or AiException.
  Future<AnalysisResult> analyze({
    required Uint8List bytes,
    required String mimeType,
  });
}
