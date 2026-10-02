import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/analysis/presentation/pages/analyze_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the loading animation is bundled as a Lottie file', () async {
    final json = await rootBundle.loadString(AnalyzePage.loadingAnimation);
    final lottie = jsonDecode(json) as Map<String, Object?>;

    expect(lottie['layers'], isA<List<Object?>>());
    expect(lottie['layers']! as List<Object?>, isNotEmpty);
  });
}
