import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:brainplay/constants/constants.dart';

/// A glassmorphism container with blur, gradient border, and depth shadows.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? glowColor;
  final double glowIntensity;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 12,
    this.glowColor,
    this.glowIntensity = 0.3,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? kPrimaryColor;
    final isDark = isDarkCtx(context);
    final rad = rs(borderRadius);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rad),
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: glow.withValues(alpha: glowIntensity * 0.4),
            blurRadius: rs(20),
            spreadRadius: rs(1),
          ),
          // Depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: rs(12),
            offset: Offset(0, rs(6)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rad),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(rs(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rad),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.4),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
