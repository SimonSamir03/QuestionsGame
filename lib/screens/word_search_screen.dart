import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/crossword_screen_controller.dart';
import '../services/crossword_data.dart';
import '../services/sound_service.dart';
import '../games/crossword_game.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coins_lives_row.dart';

class WordSearchScreen extends StatelessWidget {
  final String language;
  final int gameId;

  const WordSearchScreen({super.key, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final ctrl = Get.put(CrosswordScreenController(language: language, gameId: gameId), tag: 'ws_${gameId}_$language');
    final isAr = language == 'ar';

    return Obx(() => Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          title: Text('word_search'.tr),
          centerTitle: true,
          actions: [const CoinsLivesRow()],
        ),
        body: Obx(() {
          final filtered = ctrl.wordSearchCategories
              .where((c) => isAr ? c.id.endsWith('_ar') : !c.id.endsWith('_ar'))
              .toList();
          return ctrl.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: rs(16)),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        final cat = filtered[index];
                        final colors = [
                          kPinkColor, const Color(0xFF45B7D1),
                          kPrimaryColor, kSecondaryColor,
                          kRedColor, kYellowColor,
                        ];
                        final accentColor = colors[index % colors.length];

                        return _buildPuzzleCard(
                          emoji: cat.emoji,
                          name: cat.name,
                          subtitle: 'words_count'.trParams({'n': '${cat.words.length}'}),
                          accentColor: accentColor,
                          onTap: () {
                            SoundService().playClick();
                            Get.to(() => _WordSearchPlayScreen(category: cat, language: language, gameId: gameId));
                          },
                        );
                      },
                    ),
                  ),
                  Obx(() => !gameController.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
                ],
              );
        }),
      ),
    ));
  }

  Widget _buildPuzzleCard({
    required String emoji,
    required String name,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: rs(8)),
        padding: EdgeInsets.all(rs(14)),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(rs(14)),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: rs(46), height: rs(46),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(rs(12)),
              ),
              child: Center(child: Text(emoji, style: TextStyle(fontSize: fs(24)))),
            ),
            SizedBox(width: rs(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody, fontWeight: FontWeight.bold)),
                  SizedBox(height: rs(2)),
                  Text(subtitle, style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor, size: rs(16)),
          ],
        ),
      ),
    );
  }
}

class _WordSearchPlayScreen extends StatelessWidget {
  final CrosswordCategory category;
  final String language;
  final int gameId;

  const _WordSearchPlayScreen({required this.category, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final isAr = language == 'ar';

    return Obx(() => Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          title: Text('${category.emoji} ${category.name}'),
          centerTitle: true,
          actions: [const CoinsLivesRow()],
        ),
        body: Column(
          children: [
            Expanded(
              child: CrosswordGame(category: category, language: language, gameId: gameId),
            ),
            Obx(() => !gameController.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
          ],
        ),
      ),
    ));
  }
}
