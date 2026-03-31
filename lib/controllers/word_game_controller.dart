import 'package:brainplay/models/question_model.dart';
import 'package:get/get.dart';

class WordGameController extends GetxController {
  final Question question;
  final Function(bool) onAnswer;

  WordGameController({required this.question, required this.onAnswer});

  late final List<String> letters;
  late final RxList<bool> used;
  late final RxList<String?> slots;
  final answered = false.obs;
  final hintUsed = false.obs;

  String get hint {
    final meta = question.metadata;
    if (meta != null && meta['hint'] is String) return meta['hint'];
    return question.question;
  }

  @override
  void onInit() {
    super.onInit();
    final meta = question.metadata;
    if (meta != null && meta['letters'] is List) {
      letters = List<String>.from(meta['letters']);
    } else {
      final chars = question.answer.split('');
      chars.shuffle();
      letters = chars;
    }
    used = List.generate(letters.length, (_) => false).obs;
    slots = List.generate(question.answer.length, (_) => null).cast<String?>().obs;
  }

  bool get allFilled => slots.every((s) => s != null);

  /// Reveal the first empty slot with the correct letter.
  void useHint() {
    if (hintUsed.value || answered.value) return;
    hintUsed.value = true;
    final answer = question.answer;
    for (int i = 0; i < slots.length; i++) {
      if (slots[i] == null) {
        final correctLetter = answer[i];
        // Find this letter in available letters
        for (int j = 0; j < letters.length; j++) {
          if (!used[j] && letters[j].toLowerCase() == correctLetter.toLowerCase()) {
            used[j] = true;
            slots[i] = letters[j];
            return;
          }
        }
        // Fallback: place directly
        slots[i] = correctLetter;
        return;
      }
    }
  }

  void selectLetter(int index) {
    if (answered.value || used[index]) return;
    final emptySlot = slots.indexWhere((s) => s == null);
    if (emptySlot == -1) return;
    used[index] = true;
    slots[emptySlot] = letters[index];
  }

  void removeFromSlot(int index) {
    if (answered.value || slots[index] == null) return;
    final letter = slots[index]!;
    slots[index] = null;
    for (int i = 0; i < letters.length; i++) {
      if (letters[i] == letter && used[i]) {
        used[i] = false;
        break;
      }
    }
  }

  void submit() {
    if (!allFilled || answered.value) return;
    answered.value = true;
    final userAnswer = slots.join('');
    final correct = userAnswer.toLowerCase() == question.answer.toLowerCase();
    Future.delayed(const Duration(milliseconds: 500), () => onAnswer(correct));
  }
}
