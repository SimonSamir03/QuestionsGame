import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/crossword_screen_controller.dart';
import '../services/crossword_data.dart';
import '../services/classic_crossword_data.dart';
import '../services/sound_service.dart';
import '../games/crossword_game.dart';
import '../games/classic_crossword_game.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class CrosswordScreen extends StatelessWidget {
  final String language;
  final int gameId;

  const CrosswordScreen({super.key, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final ctrl = Get.put(CrosswordScreenController(language: language, gameId: gameId), tag: 'cw_${gameId}_$language');

    return Obx(() {
      final isAr = gameController.isAr;

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: kBgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: kTextPrimary,
            title: Text('word_games_title'.tr),
            centerTitle: true,
            actions: [const CoinsLivesRow()],
          ),
          body: AnimatedGameBg(
            child: ctrl.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: rs(16)),
                    children: [
                      if (ctrl.classicPuzzles.isNotEmpty) ...[
                        _buildSectionHeader(
                          'classic_crossword'.tr,
                          'classic_crossword_sub'.tr,
                          '\u270f\ufe0f',
                        ),
                        SizedBox(height: rs(10)),
                        ...ctrl.classicPuzzles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final puzzle = entry.value;
                          final colors = [
                            kPrimaryColor, kSecondaryColor,
                            kRedColor, kYellowColor,
                            kPinkColor, const Color(0xFF45B7D1),
                          ];
                          final accentColor = colors[index % colors.length];

                          return _buildPuzzleCard(
                            context: context,
                            emoji: puzzle.emoji,
                            name: puzzle.name,
                            subtitle: 'words_count'.trParams({'n': '${puzzle.entries.length}'}),
                            accentColor: accentColor,
                            onTap: () {
                              SoundService().playClick();
                              Get.to(() => _ClassicPlayScreen(puzzle: puzzle, language: language, gameId: gameId));
                            },
                          );
                        }),
                        SizedBox(height: rs(16)),
                      ],

                      if (ctrl.wordSearchCategories.isNotEmpty) ...[
                        _buildSectionHeader(
                          'word_search'.tr,
                          'word_search_sub'.tr,
                          '\u{1f50d}',
                        ),
                        SizedBox(height: rs(10)),
                        ...ctrl.wordSearchCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final cat = entry.value;
                          final colors = [
                            kPinkColor, const Color(0xFF45B7D1),
                            kPrimaryColor, kSecondaryColor,
                            kRedColor, kYellowColor,
                          ];
                          final accentColor = colors[index % colors.length];

                          return _buildPuzzleCard(
                            context: context,
                            emoji: cat.emoji,
                            name: cat.name,
                            subtitle: 'words_count'.trParams({'n': '${cat.words.length}'}),
                            accentColor: accentColor,
                            onTap: () {
                              SoundService().playClick();
                              Get.to(() => _WordSearchPlayScreen(category: cat, language: language, gameId: gameId));
                            },
                          );
                        }),
                        SizedBox(height: rs(16)),
                      ],
                    ],
                  ),
                ),
                if (!gameController.isPremium.value) const BannerAdWidget(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, String subtitle, String emoji) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: rs(12), horizontal: rs(4)),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: fs(24))),
          SizedBox(width: rs(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: kTextPrimary, fontSize: kFontSizeH4, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: kTextDisabled, fontSize: kFontSizeCaption)),
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
    return Padding(
      padding: EdgeInsets.only(bottom: rs(8)),
      child: DepthCard(
        onTap: onTap,
        padding: EdgeInsets.all(rs(14)),
        borderRadius: 16,
        accentColor: accentColor,
        elevation: 0.8,
        child: Row(
          children: [
            Container(
              width: rs(46), height: rs(46),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.3),
                    accentColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(rs(12)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: rs(8),
                    offset: Offset(0, rs(2)),
                  ),
                ],
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

class _ClassicPlayScreen extends StatelessWidget {
  final ClassicCrosswordPuzzle puzzle;
  final String language;
  final int gameId;

  const _ClassicPlayScreen({required this.puzzle, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final isAr = language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          title: Text('${puzzle.emoji} ${puzzle.name}'),
          centerTitle: true,
          actions: [const CoinsLivesRow()],
        ),
        body: AnimatedGameBg(
          child: Column(
            children: [
              Expanded(
                child: ClassicCrosswordGame(puzzle: puzzle, language: language, gameId: gameId),
              ),
              Obx(() => !gameController.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
            ],
          ),
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

    return Directionality(
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
        body: AnimatedGameBg(
          child: Column(
            children: [
              Expanded(
                child: CrosswordGame(category: category, language: language, gameId: gameId),
              ),
              Obx(() => !gameController.isPremium.value ? const BannerAdWidget() : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
