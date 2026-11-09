import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../models/feedback_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/feedback_provider.dart';
import '../screens/feedback_history_screen.dart';
import '../widgets/animated_star_rating.dart';

/// Screen for users to submit new feedback / reviews.
///
/// Features:
///   - Category dropdown (Task / Course / Service)
///   - Animated 5-star rating widget
///   - Multiline comment field
///   - Success Lottie animation + SnackBar on submission
///   - Form validation
class FeedbackSubmissionScreen extends ConsumerStatefulWidget {
  const FeedbackSubmissionScreen({super.key});

  @override
  ConsumerState<FeedbackSubmissionScreen> createState() =>
      _FeedbackSubmissionScreenState();
}

class _FeedbackSubmissionScreenState
    extends ConsumerState<FeedbackSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  bool _isSubmitting = false;
  bool _isCommentFocused = false;
  int _rating = 0;
  String _selectedCategory = FeedbackCategories.task;

  @override
  void initState() {
    super.initState();
    _commentFocusNode.addListener(() {
      setState(() => _isCommentFocused = _commentFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  /// Submits the feedback to Firestore.
  ///
  /// On success: shows a success Lottie dialog, then a SnackBar, then clears the form.
  Future<void> _handleSubmit() async {
    // Validate all fields
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating'),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get the current user's info for the feedback document
      final user = ref.read(currentUserProvider).value;
      final firestoreService = ref.read(firestoreServiceProvider);

      final feedback = Feedback(
        id: '', // Firestore will auto-generate
        userId: user?.uid ?? 'unknown',
        userName: user?.displayName ?? 'Anonymous',
        rating: _rating,
        comment: _commentController.text.trim(),
        category: _selectedCategory,
        timestamp: DateTime.now(), // will be overwritten by server timestamp
      );

      await firestoreService.addFeedback(feedback);

      if (!mounted) return;

      // Show success animation dialog
      _showSuccessDialog();

      // Clear the form
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: ${e.toString()}'),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Shows a success Lottie animation in a dialog.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Lottie animation
            Lottie.asset(
              LottieAssets.success,
              width: 150,
              height: 150,
              repeat: false,
              onLoaded: (composition) {
                // Auto-dismiss after animation completes
                Future.delayed(composition.duration, () {
                  if (context.mounted) Navigator.of(context).pop();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.submitSuccess,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Also show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.submitSuccess),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Clears the form after successful submission.
  void _clearForm() {
    _commentController.clear();
    setState(() {
      _rating = 0;
      _selectedCategory = FeedbackCategories.task;
    });
  }

  /// Navigates to the user's feedback history screen.
  void _navigateToHistory() {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const FeedbackHistoryScreen(),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Feedback'),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My Feedback History',
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              Text(
                'How was your experience?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Your feedback helps us improve',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 600.ms),

              const SizedBox(height: 32),

              // ── Category Dropdown ──
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: FeedbackCategories.all
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // ── Star Rating ──
              Text(
                'Rating',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 12),

              AnimatedStarRating(
                rating: _rating,
                onRatingChanged: (newRating) {
                  setState(() => _rating = newRating);
                },
                size: 44,
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 24),

              // ── Comment Field ──
              // Card elevates (shadow + border) smoothly when the field gains focus.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isCommentFocused
                        ? theme.colorScheme.primary.withValues(alpha: 0.5)
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.4),
                    width: _isCommentFocused ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(
                        alpha: _isCommentFocused ? 0.25 : 0.08,
                      ),
                      blurRadius: _isCommentFocused ? 12 : 4,
                      offset: Offset(0, _isCommentFocused ? 6 : 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: TextFormField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLines: 5,
                  maxLength: 500,
                  textInputAction: TextInputAction.newline,
                  validator: Validators.validateComment,
                  cursorColor: theme.colorScheme.primary,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Your Feedback',
                    hintText: 'Tell us about your experience...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.comment_outlined),
                    ),
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // ── Submit Button ──
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Feedback'),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
