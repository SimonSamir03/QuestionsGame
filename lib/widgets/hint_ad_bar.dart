import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../services/ads_service.dart';
import '../services/api_service.dart';

class HintAdBar extends StatelessWidget {
  final VoidCallback onHint;
  final bool hintEnabled;

  const HintAdBar({
    super.key,
    required this.onHint,
    this.hintEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();
    final isAr = gc.isAr;
    final hintCost = gc.hintCostGems;
    final adReward = gc.gemsPerAd;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            final canAfford = gc.coins.value >= hintCost;
            return _BarButton3D(
              icon: Icons.lightbulb_outline,
              label: isAr ? '\u062a\u0644\u0645\u064a\u062d ($hintCost)' : 'Hint ($hintCost)',
              color: kOrangeColor,
              enabled: hintEnabled && canAfford,
              onTap: () {
                if (!hintEnabled) return;
                if (!canAfford) {
                  Get.snackbar(
                    isAr ? '\u0639\u0645\u0644\u0627\u062a \u063a\u064a\u0631 \u0643\u0627\u0641\u064a\u0629' : 'Not Enough Coins',
                    isAr ? '\u0634\u0627\u0647\u062f \u0625\u0639\u0644\u0627\u0646' : 'Watch an ad to earn coins',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: kCardColor,
                    colorText: kTextPrimary,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                gc.spendCoins(hintCost);
                onHint();
              },
            );
          }),
          SizedBox(width: rs(12)),
          _BarButton3D(
            icon: Icons.play_circle_outline,
            label: isAr ? '\u0625\u0639\u0644\u0627\u0646 +$adReward' : 'Ad +$adReward',
            color: kGreenColor,
            enabled: true,
            onTap: () async {
              if (!gc.isOnline.value) { gc.showOfflineRewardDialog(); return; }
              final watched = await AdsService().showRewarded();
              if (watched) {
                final res = await ApiService().logAdWatch(rewardType: 'hint_ad', coinsEarned: adReward);
                if (res != null && res['allowed'] == true) {
                  gc.addGems((res['coins_earned'] as num?)?.toInt() ?? adReward);
                }
                Get.snackbar(
                  isAr ? '\u0645\u0643\u0627\u0641\u0623\u0629' : 'Reward',
                  isAr ? '+$adReward \u0639\u0645\u0644\u0629!' : '+$adReward coins!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: kGreenColor.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _BarButton3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _BarButton3D({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : color.withValues(alpha: 0.35);
    final darkColor = HSLColor.fromColor(effectiveColor)
        .withLightness((HSLColor.fromColor(effectiveColor).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(14), vertical: rs(7)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              effectiveColor.withValues(alpha: 0.2),
              effectiveColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(14)),
          border: Border.all(color: effectiveColor, width: rs(1.2)),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: darkColor.withValues(alpha: 0.3),
                    offset: Offset(0, rs(2)),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.12),
                    blurRadius: rs(6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: rs(18), color: effectiveColor),
            SizedBox(width: rs(6)),
            Text(
              label,
              style: TextStyle(
                fontSize: kFontSizeCaption,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
