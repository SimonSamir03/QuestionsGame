import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/splash_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/daily_reward_controller.dart';
import '../controllers/leaderboard_controller.dart';
import '../controllers/mystery_box_controller.dart';
import '../controllers/shop_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // GameController is already put in main() so it's available before GetMaterialApp.
    if (!Get.isRegistered<GameController>()) {
      Get.put(GameController(), permanent: true);
    }
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

class DailyRewardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DailyRewardController());
  }
}

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LeaderboardController());
  }
}

class MysteryBoxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MysteryBoxController());
  }
}

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShopController());
  }
}
