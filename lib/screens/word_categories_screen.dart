import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../games/word_categories_game.dart';
import '../widgets/banner_ad_widget.dart';

class WordCategoriesScreen extends StatelessWidget {
  const WordCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();

    return Obx(() {
      final isAr = game.isAr;

      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isAr ? '\u062a\u062d\u062f\u064a \u0627\u0644\u062d\u0631\u0648\u0641' : 'Word Categories'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Text('\u{1fa99}', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text('${game.coins.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: WordCategoriesGame(
                language: game.language.value,
                onTimeUpGoBack: () => Get.back(),
                onRoundEnd: (score, correctCount, won) {
                  if (won) {
                    game.addCoins(score);
                  } else {
                    game.loseLife();
                  }
                  game.incrementLevelCounter();

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF2a2a4a),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        won
                            ? (isAr ? '\u0641\u0632\u062a! \u{1f389}' : 'You Won! \u{1f389}')
                            : (isAr ? '\u062e\u0633\u0631\u062a! \u{1f622}' : 'You Lost! \u{1f622}'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            won
                                ? (isAr ? '+$score \u0646\u0642\u0637\u0629' : '+$score points')
                                : (isAr ? '$correctCount/6 \u0635\u062d - \u0644\u0627\u0632\u0645 \u0643\u0644\u0647\u0645 \u064a\u0628\u0642\u0648\u0627 \u0635\u062d!' : '$correctCount/6 correct - All must be correct!'),
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
                                const Text('\u2764\ufe0f', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  '${game.lives.value} ${isAr ? '\u062d\u064a\u0627\u0629 \u0645\u062a\u0628\u0642\u064a\u0629' : 'lives left'}',
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
                            Get.back(); // close dialog
                            Get.off(() => const WordCategoriesScreen());
                          },
                          child: Text(isAr ? '\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649' : 'Play Again'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back(); // close dialog
                            Get.back(); // go home
                          },
                          child: Text(isAr ? '\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0629' : 'Home'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!game.isPremium.value) const BannerAdWidget(),
          ],
        ),
      );
    });
  }
}
