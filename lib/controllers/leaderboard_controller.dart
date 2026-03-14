import 'package:get/get.dart';
import '../services/api_service.dart';

class LeaderboardController extends GetxController {
  final _api = ApiService();
  final leaderboard = <dynamic>[].obs;
  final isLoading = true.obs;
  final currentPeriod = 'global'.obs;

  final periods = ['daily', 'weekly', 'monthly', 'global'];

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  void changePeriod(String period) {
    currentPeriod.value = period;
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    final data = await _api.getLeaderboard(period: currentPeriod.value);
    if (data != null) {
      leaderboard.value = data['leaderboard'] ?? [];
    }
    isLoading.value = false;
  }
}
