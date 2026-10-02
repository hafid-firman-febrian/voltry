import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/analysis_result.dart';
import 'analysis_parser.dart';
import 'food_analyzer.dart';

final foodAnalyzerProvider = Provider<FoodAnalyzer>(
  (ref) => GeminiFoodAnalyzer(),
);

/// Thin adapter around Firebase AI Logic. All validation lives in
/// [parseAnalysis], so this class is checked by hand on a device rather than
/// unit tested.
class GeminiFoodAnalyzer implements FoodAnalyzer {
  // Newest stable Flash model on the free Gemini Developer API as of
  // 2026-10-01. Check https://firebase.google.com/docs/ai-logic/models before
  // changing: Google retires older models and closes them to new projects.
  static const modelName = 'gemini-3.8-flash';
  static const timeout = Duration(seconds: 30);

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
    try {
      final response = await _model
          .generateContent([
            Content.multi([TextPart(prompt), InlineDataPart(mimeType, bytes)]),
          ])
          .timeout(timeout);
      return parseAnalysis(response.text);
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException('Gemini did not answer within 30 seconds');
    } on IOException catch (error) {
      // package:http wraps socket errors in a ClientException that also
      // implements SocketException, so this catches offline and DNS errors.
      throw NetworkException(error.toString());
    } on FirebaseAIException catch (error) {
      throw AiException(error.message);
    } on Exception catch (error) {
      throw AiException(error.toString());
    }
  }
}
