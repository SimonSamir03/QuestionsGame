import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';

class CoinsLivesRow extends StatelessWidget {
  const CoinsLivesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();
    final isDark = isDarkCtx(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(end: rs(4)),
      child: Obx(() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniPill(emoji: '\u{1F48E}', value: gc.coins.value, color: kPrimaryColor, isDark: isDark),
          SizedBox(width: rs(4)),
          _MiniPill(emoji: '\u2B50', value: gc.xp.value, color: Colors.amber, isDark: isDark),
          SizedBox(width: rs(4)),
          _MiniPill(emoji: '\u2764\uFE0F', value: gc.lives.value, color: Colors.redAccent, isDark: isDark),
        ],
      )),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String emoji;
  final int value;
  final Color color;
  final bool isDark;

  const _MiniPill({
    required this.emoji,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(6), vertical: rs(3)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()]
              : [Colors.white, const Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(rs(16)),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : color.withValues(alpha: 0.08),
            offset: Offset(0, rs(1)),
            blurRadius: rs(1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: fs(10))),
          SizedBox(width: rs(2)),
          Text(
            '$value',
            style: TextStyle(
              fontSize: kFontSizeCaption,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
