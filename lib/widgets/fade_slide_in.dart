import 'package:flutter/material.dart';

/// Fades and slides a child in from below on first build.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 30),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: Curves.easeOut,
      builder: (context, value, _) {
        // Account for delay by clamping progress
        final delayFraction =
            delay.inMilliseconds / (duration + delay).inMilliseconds;
        final progress =
            ((value - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1.0 - progress),
              offset.dy * (1.0 - progress),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
