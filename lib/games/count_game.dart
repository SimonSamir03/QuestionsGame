import 'package:flutter/material.dart';
import '../models/puzzle_model.dart';

class CountGame extends StatefulWidget {
  final Puzzle puzzle;
  final Function(bool) onAnswer;
  const CountGame({super.key, required this.puzzle, required this.onAnswer});

  @override
  State<CountGame> createState() => _CountGameState();
}

class _CountGameState extends State<CountGame> {
  int? _selected;
  bool _answered = false;

  static const _emojis = {
    'triangles': '🔺', 'circles': '🔵', 'squares': '🟦', 'rectangles': '🟩',
    'stars': '⭐', 'diamonds': '💎', 'hearts': '❤️',
    'مثلثات': '🔺', 'دوائر': '🔵', 'مربعات': '🟦', 'نجوم': '⭐', 'قلوب': '❤️',
  };

  String _getEmoji() {
    for (final e in _emojis.entries) {
      if (widget.puzzle.question.toLowerCase().contains(e.key)) return e.value;
    }
    return '🔷';
  }

  void _select(int i) {
    if (_answered) return;
    setState(() { _selected = i; _answered = true; });
    final options = widget.puzzle.options ?? [];
    final correct = options[i] == widget.puzzle.answer;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) widget.onAnswer(correct);
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.puzzle.options ?? [];
    final emoji = _getEmoji();
    final count = int.tryParse(widget.puzzle.answer) ?? 5;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
        children: List.generate(count, (_) => Text(emoji, style: const TextStyle(fontSize: 30)))),
      const SizedBox(height: 20),
      Text(widget.puzzle.question, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2),
        itemCount: options.length,
        itemBuilder: (_, i) {
          Color border = Colors.white.withOpacity(0.08);
          Color bg = const Color(0xFF1e2a4a);
          if (_answered) {
            if (options[i] == widget.puzzle.answer) { border = const Color(0xFF00C853); bg = const Color(0xFF00C853).withOpacity(0.15); }
            else if (i == _selected) { border = const Color(0xFFFF5252); bg = const Color(0xFFFF5252).withOpacity(0.15); }
          }
          return GestureDetector(onTap: () => _select(i), child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 2)),
            child: Center(child: Text(options[i], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
          ));
        },
      ),
    ]);
  }
}
