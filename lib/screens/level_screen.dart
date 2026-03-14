import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/level_controller.dart';
import '../controllers/game_controller.dart';
import 'game_screen.dart';

class LevelScreen extends StatelessWidget {
  final String gameType;

  const LevelScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(LevelController(gameType: gameType), tag: 'lc_$gameType');
    final game = Get.find<GameController>();

    final diffColors = {
      'easy': const Color(0xFF4ECDC4),
      'medium': const Color(0xFFFFBE0B),
      'hard': const Color(0xFFFF6B6B),
      'expert': const Color(0xFF6C63FF),
    };

    final difficulties = ['easy', 'medium', 'hard', 'expert'];

    return Obx(() {
      final isAr = game.isAr;

      final diffLabels = isAr
          ? {'easy': 'سهل', 'medium': 'متوسط', 'hard': 'صعب', 'expert': 'خبير'}
          : {'easy': 'Easy', 'medium': 'Medium', 'hard': 'Hard', 'expert': 'Expert'};

      final gameLabels = isAr
          ? {'word': 'ترتيب الحروف', 'quiz': 'أسئلة سريعة', 'count': 'عد الأشكال'}
          : {'word': 'Word Builder', 'quiz': 'Quick Quiz', 'count': 'Count Puzzle'};

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(gameLabels[gameType] ?? gameType),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('${game.coins.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    const Text('❤️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('${game.lives.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // "New Challenges Every Day" tag
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  isAr ? 'تحديات جديدة كل يوم ♾️' : 'New Challenges Every Day ♾️',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              // Difficulty Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: difficulties.map((d) {
                    final isSelected = ctrl.difficulty.value == d;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => ctrl.changeDifficulty(d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? diffColors[d] : const Color(0xFF2a2a4a),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              diffLabels[d] ?? d,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white54,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Puzzle Grid
              Expanded(
                child: ctrl.isLoading.value && ctrl.puzzles.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.puzzles.isEmpty
                        ? Center(
                            child: Text(
                              isAr ? 'لا توجد ألغاز' : 'No puzzles available',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scroll) {
                              if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                                ctrl.loadMore();
                              }
                              return false;
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: ctrl.puzzles.length,
                              itemBuilder: (ctx, index) {
                                final isUnlocked = game.isLevelUnlocked(gameType, ctrl.difficulty.value, index);
                                final isCompleted = game.isLevelCompleted(gameType, ctrl.difficulty.value, index);
                                final accentColor = diffColors[ctrl.difficulty.value] ?? Colors.white;

                                return GestureDetector(
                                  onTap: () {
                                    if (!isUnlocked) return;
                                    if (game.lives.value <= 0) {
                                      _showNoLivesDialog(isAr, game);
                                      return;
                                    }
                                    Get.to(
                                      () => GameScreen(
                                        puzzle: ctrl.puzzles[index],
                                        levelNumber: index + 1,
                                        puzzles: ctrl.puzzles.toList(),
                                        currentIndex: index,
                                      ),
                                      transition: Transition.rightToLeft,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !isUnlocked
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : isCompleted
                                              ? accentColor.withValues(alpha: 0.3)
                                              : accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isUnlocked
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : isCompleted
                                                ? accentColor.withValues(alpha: 0.7)
                                                : accentColor.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Center(
                                      child: !isUnlocked
                                          ? Icon(Icons.lock, color: Colors.white.withValues(alpha: 0.2), size: 18)
                                          : isCompleted
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Text('${index + 1}', style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                                                    Positioned(
                                                      right: 2, top: 2,
                                                      child: Icon(Icons.check_circle, color: accentColor, size: 12),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  '${index + 1}',
                                                  style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showNoLivesDialog(bool isAr, GameController game) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a2a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'نفدت الحياة!' : 'No Lives Left!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              isAr ? 'شاهد إعلان للحصول على حياة' : 'Watch an ad to get a life',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isAr ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              game.addLife();
              Get.back();
            },
            icon: const Icon(Icons.play_circle),
            label: Text(isAr ? 'شاهد إعلان' : 'Watch Ad'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4)),
          ),
        ],
      ),
    );
  }
}
