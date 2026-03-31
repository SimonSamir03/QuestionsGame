import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/home_controller.dart';
import '../games/ludo_game.dart';
import '../models/ludo_models.dart';
import '../services/ads_service.dart';
import '../services/game_sync_service.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/game_result_dialog.dart';

class LudoModeScreen extends StatelessWidget {
  const LudoModeScreen({super.key});

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
            title: Text(isAr ? 'لودو' : 'Ludo'),
            centerTitle: true,
            actions: const [CoinsLivesRow()],
          ),
          body: AnimatedGameBg(
            child: Padding(
              padding: EdgeInsets.all(rs(20)),
              child: Column(
                children: [
                  // Header
                  Text(
                    isAr ? 'اختر وضع اللعب' : 'Choose Game Mode',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: kFontSizeH3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: rs(24)),

                  // Mode cards with DepthCard
                  _buildModeCard(
                    context: context,
                    icon: Icons.smart_toy,
                    title: isAr ? 'ضد الكمبيوتر' : 'vs Computer',
                    subtitle: isAr ? 'العب ضد الذكاء الاصطناعي' : 'Play against AI',
                    color: Colors.orange,
                    onTap: () => _startGame(context, LudoMode.vsAi),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.people,
                    title: isAr ? 'لاعبين' : '2 Players',
                    subtitle: isAr ? 'العب مع صديق على نفس الجهاز' : 'Play with a friend locally',
                    color: Colors.green,
                    onTap: () => _startGame(context, LudoMode.local2),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.group,
                    title: isAr ? '3 لاعبين' : '3 Players',
                    subtitle: isAr ? 'العب مع أصدقائك' : 'Play with friends',
                    color: Colors.blue,
                    onTap: () => _startGame(context, LudoMode.local3),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.groups,
                    title: isAr ? '4 لاعبين' : '4 Players',
                    subtitle: isAr ? 'الوضع الكلاسيكي' : 'Classic mode',
                    color: Colors.purple,
                    onTap: () => _startGame(context, LudoMode.local4),
                  ),
                  SizedBox(height: rs(12)),
                  _buildModeCard(
                    context: context,
                    icon: Icons.wifi,
                    title: isAr ? 'أونلاين' : 'Online',
                    subtitle: isAr ? 'العب مع لاعبين عبر الإنترنت' : 'Play with others online',
                    color: Colors.red,
                    onTap: () {
                      Get.snackbar(
                        isAr ? 'قريبًا' : 'Coming Soon',
                        isAr ? 'اللعب الأونلاين قريبًا!' : 'Online play coming soon!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: kCardColor,
                        colorText: kTextPrimary,
                      );
                    },
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

  void _startGame(BuildContext context, LudoMode mode) {
    final gc = Get.find<GameController>();
    final isAr = gc.isAr;
    final selectedColor = LudoColor.red.obs;

    Get.dialog(
      Dialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(20))),
        child: Padding(
          padding: EdgeInsets.all(rs(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAr ? 'اختر لونك' : 'Choose Your Color',
                style: TextStyle(color: kTextPrimary, fontSize: kFontSizeH3, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: rs(20)),
              Obx(() => Wrap(
                spacing: rs(12),
                runSpacing: rs(12),
                alignment: WrapAlignment.center,
                children: LudoColor.values.map((color) {
                  final isSelected = selectedColor.value == color;
                  return GestureDetector(
                    onTap: () => selectedColor.value = color,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: rs(50),
                      height: rs(50),
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected ? [
                          // 3D depth
                          BoxShadow(
                            color: HSLColor.fromColor(color.color)
                                .withLightness((HSLColor.fromColor(color.color).lightness - 0.2).clamp(0.0, 1.0))
                                .toColor(),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                          // Neon glow
                          BoxShadow(color: color.color.withValues(alpha: 0.5), blurRadius: 12),
                          BoxShadow(color: color.color.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 2),
                        ] : [
                          BoxShadow(
                            color: HSLColor.fromColor(color.color)
                                .withLightness((HSLColor.fromColor(color.color).lightness - 0.2).clamp(0.0, 1.0))
                                .toColor(),
                            offset: const Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: rs(28))
                          : null,
                    ),
                  );
                }).toList(),
              )),
              SizedBox(height: rs(24)),
              Button3D(
                label: isAr ? 'ابدأ' : 'Start',
                color: kPrimaryColor,
                fontSize: kFontSizeBodyLarge.toDouble(),
                onTap: () {
                  Get.back();
                  Get.to(
                    () => _LudoGameScreen(mode: mode, playerColor: selectedColor.value),
                    transition: Transition.rightToLeft,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LudoGameScreen extends StatelessWidget {
  final LudoMode mode;
  final LudoColor playerColor;
  const _LudoGameScreen({required this.mode, this.playerColor = LudoColor.red});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();

    return Obx(() => Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextPrimary,
        title: Text(gc.isAr ? 'لودو' : 'Ludo'),
        centerTitle: true,
        actions: const [CoinsLivesRow()],
      ),
      body: AnimatedGameBg(
        showParticles: false,
        child: Column(
          children: [
            Expanded(
              child: LudoGame(
                mode: mode,
                playerColor: playerColor,
                language: gc.language.value,
                onGameEnd: (winner) {
                  final ludoId = Get.find<HomeController>().games.firstWhereOrNull((g) => g.slug == 'ludo')?.id;
                  final isPlayerWin = mode == LudoMode.vsAi && winner == playerColor;
                  final isLocalGame = mode != LudoMode.vsAi && mode != LudoMode.online;

                  final rewarded = gc.checkOnlineForReward();
                  if (isPlayerWin && rewarded) {
                    gc.addXp(gc.xpPerGameWin, source: 'ludo_win');
                    if (ludoId != null) GameSyncService().submitScore(gameId: ludoId, score: gc.xpPerGameWin);
                  } else if (mode == LudoMode.vsAi && !isPlayerWin) {
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
                    title: '${winner.label(gc.isAr)} ${gc.isAr ? "فاز!" : "wins!"}',
                    onPlayAgain: () => Get.off(() => _LudoGameScreen(mode: mode)),
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
