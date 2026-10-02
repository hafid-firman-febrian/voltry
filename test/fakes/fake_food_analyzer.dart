import 'dart:async';
import 'dart:typed_data';

import 'package:voltry/features/analysis/data/food_analyzer.dart';
import 'package:voltry/features/analysis/domain/analysis_result.dart';

/// Answers each call with the next queued reply. A reply is either an
/// [AnalysisResult] or an exception to throw.
class FakeFoodAnalyzer implements FoodAnalyzer {
  FakeFoodAnalyzer(this.replies);

  final List<Object> replies;
  final requests = <({Uint8List bytes, String mimeType})>[];

  /// When set, analyze waits for it, to test the loading state.
  Completer<void>? gate;

  @override
  Future<AnalysisResult> analyze({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    requests.add((bytes: bytes, mimeType: mimeType));
    await gate?.future;
    final reply = replies.removeAt(0);
    if (reply is AnalysisResult) return reply;
    throw reply;
  }
}
