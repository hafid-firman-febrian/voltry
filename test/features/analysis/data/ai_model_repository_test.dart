import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/ai_model_repository.dart';
import 'package:voltry/features/analysis/domain/ai_model.dart';

void main() {
  Future<AiModelRepository> repositoryWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return AiModelRepository(await SharedPreferences.getInstance());
  }

  test('read falls back to 3.7 Flash when nothing is stored', () async {
    expect((await repositoryWith({})).read(), AiModel.gemini37Flash);
  });

  test('read returns the stored model', () async {
    final repository = await repositoryWith({
      AiModelRepository.key: 'gemini-3.5-flash-lite',
    });

    expect(repository.read(), AiModel.gemini35FlashLite);
  });

  test('read falls back when the stored model is no longer offered', () async {
    final repository = await repositoryWith({
      AiModelRepository.key: 'gemini-2.5-flash',
    });

    expect(repository.read(), AiModel.gemini37Flash);
  });

  test('write stores the id, so the choice survives a restart', () async {
    await (await repositoryWith({})).write(AiModel.gemini38Flash);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AiModelRepository.key), 'gemini-3.8-flash');
    expect(AiModelRepository(prefs).read(), AiModel.gemini38Flash);
  });

  test('a refused write becomes StorageException', () {
    expect(
      AiModelRepository(_FailingPreferences()).write(AiModel.gemini38Flash),
      throwsA(isA<StorageException>()),
    );
  });

  test('a platform error on write becomes StorageException', () {
    expect(
      AiModelRepository(
        _FailingPreferences(PlatformException(code: 'write_failed')),
      ).write(AiModel.gemini38Flash),
      throwsA(isA<StorageException>()),
    );
  });
}

/// Fails every setString: returns false, as shared_preferences does when the
/// platform refuses the write, or throws [error] when one is given.
class _FailingPreferences implements SharedPreferences {
  _FailingPreferences([this.error]);

  final PlatformException? error;

  @override
  Future<bool> setString(String key, String value) async {
    final error = this.error;
    if (error != null) throw error;
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
