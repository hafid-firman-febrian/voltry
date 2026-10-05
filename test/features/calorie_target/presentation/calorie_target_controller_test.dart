import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/providers/core_providers.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';
import 'package:voltry/features/calorie_target/data/calorie_target_repository.dart';
import 'package:voltry/features/calorie_target/presentation/controllers/calorie_target_controller.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fixtures/app_user_fixtures.dart';

void main() {
  test("starts from the signed-in user's target and updates it", () async {
    final firestore = FakeFirebaseFirestore();
    final userDoc = firestore.doc('users/${testUser.uid}');
    await userDoc.set({CalorieTargetRepository.field: 2400});
    final container = ProviderContainer.test(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(user: testUser),
        ),
      ],
    );

    expect(await container.read(calorieTargetControllerProvider.future), 2400);

    await container.read(calorieTargetControllerProvider.notifier).save(1900);

    expect(container.read(calorieTargetControllerProvider).value, 1900);
    expect((await userDoc.get()).data(), {CalorieTargetRepository.field: 1900});
  });
}
