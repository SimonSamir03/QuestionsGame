import 'package:flutter/material.dart';

/// Animates a number counting up from [begin] to [end].
class CountUpText extends StatelessWidget {
  final int begin;
  final int end;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const CountUpText({
    super.key,
    this.begin = 0,
    required this.end,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: begin, end: end),
      duration: duration,
      builder: (context, value, _) {
        return Text('$prefix$value$suffix', style: style);
      },
    );
  }
}
