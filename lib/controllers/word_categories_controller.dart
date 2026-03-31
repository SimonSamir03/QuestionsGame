import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';
import '../models/word_category_result_model.dart';
import '../services/api_service.dart';
import '../services/sound_service.dart';
import '../services/ads_service.dart';
import '../services/local_data.dart';
import 'game_controller.dart';

class WordCategoriesController extends GetxController {
  final String language;
  final Function(int score, int correctCount, bool won) onRoundEnd;
  final VoidCallback onTimeUpGoBack;

  WordCategoriesController({
    required this.language,
    required this.onRoundEnd,
    required this.onTimeUpGoBack,
  });

  final _api = ApiService();
  final letter = Rxn<String>();
  final categories = <String>[].obs;
  final answers = <String, String>{}.obs;
  late final timeLeft = Get.find<GameController>().wordCategoryTimer.obs;
  final isLoading = true.obs;
  final isSubmitted = false.obs;
  final isTimeUp = false.obs;
  final results = Rxn<WordCategoryResultModel>();
  final hintUsed = false.obs;
  final hintText = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _fetchLetter();
  }

  Future<void> _fetchLetter() async {
    var data = await _api.getRandomLetter(language);
    data ??= LocalData.getRandomLetter(language);
    if (data != null) {
      letter.value = data['letter'];
      categories.value = List<String>.from(data['categories']);
      for (var cat in categories) {
        answers[cat] = '';
      }
      isLoading.value = false;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft.value--;
      if (timeLeft.value <= 5 && timeLeft.value > 0) {
        SoundService().playCountdown();
      }
      if (timeLeft.value <= 0) {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    if (isSubmitted.value || isTimeUp.value) return;
    SoundService().playWrong();
    isTimeUp.value = true;
  }

  Future<void> addExtraTime() async {
    final watched = await AdsService().showRewarded();
    if (watched) {
      isTimeUp.value = false;
      timeLeft.value = 15;
      _startTimer();
    }
  }

  /// Show the first letter of the current round's letter as a reminder hint.
  void useHint() {
    if (hintUsed.value || letter.value == null) return;
    hintUsed.value = true;
    // Hint: fill the first empty category with the letter itself as a starter
    for (final cat in categories) {
      if ((answers[cat] ?? '').isEmpty) {
        final l = letter.value!;
        hintText.value = language == 'ar'
            ? '$cat: $l...'
            : '$cat: $l...';
        return;
      }
    }
  }

  void updateAnswer(String category, String value) {
    answers[category] = value;
  }

  Future<void> submitRound() async {
    if (isSubmitted.value) return;
    isSubmitted.value = true;
    isTimeUp.value = false;
    _timer?.cancel();

    final result = await _api.submitWordCategoryRound(
      letter.value!,
      language,
      Map<String, String>.from(answers),
    );

    if (result != null) {
      final parsed = WordCategoryResultModel.fromJson(result);
      results.value = parsed;
      if (parsed.won) {
        SoundService().playLevelComplete();
      } else {
        SoundService().playWrong();
      }
      await Future.delayed(const Duration(seconds: 3));
      onRoundEnd(parsed.score, parsed.correctCount, parsed.won);
    } else {
      // Offline fallback
      results.value = WordCategoryResultModel(
        letter: letter.value ?? '',
        correctCount: 0,
        total: categories.length,
        score: 0,
        won: false,
        coinsEarned: 0,
        results: {
          for (var cat in categories)
            cat: CategoryResult(answer: answers[cat] ?? '', isValid: false),
        },
      );
      SoundService().playWrong();
      await Future.delayed(const Duration(seconds: 3));
      onRoundEnd(0, 0, false);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
