import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../services/ads_service.dart';
import 'game_controller.dart';

class MysteryBoxController extends GetxController with GetTickerProviderStateMixin {
  final isOpened = false.obs;
  final reward = Rxn<Map<String, dynamic>>();

  late AnimationController shakeController;
  late Animation<double> shakeAnim;

  @override
  void onInit() {
    super.onInit();
    shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    shakeAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.easeInOut),
    );
  }

  void openBox() {
    final ads = AdsService();
    final r = ads.generateMysteryReward();
    final game = Get.find<GameController>();

    if (!game.isOnline.value) {
      game.showOfflineRewardDialog();
      return;
    }

    isOpened.value = true;
    reward.value = r;
    shakeController.stop();

    if (r['type'] == 'coins') {
      game.addGems(r['amount'] as int);
    } else if (r['type'] == 'life') {
      game.addLife(r['amount'] as int);
    }
    game.resetMysteryBoxCounter();
  }

  Future<void> openAnotherBox() async {
    final watched = await AdsService().showRewarded();
    if (watched) {
      isOpened.value = false;
      reward.value = null;
      shakeController.repeat(reverse: true);
    }
  }

  @override
  void onClose() {
    shakeController.dispose();
    super.onClose();
  }
}
