import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/feedback_provider.dart';
import '../widgets/feedback_card.dart';

/// Displays the current user's feedback history with REAL-TIME updates.
///
/// Uses [userFeedbackProvider] (a StreamProvider) so new feedback submitted
/// on the submission screen appears here instantly.
///
/// Animations:
///   - Each card animates in with a staggered fade + slide.
///   - Empty state shows a Lottie animation.
class FeedbackHistoryScreen extends ConsumerWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Watch the user-specific real-time feedback stream
    final feedbackAsync = ref.watch(userFeedbackProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feedback'),
      ),
      body: feedbackAsync.when(
        data: (feedbackList) {
          // ── Empty State ──
          if (feedbackList.isEmpty) {
            return _buildEmptyState(context);
          }

          // ── Feedback List with staggered animations ──
          return RefreshIndicator(
            onRefresh: () async {
              // Re-trigger the stream provider to refresh data
              ref.invalidate(userFeedbackProvider(user.uid));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                final feedback = feedbackList[index];
                return FeedbackCard(feedback: feedback)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 80 * index),
                      duration: 400.ms,
                    )
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      delay: Duration(milliseconds: 80 * index),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    );
              },
            ),
          );
        },
        loading: () => Center(
          child: Lottie.asset(
            LottieAssets.loading,
            width: 120,
            height: 120,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.genericError,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the empty state with a Lottie animation.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state Lottie animation
            Lottie.asset(
              LottieAssets.empty,
              width: 180,
              height: 180,
            ),

            const SizedBox(height: 24),

            Text(
              AppStrings.noFeedbackTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: 8),

            Text(
              AppStrings.noFeedbackSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
