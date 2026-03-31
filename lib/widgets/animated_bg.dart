import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brainplay/constants/constants.dart';

/// An animated gradient background with floating particles for a modern 3D feel.
class AnimatedGameBg extends StatefulWidget {
  final Widget child;
  final Color? color1;
  final Color? color2;
  final bool showParticles;
  final int particleCount;

  const AnimatedGameBg({
    super.key,
    required this.child,
    this.color1,
    this.color2,
    this.showParticles = true,
    this.particleCount = 15,
  });

  @override
  State<AnimatedGameBg> createState() => _AnimatedGameBgState();
}

class _AnimatedGameBgState extends State<AnimatedGameBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    final rng = Random();
    _particles = List.generate(widget.particleCount, (_) => _Particle(rng));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkCtx(context);
    final c1 = widget.color1 ?? (isDark ? kDarkBgColor : kLightBgColor);
    final c2 = widget.color2 ??
        (isDark
            ? HSLColor.fromColor(kDarkBgColor).withLightness(0.12).toColor()
            : HSLColor.fromColor(kLightBgColor).withLightness(0.92).toColor());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
      ),
      child: widget.showParticles
          ? AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _ctrl.value,
                    color: kPrimaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
                  ),
                  child: widget.child,
                );
              },
            )
          : widget.child,
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double offset;

  _Particle(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        size = rng.nextDouble() * 3 + 1,
        speed = rng.nextDouble() * 0.5 + 0.3,
        offset = rng.nextDouble() * 2 * pi;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final p in particles) {
      final angle = progress * 2 * pi * p.speed + p.offset;
      final dx = p.x * size.width + sin(angle) * 20;
      final dy = p.y * size.height + cos(angle) * 15;
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
