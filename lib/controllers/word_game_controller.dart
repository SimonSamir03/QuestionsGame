import 'package:get/get.dart';
import '../models/puzzle_model.dart';

class WordGameController extends GetxController {
  final Puzzle puzzle;
  final Function(bool) onAnswer;

  WordGameController({required this.puzzle, required this.onAnswer});

  late final List<String> letters;
  late final RxList<bool> used;
  late final RxList<String?> slots;
  final answered = false.obs;

  @override
  void onInit() {
    super.onInit();
    final chars = puzzle.answer.split('');
    chars.shuffle();
    letters = chars;
    used = List.generate(chars.length, (_) => false).obs;
    slots = List.generate(puzzle.answer.length, (_) => null).cast<String?>().obs;
  }

  bool get allFilled => slots.every((s) => s != null);

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
    final correct = userAnswer.toLowerCase() == puzzle.answer.toLowerCase();
    Future.delayed(const Duration(milliseconds: 500), () => onAnswer(correct));
  }
}
