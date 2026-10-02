import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:voltry/core/database/app_database.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/meal_log/data/local_meal_log_repository.dart';

import '../../../fixtures/meal_log_fixtures.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late LocalMealLogRepository repository;

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = LocalMealLogRepository(db);
  });

  tearDown(() => db.close());

  test('fetchAll returns inserted logs newest first', () async {
    final older = mealLog(
      id: 'older',
      createdAt: DateTime.utc(2026, 9, 30, 12),
    );
    final newer = mealLog(
      id: 'newer',
      createdAt: DateTime.utc(2026, 10, 1, 12),
    );
    await repository.insert(older);
    await repository.insert(newer);

    expect(await repository.fetchAll(), [newer, older]);
  });

  test('delete removes only the given log', () async {
    await repository.insert(mealLog(id: 'keep'));
    await repository.insert(mealLog(id: 'drop'));

    await repository.delete('drop');

    expect((await repository.fetchAll()).map((log) => log.id), ['keep']);
  });

  test('a deleted log can be inserted again with the same id (undo)', () async {
    final log = mealLog(id: 'undo-me');
    await repository.insert(log);
    await repository.delete(log.id);

    await repository.insert(log);

    expect(await repository.fetchAll(), [log]);
  });

  test('database errors become StorageException', () async {
    final log = mealLog(id: 'dup');
    await repository.insert(log);

    expect(() => repository.insert(log), throwsA(isA<StorageException>()));
  });
}
