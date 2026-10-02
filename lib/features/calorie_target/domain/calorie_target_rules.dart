import 'package:flutter/foundation.dart';

abstract final class CalorieTargetRules {
  static const min = 800;
  static const max = 5000;
  static const fallback = 2000;

  static bool isValid(int kcal) => kcal >= min && kcal <= max;

  /// The target typed by the user, or null when it is not a whole number
  /// from [min] to [max].
  static int? parse(String input) {
    final kcal = int.tryParse(input.trim());
    return kcal != null && isValid(kcal) ? kcal : null;
  }

  static String? validate(String input) =>
      parse(input) == null ? 'Enter a whole number from 800 to 5,000.' : null;
}

@immutable
class TargetProgress {
  const TargetProgress({
    required this.fraction,
    required this.percent,
    required this.overBy,
  });

  /// 0 to 1, for the ring. Capped at 1 once the target is passed.
  final double fraction;

  /// Uncapped, rounded share of the target, for the label inside the ring.
  final int percent;

  /// Calories above the target, or 0.
  final int overBy;

  bool get isOver => overBy > 0;
}

TargetProgress targetProgress({required int consumed, required int target}) {
  final ratio = target <= 0 ? 0.0 : consumed / target;
  return TargetProgress(
    fraction: ratio.clamp(0.0, 1.0),
    percent: (ratio * 100).round(),
    overBy: consumed > target ? consumed - target : 0,
  );
}
