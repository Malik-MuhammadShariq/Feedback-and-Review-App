import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A statistics card with an animated counting number.
///
/// Animations:
///   - The number counts up from 0 to the target value using an
///     [AnimationController] with a [Tween].
///   - The card itself slides in from below on build.
///
/// Usage:
///   StatCard(
///     icon: Icons.reviews_outlined,
///     label: 'Total Reviews',
///     value: 42,
///   )
class StatCard extends StatefulWidget {
  /// The icon displayed at the top of the card.
  final IconData icon;

  /// The label text (e.g., "Total Reviews").
  final String label;

  /// The numeric value to display and animate to.
  final num value;

  /// Number of decimal places for display. 0 for integers.
  final int decimals;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.decimals = 0,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation runs once on build, counting from 0 to target value
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Smooth deceleration
    ));

    // Start the animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──
            CircleAvatar(
              radius: 22,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
              child: Icon(
                widget.icon,
                color: kPrimaryColor,
                size: 24,
              ),
            ),

            const SizedBox(height: 16),

            // ── Animated Value ──
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final displayValue = widget.decimals > 0
                    ? _animation.value.toStringAsFixed(widget.decimals)
                    : _animation.value.toInt().toString();
                return Text(
                  displayValue,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // ── Label ──
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
