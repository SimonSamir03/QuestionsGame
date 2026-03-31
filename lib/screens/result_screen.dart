import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../models/question_model.dart';
import '../controllers/result_controller.dart';
import '../routes/app_routes.dart';
import '../services/sound_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/count_up_text.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  final bool isCorrect;
  final int gameId;
  final String gameSlug;
  final Question? question;
  final int levelNumber;
  final List<Question>? questions;
  final int? currentIndex;

  const ResultScreen({
    super.key,
    required this.isCorrect,
    required this.gameId,
    required this.gameSlug,
    required this.levelNumber,
    this.currentIndex,
  })  : question = null,
        questions = null;

  const ResultScreen.quiz({
    super.key,
    required this.isCorrect,
    required this.gameId,
    required this.gameSlug,
    required Question this.question,
    required this.levelNumber,
    this.questions,
    this.currentIndex,
  });

  bool get _isQuiz => question != null;
  int get _nextListLength => _isQuiz ? (questions?.length ?? 0) : 0;

  @override
  Widget build(BuildContext context) {
    final resultController = Get.put(ResultController(isCorrect: isCorrect));
    return Obx(() {
      final game = resultController.game;
      return Scaffold(
        body: AnimatedGameBg(
          particleCount: isCorrect ? 20 : 8,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: resultController.confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [kPrimaryColor, kSecondaryColor, Colors.amber, Colors.pink, Colors.orange],
                ),
              ),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(rs(32)),
                    child: ScaleTransition(
                      scale: resultController.scaleAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Emoji with glow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: (isCorrect ? kGreenColor : kRedColor).withValues(alpha: 0.3),
                                  blurRadius: rs(30),
                                  spreadRadius: rs(5),
                                ),
                              ],
                            ),
                            child: Text(
                              isCorrect ? '\u{1F389}' : '\u{1F622}',
                              style: TextStyle(fontSize: fs(80)),
                            ),
                          ),
                          SizedBox(height: rs(16)),
                          Text(
                            isCorrect ? 'result_correct'.tr : 'result_wrong'.tr,
                            style: TextStyle(
                              fontSize: kFontSizeH2,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                              shadows: [
                                Shadow(
                                  color: (isCorrect ? kGreenColor : kRedColor).withValues(alpha: 0.4),
                                  blurRadius: rs(12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: rs(16)),
                          // Stats card with 3D
                          DepthCard(
                            accentColor: isCorrect ? kGreenColor : kRedColor,
                            padding: EdgeInsets.all(rs(20)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('\u{1FA99}', style: TextStyle(fontSize: fs(24))),
                                    SizedBox(width: rs(8)),
                                    CountUpText(
                                      end: isCorrect
                                          ? (resultController.doubledCoins.value ? 20 : 10)
                                          : 0,
                                      prefix: '+',
                                      style: TextStyle(
                                        fontSize: kFontSizeH2,
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect ? Colors.amber : kTextHint,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: rs(8)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('\u2764\ufe0f', style: TextStyle(fontSize: fs(18))),
                                    SizedBox(width: rs(6)),
                                    Text(
                                      'lives_count'.trParams({'n': '${game.lives.value}'}),
                                      style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: rs(24)),
                          if (isCorrect && !resultController.doubledCoins.value && !game.isPremium.value)
                            _buildAdButton(
                              icon: Icons.play_circle,
                              label: 'btn_double_coins'.tr,
                              color: Colors.amber,
                              onTap: resultController.doubleCoinsReward,
                            ),
                          if (!isCorrect && game.lives.value <= 0)
                            _buildAdButton(
                              icon: Icons.play_circle,
                              label: 'btn_watch_continue'.tr,
                              color: kSecondaryColor,
                              onTap: resultController.continueAfterLoss,
                            ),
                          SizedBox(height: rs(16)),
                          if (isCorrect)
                            Button3D(
                              label: (currentIndex != null && currentIndex! + 1 < _nextListLength)
                                  ? 'btn_next_level'.tr
                                  : 'btn_back_home'.tr,
                              color: kPrimaryColor,
                              onTap: () {
                                SoundService().playClick();
                                if (currentIndex != null) {
                                  int? nextIndex;
                                  for (int i = currentIndex! + 1; i < _nextListLength; i++) {
                                    if (!game.isLevelCompleted(gameSlug, question!.difficulty, i)) {
                                      nextIndex = i;
                                      break;
                                    }
                                  }
                                  if (nextIndex != null) {
                                    if (game.shouldShowMysteryBox) {
                                      Get.toNamed(AppRoutes.mysteryBox)?.then((_) {
                                        Get.off(() => _buildNextGameScreen(nextIndex!));
                                      });
                                      return;
                                    }
                                    Get.off(() => _buildNextGameScreen(nextIndex!));
                                    return;
                                  }
                                }
                                Get.offAllNamed(AppRoutes.home);
                              },
                            ),
                          if (!isCorrect && game.lives.value > 0)
                            Button3D(
                              label: 'btn_try_again'.tr,
                              color: kRedColor,
                              onTap: () => Get.off(() => _buildCurrentGameScreen()),
                            ),
                          SizedBox(height: rs(10)),
                          TextButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.home),
                            child: Text(
                              'btn_home'.tr,
                              style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNextGameScreen(int nextIndex) {
    return GameScreen.quiz(
      gameId: gameId,
      gameSlug: gameSlug,
      question: questions![nextIndex],
      levelNumber: nextIndex + 1,
      questions: questions,
      currentIndex: nextIndex,
    );
  }

  Widget _buildCurrentGameScreen() {
    return GameScreen.quiz(
      gameId: gameId,
      gameSlug: gameSlug,
      question: question!,
      levelNumber: levelNumber,
      questions: questions,
      currentIndex: currentIndex,
    );
  }

  Widget _buildAdButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(12)),
      child: AnimatedButton(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: rs(48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rs(14)),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: rs(8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: rs(20)),
              SizedBox(width: rs(8)),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: kFontSizeBody)),
            ],
          ),
        ),
      ),
    );
  }
}
