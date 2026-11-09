import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../user/screens/feedback_submission_screen.dart';
import '../screens/signup_screen.dart';

/// Login screen with email/password authentication.
///
/// Animations:
///   - Entire form fades in with a slight upward slide on screen load.
///   - Error messages appear with a shake animation.
///   - Page transitions use a custom fade-slide via [PageRouteBuilder].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isPressed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Attempts to sign in the user.
  ///
  /// On success, reads the user's role from Firestore via [AuthService.getCurrentUser]
  /// and navigates to the appropriate screen (admin dashboard or user submission).
  /// On failure, shows a SnackBar with the error message.
  Future<void> _handleSignIn() async {
    // Visual feedback: brief scale-down animation on press.
    // Driven from onPressed (not a Listener wrapper) so the button's
    // gesture recognizer is never rebuilt mid-tap.
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isPressed = false);
    });

    // Validate form fields first
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final AuthService authService = ref.read(authServiceProvider);

      // Sign in via Firebase Auth
      await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Fetch the user document to determine role (dynamic role check)
      final user = await authService.getCurrentUser();

      if (!mounted) return;

      // Route based on role
      if (user?.isAdmin == true) {
        _navigateTo(const AdminDashboardScreen());
      } else {
        _navigateTo(const FeedbackSubmissionScreen());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_getFirebaseAuthMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      _showError('Sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _getFirebaseAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Sign-in failed. Please check your credentials.';
    }
  }

  /// Shows a modern, styled error message in a SnackBar.
  void _showError(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.error.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Navigates to the given screen with a fade-slide transition.
  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade + slight upward slide transition
          final fadeAnimation =
              Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ));
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ));
          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Navigates to the signup screen with a fade-slide transition.
  void _navigateToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ));
          return SlideTransition(position: slideAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // ── App Logo / Icon ──
                  const Hero(
                    tag: 'app_logo',
                    child: Icon(
                      Icons.reviews_outlined,
                      size: 72,
                      color: kPrimaryColor,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.5, 0.5)),

                  const SizedBox(height: 16),

                  // ── Title ──
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms),

                  const SizedBox(height: 40),

                  // ── Email Field ──
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateEmail,
                    cursorColor: theme.colorScheme.primary,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Password Field ──
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    validator: Validators.validatePassword,
                    cursorColor: theme.colorScheme.primary,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideX(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // ── Sign In Button ──
                  // Gradient button with gentle scale-down on press.
                  // Animation is driven from _handleSignIn (onPressed) to
                  // avoid rebuilding the gesture recognizer mid-tap.
                  AnimatedScale(
                    scale: _isPressed ? 0.96 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.4),
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                ]
                              : [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onPrimary,
                          disabledForegroundColor: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.7),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // ── Sign Up Link ──
                  TextButton(
                    onPressed: _navigateToSignUp,
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: theme.textTheme.bodyMedium,
                        children: const [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
