import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/app_bindings.dart';
import '../screens/splash_screen.dart';
import '../screens/language_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/daily_reward_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/mystery_box_screen.dart';
import '../screens/word_categories_screen.dart';
import '../screens/crossword_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(name: AppRoutes.language, page: () => const LanguageScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    // level, game, result use Get.to() with params — not named routes
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.shop, page: () => const ShopScreen()),
    GetPage(name: AppRoutes.dailyReward, page: () => const DailyRewardScreen(), binding: DailyRewardBinding()),
    GetPage(name: AppRoutes.leaderboard, page: () => const LeaderboardScreen(), binding: LeaderboardBinding()),
    GetPage(name: AppRoutes.mysteryBox, page: () => const MysteryBoxScreen(), binding: MysteryBoxBinding()),
    GetPage(name: AppRoutes.wordCategories, page: () => const WordCategoriesScreen()),
    GetPage(name: AppRoutes.crossword, page: () => const CrosswordScreen()),
  ];
}
