import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/crossword_screen_controller.dart';
import '../services/classic_crossword_data.dart';
import '../services/sound_service.dart';
import '../games/classic_crossword_game.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class ClassicCrosswordScreen extends StatelessWidget {
  final String language;
  final int gameId;

  const ClassicCrosswordScreen({super.key, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final ctrl = Get.put(CrosswordScreenController(language: language, gameId: gameId), tag: 'cc_${gameId}_$language');
    final isAr = language == 'ar';

    return Obx(() => Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          title: Text('classic_crossword'.tr),
          centerTitle: true,
          actions: [const CoinsLivesRow()],
        ),
        body: AnimatedGameBg(
          child: Obx(() {
            final filtered = ctrl.classicPuzzles
                .where((p) => isAr ? p.id.endsWith('_ar') : !p.id.endsWith('_ar'))
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
                          final puzzle = filtered[index];
                          final colors = [
                            kPrimaryColor, kSecondaryColor,
                            kRedColor, kYellowColor,
                            kPinkColor, const Color(0xFF45B7D1),
                          ];
                          final accentColor = colors[index % colors.length];

                          return _buildPuzzleCard(
                            emoji: puzzle.emoji,
                            name: puzzle.name,
                            subtitle: 'words_count'.trParams({'n': '${puzzle.entries.length}'}),
                            accentColor: accentColor,
                            onTap: () {
                              SoundService().playClick();
                              Get.to(() => _ClassicPlayScreen(puzzle: puzzle, language: language, gameId: gameId));
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

    return Obx(() => Directionality(
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
    ));
  }
}
