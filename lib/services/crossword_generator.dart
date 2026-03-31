import 'dart:math';
import 'classic_crossword_data.dart';

/// Auto-generates crossword grid positions from a list of words.
/// Input:  list of {answer, clue}
/// Output: ClassicCrosswordPuzzle with computed row/col/direction + grid size
class CrosswordGenerator {
  static ClassicCrosswordPuzzle generate({
    required String id,
    required String name,
    required String emoji,
    required List<Map<String, String>> clues,
    bool rtl = false,
  }) {
    final words = clues.map((c) => c['answer']!.toUpperCase()).toList();
    final placed = <_PlacedWord>[];
    int minRow = 0, maxRow = 0, minCol = 0, maxCol = 0;

    // Sort by length descending — longer words first for better intersections
    final indexed = List.generate(words.length, (i) => i);
    indexed.sort((a, b) => words[b].length.compareTo(words[a].length));

    for (final i in indexed) {
      final word = words[i];
      if (placed.isEmpty) {
        // Place first word horizontally at origin
        placed.add(_PlacedWord(word: word, index: i, row: 0, col: 0, direction: 'across'));
        maxCol = word.length - 1;
        continue;
      }

      final spot = _findBestSpot(word, placed);
      if (spot != null) {
        placed.add(_PlacedWord(word: word, index: spot.index, row: spot.row, col: spot.col, direction: spot.direction));
        // Update bounds
        if (spot.direction == 'across') {
          for (int c = 0; c < word.length; c++) {
            final col = spot.col + c;
            if (col < minCol) minCol = col;
            if (col > maxCol) maxCol = col;
          }
          if (spot.row < minRow) minRow = spot.row;
          if (spot.row > maxRow) maxRow = spot.row;
        } else {
          for (int r = 0; r < word.length; r++) {
            final row = spot.row + r;
            if (row < minRow) minRow = row;
            if (row > maxRow) maxRow = row;
          }
          if (spot.col < minCol) minCol = spot.col;
          if (spot.col > maxCol) maxCol = spot.col;
        }
      } else {
        // No intersection found — place below existing grid
        final newRow = maxRow + 2;
        final dir = placed.length.isOdd ? 'down' : 'across';
        placed.add(_PlacedWord(word: word, index: i, row: newRow, col: 0, direction: dir));
        if (dir == 'across') {
          final endCol = word.length - 1;
          if (endCol > maxCol) maxCol = endCol;
          if (newRow > maxRow) maxRow = newRow;
        } else {
          final endRow = newRow + word.length - 1;
          if (endRow > maxRow) maxRow = endRow;
        }
      }
    }

    // Normalize positions (shift so min is 0)
    final entries = <CrosswordEntry>[];
    int number = 1;

    // Sort placed words by position for consistent numbering
    placed.sort((a, b) {
      final rowCmp = a.row.compareTo(b.row);
      return rowCmp != 0 ? rowCmp : a.col.compareTo(b.col);
    });

    for (final p in placed) {
      final normalRow = p.row - minRow;
      final normalCol = p.col - minCol;
      entries.add(CrosswordEntry(
        number: number++,
        direction: p.direction,
        row: normalRow,
        col: rtl && p.direction == 'across' ? normalCol + p.word.length - 1 : normalCol,
        answer: p.word,
        clue: clues[p.index]['clue'] ?? '',
      ));
    }

    final gridRows = maxRow - minRow + 2; // +1 for size, +1 for padding
    final gridCols = maxCol - minCol + 2;
    final size = max(gridRows, gridCols).clamp(8, 15);

    return ClassicCrosswordPuzzle(
      id: id,
      name: name,
      emoji: emoji,
      gridRows: size,
      gridCols: size,
      entries: entries,
    );
  }

