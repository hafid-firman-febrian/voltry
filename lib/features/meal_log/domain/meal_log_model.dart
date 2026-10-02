import 'package:flutter/foundation.dart';

import '../../analysis/domain/nutrition_analysis_model.dart';

@immutable
class MealLog {
  const MealLog({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.photoFileName,
    required this.createdAt,
  });

  final String id;
  final String foodName;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  /// File name inside the photos folder, never a full path (see PhotoStorage).
  final String photoFileName;

  /// Moment the meal was saved, in UTC.
  final DateTime createdAt;

  factory MealLog.fromRow(Map<String, Object?> row) => MealLog(
    id: row['id']! as String,
    foodName: row['food_name']! as String,
    calories: row['calories']! as int,
    proteinG: row['protein_g']! as int,
    carbsG: row['carbs_g']! as int,
    fatG: row['fat_g']! as int,
    photoFileName: row['photo_file_name']! as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row['created_at']! as int,
      isUtc: true,
    ),
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'food_name': foodName,
    'calories': calories,
    'protein_g': proteinG,
    'carbs_g': carbsG,
    'fat_g': fatG,
    'photo_file_name': photoFileName,
    // Epoch ms instead of an ISO string: toIso8601String() adds microsecond
    // digits only when they are non-zero, so string order would not match
    // time order.
    'created_at': createdAt.toUtc().millisecondsSinceEpoch,
  };

  NutritionAnalysis get nutrition => NutritionAnalysis(
    foodName: foodName,
    calories: calories,
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
  );

  @override
  bool operator ==(Object other) =>
      other is MealLog &&
      other.id == id &&
      other.foodName == foodName &&
      other.calories == calories &&
      other.proteinG == proteinG &&
      other.carbsG == carbsG &&
      other.fatG == fatG &&
      other.photoFileName == photoFileName &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    foodName,
    calories,
    proteinG,
    carbsG,
    fatG,
    photoFileName,
    createdAt,
  );
}
