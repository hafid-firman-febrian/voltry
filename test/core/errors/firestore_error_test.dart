import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/core/errors/firestore_error.dart';

void main() {
  FirebaseException firestoreFailure(String code) =>
      FirebaseException(plugin: 'cloud_firestore', code: code);

  test('an unreachable or slow server is a network problem', () {
    expect(
      firestoreError(firestoreFailure('unavailable')),
      isA<NetworkException>(),
    );
    expect(
      firestoreError(firestoreFailure('deadline-exceeded')),
      isA<NetworkException>(),
    );
  });

  test('any other Firestore failure is a storage problem', () {
    expect(
      firestoreError(firestoreFailure('permission-denied')),
      isA<StorageException>(),
    );
  });

  test('keeps the Firestore code in the developer detail', () {
    expect(
      firestoreError(firestoreFailure('permission-denied')).detail,
      contains('permission-denied'),
    );
  });
}
