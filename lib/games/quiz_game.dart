import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/puzzle_model.dart';
import '../controllers/quiz_game_controller.dart';

class QuizGame extends StatelessWidget {
  final Puzzle puzzle;
  final Function(bool) onAnswer;
  const QuizGame({super.key, required this.puzzle, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(QuizGameController(puzzle: puzzle, onAnswer: onAnswer), tag: 'qg_${puzzle.id}');
    final options = puzzle.options ?? [];
    const letters = ['A', 'B', 'C', 'D'];

    return Obx(() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(puzzle.question, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.6)),
      const SizedBox(height: 30),
      ...List.generate(options.length, (i) {
        Color border = Colors.white.withValues(alpha: 0.08);
        Color bg = const Color(0xFF1e2a4a);
        if (ctrl.answered.value) {
          if (ctrl.isCorrectOption(i)) { border = const Color(0xFF00C853); bg = const Color(0xFF00C853).withValues(alpha: 0.15); }
          else if (i == ctrl.selectedIndex.value) { border = const Color(0xFFFF5252); bg = const Color(0xFFFF5252).withValues(alpha: 0.15); }
        }
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
          onTap: () => ctrl.selectAnswer(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 2)),
            child: Row(children: [
              CircleAvatar(radius: 15, backgroundColor: Colors.white.withValues(alpha: 0.06),
                child: Text(letters[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(child: Text(options[i], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            ]),
          ),
        ));
      }),
    ]));
  }
}
