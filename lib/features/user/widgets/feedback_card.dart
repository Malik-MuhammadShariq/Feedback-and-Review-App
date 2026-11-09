import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/feedback_model.dart';

/// A Material 3 card displaying a feedback entry.
///
/// Animations:
///   - The category icon is wrapped in a [Hero] widget for smooth transitions
///     to a detail screen.
///   - The card slides in from below with a fade when built.
///
/// Usage:
///   FeedbackCard(feedback: myFeedback)
class FeedbackCard extends StatelessWidget {
  /// The feedback data to display.
  final Feedback feedback;

  /// Optional tap handler for the entire card.
  final VoidCallback? onTap;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.onTap,
  });

  /// Returns the icon for each category.
  IconData _categoryIcon(String category) {
    switch (category) {
      case FeedbackCategories.task:
        return Icons.task_alt;
      case FeedbackCategories.course:
        return Icons.school_outlined;
      case FeedbackCategories.service:
        return Icons.room_service_outlined;
      default:
        return Icons.feedback_outlined;
    }
  }

  /// Returns the color for each category.
  Color _categoryColor(String category) {
    switch (category) {
      case FeedbackCategories.task:
        return Colors.blue;
      case FeedbackCategories.course:
        return Colors.purple;
      case FeedbackCategories.service:
        return Colors.orange;
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor(feedback.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Category + Rating ──
              Row(
                children: [
                  // Hero-wrapped category icon for smooth transitions
                  Hero(
                    tag: 'category_icon_${feedback.id}',
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: categoryColor.withValues(alpha: 0.15),
                      child: Icon(
                        _categoryIcon(feedback.category),
                        color: categoryColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Category name
                  Expanded(
                    child: Text(
                      feedback.category,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  // Rating stars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final filled = index < feedback.rating;
                      return Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: filled ? Colors.amber : Colors.grey.shade400,
                        size: 18,
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Comment Preview ──
              Text(
                feedback.comment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // ── Footer: User + Timestamp ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    feedback.userName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(feedback.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
