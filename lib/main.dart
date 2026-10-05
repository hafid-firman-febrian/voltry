import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/core_providers.dart';
import 'features/meal_log/data/photo_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No options: on Android and iOS Firebase reads google-services.json and
  // GoogleService-Info.plist. Both are git-ignored (see docs/setup/firebase.md),
  // so the Dart code compiles without any Firebase config checked in.
  await Firebase.initializeApp();

  final preferences = await SharedPreferences.getInstance();
  final documents = await getApplicationDocumentsDirectory();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        photoStorageProvider.overrideWithValue(
          PhotoStorage(Directory(p.join(documents.path, 'meal_photos'))),
        ),
      ],
      child: const VoltryApp(),
    ),
  );
}
