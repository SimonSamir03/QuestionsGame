import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/puzzle_model.dart';
import '../controllers/word_game_controller.dart';

class WordGame extends StatelessWidget {
  final Puzzle puzzle;
  final Function(bool) onAnswer;
  const WordGame({super.key, required this.puzzle, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WordGameController(puzzle: puzzle, onAnswer: onAnswer), tag: 'wg_${puzzle.id}');
    final isAr = puzzle.language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Obx(() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
          children: List.generate(ctrl.letters.length, (i) => GestureDetector(
            onTap: () => ctrl.selectLetter(i),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: ctrl.used[i] ? const Color(0xFF6C63FF) : const Color(0xFF1e2a4a),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6C63FF), width: 2),
              ),
              child: Center(child: Text(ctrl.letters[i],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: ctrl.used[i] ? Colors.white : const Color(0xFF6C63FF)))),
            ),
          )),
        ),
        const SizedBox(height: 30),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
          children: List.generate(ctrl.slots.length, (i) => GestureDetector(
            onTap: () => ctrl.removeFromSlot(i),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: ctrl.slots[i] != null ? const Color(0xFF6C63FF).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ctrl.slots[i] != null ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.15), width: 2),
              ),
              child: Center(child: Text(ctrl.slots[i] ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF)))),
            ),
          )),
        ),
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: ctrl.allFilled ? ctrl.submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            disabledBackgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(isAr ? 'إرسال' : 'Submit', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        )),
      ])),
    );
  }
}
