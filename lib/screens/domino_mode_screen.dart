import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_bg.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/depth_card.dart';

class DominoModeScreen extends StatelessWidget {
  const DominoModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextPrimary,
        title: Text('game_domino'.tr),
        centerTitle: true,
        actions: [const CoinsLivesRow()],
      ),
      extendBodyBehindAppBar: false,
      body: AnimatedGameBg(
        showParticles: true,
        particleCount: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rs(24), vertical: rs(32)),
          child: Column(
            children: [
              Text(
                'domino_choose_mode'.tr,
                style: TextStyle(
                  fontSize: kFontSizeH3,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
              SizedBox(height: rs(32)),
              _buildModeCard(
                title: 'domino_classic'.tr,
                subtitle: 'domino_classic_sub'.tr,
                icon: Icons.extension,
                color: kOrangeColor,
                onTap: () => Get.toNamed(AppRoutes.dominoClassic),
              ),
              SizedBox(height: rs(16)),
              _buildModeCard(
                title: 'domino_all_fives'.tr,
                subtitle: 'domino_all_fives_sub'.tr,
                icon: Icons.star,
                color: kPrimaryColor,
                onTap: () => Get.toNamed(AppRoutes.dominoAllFives),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return DepthCard(
      onTap: onTap,
      padding: EdgeInsets.all(rs(20)),
      borderRadius: 20,
      accentColor: color,
      elevation: 1.2,
      child: Row(
        children: [
          // 3D icon container with gradient + glow
          Container(
            width: rs(56),
            height: rs(56),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.25),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(kRadiusS),
              boxShadow: [
                // Inner neon glow
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: rs(10),
                  spreadRadius: rs(1),
                ),
                // 3D depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: Offset(0, rs(2)),
                  blurRadius: rs(4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: rs(28)),
          ),
          SizedBox(width: rs(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: kFontSizeH4,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
                SizedBox(height: rs(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: kFontSizeCaption,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(rs(8)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: rs(6),
                ),
              ],
            ),
            child: Icon(Icons.arrow_forward_ios, color: color, size: rs(16)),
          ),
        ],
      ),
    );
  }
}
