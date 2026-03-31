import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/level_controller.dart';
import '../controllers/game_controller.dart';
import 'game_screen.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';

class LevelScreen extends StatelessWidget {
  final int gameId;
  final String gameSlug;
  final String? gameLanguage;

  const LevelScreen({super.key, required this.gameId, required this.gameSlug, this.gameLanguage});

  @override
  Widget build(BuildContext context) {
    final tag = gameLanguage != null ? 'lc_${gameId}_$gameLanguage' : 'lc_$gameId';
    final levelController = Get.put(LevelController(gameId: gameId, gameSlug: gameSlug, gameLanguage: gameLanguage), tag: tag);
    final gameController = Get.find<GameController>();

    final diffColors = {
      'easy': kSecondaryColor,
      'medium': kYellowColor,
      'hard': kRedColor,
      'expert': kPrimaryColor,
    };

    final difficulties = ['easy', 'medium', 'hard', 'expert'];

    return Obx(() {
      final _ = gameController.completedLevels.length;
      final isAr = gameController.isAr;

      final diffLabels = {
        'easy': 'diff_easy'.tr, 'medium': 'diff_medium'.tr,
        'hard': 'diff_hard'.tr, 'expert': 'diff_expert'.tr,
      };
      final gameLabels = {
        'word_rearrange': 'game_word'.tr, 'quiz': 'game_quiz'.tr,
      };

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: AnimatedGameBg(
            particleCount: 10,
            child: SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
                    child: Row(
                      children: [
                        _BackBtn(onTap: () => Get.back()),
                        SizedBox(width: rs(10)),
                        Expanded(
                          child: Text(
                            gameLabels[gameSlug] ?? gameSlug,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: kFontSizeH4,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: rs(10)),
                        const CoinsLivesRow(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs(16)),
                    child: Text(
                      'new_challenges'.tr,
                      style: TextStyle(color: kTextDisabled, fontSize: kFontSizeCaption),
                    ),
                  ),
                  SizedBox(height: rs(12)),
                  // 3D Difficulty Tabs
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs(16)),
                    child: Row(
                      children: difficulties.map((d) {
                        final isSelected = levelController.difficulty.value == d;
                        final color = diffColors[d]!;
                        final darkColor = HSLColor.fromColor(color)
                            .withLightness((HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0))
                            .toColor();

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => levelController.changeDifficulty(d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: rs(3)),
                              padding: EdgeInsets.symmetric(vertical: rs(10)),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: [color, color.withValues(alpha: 0.85)])
                                    : null,
                                color: isSelected ? null : kCardColor,
                                borderRadius: BorderRadius.circular(rs(14)),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(color: darkColor, offset: Offset(0, rs(3)), blurRadius: 0),
                                        BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: rs(8)),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDarkCtx(context) ? 0.3 : 0.05),
                                          offset: Offset(0, rs(2)),
                                          blurRadius: rs(1),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Text(
                                  diffLabels[d] ?? d,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : kTextHint,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: kFontSizeCaption,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: rs(16)),
                  // 3D Level Grid
                  Expanded(
                    child: levelController.isLoading.value && levelController.itemCount == 0
                        ? const Center(child: CircularProgressIndicator())
                        : levelController.itemCount == 0
                            ? Center(child: Text('no_puzzles'.tr, style: TextStyle(color: kTextHint)))
                            : NotificationListener<ScrollNotification>(
                                onNotification: (scroll) {
                                  if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                                    levelController.loadMore();
                                  }
                                  return false;
                                },
                                child: GridView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: rs(16)),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: rs(8),
                                    mainAxisSpacing: rs(8),
                                  ),
                                  itemCount: levelController.itemCount,
                                  itemBuilder: (ctx, index) {
                                    final isUnlocked = gameController.isLevelUnlocked(gameSlug, levelController.difficulty.value, index);
                                    final isCompleted = gameController.isLevelCompleted(gameSlug, levelController.difficulty.value, index);
                                    final accentColor = diffColors[levelController.difficulty.value] ?? kTextPrimary;
                                    final darkAccent = HSLColor.fromColor(accentColor)
                                        .withLightness((HSLColor.fromColor(accentColor).lightness - 0.15).clamp(0.0, 1.0))
                                        .toColor();

                                    return GestureDetector(
                                      onTap: () {
                                        if (!isUnlocked || isCompleted) return;
                                        if (gameController.lives.value <= 0) {
                                          _showNoLivesDialog(gameController);
                                          return;
                                        }
                                        Get.to(
                                          () => GameScreen.quiz(
                                            gameId: gameId,
                                            gameSlug: gameSlug,
                                            question: levelController.questions[index],
                                            levelNumber: index + 1,
                                            questions: levelController.questions.toList(),
                                            currentIndex: index,
                                          ),
                                          transition: Transition.rightToLeft,
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: isCompleted
                                              ? LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [accentColor.withValues(alpha: 0.35), accentColor.withValues(alpha: 0.2)],
                                                )
                                              : null,
                                          color: !isUnlocked
                                              ? kTextPrimary.withValues(alpha: 0.05)
                                              : isCompleted
                                                  ? null
                                                  : accentColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(rs(12)),
                                          border: Border.all(
                                            color: !isUnlocked
                                                ? kBorderColor
                                                : isCompleted
                                                    ? accentColor.withValues(alpha: 0.7)
                                                    : accentColor.withValues(alpha: 0.3),
                                          ),
                                          boxShadow: isUnlocked
                                              ? [
                                                  BoxShadow(
                                                    color: isCompleted
                                                        ? darkAccent.withValues(alpha: 0.2)
                                                        : Colors.black.withValues(alpha: isDarkCtx(context) ? 0.2 : 0.04),
                                                    offset: Offset(0, rs(2)),
                                                    blurRadius: rs(1),
                                                  ),
                                                  if (isCompleted)
                                                    BoxShadow(
                                                      color: accentColor.withValues(alpha: 0.1),
                                                      blurRadius: rs(6),
                                                    ),
                                                ]
                                              : null,
                                        ),
                                        child: Stack(
                                          children: [
                                            // Glossy top for completed
                                            if (isCompleted)
                                              Positioned(
                                                top: 0, left: 0, right: 0,
                                                height: rs(18),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(rs(11))),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Center(
                                              child: !isUnlocked
                                                  ? Icon(Icons.lock, color: kTextDisabled, size: rs(18))
                                                  : isCompleted
                                                      ? Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Text('${index + 1}',
                                                                style: TextStyle(color: accentColor, fontSize: kFontSizeBodyLarge, fontWeight: FontWeight.bold)),
                                                            Positioned(
                                                              right: rs(2), top: rs(2),
                                                              child: Icon(Icons.check_circle, color: accentColor, size: rs(12)),
                                                            ),
                                                          ],
                                                        )
                                                      : Text('${index + 1}',
                                                          style: TextStyle(color: accentColor, fontSize: kFontSizeBodyLarge, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
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
          ),
        ),
      );
    });
  }

  void _showNoLivesDialog(GameController gameController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(24))),
        title: Text('no_lives_title'.tr, textAlign: TextAlign.center, style: TextStyle(color: kTextPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\u{1f494}', style: TextStyle(fontSize: fs(48))),
            SizedBox(height: rs(12)),
            Text('no_lives_body'.tr, style: TextStyle(color: kTextSecondary), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('btn_later'.tr)),
          ElevatedButton.icon(
            onPressed: () {
              if (!gameController.isOnline.value) { Get.back(); gameController.showOfflineRewardDialog(); return; }
              gameController.addLife();
              Get.back();
            },
            icon: const Icon(Icons.play_circle),
            label: Text('btn_watch_ad'.tr),
            style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
          ),
        ],
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

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
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, color: kTextSecondary, size: rs(20)),
      ),
    );
  }
}
