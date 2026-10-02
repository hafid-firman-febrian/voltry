import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/calorie_target/domain/calorie_target_rules.dart';

void main() {
  group('CalorieTargetRules.parse', () {
    test('accepts whole numbers from 800 to 5000, ignoring spaces', () {
      expect(CalorieTargetRules.parse('800'), 800);
      expect(CalorieTargetRules.parse(' 2200 '), 2200);
      expect(CalorieTargetRules.parse('5000'), 5000);
    });

    test('rejects out-of-range, decimal, empty and non-numeric input', () {
      for (final input in ['799', '5001', '1800.5', '', 'abc', '-1000']) {
        expect(CalorieTargetRules.parse(input), isNull, reason: input);
      }
    });
  });

  test('validate returns an error only for invalid input', () {
    expect(CalorieTargetRules.validate('2000'), isNull);
    expect(
      CalorieTargetRules.validate('50'),
      'Enter a whole number from 800 to 5,000.',
    );
  });

  group('targetProgress', () {
    test('reports the share of the target', () {
      final progress = targetProgress(consumed: 1450, target: 2000);

      expect(progress.fraction, closeTo(0.725, 0.0001));
      expect(progress.percent, 73);
      expect(progress.isOver, isFalse);
    });

    test(
      'caps the ring at full but keeps the real percent when over target',
      () {
        final progress = targetProgress(consumed: 2250, target: 2000);

        expect(progress.fraction, 1.0);
        expect(progress.percent, 113);
        expect(progress.overBy, 250);
        expect(progress.isOver, isTrue);
      },
    );

    test('is empty when nothing was eaten', () {
      final progress = targetProgress(consumed: 0, target: 2000);

      expect(progress.fraction, 0);
      expect(progress.percent, 0);
      expect(progress.overBy, 0);
    });
  });
}
