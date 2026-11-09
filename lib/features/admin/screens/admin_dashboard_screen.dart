import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/feedback_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/feedback_provider.dart';
import '../widgets/feedback_list_item.dart';
import '../widgets/rating_distribution_chart.dart';
import '../widgets/stat_card.dart';

/// Admin dashboard showing real-time feedback analytics.
///
/// Features:
///   - Stat cards (Total Reviews + Average Rating) with animated counters
///   - Rating distribution bar chart
///   - Real-time feedback list with staggered animations
///   - Pull-to-refresh support
///
/// ⚡ REAL-TIME: Uses [allFeedbackProvider] (StreamProvider backed by Firestore
/// `.snapshots()`) so new reviews appear instantly without manual refresh.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch the real-time feedback stream
    final feedbackAsync = ref.watch(allFeedbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _handleSignOut(context, ref),
          ),
        ],
      ),
      body: feedbackAsync.when(
        data: (feedbackList) => _buildDashboard(context, ref, feedbackList),
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
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(AppStrings.genericError, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allFeedbackProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main dashboard content.
  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    List<Feedback> feedbackList,
  ) {
    final theme = Theme.of(context);

    // Calculate statistics
    final totalReviews = feedbackList.length;
    final avgRating = totalReviews > 0
        ? feedbackList
                .map((f) => f.rating)
                .fold<int>(0, (sum, rating) => sum + rating) /
            totalReviews
        : 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate providers to trigger a fresh data fetch
        ref.invalidate(allFeedbackProvider);
        ref.invalidate(averageRatingProvider);
      },
      child: CustomScrollView(
        slivers: [
          // ── Stats Row ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  // Total Reviews stat card
                  Expanded(
                    child: StatCard(
                      icon: Icons.reviews_outlined,
                      label: 'Total Reviews',
                      value: totalReviews,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                  const SizedBox(width: 12),
                  // Average Rating stat card
                  Expanded(
                    child: StatCard(
                      icon: Icons.star_outline,
                      label: 'Average Rating',
                      value: avgRating,
                      decimals: 1,
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                ],
              ),
            ),
          ),

          // ── Rating Distribution Chart ──
          if (totalReviews > 0)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: RatingDistributionChart(feedbackList: feedbackList),
              ),
            ),

          // ── Section Header ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Feedback',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms),
            ),
          ),

          // ── Empty State or Feedback List ──
          if (totalReviews == 0)
            SliverFillRemaining(
              child: _buildEmptyState(context),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final feedback = feedbackList[index];
                  return FeedbackListItem(
                    feedback: feedback,
                    index: index,
                  );
                },
                childCount: totalReviews,
              ),
            ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
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

  /// Signs out the current user and navigates back to login.
  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    // Navigation is handled automatically by authStateChangeProvider
    // in the root widget (main.dart)
  }
}
