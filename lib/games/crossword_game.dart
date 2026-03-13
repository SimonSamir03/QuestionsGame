import 'dart:math';
import 'package:flutter/material.dart';
import '../services/crossword_data.dart';

class CrosswordGame extends StatefulWidget {
  final CrosswordCategory category;
  final String language;

  const CrosswordGame({super.key, required this.category, required this.language});

  @override
  State<CrosswordGame> createState() => _CrosswordGameState();
}

class _CrosswordGameState extends State<CrosswordGame> {
  static const int gridSize = 10;
  late List<List<String>> _grid;
  late List<String> _wordsToFind;
  final Set<String> _foundWords = {};
  final Set<int> _selectedCells = {};
  final Set<int> _foundCells = {};
  int? _dragStart;
  int? _dragEnd;
  final Set<int> _currentDragCells = {};

  @override
  void initState() {
    super.initState();
    _wordsToFind = widget.category.getWords(widget.language);
    _grid = _generateGrid();
  }

  List<List<String>> _generateGrid() {
    final grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    final random = Random();
    final placed = <String>[];

    final isAr = widget.language == 'ar';
    final fillChars = isAr
        ? 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي'
        : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // Try to place each word
    for (final word in _wordsToFind) {
      final chars = word.split('');
      bool wordPlaced = false;

      for (int attempt = 0; attempt < 100; attempt++) {
        // 0=horizontal, 1=vertical
        final direction = random.nextInt(2);
        int row, col;

        if (direction == 0) {
          // Horizontal
          row = random.nextInt(gridSize);
          col = random.nextInt(gridSize - chars.length + 1);
        } else {
          // Vertical
          row = random.nextInt(gridSize - chars.length + 1);
          col = random.nextInt(gridSize);
        }

        bool canPlace = true;
        for (int i = 0; i < chars.length; i++) {
          final r = direction == 0 ? row : row + i;
          final c = direction == 0 ? col + i : col;
          if (grid[r][c] != '' && grid[r][c] != chars[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < chars.length; i++) {
            final r = direction == 0 ? row : row + i;
            final c = direction == 0 ? col + i : col;
            grid[r][c] = chars[i];
          }
          placed.add(word);
          wordPlaced = true;
          break;
        }
      }

      if (!wordPlaced) {
        // Skip words that couldn't be placed
      }
    }

    // Update words list to only include placed words
    _wordsToFind = placed;

    // Fill empty cells with random letters
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = fillChars[random.nextInt(fillChars.length)];
        }
      }
    }

    return grid;
  }

  Set<int> _getCellsBetween(int start, int end) {
    final cells = <int>{};
    final startRow = start ~/ gridSize;
    final startCol = start % gridSize;
    final endRow = end ~/ gridSize;
    final endCol = end % gridSize;

    // Only allow horizontal or vertical selections
    if (startRow == endRow) {
      // Horizontal
      final minCol = min(startCol, endCol);
      final maxCol = max(startCol, endCol);
      for (int c = minCol; c <= maxCol; c++) {
        cells.add(startRow * gridSize + c);
      }
    } else if (startCol == endCol) {
      // Vertical
      final minRow = min(startRow, endRow);
      final maxRow = max(startRow, endRow);
      for (int r = minRow; r <= maxRow; r++) {
        cells.add(r * gridSize + startCol);
      }
    }

    return cells;
  }

  String _getWordFromCells(Set<int> cells) {
    if (cells.isEmpty) return '';
    final sorted = cells.toList()..sort();
    return sorted.map((i) => _grid[i ~/ gridSize][i % gridSize]).join('');
  }

  void _checkSelection() {
    final word = _getWordFromCells(_currentDragCells);
    final reversedWord = word.split('').reversed.join('');

    for (final w in _wordsToFind) {
      if ((word == w || reversedWord == w) && !_foundWords.contains(w)) {
        setState(() {
          _foundWords.add(w);
          _foundCells.addAll(_currentDragCells);
        });

        if (_foundWords.length == _wordsToFind.length) {
          // All words found!
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showCompleteDialog();
          });
        }
        break;
      }
    }
  }

  void _showCompleteDialog() {
    final isAr = widget.language == 'ar';
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
          isAr ? 'لقيت كل الكلمات!' : 'You found all the words!',
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

  @override
  Widget build(BuildContext context) {
    final isAr = widget.language == 'ar';
    final accentColor = const Color(0xFF6C63FF);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  isAr
                      ? '${_foundWords.length} / ${_wordsToFind.length} كلمات'
                      : '${_foundWords.length} / ${_wordsToFind.length} words',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${widget.category.emoji} ${isAr ? widget.category.nameAr : widget.category.nameEn}',
                  style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold),
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
                  final cellSize = min(constraints.maxWidth, constraints.maxHeight) / gridSize;
                  return Center(
                    child: GestureDetector(
                      onPanStart: (details) {
                        final cell = _getCellFromPosition(details.localPosition, cellSize);
                        if (cell != null) {
                          setState(() {
                            _dragStart = cell;
                            _dragEnd = cell;
                            _currentDragCells
                              ..clear()
                              ..add(cell);
                          });
                        }
                      },
                      onPanUpdate: (details) {
                        final cell = _getCellFromPosition(details.localPosition, cellSize);
                        if (cell != null && _dragStart != null) {
                          setState(() {
                            _dragEnd = cell;
                            _currentDragCells
                              ..clear()
                              ..addAll(_getCellsBetween(_dragStart!, cell));
                          });
                        }
                      },
                      onPanEnd: (_) {
                        _checkSelection();
                        setState(() {
                          _currentDragCells.clear();
                          _dragStart = null;
                          _dragEnd = null;
                        });
                      },
                      child: SizedBox(
                        width: cellSize * gridSize,
                        height: cellSize * gridSize,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                          ),
                          itemCount: gridSize * gridSize,
                          itemBuilder: (ctx, index) {
                            final row = index ~/ gridSize;
                            final col = index % gridSize;
                            final isFound = _foundCells.contains(index);
                            final isDragging = _currentDragCells.contains(index);

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
                                child: Text(
                                  _grid[row][col],
                                  style: TextStyle(
                                    color: isFound
                                        ? const Color(0xFF4ECDC4)
                                        : isDragging
                                            ? accentColor
                                            : Colors.white70,
                                    fontSize: cellSize * 0.45,
                                    fontWeight: isFound || isDragging ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
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
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a4a),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: _wordsToFind.map((word) {
                      final found = _foundWords.contains(word);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: found
                              ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: found
                                ? const Color(0xFF4ECDC4).withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            color: found ? const Color(0xFF4ECDC4) : Colors.white54,
                            fontSize: 12,
                            fontWeight: found ? FontWeight.bold : FontWeight.normal,
                            decoration: found ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
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
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return row * gridSize + col;
    }
    return null;
  }
}
