import 'package:get/get.dart';
import '../models/puzzle_model.dart';

class QuizGameController extends GetxController {
  final Puzzle puzzle;
  final Function(bool) onAnswer;

  QuizGameController({required this.puzzle, required this.onAnswer});

  final selectedIndex = (-1).obs;
  final answered = false.obs;

  bool isCorrectOption(int index) {
    final options = puzzle.options ?? [];
    if (index < 0 || index >= options.length) return false;
    return options[index].toLowerCase() == puzzle.answer.toLowerCase();
  }

  void selectAnswer(int index) {
    if (answered.value) return;
    selectedIndex.value = index;
    answered.value = true;
    final correct = isCorrectOption(index);
    Future.delayed(const Duration(milliseconds: 800), () => onAnswer(correct));
  }
}
