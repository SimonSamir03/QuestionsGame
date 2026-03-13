import 'package:flutter/material.dart';
import '../models/puzzle_model.dart';

class WordGame extends StatefulWidget {
  final Puzzle puzzle;
  final Function(bool) onAnswer;
  const WordGame({super.key, required this.puzzle, required this.onAnswer});

  @override
  State<WordGame> createState() => _WordGameState();
}

class _WordGameState extends State<WordGame> {
  late List<String> _letters;
  late List<bool> _used;
  late List<String?> _slots;

  @override
  void initState() {
    super.initState();
    _letters = widget.puzzle.question.split('').where((l) => l.trim().isNotEmpty).toList();
    _used = List.filled(_letters.length, false);
    _slots = List.filled(widget.puzzle.answer.length, null);
  }

  void _selectLetter(int index) {
    if (_used[index]) return;
    final emptySlot = _slots.indexWhere((s) => s == null);
    if (emptySlot == -1) return;
    setState(() { _used[index] = true; _slots[emptySlot] = _letters[index]; });
  }

  void _removeFromSlot(int index) {
    if (_slots[index] == null) return;
    final letter = _slots[index]!;
    for (int i = 0; i < _letters.length; i++) {
      if (_letters[i] == letter && _used[i]) {
        setState(() { _used[i] = false; _slots[index] = null; });
        break;
      }
    }
  }

  void _submit() {
    final answer = _slots.where((s) => s != null).join('').toLowerCase();
    widget.onAnswer(answer == widget.puzzle.answer.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final allFilled = !_slots.contains(null);
    final isAr = widget.puzzle.language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
          children: List.generate(_letters.length, (i) => GestureDetector(
            onTap: () => _selectLetter(i),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _used[i] ? const Color(0xFF6C63FF) : const Color(0xFF1e2a4a),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6C63FF), width: 2),
              ),
              child: Center(child: Text(_letters[i],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: _used[i] ? Colors.white : const Color(0xFF6C63FF)))),
            ),
          )),
        ),
        const SizedBox(height: 30),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
          children: List.generate(_slots.length, (i) => GestureDetector(
            onTap: () => _removeFromSlot(i),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _slots[i] != null ? const Color(0xFF6C63FF).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _slots[i] != null ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.15), width: 2),
              ),
              child: Center(child: Text(_slots[i] ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF)))),
            ),
          )),
        ),
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: allFilled ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            disabledBackgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(isAr ? 'إرسال' : 'Submit', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        )),
      ]),
    );
  }
}
