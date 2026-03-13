import 'package:flutter/material.dart';
import '../services/classic_crossword_data.dart';

class ClassicCrosswordGame extends StatefulWidget {
  final ClassicCrosswordPuzzle puzzle;
  final String language;

  const ClassicCrosswordGame({super.key, required this.puzzle, required this.language});

  @override
  State<ClassicCrosswordGame> createState() => _ClassicCrosswordGameState();
}

class _ClassicCrosswordGameState extends State<ClassicCrosswordGame> {
  late Map<String, String> _activeCells; // "row,col" -> correct letter
  late Map<String, int> _cellNumbers;    // "row,col" -> number
  late Map<String, String> _userInput;   // "row,col" -> user typed letter
  String? _selectedCell;                 // "row,col"
  String _selectedDirection = 'across';
  CrosswordEntry? _selectedEntry;
  // On-screen keyboard only (mobile)

  @override
  void initState() {
    super.initState();
    _activeCells = widget.puzzle.activeCells;
    _cellNumbers = widget.puzzle.cellNumbers;
    _userInput = {};
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectCell(String key) {
    if (!_activeCells.containsKey(key)) return;
    setState(() {
      if (_selectedCell == key) {
        // Toggle direction on re-tap
        _selectedDirection = _selectedDirection == 'across' ? 'down' : 'across';
      }
      _selectedCell = key;
      _selectedEntry = _findEntryForCell(key, _selectedDirection);
      // If no entry in this direction, try the other
      if (_selectedEntry == null) {
        _selectedDirection = _selectedDirection == 'across' ? 'down' : 'across';
        _selectedEntry = _findEntryForCell(key, _selectedDirection);
      }
    });
    // focus
  }

  CrosswordEntry? _findEntryForCell(String key, String direction) {
    final parts = key.split(',');
    final row = int.parse(parts[0]);
    final col = int.parse(parts[1]);

    for (final entry in widget.puzzle.entries) {
      if (entry.direction != direction) continue;
      for (int i = 0; i < entry.length; i++) {
        final r = entry.direction == 'down' ? entry.row + i : entry.row;
        final c = entry.direction == 'across' ? entry.col + i : entry.col;
        if (r == row && c == col) return entry;
      }
    }
    return null;
  }

  Set<String> _getEntryCells(CrosswordEntry entry) {
    final cells = <String>{};
    for (int i = 0; i < entry.length; i++) {
      final r = entry.direction == 'down' ? entry.row + i : entry.row;
      final c = entry.direction == 'across' ? entry.col + i : entry.col;
      cells.add('$r,$c');
    }
    return cells;
  }

  void _handleKeyInput(String letter) {
    if (_selectedCell == null || _selectedEntry == null) return;

    setState(() {
      _userInput[_selectedCell!] = letter.toUpperCase();
      _moveToNextCell();
    });

    _checkCompletion();
  }

  void _handleBackspace() {
    if (_selectedCell == null || _selectedEntry == null) return;

    setState(() {
      if (_userInput.containsKey(_selectedCell!) && _userInput[_selectedCell!]!.isNotEmpty) {
        _userInput[_selectedCell!] = '';
      } else {
        _moveToPrevCell();
        if (_selectedCell != null) {
          _userInput[_selectedCell!] = '';
        }
      }
    });
  }

  void _moveToNextCell() {
    if (_selectedCell == null || _selectedEntry == null) return;
    final parts = _selectedCell!.split(',');
    final row = int.parse(parts[0]);
    final col = int.parse(parts[1]);

    final nextRow = _selectedDirection == 'down' ? row + 1 : row;
    final nextCol = _selectedDirection == 'across' ? col + 1 : col;
    final nextKey = '$nextRow,$nextCol';

    if (_activeCells.containsKey(nextKey)) {
      _selectedCell = nextKey;
    }
  }

  void _moveToPrevCell() {
    if (_selectedCell == null || _selectedEntry == null) return;
    final parts = _selectedCell!.split(',');
    final row = int.parse(parts[0]);
    final col = int.parse(parts[1]);

    final prevRow = _selectedDirection == 'down' ? row - 1 : row;
    final prevCol = _selectedDirection == 'across' ? col - 1 : col;
    final prevKey = '$prevRow,$prevCol';

    if (_activeCells.containsKey(prevKey)) {
      _selectedCell = prevKey;
    }
  }

  void _checkCompletion() {
    bool allCorrect = true;
    for (final entry in _activeCells.entries) {
      final userChar = _userInput[entry.key] ?? '';
      if (userChar.toUpperCase() != entry.value.toUpperCase()) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showCompleteDialog();
      });
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

  @override
  Widget build(BuildContext context) {
    final isAr = widget.language == 'ar';
    final entryCells = _selectedEntry != null ? _getEntryCells(_selectedEntry!) : <String>{};

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
          children: [
            // Clue display
            if (_selectedEntry != null)
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
                  '${_selectedEntry!.number}. ${_selectedEntry!.direction == 'across' ? (isAr ? 'أفقي' : 'Across') : (isAr ? 'رأسي' : 'Down')}: ${isAr ? _selectedEntry!.clueAr : _selectedEntry!.clueEn}',
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
                    final cellSize = maxSize / widget.puzzle.gridCols;

                    return Center(
                      child: SizedBox(
                        width: cellSize * widget.puzzle.gridCols,
                        height: cellSize * widget.puzzle.gridRows,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.puzzle.gridCols,
                          ),
                          itemCount: widget.puzzle.gridRows * widget.puzzle.gridCols,
                          itemBuilder: (ctx, index) {
                            final row = index ~/ widget.puzzle.gridCols;
                            final col = index % widget.puzzle.gridCols;
                            final key = '$row,$col';
                            final isActive = _activeCells.containsKey(key);
                            final number = _cellNumbers[key];
                            final isSelected = _selectedCell == key;
                            final isHighlighted = entryCells.contains(key);
                            final userLetter = _userInput[key] ?? '';
                            final correctLetter = _activeCells[key] ?? '';
                            final isCorrect = userLetter.toUpperCase() == correctLetter.toUpperCase() && userLetter.isNotEmpty;

                            if (!isActive) {
                              return Container(
                                margin: const EdgeInsets.all(0.5),
                                color: const Color(0xFF0d0d1a),
                              );
                            }

                            return GestureDetector(
                              onTap: () => _selectCell(key),
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
                                    // Number
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
                                    // Letter
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
              child: _buildClueList(isAr),
            ),

            // Keyboard
            _buildKeyboard(),
          ],
        ),
      );
  }

  Widget _buildClueList(bool isAr) {
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
                  _buildClueTab(widget.puzzle.across, isAr),
                  _buildClueTab(widget.puzzle.down, isAr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClueTab(List<CrosswordEntry> entries, bool isAr) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: entries.length,
      itemBuilder: (ctx, i) {
        final entry = entries[i];
        final isEntryComplete = _isEntryComplete(entry);
        final isEntrySelected = _selectedEntry == entry;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCell = '${entry.row},${entry.col}';
              _selectedDirection = entry.direction;
              _selectedEntry = entry;
            });
            // focus
          },
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

  bool _isEntryComplete(CrosswordEntry entry) {
    for (int i = 0; i < entry.length; i++) {
      final r = entry.direction == 'down' ? entry.row + i : entry.row;
      final c = entry.direction == 'across' ? entry.col + i : entry.col;
      final key = '$r,$c';
      final user = _userInput[key] ?? '';
      final correct = _activeCells[key] ?? '';
      if (user.toUpperCase() != correct.toUpperCase()) return false;
    }
    return true;
  }

  Widget _buildKeyboard() {
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
                    _handleBackspace();
                  } else {
                    _handleKeyInput(key);
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
}
