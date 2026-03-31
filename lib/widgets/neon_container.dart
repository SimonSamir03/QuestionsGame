import 'package:flutter/material.dart';
import 'package:brainplay/constants/constants.dart';

/// A container with neon glow border and 3D depth shadows.
class NeonContainer extends StatelessWidget {
  final Widget child;
  final Color neonColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double neonSpread;
  final double? width;
  final double? height;
  final Gradient? gradient;

  const NeonContainer({
    super.key,
    required this.child,
    this.neonColor = kPrimaryColor,
    this.padding,
    this.margin,
    this.borderRadius = 18,
    this.neonSpread = 0.5,
    this.width,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final rad = rs(borderRadius);
    final isDark = isDarkCtx(context);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rad),
        boxShadow: [
          // Neon outer glow
          BoxShadow(
            color: neonColor.withValues(alpha: neonSpread * 0.6),
            blurRadius: rs(16),
            spreadRadius: rs(1),
          ),
          // Neon inner glow
          BoxShadow(
            color: neonColor.withValues(alpha: neonSpread * 0.3),
            blurRadius: rs(6),
          ),
          // 3D depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
            blurRadius: rs(10),
            offset: Offset(0, rs(5)),
          ),
        ],
      ),
      child: Container(
        padding: padding ?? EdgeInsets.all(rs(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rad),
          gradient: gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        kDarkCardColor,
                        kDarkCardColor.withValues(alpha: 0.8),
                      ]
                    : [
                        kLightCardColor,
                        kLightCardColor.withValues(alpha: 0.9),
                      ],
              ),
          border: Border.all(
            color: neonColor.withValues(alpha: isDark ? 0.5 : 0.3),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
