import 'package:get/get.dart';
import '../services/classic_crossword_data.dart';

class ClassicCrosswordController extends GetxController {
  final ClassicCrosswordPuzzle puzzle;
  final String language;

  ClassicCrosswordController({required this.puzzle, required this.language});

  bool get isAr => language == 'ar';

  late final Map<String, String> activeCellsMap;
  late final Map<String, int> cellNumbers;
  final userInput = <String, String>{}.obs;
  final selectedCell = Rxn<String>();
  final selectedDirection = 'across'.obs;
  final selectedEntry = Rxn<CrosswordEntry>();
  final isComplete = false.obs;
  final hintUsed = false.obs;
  final hintCells = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    activeCellsMap = puzzle.activeCells(rtlAcross: isAr);
    cellNumbers = puzzle.cellNumbers;
  }

  void selectCell(String key) {
    if (!activeCellsMap.containsKey(key)) return;
    if (selectedCell.value == key) {
      selectedDirection.value = selectedDirection.value == 'across' ? 'down' : 'across';
    }
    selectedCell.value = key;
    selectedEntry.value = _findEntryForCell(key, selectedDirection.value);
    if (selectedEntry.value == null) {
      selectedDirection.value = selectedDirection.value == 'across' ? 'down' : 'across';
      selectedEntry.value = _findEntryForCell(key, selectedDirection.value);
    }
  }

  CrosswordEntry? _findEntryForCell(String key, String direction) {
    final parts = key.split(',');
    final row = int.parse(parts[0]);
    final col = int.parse(parts[1]);

    for (final entry in puzzle.entries) {
      if (entry.direction != direction) continue;
      for (int i = 0; i < entry.length; i++) {
        final r = entry.direction == 'down' ? entry.row + i : entry.row;
        final c = entry.direction == 'across'
            ? (isAr ? entry.col - i : entry.col + i)
            : entry.col;
        if (r == row && c == col) return entry;
      }
    }
    return null;
  }

  Set<String> getEntryCells(CrosswordEntry entry) {
    final cells = <String>{};
    for (int i = 0; i < entry.length; i++) {
      final r = entry.direction == 'down' ? entry.row + i : entry.row;
      final c = entry.direction == 'across'
          ? (isAr ? entry.col - i : entry.col + i)
          : entry.col;
      cells.add('$r,$c');
    }
    return cells;
  }

  void handleKeyInput(String letter) {
    if (selectedCell.value == null || selectedEntry.value == null) return;
    final updated = Map<String, String>.from(userInput);
    updated[selectedCell.value!] = letter;
    userInput.value = updated;
    _moveToNextCell();
    _checkCompletion();
  }

  void handleBackspace() {
    if (selectedCell.value == null || selectedEntry.value == null) return;
    final updated = Map<String, String>.from(userInput);
    if (updated.containsKey(selectedCell.value!) && (updated[selectedCell.value!] ?? '').isNotEmpty) {
      updated[selectedCell.value!] = '';
      userInput.value = updated;
    } else {
      _moveToPrevCell();
      if (selectedCell.value != null) {
        updated[selectedCell.value!] = '';
        userInput.value = updated;
      }
    }
  }

  void _moveToNextCell() {
    if (selectedCell.value == null) return;
    final parts = selectedCell.value!.split(',');
    final row = int.parse(parts[0]);
    final col = int.parse(parts[1]);

    final nextRow = selectedDirection.value == 'down' ? row + 1 : row;
    final nextCol = selectedDirection.value == 'across'
        ? (isAr ? col - 1 : col + 1)
        : col;
    final nextKey = '$nextRow,$nextCol';
    if (activeCellsMap.containsKey(nextKey)) {
      selectedCell.value = nextKey;
    }
  }

  void _moveToPrevCell() {
    if (selectedCell.value == null) return;
    final parts = selectedCell.value!.split(',');
    final row = int.parse(parts[0]);
    final col = int.parse(parts[1]);

    final prevRow = selectedDirection.value == 'down' ? row - 1 : row;
    final prevCol = selectedDirection.value == 'across'
        ? (isAr ? col + 1 : col - 1)
        : col;
    final prevKey = '$prevRow,$prevCol';
    if (activeCellsMap.containsKey(prevKey)) {
      selectedCell.value = prevKey;
    }
  }

  void _checkCompletion() {
    for (final entry in activeCellsMap.entries) {
      final userChar = userInput[entry.key] ?? '';
      if (userChar != entry.value) return;
    }
    isComplete.value = true;
  }

  bool isEntryComplete(CrosswordEntry entry) {
    for (int i = 0; i < entry.length; i++) {
      final r = entry.direction == 'down' ? entry.row + i : entry.row;
      final c = entry.direction == 'across'
          ? (isAr ? entry.col - i : entry.col + i)
          : entry.col;
      final key = '$r,$c';
      final user = userInput[key] ?? '';
      final correct = activeCellsMap[key] ?? '';
      if (user != correct) return false;
    }
    return true;
  }

  /// Reveal one empty/wrong cell in the currently selected entry.
  void useHint() {
    if (hintUsed.value) return;
    final entry = selectedEntry.value;
    if (entry == null) return;
    hintUsed.value = true;
    final cells = getEntryCells(entry);
    for (final key in cells) {
      final correct = activeCellsMap[key] ?? '';
      final current = userInput[key] ?? '';
      if (current != correct) {
        final updated = Map<String, String>.from(userInput);
        updated[key] = correct;
        userInput.value = updated;
        hintCells.add(key);
        _checkCompletion();
        return;
      }
    }
  }

  void selectEntry(CrosswordEntry entry) {
    selectedCell.value = '${entry.row},${entry.col}';
    selectedDirection.value = entry.direction;
    selectedEntry.value = entry;
  }
}
