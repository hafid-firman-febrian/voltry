import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_model_repository.dart';
import '../../domain/ai_model.dart';

final aiModelControllerProvider = NotifierProvider<AiModelController, AiModel>(
  AiModelController.new,
);

class AiModelController extends Notifier<AiModel> {
  @override
  AiModel build() => ref.watch(aiModelRepositoryProvider).read();

  /// Throws StorageException and keeps the old model when saving fails.
  Future<void> select(AiModel model) async {
    await ref.read(aiModelRepositoryProvider).write(model);
    state = model;
  }
}
