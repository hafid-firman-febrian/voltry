import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/ai_model_repository.dart';
import 'package:voltry/features/analysis/domain/ai_model.dart';

class FakeAiModelRepository implements AiModelRepository {
  FakeAiModelRepository([this.stored = AiModel.fallback]);

  AiModel stored;

  /// When set, write throws it and keeps [stored] unchanged.
  AppException? failWith;

  @override
  AiModel read() => stored;

  @override
  Future<void> write(AiModel model) async {
    final failure = failWith;
    if (failure != null) throw failure;
    stored = model;
  }
}