  static _Spot? _findBestSpot(String word, List<_PlacedWord> placed) {
    _Spot? best;
    int bestScore = -1;

    for (final existing in placed) {
      // Try to intersect: if existing is across, new should be down, and vice versa
      final newDir = existing.direction == 'across' ? 'down' : 'across';

      for (int ei = 0; ei < existing.word.length; ei++) {
        for (int wi = 0; wi < word.length; wi++) {
          if (existing.word[ei] != word[wi]) continue;

          // Found matching letter
          int newRow, newCol;
          if (newDir == 'down') {
            // existing is across, new word goes down
            newRow = existing.row - wi;
            newCol = existing.col + ei;
          } else {
            // existing is down, new word goes across
            newRow = existing.row + ei;
            newCol = existing.col - wi;
          }

          if (_canPlace(word, newRow, newCol, newDir, placed)) {
            // Score: prefer more intersections
            final score = _countIntersections(word, newRow, newCol, newDir, placed);
            if (score > bestScore) {
              bestScore = score;
              best = _Spot(
                index: placed.isEmpty ? 0 : word.length, // will be overwritten
                row: newRow,
                col: newCol,
                direction: newDir,
              );
            }
          }
        }
      }
    }

    // Fix index — find original index from the word in clues
    if (best != null) {
      // Index is set by caller
    }
    return best;
  }

  static bool _canPlace(String word, int row, int col, String dir, List<_PlacedWord> placed) {
    final cells = <String, String>{};
    for (final p in placed) {
      if (p.direction == 'across') {
        for (int i = 0; i < p.word.length; i++) {
          cells['${p.row},${p.col + i}'] = p.word[i];
        }
      } else {
        for (int i = 0; i < p.word.length; i++) {
          cells['${p.row + i},${p.col}'] = p.word[i];
        }
      }
    }

    for (int i = 0; i < word.length; i++) {
      final r = dir == 'down' ? row + i : row;
      final c = dir == 'across' ? col + i : col;
      final key = '$r,$c';
      if (cells.containsKey(key) && cells[key] != word[i]) {
        return false; // Conflict
      }

      // Check adjacent cells (no parallel touching)
      if (!cells.containsKey(key)) {
        if (dir == 'across') {
          // Check above and below
          if (cells.containsKey('${r - 1},$c') && !_isIntersection(r - 1, c, placed)) return false;
          if (cells.containsKey('${r + 1},$c') && !_isIntersection(r + 1, c, placed)) return false;
        } else {
          // Check left and right
          if (cells.containsKey('$r,${c - 1}') && !_isIntersection(r, c - 1, placed)) return false;
          if (cells.containsKey('$r,${c + 1}') && !_isIntersection(r, c + 1, placed)) return false;
        }
      }
    }

    // Check cell before and after word is empty
    if (dir == 'across') {
      if (cells.containsKey('$row,${col - 1}')) return false;
      if (cells.containsKey('$row,${col + word.length}')) return false;
    } else {
      if (cells.containsKey('${row - 1},$col')) return false;
      if (cells.containsKey('${row + word.length},$col')) return false;
    }

    return true;
  }

  static bool _isIntersection(int r, int c, List<_PlacedWord> placed) {
    int count = 0;
    for (final p in placed) {
      if (p.direction == 'across') {
        if (p.row == r && c >= p.col && c < p.col + p.word.length) count++;
      } else {
        if (p.col == c && r >= p.row && r < p.row + p.word.length) count++;
      }
    }
    return count > 0;
  }

  static int _countIntersections(String word, int row, int col, String dir, List<_PlacedWord> placed) {
    int count = 0;
    final cells = <String, String>{};
    for (final p in placed) {
      if (p.direction == 'across') {
        for (int i = 0; i < p.word.length; i++) {
          cells['${p.row},${p.col + i}'] = p.word[i];
        }
      } else {
        for (int i = 0; i < p.word.length; i++) {
          cells['${p.row + i},${p.col}'] = p.word[i];
        }
      }
    }
    for (int i = 0; i < word.length; i++) {
      final r = dir == 'down' ? row + i : row;
      final c = dir == 'across' ? col + i : col;
      if (cells.containsKey('$r,$c') && cells['$r,$c'] == word[i]) {
        count++;
      }
    }
    return count;
  }
}

class _PlacedWord {
  final String word;
  final int index; // original index in clues list
  final int row;
  final int col;
  final String direction;

  _PlacedWord({required this.word, required this.index, required this.row, required this.col, required this.direction});
}

class _Spot {
  final int index;
  final int row;
  final int col;
  final String direction;

  _Spot({required this.index, required this.row, required this.col, required this.direction});
}
