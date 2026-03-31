import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../services/local_data.dart';
import 'game_controller.dart';

class LevelController extends GetxController {
  final int gameId;
  final String gameSlug;
  final String? gameLanguage;

  LevelController({required this.gameId, required this.gameSlug, this.gameLanguage});

  bool get isQuiz => gameSlug == 'quiz';

  final difficulty = 'easy'.obs;
  final questions = <Question>[].obs;
  final isLoading = true.obs;
  final hasMore = true.obs;
  int _currentPage = 1;

  int get itemCount => questions.length;

  final _api = ApiService();
  GameController get _game => Get.find<GameController>();
  String get _language => gameLanguage ?? _game.language.value;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    if (gameLanguage == null) {
      ever(_game.language, (_) {
        _currentPage = 1;
        loadQuestions();
      });
    }
  }

  void changeDifficulty(String d) {
    difficulty.value = d;
    _currentPage = 1;
    loadQuestions();
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> loadQuestions() async {
    isLoading.value = true;

    final online = await _hasInternet();

    if (online) {
      final result = isQuiz
          ? await _api.getQuizQuestions(gameId, difficulty.value, _language, page: _currentPage)
          : await _api.getWordQuestions(gameId, difficulty.value, _language, page: _currentPage);

      if (result != null) {
        if (_currentPage == 1) {
          questions.value = result;
        } else {
          questions.addAll(result);
        }
        hasMore.value = result.length >= 10;
        isLoading.value = false;
        return;
      }
    }

    // Offline or API failed — use local data
    if (_currentPage == 1) {
      questions.value = LocalData.getQuestions(gameId, difficulty.value, _language);
    }
    hasMore.value = false;
    isLoading.value = false;
  }

  void loadMore() {
    if (hasMore.value && !isLoading.value) {
      _currentPage++;
      loadQuestions();
    }
  }
}
