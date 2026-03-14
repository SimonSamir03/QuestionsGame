import 'package:get/get.dart';
import '../services/ads_service.dart';
import 'game_controller.dart';

class MysteryBoxController extends GetxController {
  final isOpened = false.obs;
  final reward = Rxn<Map<String, dynamic>>();

  void openBox() {
    final ads = AdsService();
    final r = ads.generateMysteryReward();
    final game = Get.find<GameController>();

    isOpened.value = true;
    reward.value = r;

    if (r['type'] == 'coins') {
      game.addCoins(r['amount'] as int);
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
    }
  }
}
