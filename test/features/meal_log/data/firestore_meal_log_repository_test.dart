import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/providers/core_providers.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';
import 'package:voltry/features/meal_log/data/firestore_meal_log_repository.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fixtures/app_user_fixtures.dart';
import '../../../fixtures/meal_log_fixtures.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreMealLogRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreMealLogRepository(firestore, testUser.uid);
  });

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

  test('each meal is stored under its user as its row', () async {
    final log = mealLog(id: 'lunch');

    await repository.insert(log);
    final stored = await firestore
        .doc('users/${testUser.uid}/meals/lunch')
        .get();

    expect(stored.data(), log.toRow());
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

  test(
    'a malformed meal document is skipped and the rest still load',
    () async {
      final good = mealLog(id: 'good');
      await repository.insert(good);
      final meals = firestore.collection('users/${testUser.uid}/meals');
      // Hand edits in the Firebase console can store a fraction or drop a
      // field, which Firestore accepts because it has no schema.
      await meals.doc('fraction').set({
        ...mealLog(id: 'fraction').toRow(),
        'calories': 450.5,
      });
      await meals
          .doc('missing')
          .set({...mealLog(id: 'missing').toRow()}..remove('food_name'));

      expect(await repository.fetchAll(), [good]);
    },
  );

  test("one user never sees another user's meals", () async {
    await repository.insert(mealLog(id: 'mine'));

    final other = FirestoreMealLogRepository(firestore, otherUser.uid);

    expect(await other.fetchAll(), isEmpty);
  });

  test('the provider follows the account that signs in next', () async {
    final auth = FakeAuthRepository(user: testUser);
    final container = ProviderContainer.test(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    container.listen(mealLogRepositoryProvider, (_, _) {});
    await container.read(mealLogRepositoryProvider).insert(mealLog(id: 'a'));

    auth
      ..emit(null)
      ..emit(otherUser);
    await Future<void>.delayed(Duration.zero);

    expect(await container.read(mealLogRepositoryProvider).fetchAll(), isEmpty);
  });
}
