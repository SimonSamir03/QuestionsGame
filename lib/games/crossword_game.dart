import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/crossword_data.dart';
import '../controllers/crossword_controller.dart';

class CrosswordGame extends StatelessWidget {
  final CrosswordCategory category;
  final String language;

  const CrosswordGame({super.key, required this.category, required this.language});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CrosswordController(category: category, language: language), tag: 'cw_${category.id}');
    final isAr = language == 'ar';
    const accentColor = Color(0xFF6C63FF);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Obx(() => Text(
                  isAr
                      ? '${ctrl.foundWords.length} / ${ctrl.wordsToFind.length} كلمات'
                      : '${ctrl.foundWords.length} / ${ctrl.wordsToFind.length} words',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                )),
                const Spacer(),
                Text(
                  '${category.emoji} ${isAr ? category.nameAr : category.nameEn}',
                  style: const TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = min(constraints.maxWidth, constraints.maxHeight) / CrosswordController.gridSize;
                  return Center(
                    child: GestureDetector(
                      onPanStart: (d) {
                        final cell = _getCellFromPosition(d.localPosition, cellSize);
                        if (cell != null) ctrl.onDragStart(cell);
                      },
                      onPanUpdate: (d) {
                        final cell = _getCellFromPosition(d.localPosition, cellSize);
                        if (cell != null) ctrl.onDragUpdate(cell);
                      },
                      onPanEnd: (_) => ctrl.onDragEnd(),
                      child: SizedBox(
                        width: cellSize * CrosswordController.gridSize,
                        height: cellSize * CrosswordController.gridSize,
                        child: Obx(() => GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: CrosswordController.gridSize),
                          itemCount: CrosswordController.gridSize * CrosswordController.gridSize,
                          itemBuilder: (ctx, index) {
                            final row = index ~/ CrosswordController.gridSize;
                            final col = index % CrosswordController.gridSize;
                            final isFound = ctrl.foundCells.contains(index);
                            final isDragging = ctrl.currentDragCells.contains(index);

                            return Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: isFound
                                    ? const Color(0xFF4ECDC4).withValues(alpha: 0.3)
                                    : isDragging
                                        ? accentColor.withValues(alpha: 0.3)
                                        : const Color(0xFF2a2a4a),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isFound
                                      ? const Color(0xFF4ECDC4).withValues(alpha: 0.6)
                                      : isDragging
                                          ? accentColor.withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(ctrl.grid[row][col],
                                  style: TextStyle(
                                    color: isFound ? const Color(0xFF4ECDC4) : isDragging ? accentColor : Colors.white70,
                                    fontSize: cellSize * 0.45,
                                    fontWeight: isFound || isDragging ? FontWeight.bold : FontWeight.normal,
                                  )),
                              ),
                            );
                          },
                        )),
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
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a4a),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Obx(() => SingleChildScrollView(
                  child: Wrap(
                    spacing: 8, runSpacing: 6, alignment: WrapAlignment.center,
                    children: ctrl.wordsToFind.map((word) {
                      final found = ctrl.foundWords.contains(word);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: found ? const Color(0xFF4ECDC4).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: found ? const Color(0xFF4ECDC4).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(word,
                          style: TextStyle(
                            color: found ? const Color(0xFF4ECDC4) : Colors.white54,
                            fontSize: 12,
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

  int? _getCellFromPosition(Offset position, double cellSize) {
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    if (row >= 0 && row < CrosswordController.gridSize && col >= 0 && col < CrosswordController.gridSize) {
      return row * CrosswordController.gridSize + col;
    }
    return null;
  }
}
