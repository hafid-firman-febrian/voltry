import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Opened in main() before runApp and injected with overrideWithValue, so no
/// other provider has to be async just to wait for it.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

/// Tests override it with a FakeFirebaseFirestore.
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// Current time. Tests override it to pin "today".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// New record ids. Tests override it for predictable ids.
final idGeneratorProvider = Provider<String Function()>(
  (ref) => const Uuid().v4,
);
