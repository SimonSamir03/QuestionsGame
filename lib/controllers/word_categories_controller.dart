import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/sound_service.dart';
import '../services/ads_service.dart';
import '../services/local_puzzles.dart';

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
  final timeLeft = 30.obs;
  final isLoading = true.obs;
  final isSubmitted = false.obs;
  final isTimeUp = false.obs;
  final results = Rxn<Map<String, dynamic>>();

  Timer? _timer;

  bool get isAr => language == 'ar';

  @override
  void onInit() {
    super.onInit();
    _fetchLetter();
  }

  Future<void> _fetchLetter() async {
    var data = await _api.getRandomLetter(language);
    data ??= LocalPuzzles.getRandomLetter(language);
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
      results.value = result;
      final correctCount = result['correct_count'] as int;
      final won = result['won'] as bool? ?? (correctCount == categories.length);
      if (won) {
        SoundService().playLevelComplete();
      } else {
        SoundService().playWrong();
      }
      await Future.delayed(const Duration(seconds: 3));
      onRoundEnd(result['score'] as int, correctCount, won);
    } else {
      // Offline fallback
      final Map<String, dynamic> localResults = {};
      for (var cat in categories) {
        localResults[cat] = {'answer': answers[cat] ?? '', 'correct': false};
      }
      SoundService().playWrong();
      results.value = {
        'score': 0,
        'won': false,
        'correct_count': 0,
        'total_categories': categories.length,
        'results': localResults,
      };
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
