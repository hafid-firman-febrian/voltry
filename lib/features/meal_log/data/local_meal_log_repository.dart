import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/meal_log_model.dart';
import 'meal_log_repository.dart';

final mealLogRepositoryProvider = Provider<MealLogRepository>(
  (ref) => LocalMealLogRepository(ref.watch(databaseProvider)),
);

class LocalMealLogRepository implements MealLogRepository {
  LocalMealLogRepository(this._db);

  static const _table = 'meal_logs';

  final Database _db;

  @override
  Future<List<MealLog>> fetchAll() => _guard(() async {
    final rows = await _db.query(_table, orderBy: 'created_at DESC');
    return rows.map(MealLog.fromRow).toList();
  });

  @override
  Future<void> insert(MealLog log) =>
      _guard(() => _db.insert(_table, log.toRow()));

  @override
  Future<void> delete(String id) =>
      _guard(() => _db.delete(_table, where: 'id = ?', whereArgs: [id]));

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DatabaseException catch (error) {
      throw StorageException(error.toString());
    }
  }
}
