import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../models/daily_reward_status_model.dart';
import '../services/api_service.dart';
import '../services/ads_service.dart';
import 'game_controller.dart';

class DailyRewardController extends GetxController with GetTickerProviderStateMixin {
  final _api = ApiService();
  final status = Rxn<DailyRewardStatusModel>();
  final isLoading = true.obs;
  final isClaiming = false.obs;

  late AnimationController bounceController;
  late Animation<double> bounceAnim;

  static const _defaultSchedule = <Map<String, dynamic>>[
    {'day': 1, 'amount': 20,  'type': 'coins'},
    {'day': 2, 'amount': 40,  'type': 'coins'},
    {'day': 3, 'amount': 60,  'type': 'coins'},
    {'day': 4, 'amount': 80,  'type': 'coins'},
    {'day': 5, 'amount': 100, 'type': 'coins'},
    {'day': 6, 'amount': 120, 'type': 'coins'},
    {'day': 7, 'amount': 200, 'type': 'mystery'},
  ];

  List<Map<String, dynamic>> get schedule =>
      status.value?.schedule ?? _defaultSchedule;

  @override
  void onInit() {
    super.onInit();
    bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.easeInOut),
    );
    loadStatus();
  }

  Future<void> loadStatus() async {
    isLoading.value = true;
    final data = await _api.getDailyRewardStatus();
    if (data != null) status.value = DailyRewardStatusModel.fromJson(data);
    isLoading.value = false;
  }

  Future<void> claimReward() async {
    final game = Get.find<GameController>();
    if (!game.isOnline.value) {
      game.showOfflineRewardDialog();
      return;
    }
    isClaiming.value = true;
    final result = await _api.claimDailyReward();
    if (result != null) {
      final game = Get.find<GameController>();
      final reward = result['reward'] as Map<String, dynamic>?;
      game.addGems((reward?['amount'] as num?)?.toInt() ?? 0);
      game.setStreakDays((result['streak_day'] as num?)?.toInt() ?? 0);
      loadStatus();
    }
    isClaiming.value = false;
  }

  Future<void> restoreStreak() async {
    final watched = await AdsService().showRewarded();
    if (watched) {
      await _api.restoreStreak();
      loadStatus();
    }
  }

  @override
  void onClose() {
    bounceController.dispose();
    super.onClose();
  }
}
