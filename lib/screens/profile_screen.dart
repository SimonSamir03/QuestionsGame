import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();
    final nameCtrl = TextEditingController(text: gc.playerName.value);
    final phoneCtrl = TextEditingController(text: gc.phoneNumber.value);

    return Obx(() {
      final isAr = gc.isAr;
      final isDark = isDarkCtx(context);
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: kTextPrimary,
            leading: _build3DBackButton(context),
            title: Text('settings_profile'.tr),
            centerTitle: true,
          ),
          body: AnimatedGameBg(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                left: rs(16),
                right: rs(16),
                bottom: rs(16),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: rs(16),
                          offset: Offset(0, rs(4)),
                        ),
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.4),
                          offset: Offset(0, rs(4)),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: kPrimaryColor.withValues(alpha: 0.2),
                      radius: rs(44),
                      child: Text(
                        gc.playerName.value.isNotEmpty
                            ? gc.playerName.value[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fs(36),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: rs(8)),
                  Text(
                    gc.playerName.value.isNotEmpty ? gc.playerName.value : 'Player',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: kFontSizeH3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (gc.phoneNumber.value.isNotEmpty)
                    Text(
                      gc.phoneNumber.value,
                      style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                    ),
                  SizedBox(height: rs(20)),

                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _statCard(context, '\u{1f48e}', isAr ? '\u062c\u0648\u0627\u0647\u0631' : 'Gems', '${gc.coins.value}', kPrimaryColor)),
                      SizedBox(width: rs(10)),
                      Expanded(child: _statCard(context, '\u2b50', isAr ? '\u062e\u0628\u0631\u0629' : 'XP', '${gc.xp.value}', Colors.amber)),
                    ],
                  ),
                  SizedBox(height: rs(10)),
                  Row(
                    children: [
                      Expanded(child: _statCard(context, '\u2764\ufe0f', 'lives'.tr, '${gc.lives.value}', Colors.redAccent)),
                      SizedBox(width: rs(10)),
                      Expanded(child: _statCard(context, '\u{1f525}', 'settings_streak'.tr, '${gc.streakDays.value}', Colors.orange)),
                    ],
                  ),
                  SizedBox(height: rs(24)),

                  // Edit fields
                  DepthCard(
                    padding: EdgeInsets.all(rs(16)),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameCtrl,
                          style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: kPrimaryColor, size: rs(22)),
                            labelText: 'settings_player_name'.tr,
                            labelStyle: TextStyle(color: kTextHint),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(rs(12)),
                              borderSide: BorderSide(color: kBorderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(rs(12)),
                              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: rs(14)),
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_outlined, color: kPrimaryColor, size: rs(22)),
                            labelText: 'settings_phone'.tr,
                            helperText: 'settings_phone_hint'.tr,
                            helperStyle: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                            labelStyle: TextStyle(color: kTextHint),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(rs(12)),
                              borderSide: BorderSide(color: kBorderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(rs(12)),
                              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: rs(18)),
                        Button3D(
                          label: 'settings_save'.tr,
                          icon: Icons.check,
                          color: kPrimaryColor,
                          height: 50,
                          onTap: () async {
                            gc.setPlayerName(nameCtrl.text.trim());
                            gc.setPhoneNumber(phoneCtrl.text.trim());
                            await gc.syncProfile();
                            Get.snackbar(
                              isAr ? '\u062a\u0645 \u0627\u0644\u062d\u0641\u0638' : 'Saved',
                              isAr ? '\u062a\u0645 \u062a\u062d\u062f\u064a\u062b \u0628\u064a\u0627\u0646\u0627\u062a\u0643' : 'Profile updated',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: kGreenColor.withValues(alpha: 0.9),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: rs(20)),

                  // Account info
                  DepthCard(
                    padding: EdgeInsets.all(rs(16)),
                    child: Column(
                      children: [
                        _infoRow(Icons.star, 'settings_status'.tr,
                          gc.isPremium.value ? 'settings_premium'.tr : 'settings_free'.tr),
                        Divider(color: kBorderColor, height: rs(20)),
                        _infoRow(Icons.games, isAr ? '\u0627\u0644\u0645\u0633\u062a\u0648\u064a\u0627\u062a' : 'Levels Played',
                          '${gc.levelCounter.value}'),
                      ],
                    ),
                  ),
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

  Widget _statCard(BuildContext context, String emoji, String label, String value, Color color) {
    final isDark = isDarkCtx(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: rs(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(rs(14)),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            offset: Offset(0, rs(4)),
            blurRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: rs(10),
            offset: Offset(0, rs(2)),
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
            height: rs(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(rs(14))),
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
          Center(
            child: Column(
              children: [
                Text(emoji, style: TextStyle(fontSize: fs(24))),
                SizedBox(height: rs(4)),
                Text(value, style: TextStyle(
                  color: color, fontSize: kFontSizeH3, fontWeight: FontWeight.bold)),
                SizedBox(height: rs(2)),
                Text(label, style: TextStyle(
                  color: kTextHint, fontSize: kFontSizeTiny)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(rs(6)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(rs(8)),
            boxShadow: [
              BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(6), offset: Offset(0, rs(2))),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: rs(16)),
        ),
        SizedBox(width: rs(12)),
        Text(label, style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody)),
        const Spacer(),
        Text(value, style: TextStyle(color: kTextHint, fontSize: kFontSizeBody)),
      ],
    );
  }
}
