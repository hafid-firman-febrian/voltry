import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/calorie_target/data/calorie_target_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CalorieTargetRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = CalorieTargetRepository(firestore, 'user-1');
  });

  Future<void> store(Map<String, Object> fields) =>
      firestore.doc('users/user-1').set(fields);

  test('read falls back to 2000 when nothing is stored', () async {
    expect(await repository.read(), 2000);
  });

  test('read ignores a stored value outside 800 to 5000', () async {
    await store({CalorieTargetRepository.field: 99999});

    expect(await repository.read(), 2000);
  });

  test('read ignores a stored value that is not a whole number', () async {
    await store({CalorieTargetRepository.field: 'lots'});

    expect(await repository.read(), 2000);
  });

  test('write then read returns the new target', () async {
    await repository.write(1800);

    expect(await repository.read(), 1800);
  });

  test('write keeps the other fields of the user document', () async {
    await store({'joined': 2026});

    await repository.write(1800);
    final stored = await firestore.doc('users/user-1').get();

    expect(stored.data(), {
      'joined': 2026,
      CalorieTargetRepository.field: 1800,
    });
  });
}
