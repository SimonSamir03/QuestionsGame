import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/game_model.dart';
import '../services/api_service.dart';
import 'home_controller.dart';

class LeaderboardController extends GetxController with GetTickerProviderStateMixin {
  final _api = ApiService();
  final leaderboard = <LeaderboardEntryModel>[].obs;
  final isLoading = true.obs;
  final currentPeriod = 'global'.obs;
  final selectedGameId = Rxn<int>(); // null = all games

  final periods = ['daily', 'weekly', 'monthly', 'global'];

  late TabController tabController;

  List<GameModel> get games {
    try {
      return Get.find<HomeController>().games;
    } catch (_) {
      return [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        changePeriod(periods[tabController.index]);
      }
    });
    loadLeaderboard();
  }

  void changePeriod(String period) {
    currentPeriod.value = period;
    loadLeaderboard();
  }

  void changeGame(int? gameId) {
    selectedGameId.value = gameId;
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    final data = await _api.getLeaderboard(
      period: currentPeriod.value,
      gameId: selectedGameId.value,
    );
    if (data != null) {
      final raw = data['leaderboard'] as List? ?? [];
      leaderboard.value = raw
          .map((e) => LeaderboardEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
