import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an authenticated user in the system.
///
/// The [role] field (`user` or `admin`) is stored in Firestore and checked
/// dynamically after login to route the user to the correct screen.
/// This avoids hardcoding admin UIDs — any user with `role == 'admin'`
/// gets access to the admin dashboard.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'user' or 'admin'

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  /// Creates an [AppUser] from a Firestore document snapshot.
  ///
  /// The document ID becomes the [uid]. Missing fields fall back to
  /// sensible defaults (empty strings, role = 'user').
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
    );
  }

  /// Serializes this user to a Firestore-compatible map.
  ///
  /// [createdAt] uses a server timestamp so all clients agree on the time
  /// regardless of their local clock.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Whether this user has admin privileges.
  bool get isAdmin => role == 'admin';

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, name: $displayName, role: $role)';
}
