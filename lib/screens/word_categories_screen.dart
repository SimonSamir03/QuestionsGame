import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../games/word_categories_game.dart';
import '../services/game_state.dart';
import '../widgets/banner_ad_widget.dart';

class WordCategoriesScreen extends StatelessWidget {
  const WordCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isAr ? 'تحدي الحروف' : 'Word Categories'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text('${gameState.coins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: WordCategoriesGame(
              language: gameState.language,
              onTimeUpGoBack: () => Navigator.of(context).pop(),
              onRoundEnd: (score, correctCount, won) {
                if (won) {
                  gameState.addCoins(score);
                } else {
                  gameState.loseLife();
                }
                gameState.incrementLevelCounter();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF2a2a4a),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      won
                          ? (isAr ? 'فزت! 🎉' : 'You Won! 🎉')
                          : (isAr ? 'خسرت! 😢' : 'You Lost! 😢'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          won
                              ? (isAr ? '+$score نقطة' : '+$score points')
                              : (isAr ? '$correctCount/6 صح - لازم كلهم يبقوا صح!' : '$correctCount/6 correct - All must be correct!'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: won ? Colors.amber : Colors.white70,
                            fontSize: 16,
                            fontWeight: won ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (!won) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('❤️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '${gameState.lives} ${isAr ? 'حياة متبقية' : 'lives left'}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const WordCategoriesScreen()),
                          );
                        },
                        child: Text(isAr ? 'العب مرة أخرى' : 'Play Again'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text(isAr ? 'الرئيسية' : 'Home'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (!gameState.isPremium) const BannerAdWidget(),
        ],
      ),
    );
  }
}
