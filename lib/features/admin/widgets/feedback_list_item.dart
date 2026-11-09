import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/feedback_model.dart';

/// A list tile displaying a single feedback entry in the admin dashboard.
///
/// Animations:
///   - Staggered slide-in from the right based on [animationDelay].
///   - Hero-wrapped category icon for smooth transitions to detail screens.
class FeedbackListItem extends StatelessWidget {
  /// The feedback data to display.
  final Feedback feedback;

  /// The index in the list (used to stagger the animation).
  final int index;

  const FeedbackListItem({
    super.key,
    required this.feedback,
    required this.index,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'category_icon_${feedback.id}',
          child: CircleAvatar(
            radius: 22,
            backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
            child: Icon(
              _categoryIcon(feedback.category),
              color: kPrimaryColor,
              size: 22,
            ),
          ),
        ),
        title: Text(
          feedback.userName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          feedback.comment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Rating stars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(feedback.rating, (i) {
                return const Icon(Icons.star, color: Colors.amber, size: 14);
              }),
            ),
            const SizedBox(height: 4),
            // Timestamp
            Text(
              DateFormat('MMM d').format(feedback.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 60 * index),
          duration: 400.ms,
        )
        .slideX(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 60 * index),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}
