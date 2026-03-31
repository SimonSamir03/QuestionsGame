import 'package:confetti/confetti.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../services/ads_service.dart';
import '../services/api_service.dart';
import '../services/sound_service.dart';
import 'game_controller.dart';

class ResultController extends GetxController with GetTickerProviderStateMixin {
  final bool isCorrect;
  ResultController({required this.isCorrect});

  final doubledCoins = false.obs;
  late ConfettiController confettiController;
  late AnimationController scaleController;
  late Animation<double> scaleAnim;

  final GameController game = Get.find();

  @override
  void onInit() {
    super.onInit();
    confettiController = ConfettiController(duration: const Duration(seconds: 3));
    scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.elasticOut),
    );
    scaleController.forward();
    playResult(isCorrect);
  }

  void playResult(bool correct) {
    if (correct) {
      confettiController.play();
      SoundService().playLevelComplete();
    } else {
      SoundService().playWrong();
    }
  }

  Future<void> doubleCoinsReward() async {
    if (!game.isOnline.value) {
      game.showOfflineRewardDialog();
      return;
    }
    final watched = await AdsService().showRewarded();
    if (watched) {
      final reward = game.gemsPerAd;
      game.addGems(reward);
      ApiService().logAdWatch(rewardType: 'double_coins', coinsEarned: reward);
      doubledCoins.value = true;
      SoundService().playReward();
    }
  }

  Future<void> continueAfterLoss() async {
    if (!game.isOnline.value) {
      game.showOfflineRewardDialog();
      return;
    }
    final watched = await AdsService().showRewarded();
    if (watched) {
      game.addLife();
      Get.back();
    }
  }

  @override
  void onClose() {
    confettiController.dispose();
    scaleController.dispose();
    super.onClose();
  }
}
