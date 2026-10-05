import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/auth/domain/account_rules.dart';
import 'package:voltry/features/auth/domain/app_user_model.dart';

void main() {
  test('uses the first letter of the name, in capitals', () {
    expect(
      initialOf(const AppUser(uid: 'u', displayName: 'rani', email: 'x@y.z')),
      'R',
    );
  });

  test('falls back to the email when the name is missing or blank', () {
    expect(initialOf(const AppUser(uid: 'u', email: 'dimas@y.z')), 'D');
    expect(
      initialOf(const AppUser(uid: 'u', displayName: '  ', email: 'dimas@y.z')),
      'D',
    );
  });

  test('shows a question mark when there is neither', () {
    expect(initialOf(const AppUser(uid: 'u')), '?');
  });
}
