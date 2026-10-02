import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract final class AppDatabase {
  static const fileName = 'voltry.db';
  static const version = 1;

  /// Opens the app database. Tests pass `databaseFactoryFfi` and
  /// `inMemoryDatabasePath`.
  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    return dbFactory.openDatabase(
      path ?? p.join(await dbFactory.getDatabasesPath(), fileName),
      options: OpenDatabaseOptions(
        version: version,
        onCreate: (db, _) => _createSchema(db),
      ),
    );
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE meal_logs (
        id TEXT PRIMARY KEY,
        food_name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein_g INTEGER NOT NULL,
        carbs_g INTEGER NOT NULL,
        fat_g INTEGER NOT NULL,
        photo_file_name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_meal_logs_created_at ON meal_logs(created_at)',
    );
  }
}
