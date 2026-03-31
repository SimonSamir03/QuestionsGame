import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../models/question_model.dart';
import '../controllers/game_controller.dart';
import '../services/ads_service.dart';
import '../services/game_sync_service.dart';
import '../services/sound_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/animated_bg.dart';
import '../games/word_game.dart';
import '../games/quiz_game.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  final int gameId;
  final String gameSlug;
  final Question question;
  final int levelNumber;
  final List<Question>? questions;
  final int? currentIndex;

  const GameScreen.quiz({
    super.key,
    required this.gameId,
    required this.gameSlug,
    required this.question,
    required this.levelNumber,
    this.questions,
    this.currentIndex,
  });

  String get _gameSlug => gameSlug;
  String get _difficulty => question.difficulty;

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final diffColor = _getDifficultyColor(_difficulty);

    return Obx(() => Scaffold(
      body: AnimatedGameBg(
        particleCount: 10,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with 3D
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
                child: Row(
                  children: [
                    _AppBarButton3D(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Get.back(),
                    ),
                    SizedBox(width: rs(10)),
                    Expanded(
                      child: _LevelBadge3D(
                        levelNumber: levelNumber,
                        difficulty: _difficulty,
                        diffColor: diffColor,
                        isOnline: question.id > 0,
                      ),
                    ),
                    SizedBox(width: rs(10)),
                    const CoinsLivesRow(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(rs(16)),
                    child: _buildGame(gameController),
                  ),
                ),
              ),
              Obx(() => !gameController.isPremium.value
                  ? const BannerAdWidget()
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildGame(GameController gameController) {
    if (gameId == 1) {
      return WordGame(question: question, onAnswer: (correct) => _handleAnswer(correct, gameController));
    }
    return QuizGame(question: question, onAnswer: (correct) => _handleAnswer(correct, gameController));
  }

  void _handleAnswer(bool correct, GameController gameController) async {
    final sync = GameSyncService();

    if (question.id > 0) {
      sync.submitAnswer(questionId: question.id, answer: question.answer, levelNumber: levelNumber);
    }

    final rewarded = gameController.checkOnlineForReward();
    if (correct) {
      final alreadyCompleted = currentIndex != null &&
          gameController.isLevelCompleted(_gameSlug, _difficulty, currentIndex!);
      if (!alreadyCompleted && rewarded) {
        gameController.addXp(gameController.xpPerCorrectAnswer, source: 'quiz_correct');
        gameController.incrementLevelCounter();
        if (currentIndex != null) {
          gameController.completeLevel(_gameSlug, _difficulty, currentIndex!);
        }
        sync.submitScore(gameId: gameId, score: 10);
        sync.saveProgress(gameId: gameId, level: levelNumber, difficulty: _difficulty, score: 10);
      }
      SoundService().playCorrect();
    } else {
      gameController.loseLife();
    }

    if (gameController.shouldShowInterstitial && !gameController.isPremium.value) {
      await AdsService().showInterstitial();
    }

    Get.off(
      () => ResultScreen.quiz(
        isCorrect: correct,
        gameId: gameId,
        gameSlug: gameSlug,
        question: question,
        levelNumber: levelNumber,
        questions: questions,
        currentIndex: currentIndex,
      ),
      transition: Transition.fade,
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return kSecondaryColor;
      case 'medium': return kYellowColor;
      case 'hard': return kRedColor;
      case 'expert': return kPrimaryColor;
      default: return Colors.white24;
    }
  }
}

class _AppBarButton3D extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarButton3D({required this.icon, required this.onTap});

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
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.06),
              blurRadius: rs(8),
            ),
          ],
        ),
        child: Icon(icon, color: kTextSecondary, size: rs(20)),
      ),
    );
  }
}

class _LevelBadge3D extends StatelessWidget {
  final int levelNumber;
  final String difficulty;
  final Color diffColor;
  final bool isOnline;

  const _LevelBadge3D({
    required this.levelNumber,
    required this.difficulty,
    required this.diffColor,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(14), vertical: rs(6)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            diffColor.withValues(alpha: 0.2),
            diffColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(rs(14)),
        border: Border.all(color: diffColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: diffColor.withValues(alpha: 0.15),
            blurRadius: rs(8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'level_label'.trParams({'n': '$levelNumber'}),
            style: TextStyle(
              fontSize: kFontSizeBody,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          SizedBox(width: rs(8)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: rs(8), vertical: rs(2)),
            decoration: BoxDecoration(
              color: diffColor,
              borderRadius: BorderRadius.circular(rs(8)),
              boxShadow: [
                BoxShadow(
                  color: diffColor.withValues(alpha: 0.4),
                  blurRadius: rs(4),
                ),
              ],
            ),
            child: Text(
              difficulty.toUpperCase(),
              style: TextStyle(
                fontSize: kFontSizeTiny,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: rs(6)),
          Container(
            width: rs(8),
            height: rs(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.amber,
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? Colors.green : Colors.amber).withValues(alpha: 0.5),
                  blurRadius: rs(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
