import 'package:get/get.dart';
import '../models/question_model.dart';

class QuizGameController extends GetxController {
  final Question question;
  final Function(bool) onAnswer;

  QuizGameController({required this.question, required this.onAnswer})
      : _shuffledIndices = List.generate(question.answers?.length ?? 0, (i) => i)..shuffle();

  final selectedIndex = (-1).obs;
  final answered = false.obs;
  final hintUsed = false.obs;
  final eliminatedIndexes = <int>{}.obs;

  /// Shuffled display order: _shuffledIndices[displayIndex] = originalIndex
  final List<int> _shuffledIndices;

  List<String> get options {
    final answers = question.answers;
    if (answers == null) return [];
    return _shuffledIndices.map((i) => answers[i].answerText).toList();
  }

  /// Check if the display index points to the correct answer.
  bool isCorrectOption(int displayIndex) {
    final answers = question.answers;
    if (answers == null || displayIndex < 0 || displayIndex >= _shuffledIndices.length) return false;
    return answers[_shuffledIndices[displayIndex]].isCorrect;
  }

  /// Eliminate 2 wrong answers as a hint.
  void useHint() {
    if (hintUsed.value || answered.value) return;
    hintUsed.value = true;
    final wrongDisplayIndexes = <int>[];
    for (int i = 0; i < _shuffledIndices.length; i++) {
      if (!isCorrectOption(i)) wrongDisplayIndexes.add(i);
    }
    wrongDisplayIndexes.shuffle();
    eliminatedIndexes.addAll(wrongDisplayIndexes.take(2));
  }

  void selectAnswer(int index) {
    if (answered.value) return;
    selectedIndex.value = index;
    answered.value = true;
    final correct = isCorrectOption(index);
    Future.delayed(const Duration(milliseconds: 800), () => onAnswer(correct));
  }
}
