import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../services/classic_crossword_data.dart';
import '../services/game_sync_service.dart';
import '../controllers/classic_crossword_controller.dart';
import '../widgets/hint_ad_bar.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/depth_card.dart';

class ClassicCrosswordGame extends StatelessWidget {
  final ClassicCrosswordPuzzle puzzle;
  final int gameId;
  final String language;

  const ClassicCrosswordGame({super.key, required this.puzzle, required this.language, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      ClassicCrosswordController(puzzle: puzzle, language: language),
      tag: 'ccw_${puzzle.id}',
    );
    final isAr = language == 'ar';

    // Listen for completion once
    once(ctrl.isComplete, (val) {
      if (val) _showCompleteDialog(context, isAr);
    });

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Obx(() {
        final entryCells = ctrl.selectedEntry.value != null
            ? ctrl.getEntryCells(ctrl.selectedEntry.value!)
            : <String>{};
        // Access userInput so Obx tracks it for grid rebuilds
        final _ = ctrl.userInput.length;
        final isDark = isDarkCtx(context);

        return Column(
          children: [
            // Hint & Ad bar
            if (!ctrl.isComplete.value)
              HintAdBar(
                onHint: ctrl.useHint,
                hintEnabled: !ctrl.hintUsed.value,
              ),
            // Clue display
            if (ctrl.selectedEntry.value != null)
              Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(6)),
                  child: DepthCard(
                    padding: EdgeInsets.symmetric(horizontal: rs(14), vertical: rs(10)),
                    borderRadius: 12,
                    elevation: 0.6,
                    accentColor: kPrimaryColor,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              kPrimaryColor.withValues(alpha: 0.2),
                              kPrimaryColor.withValues(alpha: 0.08),
                            ]
                          : [
                              kPrimaryColor.withValues(alpha: 0.12),
                              kPrimaryColor.withValues(alpha: 0.04),
                            ],
                    ),
                    child: Text(
                      '${ctrl.selectedEntry.value!.number}. ${ctrl.selectedEntry.value!.direction == 'across' ? (isAr ? 'أفقي' : 'Across') : (isAr ? 'رأسي' : 'Down')}: ${ctrl.selectedEntry.value!.clue}',
                      style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody),
                    ),
                  ),
                ),
              ),

            // Grid
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(rs(8)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxSize = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    final cellSize = maxSize / puzzle.gridCols;

                    return Center(
                      child: SizedBox(
                        width: cellSize * puzzle.gridCols,
                        height: cellSize * puzzle.gridRows,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: puzzle.gridCols,
                          ),
                          itemCount: puzzle.gridRows * puzzle.gridCols,
                          itemBuilder: (ctx, index) {
                            final row = index ~/ puzzle.gridCols;
                            final col = index % puzzle.gridCols;
                            final key = '$row,$col';
                            final isActive = ctrl.activeCellsMap.containsKey(key);
                            final number = ctrl.cellNumbers[key];
                            final isSelected = ctrl.selectedCell.value == key;
                            final isHighlighted = entryCells.contains(key);
                            final isHintCell = ctrl.hintCells.contains(key);
                            final userLetter = ctrl.userInput[key] ?? '';
                            final correctLetter = ctrl.activeCellsMap[key] ?? '';
                            final isCorrect = userLetter.toUpperCase() == correctLetter.toUpperCase() && userLetter.isNotEmpty;

                            // Black/empty cells
                            if (!isActive) {
                              return Container(
                                margin: EdgeInsets.all(rs(0.5)),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0a0a14) : const Color(0xFF1a1a2e),
                                  borderRadius: BorderRadius.circular(rs(2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      offset: Offset(0, rs(1)),
                                      blurRadius: rs(2),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Determine cell color
                            final Color cellBg;
                            if (isSelected) {
                              cellBg = kPrimaryColor.withValues(alpha: 0.4);
                            } else if (isHintCell) {
                              cellBg = kOrangeColor.withValues(alpha: 0.35);
                            } else if (isHighlighted) {
                              cellBg = kPrimaryColor.withValues(alpha: 0.15);
                            } else {
                              cellBg = isDark ? const Color(0xFF2a2a40) : const Color(0xFFF5F5F0);
                            }

                            // Shadow/glow color based on state
                            final glowColor = isSelected
                                ? kPrimaryColor
                                : isHintCell
                                    ? kOrangeColor
                                    : isHighlighted
                                        ? kPrimaryColor
                                        : (isDark ? Colors.black : Colors.grey);

                            return GestureDetector(
                              onTap: () => ctrl.selectCell(key),
                              child: Container(
                                margin: EdgeInsets.all(rs(0.5)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(rs(4)),
                                  boxShadow: [
                                    // 3D base depth
                                    BoxShadow(
                                      color: glowColor.withValues(alpha: 0.3),
                                      offset: Offset(0, rs(2)),
                                      blurRadius: rs(0.5),
                                    ),
                                    // Ambient
                                    BoxShadow(
                                      color: glowColor.withValues(alpha: 0.1),
                                      blurRadius: rs(4),
                                      offset: Offset(0, rs(1)),
                                    ),
                                    // Neon glow for selected/hint
                                    if (isSelected || isHintCell)
                                      BoxShadow(
                                        color: (isSelected ? kPrimaryColor : kOrangeColor)
                                            .withValues(alpha: 0.45),
                                        blurRadius: rs(10),
                                        spreadRadius: rs(1),
                                      ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(rs(4)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        cellBg,
                                        HSLColor.fromColor(cellBg)
                                            .withLightness((HSLColor.fromColor(cellBg).lightness - 0.03).clamp(0.0, 1.0))
                                            .toColor(),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? kPrimaryColor
                                          : isHintCell
                                              ? kOrangeColor.withValues(alpha: 0.8)
                                              : isDark
                                                  ? Colors.white.withValues(alpha: 0.1)
                                                  : Colors.black26,
                                      width: isSelected ? rs(2) : rs(0.5),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Glossy highlight on top 40%
                                      if (isSelected || isHighlighted || isHintCell || userLetter.isNotEmpty)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: cellSize * 0.4,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(rs(3))),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.22),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Cell number
                                      if (number != null)
                                        Positioned(
                                          left: rs(2),
                                          top: rs(1),
                                          child: Text(
                                            '$number',
                                            style: TextStyle(
                                              fontSize: cellSize * 0.22,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      // Letter
                                      Center(
                                        child: Text(
                                          userLetter,
                                          style: TextStyle(
                                            fontSize: cellSize * 0.45,
                                            fontWeight: FontWeight.bold,
                                            color: isCorrect
                                                ? kSecondaryColor
                                                : isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Clue lists
            Expanded(
              flex: 1,
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: _buildClueList(ctrl, isAr),
              ),
            ),

            // Keyboard
            _buildKeyboard(ctrl, context),
          ],
        );
      }),
    );
  }

  Widget _buildClueList(ClassicCrosswordController ctrl, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(8)),
      child: DepthCard(
        padding: EdgeInsets.zero,
        borderRadius: 14,
        elevation: 0.7,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                unselectedLabelColor: kTextDisabled,
                tabs: [
                  Tab(text: isAr ? 'أفقي ➡️' : 'Across ➡️'),
                  Tab(text: isAr ? 'رأسي ⬇️' : 'Down ⬇️'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildClueTab(ctrl, puzzle.across, isAr),
                    _buildClueTab(ctrl, puzzle.down, isAr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClueTab(ClassicCrosswordController ctrl, List<CrosswordEntry> entries, bool isAr) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: rs(8), vertical: rs(4)),
      itemCount: entries.length,
      itemBuilder: (ctx, i) {
        final entry = entries[i];
        final isEntryComplete = ctrl.isEntryComplete(entry);
        final isEntrySelected = ctrl.selectedEntry.value == entry;

        return GestureDetector(
          onTap: () => ctrl.selectEntry(entry),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: rs(8), vertical: rs(5)),
            margin: EdgeInsets.only(bottom: rs(2)),
            decoration: BoxDecoration(
              gradient: isEntrySelected
                  ? LinearGradient(
                      colors: [
                        kPrimaryColor.withValues(alpha: 0.18),
                        kPrimaryColor.withValues(alpha: 0.06),
                      ],
                    )
                  : null,
              color: isEntrySelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(rs(6)),
            ),
            child: Text(
              '${entry.number}. ${entry.clue}',
              style: TextStyle(
                color: isEntryComplete ? kSecondaryColor : kTextSecondary,
                fontSize: kFontSizeCaption,
                decoration: isEntryComplete ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyboard(ClassicCrosswordController ctrl, BuildContext context) {
    final rows = ctrl.isAr
        ? const [
            ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج'],
            ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك'],
            ['ئ', 'ء', 'ؤ', 'ر', 'ى', 'ة', 'و', 'ز', 'ظ', 'ذ', 'د', 'ط', '⌫'],
          ]
        : const [
            ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
            ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
            ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
          ];

    final isDark = isDarkCtx(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1a1a2e), const Color(0xFF12121e)]
              : [const Color(0xFFe8e8f0), const Color(0xFFd4d4e0)],
        ),
      ),
      padding: EdgeInsets.only(bottom: rs(8), top: rs(4)),
      child: Column(
        children: rows.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final isBackspace = key == '⌫';

              // 3D keyboard key colors
              final keyBg = isBackspace
                  ? kRedColor.withValues(alpha: 0.35)
                  : isDark
                      ? const Color(0xFF3a3a5a)
                      : const Color(0xFFfafafa);
              final keyDark = isBackspace
                  ? HSLColor.fromColor(kRedColor).withLightness(0.25).toColor()
                  : isDark
                      ? const Color(0xFF252540)
                      : const Color(0xFFc0c0cc);

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (isBackspace) {
                      ctrl.handleBackspace();
                    } else {
                      ctrl.handleKeyInput(key);
                    }
                  },
                  child: Container(
                    height: rs(38),
                    margin: EdgeInsets.all(rs(2)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(rs(8)),
                      boxShadow: [
                        // 3D base depth
                        BoxShadow(
                          color: keyDark,
                          offset: Offset(0, rs(3)),
                          blurRadius: 0,
                        ),
                        // Soft glow
                        BoxShadow(
                          color: (isBackspace ? kRedColor : kPrimaryColor).withValues(alpha: 0.08),
                          blurRadius: rs(6),
                          offset: Offset(0, rs(1)),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(rs(8)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            keyBg,
                            HSLColor.fromColor(keyBg)
                                .withLightness((HSLColor.fromColor(keyBg).lightness - 0.04).clamp(0.0, 1.0))
                                .toColor(),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Glossy highlight on top 40%
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: rs(38) * 0.4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(rs(8))),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: isDark ? 0.12 : 0.5),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              key,
                              style: TextStyle(
                                color: isBackspace ? kRedColor : kTextPrimary,
                                fontSize: isBackspace ? kFontSizeH4 : kFontSizeBody,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, bool isAr) {
    final gameController = Get.find<GameController>();
    gameController.addXp(gameController.xpPerClassicCrossword, source: 'classic_crossword');
    gameController.incrementLevelCounter();
    GameSyncService().submitScore(gameId: gameId, score: gameController.xpPerClassicCrossword);

    GameResultDialog.show(
      context: context,
      won: true,
      coinsEarned: 20,
      onPlayAgain: () => Get.back(),
      onHome: () { Get.back(); Get.back(); },
    );
  }
}
