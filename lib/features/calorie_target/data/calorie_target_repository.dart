import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/calorie_target_rules.dart';

final calorieTargetRepositoryProvider = Provider<CalorieTargetRepository>(
  (ref) => CalorieTargetRepository(ref.watch(sharedPreferencesProvider)),
);

class CalorieTargetRepository {
  CalorieTargetRepository(this._prefs);

  static const key = 'calorie_target_kcal';

  final SharedPreferences _prefs;

  /// The stored target, or the fallback when nothing valid is stored.
  int read() {
    final stored = _prefs.getInt(key);
    return stored != null && CalorieTargetRules.isValid(stored)
        ? stored
        : CalorieTargetRules.fallback;
  }

  Future<void> write(int kcal) async {
    final bool saved;
    try {
      saved = await _prefs.setInt(key, kcal);
    } on PlatformException catch (error) {
      throw StorageException(error.toString());
    }
    if (!saved) throw const StorageException('setInt returned false');
  }
}
