import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/splash_controller.dart';
import '../controllers/daily_reward_controller.dart';
import '../controllers/leaderboard_controller.dart';
import '../controllers/mystery_box_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GameController(), permanent: true);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
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
