import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/crossword_data.dart';
import '../services/classic_crossword_data.dart';
import '../services/sound_service.dart';
import '../games/crossword_game.dart';
import '../games/classic_crossword_game.dart';
import '../widgets/banner_ad_widget.dart';

class CrosswordScreen extends StatelessWidget {
  const CrosswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();

    return Obx(() {
      final isAr = game.isAr;

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(isAr ? 'ألعاب الكلمات' : 'Word Games'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Classic Crossword
                    _buildSectionHeader(
                      isAr ? 'الكلمات المتقاطعة' : 'Classic Crossword',
                      isAr ? 'حل الكلمات من الأدلة أفقي ورأسي' : 'Solve words from across & down clues',
                      '✏️',
                    ),
                    const SizedBox(height: 10),
                    ...ClassicCrosswordData.puzzles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final puzzle = entry.value;
                      final colors = [
                        const Color(0xFF6C63FF), const Color(0xFF4ECDC4),
                        const Color(0xFFFF6B6B), const Color(0xFFFFBE0B),
                        const Color(0xFFFF6B9D), const Color(0xFF45B7D1),
                      ];
                      final accentColor = colors[index % colors.length];

                      return _buildPuzzleCard(
                        context: context,
                        emoji: puzzle.emoji,
                        name: isAr ? puzzle.nameAr : puzzle.nameEn,
                        subtitle: isAr ? '${puzzle.entries.length} كلمة' : '${puzzle.entries.length} words',
                        accentColor: accentColor,
                        onTap: () {
                          SoundService().playClick();
                          Get.to(() => _ClassicPlayScreen(puzzle: puzzle, language: game.language.value));
                        },
                      );
                    }),

                    const SizedBox(height: 24),

                    // Word Search
                    _buildSectionHeader(
                      isAr ? 'البحث عن الكلمات' : 'Word Search',
                      isAr ? 'ابحث عن الكلمات المخفية في الشبكة' : 'Find hidden words in the grid',
                      '🔍',
                    ),
                    const SizedBox(height: 10),
                    ...CrosswordData.categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cat = entry.value;
                      final colors = [
                        const Color(0xFFFF6B9D), const Color(0xFF45B7D1),
                        const Color(0xFF6C63FF), const Color(0xFF4ECDC4),
                        const Color(0xFFFF6B6B), const Color(0xFFFFBE0B),
                      ];
                      final accentColor = colors[index % colors.length];

                      return _buildPuzzleCard(
                        context: context,
                        emoji: cat.emoji,
                        name: isAr ? cat.nameAr : cat.nameEn,
                        subtitle: isAr ? '${cat.wordsAr.length} كلمة' : '${cat.wordsEn.length} words',
                        accentColor: accentColor,
                        onTap: () {
                          SoundService().playClick();
                          Get.to(() => _WordSearchPlayScreen(category: cat, language: game.language.value));
                        },
                      );
                    }),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (!game.isPremium.value) const BannerAdWidget(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, String subtitle, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleCard({
    required BuildContext context,
    required String emoji,
    required String name,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a4a),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ClassicPlayScreen extends StatelessWidget {
  final ClassicCrosswordPuzzle puzzle;
  final String language;

  const _ClassicPlayScreen({required this.puzzle, required this.language});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();
    final isAr = language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('${puzzle.emoji} ${isAr ? puzzle.nameAr : puzzle.nameEn}'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ClassicCrosswordGame(puzzle: puzzle, language: language),
            ),
            Obx(() => !game.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _WordSearchPlayScreen extends StatelessWidget {
  final CrosswordCategory category;
  final String language;

  const _WordSearchPlayScreen({required this.category, required this.language});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();
    final isAr = language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('${category.emoji} ${isAr ? category.nameAr : category.nameEn}'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: CrosswordGame(category: category, language: language),
            ),
            Obx(() => !game.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
