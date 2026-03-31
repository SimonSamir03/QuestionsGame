import 'package:flutter/material.dart';
import 'package:brainplay/constants/constants.dart';

/// A 3D-looking button with depth shadow and press animation.
class Button3D extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color? textColor;
  final IconData? icon;
  final String? emoji;
  final double height;
  final double borderRadius;
  final double depth;
  final double fontSize;
  final bool expanded;

  const Button3D({
    super.key,
    required this.label,
    this.onTap,
    this.color = kPrimaryColor,
    this.textColor,
    this.icon,
    this.emoji,
    this.height = 52,
    this.borderRadius = 16,
    this.depth = 5,
    this.fontSize = 17,
    this.expanded = true,
  });

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final rad = rs(widget.borderRadius);
    final depthVal = rs(widget.depth);
    final currentDepth = _pressed ? depthVal * 0.3 : depthVal;
    final darkColor = HSLColor.fromColor(widget.color)
        .withLightness(
            (HSLColor.fromColor(widget.color).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeInOut,
        width: widget.expanded ? double.infinity : null,
        margin: EdgeInsets.only(top: _pressed ? currentDepth : 0),
        child: Container(
          height: rs(widget.height),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rad),
            boxShadow: [
              // 3D base shadow (the "depth" underside)
              BoxShadow(
                color: darkColor,
                offset: Offset(0, currentDepth),
                blurRadius: 0,
              ),
              // Soft glow
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: rs(12),
                offset: Offset(0, rs(3)),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rad),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.color.withValues(alpha: 1.0),
                  HSLColor.fromColor(widget.color)
                      .withLightness((HSLColor.fromColor(widget.color).lightness - 0.05).clamp(0.0, 1.0))
                      .toColor(),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Glossy highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: rs(widget.height) * 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(rad)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.emoji != null) ...[
                        Text(widget.emoji!, style: TextStyle(fontSize: fs(widget.fontSize + 2))),
                        SizedBox(width: rs(8)),
                      ],
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor ?? Colors.white, size: rs(widget.fontSize + 4)),
                        SizedBox(width: rs(8)),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontSize: fs(widget.fontSize),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
