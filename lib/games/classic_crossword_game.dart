import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/classic_crossword_data.dart';
import '../controllers/classic_crossword_controller.dart';

class ClassicCrosswordGame extends StatelessWidget {
  final ClassicCrosswordPuzzle puzzle;
  final String language;

  const ClassicCrosswordGame({super.key, required this.puzzle, required this.language});

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
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Obx(() {
        final entryCells = ctrl.selectedEntry.value != null
            ? ctrl.getEntryCells(ctrl.selectedEntry.value!)
            : <String>{};

        return Column(
          children: [
            // Clue display
            if (ctrl.selectedEntry.value != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${ctrl.selectedEntry.value!.number}. ${ctrl.selectedEntry.value!.direction == 'across' ? (isAr ? 'أفقي' : 'Across') : (isAr ? 'رأسي' : 'Down')}: ${isAr ? ctrl.selectedEntry.value!.clueAr : ctrl.selectedEntry.value!.clueEn}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),

            // Grid
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                            final isActive = ctrl.activeCells.containsKey(key);
                            final number = ctrl.cellNumbers[key];
                            final isSelected = ctrl.selectedCell.value == key;
                            final isHighlighted = entryCells.contains(key);
                            final userLetter = ctrl.userInput[key] ?? '';
                            final correctLetter = ctrl.activeCells[key] ?? '';
                            final isCorrect = userLetter.toUpperCase() == correctLetter.toUpperCase() && userLetter.isNotEmpty;

                            if (!isActive) {
                              return Container(
                                margin: const EdgeInsets.all(0.5),
                                color: const Color(0xFF0d0d1a),
                              );
                            }

                            return GestureDetector(
                              onTap: () => ctrl.selectCell(key),
                              child: Container(
                                margin: const EdgeInsets.all(0.5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6C63FF).withValues(alpha: 0.4)
                                      : isHighlighted
                                          ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                                          : const Color(0xFFF5F5F0),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6C63FF)
                                        : Colors.black26,
                                    width: isSelected ? 2 : 0.5,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    if (number != null)
                                      Positioned(
                                        left: 2,
                                        top: 1,
                                        child: Text(
                                          '$number',
                                          style: TextStyle(
                                            fontSize: cellSize * 0.22,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    Center(
                                      child: Text(
                                        userLetter,
                                        style: TextStyle(
                                          fontSize: cellSize * 0.45,
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect ? const Color(0xFF2d8c5a) : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
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
              child: _buildClueList(ctrl, isAr),
            ),

            // Keyboard
            _buildKeyboard(ctrl),
          ],
        );
      }),
    );
  }

  Widget _buildClueList(ClassicCrosswordController ctrl, bool isAr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a4a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: const Color(0xFF6C63FF),
              labelColor: const Color(0xFF6C63FF),
              unselectedLabelColor: Colors.white38,
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
    );
  }

  Widget _buildClueTab(ClassicCrosswordController ctrl, List<CrosswordEntry> entries, bool isAr) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: entries.length,
      itemBuilder: (ctx, i) {
        final entry = entries[i];
        final isEntryComplete = ctrl.isEntryComplete(entry);
        final isEntrySelected = ctrl.selectedEntry.value == entry;

        return GestureDetector(
          onTap: () => ctrl.selectEntry(entry),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: isEntrySelected
                  ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.number}. ${isAr ? entry.clueAr : entry.clueEn}',
              style: TextStyle(
                color: isEntryComplete ? const Color(0xFF4ECDC4) : Colors.white70,
                fontSize: 12,
                decoration: isEntryComplete ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyboard(ClassicCrosswordController ctrl) {
    const rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
    ];

    return Container(
      color: const Color(0xFF1a1a2e),
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Column(
        children: rows.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final isBackspace = key == '⌫';
              return GestureDetector(
                onTap: () {
                  if (isBackspace) {
                    ctrl.handleBackspace();
                  } else {
                    ctrl.handleKeyInput(key);
                  }
                },
                child: Container(
                  width: isBackspace ? 48 : 32,
                  height: 38,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isBackspace
                        ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
                        : const Color(0xFF3a3a5a),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: TextStyle(
                        color: isBackspace ? const Color(0xFFFF6B6B) : Colors.white,
                        fontSize: isBackspace ? 18 : 14,
                        fontWeight: FontWeight.bold,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'أحسنت! 🎉' : 'Well Done! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        content: Text(
          isAr ? 'حليت الكلمات المتقاطعة!' : 'You solved the crossword!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(isAr ? 'رجوع' : 'Back', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
