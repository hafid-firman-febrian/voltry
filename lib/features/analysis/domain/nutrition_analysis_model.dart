import 'package:flutter/foundation.dart';

/// Gemini's estimate for one photo, before the user saves it.
@immutable
class NutritionAnalysis {
  const NutritionAnalysis({
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final String foodName;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  @override
  bool operator ==(Object other) =>
      other is NutritionAnalysis &&
      other.foodName == foodName &&
      other.calories == calories &&
      other.proteinG == proteinG &&
      other.carbsG == carbsG &&
      other.fatG == fatG;

  @override
  int get hashCode => Object.hash(foodName, calories, proteinG, carbsG, fatG);
}
