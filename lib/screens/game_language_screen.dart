import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import 'level_screen.dart';
import 'crossword_screen.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class GameLanguageScreen extends StatelessWidget {
  final int gameId;
  final String gameSlug;

  const GameLanguageScreen({super.key, required this.gameId, required this.gameSlug});

  static const _gameLabels = {
    'word_rearrange': 'game_word',
    'quiz': 'game_quiz',
    'crossword': 'word_games_title',
    'classic_crossword': 'classic_crossword',
  };

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final isAr = gameController.isAr;
    final labelKey = _gameLabels[gameSlug] ?? gameSlug;

    return Obx(() {
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
            title: Text(labelKey.tr),
            centerTitle: true,
          ),
          body: AnimatedGameBg(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(rs(32)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\u{1f30d}', style: TextStyle(fontSize: fs(64))),
                    SizedBox(height: rs(24)),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          kBrandGradient.createShader(bounds),
                      child: Text(
                        'choose_play_language'.tr,
                        style: TextStyle(
                          fontSize: kFontSizeH2,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: rs(8)),
                    Text(
                      'choose_play_language_sub'.tr,
                      style: TextStyle(fontSize: kFontSizeBody, color: kTextHint),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: rs(48)),
                    _buildLanguageButton(
                      context: context,
                      flag: '\u{1f1ec}\u{1f1e7}',
                      label: 'English',
                      subtitle: 'Play in English',
                      langCode: 'en',
                      color: kPrimaryColor,
                    ),
                    SizedBox(height: rs(16)),
                    _buildLanguageButton(
                      context: context,
                      flag: '\u{1f1ea}\u{1f1ec}',
                      label: '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
                      subtitle: '\u0627\u0644\u0639\u0628 \u0628\u0627\u0644\u0639\u0631\u0628\u064a',
                      langCode: 'ar',
                      color: kSecondaryColor,
                    ),
                  ],
                ),
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

  void _onLanguageSelected(String langCode) {
    switch (gameSlug) {
      case 'crossword':
      case 'classic_crossword':
        Get.off(() => CrosswordScreen(language: langCode, gameId: gameId), transition: Transition.rightToLeft);
        break;
      default:
        Get.off(() => LevelScreen(gameId: gameId, gameSlug: gameSlug, gameLanguage: langCode), transition: Transition.rightToLeft);
    }
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required String flag,
    required String label,
    required String subtitle,
    required String langCode,
    Color color = kPrimaryColor,
  }) {
    final isDark = isDarkCtx(context);
    return GestureDetector(
      onTap: () => _onLanguageSelected(langCode),
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
                    Text(label,
                        style: TextStyle(
                            fontSize: kFontSizeH4,
                            fontWeight: FontWeight.bold,
                            color: kTextPrimary)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: kFontSizeBody, color: kTextHint)),
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
