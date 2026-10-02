import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/meal_log/data/local_meal_log_repository.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';
import 'package:voltry/features/meal_log/domain/meal_log_model.dart';
import 'package:voltry/features/meal_log/presentation/controllers/meal_logs_controller.dart';

import '../../../fakes/fake_meal_log_repository.dart';
import '../../../fakes/fake_photo_storage.dart';
import '../../../fixtures/meal_log_fixtures.dart';

void main() {
  late FakeMealLogRepository repository;
  late FakePhotoStorage photos;
  late ProviderContainer container;

  final older = mealLog(id: 'older', createdAt: DateTime.utc(2026, 9, 30, 12));
  final newer = mealLog(id: 'newer', createdAt: DateTime.utc(2026, 10, 1, 12));

  setUp(() {
    repository = FakeMealLogRepository([older]);
    photos = FakePhotoStorage();
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        mealLogRepositoryProvider.overrideWithValue(repository),
        photoStorageProvider.overrideWithValue(photos),
      ],
    );
  });

  MealLogsController controller() =>
      container.read(mealLogsControllerProvider.notifier);
  Future<List<MealLog>> load() =>
      container.read(mealLogsControllerProvider.future);

  test('build loads every log newest first', () async {
    repository.logs.add(newer);

    expect(await load(), [newer, older]);
  });

  test('add stores the log and keeps the list sorted', () async {
    await load();

    await controller().add(newer);

    expect(repository.logs, contains(newer));
    expect(container.read(mealLogsControllerProvider).value, [newer, older]);
  });

  test('add surfaces storage errors and leaves the list unchanged', () async {
    await load();
    repository.failWith = const StorageException('disk full');

    await expectLater(
      controller().add(newer),
      throwsA(isA<StorageException>()),
    );
    expect(container.read(mealLogsControllerProvider).value, [older]);
  });

  test('delete removes the log but keeps its photo for Undo', () async {
    await load();

    await controller().delete(older);

    expect(container.read(mealLogsControllerProvider).value, isEmpty);
    expect(repository.logs, isEmpty);
    expect(photos.deleted, isEmpty);
  });

  test('delete puts the log back when the database fails', () async {
    await load();
    repository.failWith = const StorageException('locked');

    await expectLater(
      controller().delete(older),
      throwsA(isA<StorageException>()),
    );
    expect(container.read(mealLogsControllerProvider).value, [older]);
  });

  test('restore brings a deleted log back', () async {
    await load();
    await controller().delete(older);

    await controller().restore(older);

    expect(container.read(mealLogsControllerProvider).value, [older]);
    expect(repository.logs, [older]);
  });

  test('purgePhoto deletes the file and swallows storage errors', () async {
    await controller().purgePhoto(older);
    expect(photos.deleted, ['older.jpg']);

    photos.failDeleteWith = const StorageException('busy');
    await controller().purgePhoto(older);
  });

  test('deletePermanently removes the log and its photo', () async {
    await load();

    await controller().deletePermanently(older);

    expect(container.read(mealLogsControllerProvider).value, isEmpty);
    expect(photos.deleted, ['older.jpg']);
  });
}
