import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltry/app.dart';
import 'package:voltry/core/providers/core_providers.dart';
import 'package:voltry/features/analysis/data/ai_model_repository.dart';
import 'package:voltry/features/analysis/data/gemini_food_analyzer.dart';
import 'package:voltry/features/analysis/data/photo_picker.dart';
import 'package:voltry/features/calorie_target/data/calorie_target_repository.dart';
import 'package:voltry/features/meal_log/data/firestore_meal_log_repository.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';

import '../fakes/fake_food_analyzer.dart';
import '../fakes/fake_meal_log_repository.dart';
import '../fakes/fake_photo_picker.dart';
import '../fakes/fake_photo_storage.dart';

/// "Now" for every app-level test: Thursday 1 October 2026, 20:00 local.
final testNow = DateTime(2026, 10, 1, 20);

/// Pumps the whole app, router included, on top of fakes, on an iPhone-sized
/// screen (390 x 844). With [settle], waits until the first page has loaded.
Future<void> pumpVoltryApp(
  WidgetTester tester, {
  FakeMealLogRepository? repository,
  FakePhotoStorage? photos,
  FakeFoodAnalyzer? analyzer,
  FakePhotoPicker? picker,
  int? storedTarget,
  String? storedModelId,
  DateTime Function()? clock,
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    CalorieTargetRepository.key: ?storedTarget,
    AiModelRepository.key: ?storedModelId,
  });
  final preferences = await SharedPreferences.getInstance();
  final overrides = <Override>[
    sharedPreferencesProvider.overrideWithValue(preferences),
    mealLogRepositoryProvider.overrideWithValue(
      repository ?? FakeMealLogRepository(),
    ),
    photoStorageProvider.overrideWithValue(photos ?? FakePhotoStorage()),
    foodAnalyzerProvider.overrideWithValue(analyzer ?? FakeFoodAnalyzer([])),
    photoPickerProvider.overrideWithValue(picker ?? FakePhotoPicker()),
    clockProvider.overrideWithValue(clock ?? () => testNow),
    idGeneratorProvider.overrideWithValue(() => 'new-meal'),
  ];

  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const VoltryApp()),
  );
  if (settle) await tester.pumpAndSettle();
}
