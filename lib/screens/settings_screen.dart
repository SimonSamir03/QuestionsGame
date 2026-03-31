import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../services/sound_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';
import '../widgets/game_confirm_dialog.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    return Obx(() {
      final isDark = isDarkCtx(context);
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          leading: _build3DBackButton(context),
          title: Text('settings_title'.tr),
          centerTitle: true,
        ),
        body: AnimatedGameBg(
          child: ListView(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
              left: rs(16),
              right: rs(16),
              bottom: rs(16),
            ),
            children: [
              _buildSection(context, 'settings_profile'.tr, [
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(rs(8)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(rs(10)),
                      boxShadow: [
                        BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(8), offset: Offset(0, rs(2))),
                      ],
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: rs(20)),
                  ),
                  title: Text(
                    gameController.playerName.value.isEmpty
                        ? 'settings_player_name'.tr
                        : gameController.playerName.value,
                    style: TextStyle(color: kTextPrimary),
                  ),
                  subtitle: Text(
                    gameController.phoneNumber.value.isEmpty
                        ? 'settings_phone_hint'.tr
                        : gameController.phoneNumber.value,
                    style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: kTextHint, size: rs(16)),
                  onTap: () => Get.toNamed(AppRoutes.profile),
                ),
              ]),
              SizedBox(height: rs(20)),
              _buildSection(context, 'settings_appearance'.tr, [
                _buildSwitch(
                  icon: Icons.dark_mode,
                  label: 'settings_dark_mode'.tr,
                  value: gameController.isDarkMode.value,
                  onChanged: gameController.setDarkMode,
                ),
              ]),
              SizedBox(height: rs(20)),
              _buildSection(context, 'settings_audio'.tr, [
                _buildSwitch(
                  icon: Icons.volume_up,
                  label: 'settings_sound'.tr,
                  value: gameController.soundEnabled.value,
                  onChanged: (val) {
                    gameController.setSoundEnabled(val);
                    SoundService().setSoundEnabled(val);
                  },
                ),
                _buildSwitch(
                  icon: Icons.music_note,
                  label: 'settings_music'.tr,
                  value: gameController.musicEnabled.value,
                  onChanged: (val) {
                    gameController.setMusicEnabled(val);
                    SoundService().setMusicEnabled(val);
                    if (val) {
                      SoundService().startBackgroundMusic();
                    } else {
                      SoundService().stopBackgroundMusic();
                    }
                  },
                ),
              ]),
              SizedBox(height: rs(20)),
              _buildSection(context, 'settings_language'.tr, [
                _buildLanguageSelector(context, gameController),
              ]),
              SizedBox(height: rs(20)),
              _buildSection(context, 'settings_account'.tr, [
                _buildInfoTile(Icons.star, 'settings_status'.tr,
                    gameController.isPremium.value ? 'settings_premium'.tr : 'settings_free'.tr),
                _buildInfoTile(Icons.local_fire_department, 'settings_streak'.tr,
                    'settings_days'.trParams({'n': '${gameController.streakDays.value}'})),
              ]),
              SizedBox(height: rs(20)),
              _buildSection(context, 'settings_about'.tr, [
                _buildInfoTile(Icons.info, 'settings_version'.tr, '1.0.0'),
                _buildInfoTile(Icons.code, 'settings_developer'.tr, 'BrainPlay Team'),
              ]),
              SizedBox(height: rs(20)),
              // Logout button
              Button3D(
                label: gameController.isAr ? 'تسجيل الخروج' : 'Logout',
                icon: Icons.logout,
                color: kRedColor,
                textColor: Colors.white,
                onTap: () => _showLogoutDialog(gameController),
              ),
              SizedBox(height: rs(20)),
            ],
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final isDark = isDarkCtx(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody, fontWeight: FontWeight.bold)),
        SizedBox(height: rs(8)),
        DepthCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(rs(10)),
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(8), offset: Offset(0, rs(2))),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: rs(20)),
      ),
      title: Text(label, style: TextStyle(color: kTextPrimary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: kSecondaryColor,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, GameController gameController) {
    return Padding(
      padding: EdgeInsets.all(rs(12)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(rs(8)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(rs(10)),
              boxShadow: [
                BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(8), offset: Offset(0, rs(2))),
              ],
            ),
            child: Icon(Icons.language, color: Colors.white, size: rs(20)),
          ),
          SizedBox(width: rs(16)),
          Expanded(
            child: Row(
              children: [
                _langButton(context, 'EN', 'en', gameController),
                SizedBox(width: rs(12)),
                _langButton(context, '\u0639\u0631\u0628\u064a', 'ar', gameController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langButton(BuildContext context, String label, String code, GameController gameController) {
    final isSelected = gameController.language.value == code;
    final isDark = isDarkCtx(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => gameController.setLanguage(code),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: rs(10)),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)])
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(rs(10)),
            border: Border.all(color: isSelected ? kPrimaryColor : kBorderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: rs(8),
                      offset: Offset(0, rs(3)),
                    ),
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.5),
                      offset: Offset(0, rs(3)),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: isSelected ? Colors.white : kTextHint,
              fontWeight: FontWeight.bold,
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(rs(10)),
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(8), offset: Offset(0, rs(2))),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: rs(20)),
      ),
      title: Text(label, style: TextStyle(color: kTextPrimary)),
      trailing: Text(value, style: TextStyle(color: kTextHint)),
    );
  }

  void _showLogoutDialog(GameController gc) {
    GameConfirmDialog.show(
      title: gc.isAr ? 'تسجيل الخروج' : 'Logout',
      message: gc.isAr ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?',
      confirmLabel: gc.isAr ? 'خروج' : 'Logout',
      cancelLabel: gc.isAr ? 'إلغاء' : 'Cancel',
      confirmColor: kRedColor,
      onConfirm: () async {
        await ApiService().logout();
        await StorageService().clearAll();
        Get.offAllNamed(AppRoutes.splash);
      },
    );
  }
}
