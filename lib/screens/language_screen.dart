import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGameBg(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(rs(32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeSlideIn(
                    child: Text('\u{1f30d}', style: TextStyle(fontSize: fs(64))),
                  ),
                  SizedBox(height: rs(24)),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: ShaderMask(
                      shaderCallback: (bounds) => kBrandGradient.createShader(bounds),
                      child: Text(
                        'Choose Language',
                        style: TextStyle(fontSize: kFontSizeH2, fontWeight: FontWeight.bold, color: kTextPrimary),
                      ),
                    ),
                  ),
                  SizedBox(height: rs(8)),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      '\u0627\u062e\u062a\u0631 \u0627\u0644\u0644\u063a\u0629',
                      style: TextStyle(fontSize: kFontSizeH3, color: kTextHint),
                    ),
                  ),
                  SizedBox(height: rs(48)),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: _buildLanguageButton(
                      context: context,
                      flag: '\u{1f1ec}\u{1f1e7}',
                      label: 'English',
                      subtitle: 'Play in English',
                      langCode: 'en',
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: rs(16)),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: _buildLanguageButton(
                      context: context,
                      flag: '\u{1f1ea}\u{1f1ec}',
                      label: '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
                      subtitle: '\u0627\u0644\u0639\u0628 \u0628\u0627\u0644\u0639\u0631\u0628\u064a',
                      langCode: 'ar',
                      color: kSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required String flag,
    required String label,
    required String subtitle,
    required String langCode,
    required Color color,
  }) {
    final isDark = isDarkCtx(context);
    return AnimatedButton(
      onTap: () {
        final gameController = Get.find<GameController>();
        gameController.setLanguage(langCode);
        Get.offAllNamed(AppRoutes.home);
      },
      child: Container(
        width: double.infinity,
        height: rs(80),
        padding: EdgeInsets.symmetric(horizontal: rs(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.22).toColor()]
                : [Colors.white, Colors.white.withValues(alpha: 0.95)],
          ),
          borderRadius: BorderRadius.circular(rs(20)),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            // 3D base shadow
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.2),
              offset: Offset(0, rs(4)),
              blurRadius: 0,
            ),
            // Glow
            BoxShadow(
              color: color.withValues(alpha: 0.12),
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
              height: rs(30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(rs(20))),
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
            Row(
              children: [
                Text(flag, style: TextStyle(fontSize: fs(36))),
                SizedBox(width: rs(16)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: kFontSizeH4, fontWeight: FontWeight.bold, color: kTextPrimary)),
                    Text(subtitle, style: TextStyle(fontSize: kFontSizeBody, color: kTextHint)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(rs(6)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(rs(8)),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: rs(6), offset: Offset(0, rs(2))),
                    ],
                  ),
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: rs(16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
