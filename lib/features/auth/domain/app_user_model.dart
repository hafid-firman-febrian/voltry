import 'package:flutter/foundation.dart';

/// The signed-in Google account, as much of it as the app shows.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  /// Firebase Auth user id. Every Firestore path for this user starts with it.
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.displayName == displayName &&
      other.email == email &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(uid, displayName, email, photoUrl);
}
