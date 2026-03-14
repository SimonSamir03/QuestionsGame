import 'dart:math';
import 'package:get/get.dart';
import '../services/crossword_data.dart';

class CrosswordController extends GetxController {
  static const int gridSize = 12;

  final CrosswordCategory category;
  final String language;

  CrosswordController({required this.category, required this.language});

  late final List<List<String>> grid;
  late final List<String> wordsToFind;
  final foundWords = <String>[].obs;
  final foundCells = <int>{}.obs;
  final currentDragCells = <int>[].obs;

  int? _dragStartCell;

  @override
  void onInit() {
    super.onInit();
    wordsToFind = category.getWords(language);
    grid = _generateGrid();
  }

  List<List<String>> _generateGrid() {
    final rng = Random();
    final g = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    final placed = <String, List<int>>{};

    final directions = [
      [0, 1],   // right
      [1, 0],   // down
      [1, 1],   // diagonal down-right
      [-1, 1],  // diagonal up-right
    ];

    for (final word in wordsToFind) {
      bool wordPlaced = false;
      for (int attempt = 0; attempt < 100; attempt++) {
        final dir = directions[rng.nextInt(directions.length)];
        final maxRow = gridSize - (dir[0] == 1 ? word.length : (dir[0] == -1 ? 0 : 1));
        final minRow = dir[0] == -1 ? word.length - 1 : 0;
        final maxCol = gridSize - (dir[1] == 1 ? word.length : 1);

        if (maxRow < minRow || maxCol < 0) continue;

        final startRow = minRow + rng.nextInt(maxRow - minRow + 1);
        final startCol = rng.nextInt(maxCol + 1);

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final r = startRow + dir[0] * i;
          final c = startCol + dir[1] * i;
          if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) {
            canPlace = false;
            break;
          }
          if (g[r][c].isNotEmpty && g[r][c] != word[i].toUpperCase()) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          final cells = <int>[];
          for (int i = 0; i < word.length; i++) {
            final r = startRow + dir[0] * i;
            final c = startCol + dir[1] * i;
            g[r][c] = word[i].toUpperCase();
            cells.add(r * gridSize + c);
          }
          placed[word] = cells;
          wordPlaced = true;
          break;
        }
      }

      if (!wordPlaced) {
        // Force place in first available row
        for (int r = 0; r < gridSize; r++) {
          if (gridSize - 0 >= word.length) {
            bool ok = true;
            for (int i = 0; i < word.length; i++) {
              if (g[r][i].isNotEmpty && g[r][i] != word[i].toUpperCase()) {
                ok = false;
                break;
              }
            }
            if (ok) {
              final cells = <int>[];
              for (int i = 0; i < word.length; i++) {
                g[r][i] = word[i].toUpperCase();
                cells.add(r * gridSize + i);
              }
              placed[word] = cells;
              break;
            }
          }
        }
      }
    }

    // Fill empties
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const arLetters = 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي';
    final fillFrom = language == 'ar' ? arLetters : letters;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (g[r][c].isEmpty) {
          g[r][c] = fillFrom[rng.nextInt(fillFrom.length)];
        }
      }
    }

    return g;
  }

  void onDragStart(int cell) {
    _dragStartCell = cell;
    currentDragCells.value = [cell];
  }

  void onDragUpdate(int cell) {
    if (_dragStartCell == null) return;
    final startRow = _dragStartCell! ~/ gridSize;
    final startCol = _dragStartCell! % gridSize;
    final endRow = cell ~/ gridSize;
    final endCol = cell % gridSize;

    final dRow = (endRow - startRow).sign;
    final dCol = (endCol - startCol).sign;

    if (dRow == 0 && dCol == 0) {
      currentDragCells.value = [_dragStartCell!];
      return;
    }

    // Only allow straight lines
    if (dRow != 0 && dCol != 0 && (endRow - startRow).abs() != (endCol - startCol).abs()) return;

    final cells = <int>[];
    int r = startRow, c = startCol;
    while (true) {
      cells.add(r * gridSize + c);
      if (r == endRow && c == endCol) break;
      r += dRow;
      c += dCol;
      if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) break;
    }
    currentDragCells.value = cells;
  }

  void onDragEnd() {
    final selectedWord = currentDragCells.map((i) => grid[i ~/ gridSize][i % gridSize]).join('');
    final reversedWord = currentDragCells.reversed.map((i) => grid[i ~/ gridSize][i % gridSize]).join('');

    for (final word in wordsToFind) {
      if (!foundWords.contains(word)) {
        if (selectedWord.toUpperCase() == word.toUpperCase() ||
            reversedWord.toUpperCase() == word.toUpperCase()) {
          foundWords.add(word);
          foundCells.addAll(currentDragCells);
          break;
        }
      }
    }

    currentDragCells.clear();
    _dragStartCell = null;
  }
}
