import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';
import 'package:voltry/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:voltry/features/meal_log/data/firestore_meal_log_repository.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';
import 'package:voltry/features/meal_log/domain/meal_log_model.dart';
import 'package:voltry/features/meal_log/presentation/controllers/meal_logs_controller.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_meal_log_repository.dart';
import '../../../fakes/fake_photo_storage.dart';
import '../../../fixtures/app_user_fixtures.dart';
import '../../../fixtures/meal_log_fixtures.dart';

void main() {
  // The controller listens for the app returning to the foreground, which
  // needs the widgets binding even outside a widget test.
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('reload shows meals saved on another device', () async {
    await load();
    repository.logs.add(newer);

    await controller().reload();

    expect(container.read(mealLogsControllerProvider).value, [newer, older]);
  });

  test('reload keeps the list on screen when fetching fails', () async {
    await load();
    repository.failWith = const NetworkException('unavailable');

    await controller().reload();

    expect(container.read(mealLogsControllerProvider).value, [older]);
  });

  test('a reload still out when the app shuts down ends quietly', () async {
    await load();
    repository.gate = Completer<void>();
    final reload = controller().reload();

    container.dispose();
    repository.gate!.complete();

    await expectLater(reload, completes);
  });

  test('reload after a failed load tries the whole load again', () async {
    repository.failWith = const NetworkException('unavailable');
    await expectLater(load(), throwsA(isA<NetworkException>()));
    repository.failWith = null;

    await controller().reload();

    expect(await load(), [older]);
  });

  test("a reload that ends after an account switch keeps the new account's "
      'meals', () async {
    final auth = FakeAuthRepository(user: testUser);
    final mine = FakeMealLogRepository([older]);
    final theirs = FakeMealLogRepository([newer]);
    final switching = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        mealLogRepositoryProvider.overrideWith(
          (ref) => ref.watch(currentUserProvider) == testUser ? mine : theirs,
        ),
        photoStorageProvider.overrideWithValue(photos),
      ],
    );
    switching.listen(mealLogsControllerProvider, (_, _) {});
    await switching.read(mealLogsControllerProvider.future);
    mine.gate = Completer<void>();
    final staleReload = switching
        .read(mealLogsControllerProvider.notifier)
        .reload();

    auth
      ..emit(null)
      ..emit(otherUser);
    await Future<void>.delayed(Duration.zero);
    expect(await switching.read(mealLogsControllerProvider.future), [newer]);

    mine.gate!.complete();
    await staleReload;

    expect(switching.read(mealLogsControllerProvider).value, [newer]);
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
