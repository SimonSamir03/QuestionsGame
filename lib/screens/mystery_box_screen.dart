import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/mystery_box_controller.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class MysteryBoxScreen extends StatelessWidget {
  const MysteryBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mysteryBoxController = Get.find<MysteryBoxController>();
    return Obx(() {
      final isOpened = mysteryBoxController.isOpened.value;
      final reward = mysteryBoxController.reward.value;
      final isDark = isDarkCtx(context);

      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          leading: _build3DBackButton(context),
          title: Text('mystery_box_title'.tr),
          centerTitle: true,
        ),
        body: AnimatedGameBg(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                left: rs(32),
                right: rs(32),
                bottom: rs(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isOpened) ...[
                    AnimatedBuilder(
                      animation: mysteryBoxController.shakeAnim,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: mysteryBoxController.shakeAnim.value,
                          child: child,
                        );
                      },
                      child: Text('\u{1f381}', style: TextStyle(fontSize: fs(120))),
                    ),
                    SizedBox(height: rs(24)),
                    Text(
                      'mystery_box_got'.tr,
                      style: TextStyle(fontSize: kFontSizeH3, fontWeight: FontWeight.bold, color: kTextPrimary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: rs(8)),
                    Text(
                      'mystery_box_tap'.tr,
                      style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                    ),
                    SizedBox(height: rs(32)),
                    Button3D(
                      label: 'btn_open_box'.tr,
                      color: Colors.amber,
                      textColor: Colors.black,
                      height: 55,
                      onTap: mysteryBoxController.openBox,
                    ),
                  ],
                  if (isOpened && reward != null) ...[
                    Text('\u{1f389}', style: TextStyle(fontSize: fs(80))),
                    SizedBox(height: rs(16)),
                    Text(
                      'mystery_box_you_got'.tr,
                      style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                    ),
                    SizedBox(height: rs(12)),
                    Container(
                      padding: EdgeInsets.all(rs(24)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.22).toColor()]
                              : [Colors.white, Colors.white.withValues(alpha: 0.95)],
                        ),
                        borderRadius: BorderRadius.circular(rs(20)),
                        border: Border.all(color: Colors.amber, width: rs(2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            offset: Offset(0, rs(5)),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.25),
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
                                borderRadius: BorderRadius.vertical(top: Radius.circular(rs(18))),
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
                          Column(
                            children: [
                              Text(
                                reward['type'] == 'coins' ? '\u{1fa99}' : (reward['type'] == 'life' ? '\u2764\ufe0f' : '\u26a1'),
                                style: TextStyle(fontSize: fs(48)),
                              ),
                              SizedBox(height: rs(8)),
                              Text(
                                reward['label'] as String,
                                style: TextStyle(color: Colors.amber, fontSize: kFontSizeH3, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: rs(32)),
                    Button3D(
                      label: 'btn_watch_another'.tr,
                      icon: Icons.play_circle,
                      color: kSecondaryColor,
                      height: 50,
                      onTap: mysteryBoxController.openAnotherBox,
                    ),
                    SizedBox(height: rs(12)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'btn_continue'.tr,
                        style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                      ),
                    ),
                  ],
                ],
              ),
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
