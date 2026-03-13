import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_model.dart';
import '../services/game_state.dart';
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
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
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
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${gameState.coins}', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                const Text('❤️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${gameState.lives}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGame(context, gameState),
            ),
          ),
          if (!gameState.isPremium) const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context, GameState gameState) {
    switch (puzzle.type) {
      case 'word':
        return WordGame(puzzle: puzzle, onAnswer: (correct) => _handleAnswer(context, correct, gameState));
      case 'quiz':
        return QuizGame(puzzle: puzzle, onAnswer: (correct) => _handleAnswer(context, correct, gameState));
      case 'count':
        return CountGame(puzzle: puzzle, onAnswer: (correct) => _handleAnswer(context, correct, gameState));
      default:
        return Center(child: Text('Unknown game type: ${puzzle.type}'));
    }
  }

  void _handleAnswer(BuildContext context, bool correct, GameState gameState) async {
    if (correct) {
      gameState.addCoins(10);
      gameState.incrementLevelCounter();
      // Mark level as completed for progressive locking
      if (currentIndex != null) {
        gameState.completeLevel(puzzle.type, puzzle.difficulty, currentIndex!);
      }
      SoundService().playCorrect();
    } else {
      gameState.loseLife();
    }

    // Show interstitial ad every 3 levels
    if (gameState.shouldShowInterstitial && !gameState.isPremium) {
      await AdsService().showInterstitial();
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ResultScreen(
            isCorrect: correct,
            puzzle: puzzle,
            levelNumber: levelNumber,
            puzzles: puzzles,
            currentIndex: currentIndex,
          ),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    }
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
