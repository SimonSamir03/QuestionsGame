import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/home_controller.dart';
import '../games/word_categories_game.dart';
import '../services/game_sync_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/animated_bg.dart';

class WordCategoriesScreen extends StatelessWidget {
  const WordCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return Obx(() {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedGameBg(
          particleCount: 10,
          child: SafeArea(
            child: Column(
              children: [
                // Custom app bar with 3D
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
                  child: Row(
                    children: [
                      _BackBtn3D(onTap: () => Get.back()),
                      SizedBox(width: rs(8)),
                      Expanded(
                        child: Text(
                          'word_categories_title'.tr,
                          style: TextStyle(
                            fontSize: kFontSizeH4,
                            fontWeight: FontWeight.bold,
                            color: kTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const CoinsLivesRow(),
                    ],
                  ),
                ),
                Expanded(
                  child: WordCategoriesGame(
                    language: gameController.language.value,
                    onTimeUpGoBack: () => Get.back(),
                    onRoundEnd: (score, correctCount, won) {
                      final wcId = Get.find<HomeController>().games
                          .firstWhereOrNull((g) => g.slug == 'word_categories')?.id;
                      final rewarded = gameController.checkOnlineForReward();
                      if (won && rewarded) {
                        gameController.addXp(score, source: 'word_categories');
                        if (wcId != null) GameSyncService().submitScore(gameId: wcId, score: score);
                      } else if (!won) {
                        gameController.loseLife();
                      }
                      gameController.incrementLevelCounter();

                      GameResultDialog.show(
                        context: context,
                        won: won,
                        coinsEarned: won ? score : 0,
                        onPlayAgain: () => Get.off(() => const WordCategoriesScreen()),
                        onHome: () => Get.back(),
                      );
                    },
                  ),
                ),
                if (!gameController.isPremium.value) const BannerAdWidget(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _BackBtn3D extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn3D({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkCtx(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()]
                : [Colors.white, const Color(0xFFF5F3FF)],
          ),
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, rs(2)),
              blurRadius: rs(1),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, color: kTextSecondary, size: rs(20)),
      ),
    );
  }
}
