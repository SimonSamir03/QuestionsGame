import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../services/ads_service.dart';
import 'button_3d.dart';

class GameResultDialog {
  GameResultDialog._();

  static void show({
    required BuildContext context,
    required bool won,
    int coinsEarned = 0,
    String? title,
    String? subtitle,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
  }) {
    final gc = Get.find<GameController>();
    final isAr = gc.isAr;
    final isDark = isDarkCtx(context);
    final accentColor = won ? kGreenColor : kRedColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: rs(24), vertical: rs(28)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                  : [Colors.white, const Color(0xFFF8F6FF)],
            ),
            borderRadius: BorderRadius.circular(rs(24)),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: rs(24),
                spreadRadius: rs(2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: rs(12),
                offset: Offset(0, rs(6)),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji with glow
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: rs(20),
                      spreadRadius: rs(3),
                    ),
                  ],
                ),
                child: Text(won ? '\u{1F389}' : '\u{1F622}', style: TextStyle(fontSize: fs(64))),
              ),
              SizedBox(height: rs(12)),
              Text(
                title ?? (won ? 'round_won'.tr : 'round_lost'.tr),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: kFontSizeH3,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: accentColor.withValues(alpha: 0.3), blurRadius: rs(8))],
                ),
              ),
              SizedBox(height: rs(16)),
              // Info card with depth
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(rs(16)),
                decoration: BoxDecoration(
                  color: kBgColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(rs(16)),
                  border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      offset: Offset(0, rs(2)),
                      blurRadius: rs(4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (won) ...[
                      if (coinsEarned > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('\u{1FA99}', style: TextStyle(fontSize: fs(22))),
                            SizedBox(width: rs(8)),
                            Text('+$coinsEarned',
                                style: TextStyle(fontSize: kFontSizeH2, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        ),
                      SizedBox(height: rs(4)),
                      Text(subtitle ?? (isAr ? '\u0623\u062d\u0633\u0646\u062a!' : 'Well done!'),
                          style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody)),
                    ] else ...[
                      Text(subtitle ?? (isAr ? '\u062d\u0627\u0648\u0644 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649' : 'Try again'),
                          style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBodyLarge)),
                      SizedBox(height: rs(8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\u2764\ufe0f', style: TextStyle(fontSize: fs(18))),
                          SizedBox(width: rs(6)),
                          Obx(() => Text(
                            'lives_left'.trParams({'n': '${gc.lives.value}'}),
                            style: TextStyle(color: Colors.redAccent, fontSize: kFontSizeBody),
                          )),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: rs(20)),
              Button3D(
                label: 'btn_play_again'.tr,
                color: won ? kPrimaryColor : kRedColor,
                onTap: () async {
                  Get.back();
                  if (!gc.isPremium.value) await AdsService().showInterstitial();
                  if (!gc.tryShowMysteryBox()) onPlayAgain();
                },
              ),
              SizedBox(height: rs(10)),
              TextButton(
                onPressed: () async {
                  Get.back();
                  if (!gc.isPremium.value) await AdsService().showInterstitial();
                  onHome();
                },
                child: Text('btn_home'.tr, style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
