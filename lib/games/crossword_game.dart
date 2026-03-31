import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../services/crossword_data.dart';
import '../services/game_sync_service.dart';
import '../controllers/crossword_controller.dart';
import '../widgets/hint_ad_bar.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/depth_card.dart';

class CrosswordGame extends StatelessWidget {
  final CrosswordCategory category;
  final String language;
  final int gameId;

  const CrosswordGame({super.key, required this.category, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CrosswordController(category: category, language: language), tag: 'cw_${category.id}');
    final isAr = language == 'ar';
    const accentColor = kPrimaryColor;

    // Win when all words found
    ever(ctrl.foundWords, (words) {
      if (words.length == ctrl.wordsToFind.length) {
        final gc = Get.find<GameController>();
        gc.addXp(gc.xpPerCrossword, source: 'crossword');
        gc.incrementLevelCounter();
        GameSyncService().submitScore(gameId: gameId, score: gc.xpPerCrossword);
        // Show win dialog after a short delay so the last word highlight is visible
        final ctx = context;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (ctx.mounted) {
            GameResultDialog.show(
              context: ctx,
              won: true,
              coinsEarned: 15,
              onPlayAgain: () => Get.back(),
              onHome: () { Get.back(); Get.back(); },
            );
          }
        });
      }
    });

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: [
          // Hint & Ad bar
          Obx(() => ctrl.foundWords.length < ctrl.wordsToFind.length
              ? HintAdBar(
                  onHint: ctrl.useHint,
                  hintEnabled: !ctrl.hintUsed.value,
                )
              : const SizedBox.shrink()),
          // Progress
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(8)),
            child: DepthCard(
              padding: EdgeInsets.symmetric(horizontal: rs(14), vertical: rs(10)),
              borderRadius: 14,
              elevation: 0.6,
              accentColor: accentColor,
              child: Row(
                children: [
                  Obx(() => Text(
                    isAr
                        ? '${ctrl.foundWords.length} / ${ctrl.wordsToFind.length} كلمات'
                        : '${ctrl.foundWords.length} / ${ctrl.wordsToFind.length} words',
                    style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody),
                  )),
                  const Spacer(),
                  Text(
                    '${category.emoji} ${category.name}',
                    style: TextStyle(color: accentColor, fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Grid
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(8)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = min(constraints.maxWidth, constraints.maxHeight) / ctrl.gridSize;
                  return Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: GestureDetector(
                        onPanStart: (d) {
                          final cell = _getCellFromPosition(d.localPosition, cellSize, ctrl.gridSize);
                          if (cell != null) ctrl.onDragStart(cell);
                        },
                        onPanUpdate: (d) {
                          final cell = _getCellFromPosition(d.localPosition, cellSize, ctrl.gridSize);
                          if (cell != null) ctrl.onDragUpdate(cell);
                        },
                        onPanEnd: (_) => ctrl.onDragEnd(),
                        child: SizedBox(
                          width: cellSize * ctrl.gridSize,
                          height: cellSize * ctrl.gridSize,
                          child: Obx(() {
                          // Access reactive lists so Obx tracks them
                          final found = ctrl.foundCells.toSet();
                          final dragging = ctrl.currentDragCells.toList();
                          final hints = ctrl.hintCells.toSet();
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: ctrl.gridSize),
                            itemCount: ctrl.gridSize * ctrl.gridSize,
                            itemBuilder: (ctx, index) {
                              final row = index ~/ ctrl.gridSize;
                              final col = index % ctrl.gridSize;
                              final isFound = found.contains(index);
                              final isDragging = dragging.contains(index);
                              final isHint = hints.contains(index);

                              final isDark = isDarkCtx(context);

                              // Determine cell colors
                              final Color cellBg;
                              final Color borderColor;
                              if (isFound) {
                                cellBg = kSecondaryColor.withValues(alpha: 0.3);
                                borderColor = kSecondaryColor.withValues(alpha: 0.6);
                              } else if (isHint) {
                                cellBg = kOrangeColor.withValues(alpha: 0.35);
                                borderColor = kOrangeColor.withValues(alpha: 0.8);
                              } else if (isDragging) {
                                cellBg = accentColor.withValues(alpha: 0.3);
                                borderColor = accentColor.withValues(alpha: 0.6);
                              } else {
                                cellBg = kCardColor;
                                borderColor = kBorderColor;
                              }

                              // 3D depth shadow color
                              final shadowBase = isFound
                                  ? kSecondaryColor
                                  : isDragging
                                      ? accentColor
                                      : isHint
                                          ? kOrangeColor
                                          : (isDark ? Colors.black : Colors.grey);

                              return Container(
                                margin: EdgeInsets.all(rs(1.5)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(rs(6)),
                                  boxShadow: [
                                    // 3D base depth shadow
                                    BoxShadow(
                                      color: shadowBase.withValues(alpha: 0.35),
                                      offset: Offset(0, rs(2.5)),
                                      blurRadius: rs(0.5),
                                    ),
                                    // Soft ambient shadow
                                    BoxShadow(
                                      color: shadowBase.withValues(alpha: 0.12),
                                      blurRadius: rs(6),
                                      offset: Offset(0, rs(1)),
                                    ),
                                    // Neon glow for active/dragging cells
                                    if (isDragging || isFound || isHint)
                                      BoxShadow(
                                        color: (isDragging ? accentColor : isFound ? kSecondaryColor : kOrangeColor)
                                            .withValues(alpha: 0.4),
                                        blurRadius: rs(10),
                                        spreadRadius: rs(1),
                                      ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(rs(6)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        cellBg,
                                        HSLColor.fromColor(cellBg)
                                            .withLightness((HSLColor.fromColor(cellBg).lightness - 0.04).clamp(0.0, 1.0))
                                            .toColor(),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: borderColor,
                                      width: (isDragging || isFound) ? rs(1.5) : rs(1),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Glossy highlight on top 40%
                                      if (isFound || isDragging || isHint)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: cellSize * 0.4,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(rs(5))),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.25),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      Center(
                                        child: Text(ctrl.grid[row][col],
                                          style: TextStyle(
                                            color: isFound ? kSecondaryColor : isDragging ? accentColor : kTextSecondary,
                                            fontSize: cellSize * 0.45,
                                            fontWeight: isFound || isDragging ? FontWeight.bold : FontWeight.normal,
                                          )),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Word list
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(rs(8)),
              child: DepthCard(
                padding: EdgeInsets.all(rs(12)),
                borderRadius: 16,
                elevation: 0.7,
                child: Obx(() => SingleChildScrollView(
                  child: Wrap(
                    spacing: rs(8), runSpacing: rs(6), alignment: WrapAlignment.center,
                    children: ctrl.wordsToFind.map((word) {
                      final found = ctrl.foundWords.contains(word);
                      final isDark = isDarkCtx(context);

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: rs(10), vertical: rs(5)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(rs(10)),
                          gradient: found
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    kSecondaryColor.withValues(alpha: 0.25),
                                    kSecondaryColor.withValues(alpha: 0.12),
                                  ],
                                )
                              : null,
                          color: found ? null : kBorderColor.withValues(alpha: 0.2),
                          border: Border.all(
                            color: found ? kSecondaryColor.withValues(alpha: 0.5) : kBorderColor,
                          ),
                          boxShadow: found
                              ? [
                                  BoxShadow(
                                    color: kSecondaryColor.withValues(alpha: 0.25),
                                    blurRadius: rs(8),
                                    offset: Offset(0, rs(2)),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.15),
                                    blurRadius: rs(3),
                                    offset: Offset(0, rs(1.5)),
                                  ),
                                ],
                        ),
                        child: Text(word,
                          style: TextStyle(
                            color: found ? kSecondaryColor : kTextHint,
                            fontSize: kFontSizeCaption,
                            fontWeight: found ? FontWeight.bold : FontWeight.normal,
                            decoration: found ? TextDecoration.lineThrough : null,
                          )),
                      );
                    }).toList(),
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _getCellFromPosition(Offset position, double cellSize, int gridSize) {
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return row * gridSize + col;
    }
    return null;
  }
}
