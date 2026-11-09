import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/feedback_model.dart';

/// A bar chart showing the distribution of ratings (1★ to 5★).
///
/// Calculates the count of each rating from the feedback list and displays
/// it as a color-coded bar chart using [fl_chart].
///
/// Colors:
///   - 1-2 stars: Red (poor ratings)
///   - 3 stars: Yellow (average)
///   - 4-5 stars: Green (good ratings)
class RatingDistributionChart extends StatelessWidget {
  /// The list of feedback to calculate distribution from.
  final List<Feedback> feedbackList;

  const RatingDistributionChart({
    super.key,
    required this.feedbackList,
  });

  /// Calculates the count of each rating (1-5) from the feedback list.
  Map<int, int> _calculateDistribution() {
    final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final feedback in feedbackList) {
      if (feedback.rating >= 1 && feedback.rating <= 5) {
        distribution[feedback.rating] = (distribution[feedback.rating] ?? 0) + 1;
      }
    }
    return distribution;
  }

  /// Returns the color for each rating bar.
  Color _barColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red.shade400;
      case 3:
        return Colors.amber.shade600;
      case 4:
      case 5:
        return Colors.green.shade500;
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distribution = _calculateDistribution();
    final maxCount = distribution.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Text(
              'Rating Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // ── Bar Chart ──
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: (maxCount + 1).toDouble(),
                  barGroups: List.generate(5, (index) {
                    final rating = index + 1;
                    final count = distribution[rating] ?? 0;
                    return BarChartGroupData(
                      x: rating,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: _barColor(rating),
                          width: 28,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}★',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: maxCount > 0 ? (maxCount / 4).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == value.roundToDouble()) {
                            return Text(
                              value.toInt().toString(),
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxCount > 0 ? (maxCount / 4).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                ),
                swapAnimationDuration: const Duration(milliseconds: 500),
                swapAnimationCurve: Curves.easeOut,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 800.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // ── Legend ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem('Poor', Colors.red.shade400),
                const SizedBox(width: 16),
                _legendItem('Average', Colors.amber.shade600),
                const SizedBox(width: 16),
                _legendItem('Good', Colors.green.shade500),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .slideY(begin: 0.05, end: 0);
  }

  /// Builds a small legend item with a color dot and label.
  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
