import 'package:voltry/features/meal_log/domain/meal_log_model.dart';

MealLog mealLog({
  String id = 'meal-1',
  String foodName = 'Nasi goreng',
  int calories = 650,
  int proteinG = 20,
  int carbsG = 80,
  int fatG = 25,
  String? photoFileName,
  DateTime? createdAt,
}) => MealLog(
  id: id,
  foodName: foodName,
  calories: calories,
  proteinG: proteinG,
  carbsG: carbsG,
  fatG: fatG,
  photoFileName: photoFileName ?? '$id.jpg',
  createdAt: (createdAt ?? DateTime(2026, 10, 1, 12)).toUtc(),
);
