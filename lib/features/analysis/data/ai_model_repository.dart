import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/ai_model.dart';

final aiModelRepositoryProvider = Provider<AiModelRepository>(
  (ref) => AiModelRepository(ref.watch(sharedPreferencesProvider)),
);

class AiModelRepository {
  AiModelRepository(this._prefs);

  static const key = 'ai_model_id';

  final SharedPreferences _prefs;

  AiModel read() => AiModel.fromId(_prefs.getString(key));

  // Stores the id, not the enum index, so reordering AiModel cannot quietly
  // turn a saved choice into another model.
  Future<void> write(AiModel model) async {
    final bool saved;
    try {
      saved = await _prefs.setString(key, model.id);
    } on PlatformException catch (error) {
      throw StorageException(error.toString());
    }
    if (!saved) throw const StorageException('setString returned false');
  }
}
