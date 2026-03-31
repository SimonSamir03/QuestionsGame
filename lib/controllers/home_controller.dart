import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/game_model.dart';
import '../services/api_service.dart';
import 'game_controller.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController pulseController;
  late Animation<double> pulseAnim;

  final games = <GameModel>[].obs;
  final isLoadingGames = true.obs;

  /* static const _fallback = [
    {'id': 1, 'slug': 'word_rearrange', 'emoji': '\u{1f524}', 'name': 'word_rearrange', 'description': null},
    {'id': 2, 'slug': 'quiz',           'emoji': '\u2753',     'name': 'quiz',           'description': null},
    {'id': 4, 'slug': 'word_categories','emoji': '\u{1f170}',  'name': 'word_categories','description': null},
    {'id': 5, 'slug': 'crossword',      'emoji': '\u{1f50d}',  'name': 'crossword',      'description': null},
    {'id': 7, 'slug': 'block_puzzle',   'emoji': '\u{1f7e6}',  'name': 'block_puzzle',   'description': null},
    {'id': 8, 'slug': 'domino',         'emoji': '\u{1f0a1}',  'name': 'domino',         'description': null},
  ]; */

  @override
  void onInit() {
    super.onInit();
    pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
    loadGames();
    ever(Get.find<GameController>().language, (_) => loadGames());
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> loadGames() async {
    isLoadingGames.value = true;

    final online = await _hasInternet();

    if (online) {
      final data = await ApiService().getGames();
      if (data != null && data.isNotEmpty) {
        games.value = data
            .map((e) => GameModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        isLoadingGames.value = false;
        return;
      }
    }

    // Offline or API failed — use local fallback
    /* games.value = _fallback
        .map((e) => GameModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(); */
    isLoadingGames.value = false;
  }

  @override
  void onClose() {
    pulseController.dispose();
    super.onClose();
  }
}
