import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:voltry/features/analysis/presentation/pages/analyze_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<String> loadAnimation() =>
      rootBundle.loadString(AnalyzePage.loadingAnimation);

  test('the loading animation is bundled as a Lottie file', () async {
    final lottie = jsonDecode(await loadAnimation()) as Map<String, Object?>;

    expect(lottie['layers'], isA<List<Object?>>());
    expect(lottie['layers']! as List<Object?>, isNotEmpty);
  });

  test('the loading animation needs no After Effects expressions', () async {
    // package:lottie ignores expressions such as loopOut('pingpong'), so an
    // animation that relies on them freezes on a single frame in the app.
    final composition = LottieComposition.parseJsonBytes(
      utf8.encode(await loadAnimation()),
    );

    expect(composition.warnings, isNot(contains(contains('expressions'))));
  });

  test('every animated property moves inside the played frame range', () async {
    final lottie = jsonDecode(await loadAnimation()) as Map<String, Object?>;
    final firstFrame = (lottie['ip']! as num).toDouble();
    final lastFrame = (lottie['op']! as num).toDouble();

    final ranges = <(double, double)>[];
    void collect(Object? node) {
      if (node is Map<String, Object?>) {
        final keyframes = node['k'];
        if (node['a'] == 1 && keyframes is List<Object?>) {
          final times = [
            for (final keyframe in keyframes)
              ((keyframe! as Map<String, Object?>)['t']! as num).toDouble(),
          ];
          ranges.add((times.first, times.last));
        }
        node.values.forEach(collect);
      } else if (node is List<Object?>) {
        node.forEach(collect);
      }
    }

    collect(lottie['layers']);

    expect(ranges, isNotEmpty);
    for (final (start, end) in ranges) {
      expect(start, lessThanOrEqualTo(firstFrame));
      expect(end, greaterThanOrEqualTo(lastFrame));
    }
  });
}
