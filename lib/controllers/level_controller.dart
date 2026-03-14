import 'package:get/get.dart';
import '../models/puzzle_model.dart';
import '../services/api_service.dart';
import '../services/local_puzzles.dart';
import 'game_controller.dart';

class LevelController extends GetxController {
  final String gameType;

  LevelController({required this.gameType});

  final difficulty = 'easy'.obs;
  final puzzles = <Puzzle>[].obs;
  final isLoading = true.obs;
  final hasMore = true.obs;
  int _currentPage = 1;

  final _api = ApiService();
  GameController get _game => Get.find<GameController>();
  String get _language => _game.language.value;

  @override
  void onInit() {
    super.onInit();
    loadPuzzles();
  }

  void changeDifficulty(String d) {
    difficulty.value = d;
    _currentPage = 1;
    loadPuzzles();
  }

  Future<void> loadPuzzles() async {
    isLoading.value = true;

    final result = await _api.getPuzzles(
      gameType, difficulty.value, _language, page: _currentPage,
    );

    if (result != null) {
      if (_currentPage == 1) {
        puzzles.value = result;
      } else {
        puzzles.addAll(result);
      }
      hasMore.value = result.length >= 20;
    } else {
      // Try local puzzles
      final fallback = LocalPuzzles.getPuzzles(gameType, difficulty.value, _language);
      puzzles.value = fallback;
      hasMore.value = false;
    }

    isLoading.value = false;
  }

  void loadMore() {
    if (hasMore.value && !isLoading.value) {
      _currentPage++;
      loadPuzzles();
    }
  }
}
