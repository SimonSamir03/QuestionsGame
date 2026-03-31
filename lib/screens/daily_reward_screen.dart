import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/daily_reward_controller.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class DailyRewardScreen extends StatelessWidget {
  const DailyRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyRewardController = Get.find<DailyRewardController>();
    return Obx(() {
      final status = dailyRewardController.status.value;
      final isDark = isDarkCtx(context);

      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          leading: _build3DBackButton(context),
          title: Text('daily_reward_title'.tr),
          centerTitle: true,
        ),
        body: AnimatedGameBg(
          child: dailyRewardController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                    left: rs(16),
                    right: rs(16),
                    bottom: rs(16),
                  ),
                  child: Column(
                    children: [
                      // Streak Info
                      Container(
                        padding: EdgeInsets.all(rs(20)),
                        decoration: BoxDecoration(
                          gradient: kBrandGradient,
                          borderRadius: BorderRadius.circular(rs(20)),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withValues(alpha: 0.5),
                              offset: Offset(0, rs(5)),
                              blurRadius: 0,
                            ),
                            BoxShadow(
                              color: kPrimaryColor.withValues(alpha: 0.3),
                              blurRadius: rs(16),
                              offset: Offset(0, rs(4)),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Glossy highlight
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: rs(40),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(rs(20))),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.2),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('\u{1f525}', style: TextStyle(fontSize: fs(36))),
                                SizedBox(width: rs(12)),
                                Column(
                                  children: [
                                    Text(
                                      '${status?.currentStreak ?? 0}',
                                      style: TextStyle(fontSize: kFontSizeH1, fontWeight: FontWeight.bold, color: kTextPrimary),
                                    ),
                                    Text(
                                      'streak_label'.tr,
                                      style: TextStyle(color: kTextSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: rs(20)),

                      // Reward Grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: rs(8),
                            mainAxisSpacing: rs(8),
                          ),
                          itemCount: 7,
                          itemBuilder: (ctx, index) {
                            final item = dailyRewardController.schedule[index];
                            final currentStreak = status?.currentStreak ?? 0;
                            final isPast = index < (currentStreak % 7);
                            final isCurrent = index == (currentStreak % 7);
                            final canClaim = (status?.canClaim ?? false) && isCurrent;

                            return ScaleTransition(
                              scale: canClaim ? dailyRewardController.bounceAnim : const AlwaysStoppedAnimation(1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: canClaim
                                      ? LinearGradient(colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)])
                                      : isPast
                                          ? LinearGradient(colors: [
                                              kSecondaryColor.withValues(alpha: 0.3),
                                              kSecondaryColor.withValues(alpha: 0.15),
                                            ])
                                          : LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: isDark
                                                  ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.22).toColor()]
                                                  : [Colors.white, Colors.white.withValues(alpha: 0.95)],
                                            ),
                                  borderRadius: BorderRadius.circular(rs(12)),
                                  border: canClaim
                                      ? Border.all(color: Colors.amber, width: rs(2))
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: canClaim
                                          ? kPrimaryColor.withValues(alpha: 0.4)
                                          : Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                                      offset: Offset(0, rs(3)),
                                      blurRadius: canClaim ? rs(8) : 0,
                                    ),
                                    if (canClaim)
                                      BoxShadow(
                                        color: Colors.amber.withValues(alpha: 0.3),
                                        blurRadius: rs(12),
                                      ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Glossy highlight
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: rs(24),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(rs(12))),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withValues(alpha: 0.18),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'day_label'.trParams({'n': "${item['day']}"}),
                                            style: TextStyle(
                                              color: isPast ? kTextHint : kTextPrimary,
                                              fontSize: kFontSizeTiny,
                                            ),
                                          ),
                                          SizedBox(height: rs(4)),
                                          Text(
                                            item['type'] == 'mystery' ? '\u{1f381}' : '\u{1fa99}',
                                            style: TextStyle(fontSize: fs(24)),
                                          ),
                                          SizedBox(height: rs(2)),
                                          Text(
                                            item['type'] == 'mystery'
                                                ? 'mystery_label'.tr
                                                : '${item['amount']}',
                                            style: TextStyle(
                                              color: isPast ? kTextDisabled : Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: kFontSizeCaption,
                                            ),
                                          ),
                                          if (isPast)
                                            Icon(Icons.check_circle, color: kSecondaryColor, size: rs(16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Claim Button
                      if (status?.canClaim == true)
                        Button3D(
                          label: dailyRewardController.isClaiming.value
                              ? '...'
                              : 'btn_claim'.tr,
                          color: Colors.amber,
                          textColor: Colors.black,
                          height: 55,
                          onTap: dailyRewardController.isClaiming.value
                              ? null
                              : () async {
                                  await dailyRewardController.claimReward();
                                  if (dailyRewardController.status.value != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('\u{1f389} +${dailyRewardController.status.value?.lastRewardAmount ?? ''} coins!'),
                                        backgroundColor: kSecondaryColor,
                                      ),
                                    );
                                  }
                                },
                        ),

                      // Restore Streak
                      if (status?.streakBroken == true)
                        Padding(
                          padding: EdgeInsets.only(top: rs(12)),
                          child: TextButton.icon(
                            onPressed: () => dailyRewardController.restoreStreak(),
                            icon: const Icon(Icons.play_circle, color: kSecondaryColor),
                            label: Text(
                              'btn_restore_streak'.tr,
                              style: const TextStyle(color: kSecondaryColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      );
    });
  }

  Widget _build3DBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkCtx(context) ? kDarkCardColor : Colors.white,
              isDarkCtx(context)
                  ? HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()
                  : const Color(0xFFF0F0F0),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkCtx(context) ? 0.4 : 0.10),
              offset: Offset(0, rs(3)),
              blurRadius: 0,
            ),
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.10),
              blurRadius: rs(8),
              offset: Offset(0, rs(2)),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, size: rs(18), color: kTextPrimary),
      ),
    );
  }
}
