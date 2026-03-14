import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/puzzle_model.dart';
import '../controllers/count_game_controller.dart';

class CountGame extends StatelessWidget {
  final Puzzle puzzle;
  final Function(bool) onAnswer;
  const CountGame({super.key, required this.puzzle, required this.onAnswer});

  static const _emojis = {
    'triangles': '🔺', 'circles': '🔵', 'squares': '🟦', 'rectangles': '🟩',
    'stars': '⭐', 'diamonds': '💎', 'hearts': '❤️',
    'مثلثات': '🔺', 'دوائر': '🔵', 'مربعات': '🟦', 'نجوم': '⭐', 'قلوب': '❤️',
  };

  String _getEmoji() {
    for (final e in _emojis.entries) {
      if (puzzle.question.toLowerCase().contains(e.key)) return e.value;
    }
    return '🔷';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CountGameController(puzzle: puzzle, onAnswer: onAnswer), tag: 'cg_${puzzle.id}');
    final options = puzzle.options ?? [];
    final emoji = _getEmoji();
    final count = int.tryParse(puzzle.answer) ?? 5;

    return Obx(() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
        children: List.generate(count, (_) => Text(emoji, style: const TextStyle(fontSize: 30)))),
      const SizedBox(height: 20),
      Text(puzzle.question, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2),
        itemCount: options.length,
        itemBuilder: (_, i) {
          Color border = Colors.white.withValues(alpha: .08);
          Color bg = const Color(0xFF1e2a4a);
          if (ctrl.answered.value) {
            if (ctrl.isCorrectOption(i)) { border = const Color(0xFF00C853); bg = const Color(0xFF00C853).withValues(alpha: 0.15); }
            else if (i == ctrl.selectedIndex.value) { border = const Color(0xFFFF5252); bg = const Color(0xFFFF5252).withValues(alpha: 0.15); }
          }
          return GestureDetector(onTap: () => ctrl.selectAnswer(i), child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 2)),
            child: Center(child: Text(options[i], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
          ));
        },
      ),
    ]));
  }
}
