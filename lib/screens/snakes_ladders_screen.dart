import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/snakes_ladders_controller.dart';
import '../services/sound_service.dart';
import '../games/snakes_ladders_game.dart';
import '../services/ads_service.dart';
import '../services/game_sync_service.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/game_result_dialog.dart';

class SnakesLaddersModeScreen extends StatelessWidget {
  const SnakesLaddersModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();

    return Obx(() {
      final isAr = gc.isAr;
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: kBgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: kTextPrimary,
            title: Text(isAr ? 'سلم وثعبان' : 'Snakes & Ladders'),
            centerTitle: true,
            actions: const [CoinsLivesRow()],
          ),
          body: AnimatedGameBg(
            child: Padding(
              padding: EdgeInsets.all(rs(20)),
              child: Column(
                children: [
                  Text(
                    isAr ? 'اختر وضع اللعب' : 'Choose Game Mode',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: kFontSizeH3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: rs(24)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.smart_toy,
                    title: isAr ? 'ضد الكمبيوتر' : 'vs Computer',
                    subtitle: isAr ? 'العب ضد الذكاء الاصطناعي' : 'Play against AI',
                    color: Colors.orange,
                    onTap: () => _startGame(SnakesLaddersMode.vsAi),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.people,
                    title: isAr ? 'لاعبين' : '2 Players',
                    subtitle: isAr ? 'العب مع صديق على نفس الجهاز' : 'Play with a friend locally',
                    color: Colors.green,
                    onTap: () => _startGame(SnakesLaddersMode.local2),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.group,
                    title: isAr ? '3 لاعبين' : '3 Players',
                    subtitle: isAr ? 'العب مع أصدقائك' : 'Play with friends',
                    color: Colors.blue,
                    onTap: () => _startGame(SnakesLaddersMode.local3),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.groups,
                    title: isAr ? '4 لاعبين' : '4 Players',
                    subtitle: isAr ? 'الوضع الكلاسيكي' : 'Classic mode',
                    color: Colors.purple,
                    onTap: () => _startGame(SnakesLaddersMode.local4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildModeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return DepthCard(
      accentColor: color,
      elevation: 0.8,
      borderRadius: 16,
      padding: EdgeInsets.all(rs(16)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkCtx(context)
            ? [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.06),
              ]
            : [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.03),
              ],
      ),
      onTap: onTap,
      child: Row(
        children: [
          // 3D icon container with depth shadow
          Container(
            width: rs(48),
            height: rs(48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rs(14)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.15)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  offset: Offset(0, rs(3)),
                  blurRadius: rs(6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: rs(26)),
          ),
          SizedBox(width: rs(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  color: kTextPrimary,
                  fontSize: kFontSizeBodyLarge,
                  fontWeight: FontWeight.bold,
                )),
                SizedBox(height: rs(2)),
                Text(subtitle, style: TextStyle(
                  color: kTextHint,
                  fontSize: kFontSizeCaption,
                )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: kTextHint, size: rs(16)),
        ],
      ),
    );
  }

  void _startGame(SnakesLaddersMode mode) {
    SoundService().playClick();
    Get.to(
      () => _SnakesLaddersGameScreen(mode: mode),
      transition: Transition.rightToLeft,
    );
  }
}

class _SnakesLaddersGameScreen extends StatelessWidget {
  final SnakesLaddersMode mode;
  const _SnakesLaddersGameScreen({required this.mode});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();

    return Obx(() => Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextPrimary,
        title: Text(gc.isAr ? 'سلم وثعبان' : 'Snakes & Ladders'),
        centerTitle: true,
        actions: const [CoinsLivesRow()],
      ),
      body: AnimatedGameBg(
        showParticles: false,
        child: Column(
          children: [
            Expanded(
              child: SnakesLaddersGame(
                mode: mode,
                language: gc.language.value,
                onGameEnd: (winnerIdx) {
                  final gameId = Get.find<HomeController>().games.firstWhereOrNull((g) => g.slug == 'snakes_ladders')?.id;
                  final isPlayerWin = mode == SnakesLaddersMode.vsAi && winnerIdx == 0;
                  final isLocalGame = mode != SnakesLaddersMode.vsAi;

                  final rewarded = gc.checkOnlineForReward();
                  if (isPlayerWin && rewarded) {
                    gc.addXp(gc.xpPerGameWin, source: 'snakes_win');
                    if (gameId != null) GameSyncService().submitScore(gameId: gameId, score: gc.xpPerGameWin);
                  } else if (mode == SnakesLaddersMode.vsAi && !isPlayerWin) {
                    gc.loseLife();
                  }
                  gc.incrementLevelCounter();

                  if (!gc.isPremium.value) {
                    AdsService().showInterstitial();
                  }

                  GameResultDialog.show(
                    context: context,
                    won: isPlayerWin || isLocalGame,
                    coinsEarned: 0,
                    title: gc.isAr ? 'انتهت اللعبة!' : 'Game Over!',
                    onPlayAgain: () => Get.off(() => _SnakesLaddersGameScreen(mode: mode)),
                    onHome: () => Get.back(),
                  );
                },
              ),
            ),
            if (!gc.isPremium.value) const BannerAdWidget(),
          ],
        ),
      ),
    ));
  }
}
