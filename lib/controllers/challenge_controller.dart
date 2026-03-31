import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/challenge_model.dart';
import '../services/api_service.dart';

class ChallengeController extends GetxController {
  final challenges = <ChallengeModel>[].obs;
  final isLoading = true.obs;

  final _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    isLoading.value = true;
    final result = await Connectivity().checkConnectivity();
    if (!result.contains(ConnectivityResult.none)) {
      final data = await _api.getMyChallenges();
      if (data != null) {
        challenges.value = data
            .map((j) => ChallengeModel.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
      }
    }
    isLoading.value = false;
  }

  /// Called after any game action. Finds matching challenges and updates progress.
  /// [goalType]: 'score', 'levels', or 'streak'
  /// [amount]: points to add (score earned, 1 for level, streak count)
  /// [gameId]: optional — null matches challenges for any game
  void trackProgress({required String goalType, required int amount, int? gameId}) {
    for (final c in challenges) {
      if (c.isCompleted) continue;
      if (c.goalType != goalType) continue;
      // If challenge is for a specific game, skip if gameId doesn't match
      // (challenge model doesn't expose game_id, so we skip this filter for now)

      final newProgress = c.progress + amount;
      _api.updateChallengeProgress(c.id, newProgress).then((res) {
        if (res != null) {
          // Reload to get fresh state (including completion rewards)
          loadChallenges();
        }
      });
    }
  }
}
