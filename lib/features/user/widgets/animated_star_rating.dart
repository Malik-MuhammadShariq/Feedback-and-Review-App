import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An animated 5-star rating widget.
///
/// Animations:
///   - Each star smoothly fills with an [AnimatedContainer] when tapped.
///   - The tapped star scales up briefly (1.0 → 1.3 → 1.0) via [AnimatedScale].
///   - Haptic feedback ([HapticFeedback.lightImpact]) fires on tap for tactile response.
///
/// Usage:
///   AnimatedStarRating(
///     rating: 3,
///     onRatingChanged: (newRating) => setState(() => _rating = newRating),
///     size: 40,
///   )
class AnimatedStarRating extends StatefulWidget {
  /// Current rating value (1–5). 0 means no rating selected.
  final int rating;

  /// Called when the user taps a star.
  final ValueChanged<int> onRatingChanged;

  /// Size of each star icon. Defaults to 36.
  final double size;

  /// Whether the stars are interactive (tappable). Defaults to true.
  final bool interactive;

  const AnimatedStarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 36,
    this.interactive = true,
  });

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating>
    with TickerProviderStateMixin {
  /// Tracks which star is currently being animated (for scale effect).
  int _animatingStar = -1;

  /// Handles the scale animation when a star is tapped.
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      // Scale up then back down for a satisfying "pop" effect
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// Handles a star tap: triggers scale animation, haptic feedback, and callback.
  void _onStarTap(int starIndex) {
    if (!widget.interactive) return;

    setState(() => _animatingStar = starIndex);
    _scaleController.forward(from: 0);

    // Haptic feedback for tactile response
    HapticFeedback.lightImpact();

    widget.onRatingChanged(starIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final int starNumber = index + 1;
        final bool isFilled = starNumber <= widget.rating;

        return GestureDetector(
          onTap: () => _onStarTap(starNumber),
          child: AnimatedScale(
            scale: _animatingStar == starNumber ? _scaleAnimation.value : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? Colors.amber : Colors.grey.shade400,
                size: widget.size,
                shadows: isFilled
                    ? [
                        Shadow(
                          color: Colors.amber.withValues(alpha: 0.4),
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
