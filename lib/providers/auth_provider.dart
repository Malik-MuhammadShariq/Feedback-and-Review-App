import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

/// ─────────────────────────────────────────────────────────────
/// Service Provider
/// ─────────────────────────────────────────────────────────────
/// Exposes a singleton [AuthService] instance to the widget tree.
/// Widgets and other providers can `ref.read(authServiceProvider)`
/// or `ref.watch(authServiceProvider)` to access auth operations.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// ─────────────────────────────────────────────────────────────
/// Auth State Stream Provider
/// ─────────────────────────────────────────────────────────────
/// Listens to Firebase Auth's real-time authentication state.
///
/// Emits:
///   - `AsyncData(User)` when a user is signed in
///   - `AsyncData(null)` when signed out
///   - `AsyncError` on auth failures
///
/// This is the root provider that drives the app's initial routing:
/// the main widget watches this to decide between LoginScreen
/// and the authenticated screens.
final authStateChangeProvider =
    StreamProvider<User?>((ref) {
  final AuthService authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

/// ─────────────────────────────────────────────────────────────
/// Current User Provider (Dynamic Role Check)
/// ─────────────────────────────────────────────────────────────
/// Fetches the full [AppUser] from Firestore after authentication.
///
/// ⚡ DYNAMIC ROLE CHECK: Instead of hardcoding admin UIDs, this provider
/// reads the `role` field from the user's Firestore document. Admin access
/// is granted by setting `role: 'admin'` on the user document — no code
/// changes needed.
///
/// Returns:
///   - `AsyncData(AppUser)` with the user's role on success
///   - `AsyncError` if Firestore fetch fails
///
/// Usage:
///   final AsyncValue<AppUser?> user = ref.watch(currentUserProvider);
///   user.when(
///     data: (user) => user?.isAdmin == true ? AdminScreen() : UserScreen(),
///     loading: () => LoadingScreen(),
///     error: (e, _) => ErrorScreen(),
///   );
final currentUserProvider =
    FutureProvider<AppUser?>((ref) {
  final AuthService authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});
