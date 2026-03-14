import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/puzzle_model.dart';
import '../controllers/game_controller.dart';
import '../services/ads_service.dart';
import '../services/sound_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../games/word_game.dart';
import '../games/quiz_game.dart';
import '../games/count_game.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  final Puzzle puzzle;
  final int levelNumber;
  final List<Puzzle>? puzzles;
  final int? currentIndex;

  const GameScreen({
    super.key,
    required this.puzzle,
    required this.levelNumber,
    this.puzzles,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() {
          final isAr = game.isAr;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isAr ? 'مستوى' : 'Level'} $levelNumber',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(puzzle.difficulty),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  puzzle.difficulty.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(() => Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${game.coins.value}', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                const Text('❤️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${game.lives.value}', style: const TextStyle(fontSize: 14)),
              ],
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGame(game),
            ),
          ),
          Obx(() => !game.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildGame(GameController game) {
    switch (puzzle.type) {
      case 'word':
        return WordGame(puzzle: puzzle, onAnswer: (correct) => _handleAnswer(correct, game));
      case 'quiz':
        return QuizGame(puzzle: puzzle, onAnswer: (correct) => _handleAnswer(correct, game));
      case 'count':
        return CountGame(puzzle: puzzle, onAnswer: (correct) => _handleAnswer(correct, game));
      default:
        return Center(child: Text('Unknown game type: ${puzzle.type}'));
    }
  }

  void _handleAnswer(bool correct, GameController game) async {
    if (correct) {
      game.addCoins(10);
      game.incrementLevelCounter();
      if (currentIndex != null) {
        game.completeLevel(puzzle.type, puzzle.difficulty, currentIndex!);
      }
      SoundService().playCorrect();
    } else {
      game.loseLife();
    }

    // Show interstitial ad every 3 levels
    if (game.shouldShowInterstitial && !game.isPremium.value) {
      await AdsService().showInterstitial();
    }

    Get.off(
      () => ResultScreen(
        isCorrect: correct,
        puzzle: puzzle,
        levelNumber: levelNumber,
        puzzles: puzzles,
        currentIndex: currentIndex,
      ),
      transition: Transition.fade,
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return const Color(0xFF4ECDC4);
      case 'medium': return const Color(0xFFFFBE0B);
      case 'hard': return const Color(0xFFFF6B6B);
      case 'expert': return const Color(0xFF6C63FF);
      default: return Colors.white24;
    }
  }
}
