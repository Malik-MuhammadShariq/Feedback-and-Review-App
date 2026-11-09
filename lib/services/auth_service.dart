import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Wraps Firebase Auth to provide a clean API for authentication operations.
///
/// Responsibilities:
///   - User registration (with Firestore document creation)
///   - Sign-in / sign-out
///   - Auth state stream for Riverpod
///   - Dynamic role lookup from Firestore after authentication
///
/// The role is NOT hardcoded — it is read from the `users` Firestore document
/// after login, allowing admin access to be granted by simply setting
/// `role: 'admin'` on a user document.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Constructor allows dependency injection for testing.
  /// Defaults to the standard Firebase instances when not provided.
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of authentication state changes.
  ///
  /// Emits:
  ///   - `User?` when a user signs in
  ///   - `null` when a user signs out
  ///
  /// Used by [authStateChangeProvider] to drive the app's root routing.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// The currently signed-in Firebase Auth user, or `null`.
  User? get currentUser => _auth.currentUser;

  /// Registers a new user with email and password.
  ///
  /// Steps:
  ///   1. Creates a Firebase Auth account.
  ///   2. Creates an `AppUser` document in the `users` collection with the
  ///      chosen role (`user` or `admin`).
  ///
  /// Returns the created [AppUser] on success.
  /// Throws [FirebaseAuthException] on auth failures (e.g., weak password,
  /// email already in use).
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // 1. Create the Firebase Auth user
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed: user creation returned null');
      }

      // 2. Build the AppUser model with the chosen role
      final AppUser appUser = AppUser(
        uid: firebaseUser.uid,
        email: email,
        displayName: name,
        role: role,
      );

      // 3. Persist the user document to Firestore so the role is stored
      //    and can be read back on subsequent logins (dynamic role check)
      await _firestore
          .collection(CollectionNames.users)
          .doc(firebaseUser.uid)
          .set(appUser.toMap());

      return appUser;
    } on FirebaseAuthException {
      // Re-throw Firebase-specific exceptions so the UI can show
      // user-friendly messages (e.g., "email-already-in-use")
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in a clear exception
      throw Exception('Registration failed: $e');
    }
  }

  /// Signs in an existing user with email and password.
  ///
  /// Returns the signed-in [User] on success.
  /// Throws [FirebaseAuthException] for invalid credentials.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw Exception('Sign-in failed: user is null after authentication');
      }
      return user;
    } on FirebaseAuthException {
      // Re-throw so the UI can map error codes to friendly messages
      rethrow;
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  /// Fetches the full [AppUser] document from Firestore for the currently
  /// signed-in user.
  ///
  /// This is the **dynamic role check** — the role is read from Firestore
  /// rather than being hardcoded, so admin access can be granted or revoked
  /// by simply updating the `role` field on the user document.
  ///
  /// Returns `null` if no user is signed in or no document exists.
  Future<AppUser?> getCurrentUser() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(CollectionNames.users)
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return null;

      return AppUser.fromFirestore(doc);
    } catch (e) {
      // Log but don't crash — return null so the UI can handle gracefully
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
