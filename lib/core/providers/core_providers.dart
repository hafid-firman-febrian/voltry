import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Opened in main() before runApp and injected with overrideWithValue, so no
/// other provider has to be async just to wait for it.
final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('Override databaseProvider in main()'),
);

/// Same pattern as [databaseProvider].
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

/// Current time. Tests override it to pin "today".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// New record ids. Tests override it for predictable ids.
final idGeneratorProvider = Provider<String Function()>(
  (ref) => const Uuid().v4,
);
