import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/firestore_meal_log_repository.dart';
import '../../data/photo_storage.dart';
import '../../domain/daily_summary.dart';
import '../../domain/meal_log_model.dart';

final mealLogsControllerProvider =
    AsyncNotifierProvider<MealLogsController, List<MealLog>>(
      MealLogsController.new,
      // A local database that fails once keeps failing, so Riverpod's default
      // backoff would only hide the error behind a spinner for ~45 s. Show the
      // error view with Retry right away instead.
      retry: (_, _) => null,
    );

/// Every saved meal, newest first. Home and History derive their views from
/// this single list with the pure functions in daily_summary.dart.
class MealLogsController extends AsyncNotifier<List<MealLog>> {
  @override
  Future<List<MealLog>> build() {
    final lifecycle = AppLifecycleListener(onResume: reload);
    ref.onDispose(lifecycle.dispose);
    return ref.watch(mealLogRepositoryProvider).fetchAll();
  }

  /// Fetches again without going back to a spinner, so meals saved on
  /// another device show up when the app returns to the foreground. A failed
  /// fetch keeps the list on screen: it is still right, only perhaps not
  /// complete.
  Future<void> reload() async {
    if (!state.hasValue) {
      ref.invalidateSelf();
      return;
    }
    try {
      final logs = await ref.read(mealLogRepositoryProvider).fetchAll();
      if (ref.mounted) state = AsyncData(logs);
    } on AppException {
      // Firestore keeps retrying in the background, and the next resume or
      // app start fetches again.
    }
  }

  Future<void> add(MealLog log) async {
    await ref.read(mealLogRepositoryProvider).insert(log);
    _update((logs) => [log, ...logs]..sort(newestFirst));
  }

  /// Removes the row right away so a swiped tile leaves the list in the same
  /// frame. The photo stays until [purgePhoto], so Undo can bring it back.
  Future<void> delete(MealLog log) async {
    _update((logs) => [...logs.where((item) => item.id != log.id)]);
    try {
      await ref.read(mealLogRepositoryProvider).delete(log.id);
    } on AppException {
      _update((logs) => [log, ...logs]..sort(newestFirst));
      rethrow;
    }
  }

  Future<void> restore(MealLog log) => add(log);

  Future<void> purgePhoto(MealLog log) async {
    try {
      await ref.read(photoStorageProvider).delete(log.photoFileName);
    } on AppException {
      // An orphaned photo file is invisible to the user and harmless, so a
      // failed cleanup is not worth an error message.
    }
  }

  /// Delete without Undo, used after the user confirmed in a dialog.
  Future<void> deletePermanently(MealLog log) async {
    await delete(log);
    await purgePhoto(log);
  }

  void _update(List<MealLog> Function(List<MealLog> logs) change) {
    final current = state.value;
    if (current == null) {
      // Still loading or failed: reload from the database instead of
      // guessing what the full list looks like.
      ref.invalidateSelf();
      return;
    }
    state = AsyncData(change(current));
  }
}
