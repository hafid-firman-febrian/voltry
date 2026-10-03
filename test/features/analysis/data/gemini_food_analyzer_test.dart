import 'dart:async';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/gemini_food_analyzer.dart';
import 'package:voltry/features/analysis/domain/analysis_result.dart';

void main() {
  final photo = Uint8List.fromList([1, 2, 3]);

  Future<AnalysisResult> analyzeWith(
    Future<String?> Function() reply, {
    Duration timeout = GeminiFoodAnalyzer.defaultTimeout,
  }) => GeminiFoodAnalyzer(
    generate: (_) => reply(),
    timeout: timeout,
  ).analyze(bytes: photo, mimeType: 'image/jpeg');

  test('sends the prompt with the photo and parses the reply', () async {
    List<Content>? sent;
    final analyzer = GeminiFoodAnalyzer(
      generate: (prompt) async {
        sent = prompt;
        return '{"is_food": false, "food_name": "", "calories": 0,'
            ' "protein_g": 0, "carbs_g": 0, "fat_g": 0}';
      },
    );

    final result = await analyzer.analyze(bytes: photo, mimeType: 'image/png');

    expect(result, isA<NotFood>());
    final parts = sent!.single.parts;
    expect(parts.whereType<TextPart>().single.text, GeminiFoodAnalyzer.prompt);
    expect(parts.whereType<InlineDataPart>().single.mimeType, 'image/png');
    expect(parts.whereType<InlineDataPart>().single.bytes, photo);
  });

  test('a reply slower than the timeout becomes NetworkException', () {
    expect(
      analyzeWith(
        () => Completer<String?>().future,
        timeout: const Duration(milliseconds: 10),
      ),
      throwsA(isA<NetworkException>()),
    );
  });

  test('socket errors become NetworkException', () {
    expect(
      analyzeWith(() async => throw const SocketException('offline')),
      throwsA(isA<NetworkException>()),
    );
  });

  test('Firebase AI errors become AiException', () {
    expect(
      analyzeWith(() async => throw FirebaseAIException('Quota exceeded')),
      throwsA(isA<AiException>()),
    );
  });

  test('an unexpected Error becomes AiException instead of escaping', () {
    // firebase_ai casts the response body with `as`, so a malformed body
    // surfaces as a TypeError, an Error rather than an Exception.
    expect(
      analyzeWith(() async => throw StateError('malformed body')),
      throwsA(isA<AiException>()),
    );
  });

  test('prints the original cause to the console while debugging', () async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = original);

    await expectLater(
      analyzeWith(
        () async => throw FirebaseAIException('Quota exceeded: 20 per day'),
      ),
      throwsA(isA<AiException>()),
    );

    expect(logs, hasLength(1));
    expect(logs.single, contains('Quota exceeded: 20 per day'));
  });

  test('a used-up quota becomes AiQuotaException', () {
    expect(
      analyzeWith(
        () async => throw QuotaExceeded('You exceeded your current quota'),
      ),
      throwsA(isA<AiQuotaException>()),
    );
  });
}
