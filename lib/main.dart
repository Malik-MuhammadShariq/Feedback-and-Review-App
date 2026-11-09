import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/user/screens/feedback_submission_screen.dart';
import 'providers/auth_provider.dart';

/// ─────────────────────────────────────────────────────────────
/// App Entry Point
/// ─────────────────────────────────────────────────────────────
///
/// Firebase is initialized here before the app starts.
void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the configuration from google-services.json
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: FeedbackReviewApp()));
}

/// Root application widget.
///
/// Uses Riverpod's [ProviderScope] to make all providers available
/// throughout the widget tree.
class FeedbackReviewApp extends StatelessWidget {
  const FeedbackReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback Review',
      debugShowCheckedModeBanner: false,
      // Light and dark themes from our centralized theme configuration
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      // System brightness setting controls light/dark mode
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Auth Gate — Root Routing Widget
/// ─────────────────────────────────────────────────────────────
///
/// Listens to authentication state and routes users accordingly:
///   - Unauthenticated → LoginScreen
///   - Authenticated + admin → AdminDashboardScreen
///   - Authenticated + user → FeedbackSubmissionScreen
///
/// The role is checked DYNAMICALLY from Firestore (via currentUserProvider),
/// not hardcoded. Admin access is granted by setting role='admin' on the
/// user document in Firestore.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Firebase Auth state changes
    final authState = ref.watch(authStateChangeProvider);

    return authState.when(
      data: (user) {
        // ── Signed Out → Login ──
        if (user == null) {
          return const LoginScreen();
        }

        // ── Signed In → Check Role ──
        final userAsync = ref.watch(currentUserProvider);

        return userAsync.when(
          data: (appUser) {
            // Dynamic role check from Firestore document
            if (appUser == null) {
              return const LoginScreen();
            }
            if (appUser.isAdmin) {
              return const AdminDashboardScreen();
            }
            return const FeedbackSubmissionScreen();
          },
          loading: () => const _LoadingScreen(),
          error: (_, __) => const LoginScreen(),
        );
      },
      loading: () => const _LoadingScreen(),
      error: (_, __) => const LoginScreen(),
    );
  }
}

/// Simple loading screen shown while checking auth state.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
