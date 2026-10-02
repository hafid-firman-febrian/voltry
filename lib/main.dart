import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/providers/core_providers.dart';
import 'features/meal_log/data/photo_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.open();
  final preferences = await SharedPreferences.getInstance();
  final documents = await getApplicationDocumentsDirectory();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(preferences),
        photoStorageProvider.overrideWithValue(
          PhotoStorage(Directory(p.join(documents.path, 'meal_photos'))),
        ),
      ],
      child: const VoltryApp(),
    ),
  );
}
