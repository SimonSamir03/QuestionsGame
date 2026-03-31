import 'package:flutter/material.dart';
import 'package:brainplay/constants/constants.dart';

/// A card with multiple shadow layers for a 3D depth effect.
class DepthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? accentColor;
  final Gradient? gradient;
  final double elevation;
  final VoidCallback? onTap;

  const DepthCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 18,
    this.accentColor,
    this.gradient,
    this.elevation = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rad = rs(borderRadius);
    final accent = accentColor ?? kPrimaryColor;
    final isDark = isDarkCtx(context);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rad),
        boxShadow: [
          // Bottom 3D edge
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5 * elevation)
                : accent.withValues(alpha: 0.12 * elevation),
            blurRadius: rs(2),
            offset: Offset(0, rs(4 * elevation)),
          ),
          // Ambient glow
          BoxShadow(
            color: accent.withValues(alpha: 0.08 * elevation),
            blurRadius: rs(16 * elevation),
            spreadRadius: rs(1),
          ),
          // Far shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: (isDark ? 0.3 : 0.06) * elevation),
            blurRadius: rs(20 * elevation),
            offset: Offset(0, rs(8 * elevation)),
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
                        HSLColor.fromColor(kDarkCardColor)
                            .withLightness(0.22)
                            .toColor(),
                      ]
                    : [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.95),
                      ],
              ),
          border: Border.all(
            color: isDark
                ? accent.withValues(alpha: 0.15)
                : accent.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// A tile cell with 3D depth — useful for game boards (puzzles, crosswords, etc.)
class DepthTile extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;
  final double borderRadius;
  final double depth;
  final VoidCallback? onTap;
  final bool selected;
  final Color? selectedBorderColor;

  const DepthTile({
    super.key,
    required this.child,
    required this.color,
    this.size = 48,
    this.borderRadius = 10,
    this.depth = 3,
    this.onTap,
    this.selected = false,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final rad = rs(borderRadius);
    final depthVal = rs(depth);
    final darkColor = HSLColor.fromColor(color)
        .withLightness(
            (HSLColor.fromColor(color).lightness - 0.18).clamp(0.0, 1.0))
        .toColor();
    final selColor = selectedBorderColor ?? kPrimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: rs(size),
        height: rs(size),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rad),
          boxShadow: [
            // 3D base
            BoxShadow(
              color: darkColor,
              offset: Offset(0, depthVal),
              blurRadius: 0,
            ),
            // Soft shadow
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: rs(6),
              offset: Offset(0, rs(2)),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rad),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                HSLColor.fromColor(color)
                    .withLightness((HSLColor.fromColor(color).lightness - 0.06).clamp(0.0, 1.0))
                    .toColor(),
              ],
            ),
            border: selected
                ? Border.all(color: selColor, width: rs(2.5))
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
          ),
          child: Stack(
            children: [
              // Glossy top highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: rs(size) * 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(rad)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
