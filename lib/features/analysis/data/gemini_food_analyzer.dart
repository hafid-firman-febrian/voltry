import 'dart:async';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/analysis_result.dart';
import 'analysis_parser.dart';
import 'food_analyzer.dart';

final foodAnalyzerProvider = Provider<FoodAnalyzer>(
  (ref) => GeminiFoodAnalyzer(),
);

/// Sends the prompt to Gemini and returns the reply text.
typedef GenerateText = Future<String?> Function(List<Content> prompt);

/// Thin adapter around Firebase AI Logic. All validation lives in
/// [parseAnalysis]. Tests pass [generate] to check the error mapping without
/// Firebase; the real Gemini call is checked by hand on a device.
class GeminiFoodAnalyzer implements FoodAnalyzer {
  GeminiFoodAnalyzer({this.generate, this.timeout = defaultTimeout});

  // 3.7 Flash rather than the newer 3.8: on the free tier every model has its
  // own daily quota, and during device testing (2026-10-02) 3.8 Flash used up
  // its 20 requests and was often overloaded. Check
  // https://firebase.google.com/docs/ai-logic/models before changing: Google
  // retires older models and closes them to new projects.
  static const modelName = 'gemini-3.7-flash';
  static const defaultTimeout = Duration(seconds: 30);

  static const prompt =
      'You are a nutrition estimator. Look at the photo and estimate the '
      'nutrition of everything edible in it as one meal. Use typical portion '
      'sizes when the amount is unclear. Reply only with the JSON schema '
      'provided. Give food_name as a short English name for the whole meal '
      '(max 40 characters). If the photo does not show food or drink, set '
      'is_food to false, food_name to an empty string, and all numbers to 0.';

  static final responseSchema = Schema.object(
    properties: {
      'is_food': Schema.boolean(
        description: 'False when the photo shows no food or drink.',
      ),
      'food_name': Schema.string(
        description: 'Short English name for the whole meal.',
      ),
      'calories': Schema.integer(description: 'Estimated kcal for the meal.'),
      'protein_g': Schema.integer(description: 'Protein in grams.'),
      'carbs_g': Schema.integer(description: 'Carbohydrates in grams.'),
      'fat_g': Schema.integer(description: 'Fat in grams.'),
    },
    propertyOrdering: [
      'is_food',
      'food_name',
      'calories',
      'protein_g',
      'carbs_g',
      'fat_g',
    ],
  );

  /// Replaces the real Gemini call in tests.
  final GenerateText? generate;
  final Duration timeout;

  // Created on first use, because FirebaseAI.googleAI() needs the Firebase
  // app that main() initializes.
  late final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: modelName,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: responseSchema,
    ),
  );

  @override
  Future<AnalysisResult> analyze({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final send = generate ?? _generateWithModel;
    try {
      final text = await send([
        Content.multi([TextPart(prompt), InlineDataPart(mimeType, bytes)]),
      ]).timeout(timeout);
      return parseAnalysis(text);
    } catch (error) {
      final failure = _toAppException(error);
      // The UI only shows a friendly sentence, so keep the real cause (server
      // message, quota, overload) visible in the `flutter run` console.
      if (kDebugMode) debugPrint('GeminiFoodAnalyzer failed: $error');
      throw failure;
    }
  }

  AppException _toAppException(Object error) => switch (error) {
    AppException() => error,
    TimeoutException() => const NetworkException(
      'Gemini did not answer within 30 seconds',
    ),
    // package:http wraps socket errors in a ClientException that also
    // implements SocketException, so this catches offline and DNS errors.
    IOException() => NetworkException(error.toString()),
    FirebaseAIException(:final message) => AiException(message),
    // firebase_ai casts the response body with `as`, so a malformed reply
    // arrives as a TypeError. Mapping it keeps the Analyze page from spinning
    // forever instead of offering Try again.
    _ => AiException(error.toString()),
  };

  Future<String?> _generateWithModel(List<Content> prompt) async =>
      (await _model.generateContent(prompt)).text;
}
