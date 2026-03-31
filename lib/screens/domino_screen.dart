import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/domino_game_controller.dart';
import '../controllers/home_controller.dart';
import '../games/domino_game.dart';
import '../services/game_sync_service.dart';
import '../widgets/animated_bg.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/game_result_dialog.dart';

class DominoScreen extends StatelessWidget {
  const DominoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return Obx(() => Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextPrimary,
        title: Text('game_domino'.tr),
        centerTitle: true,
        actions: [
          const CoinsLivesRow(),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: AnimatedGameBg(
        showParticles: true,
        particleCount: 12,
        child: Column(
          children: [
            Expanded(
              child: DominoGame(
                language: gameController.language.value,
                onGameEnd: (won) {
                  final domCtrl = Get.find<DominoGameController>(tag: 'domino_game');
                  final dominoId = Get.find<HomeController>().games.firstWhereOrNull((g) => g.slug == 'domino')?.id;
                  final rewarded = gameController.checkOnlineForReward();
                  if (won && rewarded) {
                    gameController.addXp(gameController.xpPerGameWin, source: 'domino_win');
                    if (dominoId != null) GameSyncService().submitScore(gameId: dominoId, score: gameController.xpPerGameWin, timeTaken: domCtrl.elapsedSeconds);
                  } else if (!won) {
                    gameController.loseLife();
                  }
                  gameController.incrementLevelCounter();

                  GameResultDialog.show(
                    context: context,
                    won: won,
                    coinsEarned: 20,
                    onPlayAgain: () => Get.off(() => const DominoScreen()),
                    onHome: () => Get.back(),
                  );
                },
              ),
            ),
            Obx(() {
              final domCtrl = Get.find<DominoGameController>(tag: 'domino_game');
              final gameOver = domCtrl.gameState.value != GameState.playing;
              if (gameOver || gameController.isPremium.value) return const SizedBox.shrink();
              return const BannerAdWidget();
            }),
          ],
        ),
      ),
    ));
  }
}
