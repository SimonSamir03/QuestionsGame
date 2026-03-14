import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/ads_service.dart';
import 'game_controller.dart';

class DailyRewardController extends GetxController {
  final _api = ApiService();
  final status = Rxn<Map<String, dynamic>>();
  final isLoading = true.obs;
  final isClaiming = false.obs;

  final schedule = <Map<String, dynamic>>[
    {'day': 1, 'amount': 20, 'type': 'coins'},
    {'day': 2, 'amount': 40, 'type': 'coins'},
    {'day': 3, 'amount': 60, 'type': 'coins'},
    {'day': 4, 'amount': 80, 'type': 'coins'},
    {'day': 5, 'amount': 100, 'type': 'coins'},
    {'day': 6, 'amount': 120, 'type': 'coins'},
    {'day': 7, 'amount': 200, 'type': 'mystery'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  Future<void> loadStatus() async {
    isLoading.value = true;
    final data = await _api.getDailyRewardStatus();
    status.value = data;
    isLoading.value = false;
  }

  Future<void> claimReward() async {
    isClaiming.value = true;
    final result = await _api.claimDailyReward();
    if (result != null) {
      final game = Get.find<GameController>();
      game.addCoins(result['reward']['amount'] as int);
      game.setStreakDays(result['streak_day'] as int);
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
}
