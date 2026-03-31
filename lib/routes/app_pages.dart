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
import '../screens/block_puzzle_screen.dart';
import '../screens/domino_screen.dart';
import '../screens/domino_mode_screen.dart';
import '../screens/domino_all_fives_screen.dart';
import '../screens/challenges_screen.dart';
import '../screens/merge_game_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/notification_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/ludo_screen.dart';
import '../screens/snakes_ladders_screen.dart';
import '../screens/wallet_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(name: AppRoutes.language, page: () => const LanguageScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen(), binding: HomeBinding()),
    // level, game, result use Get.to() with params — not named routes
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.shop, page: () => const ShopScreen(), binding: ShopBinding()),
    GetPage(name: AppRoutes.dailyReward, page: () => const DailyRewardScreen(), binding: DailyRewardBinding()),
    GetPage(name: AppRoutes.leaderboard, page: () => const LeaderboardScreen(), binding: LeaderboardBinding()),
    GetPage(name: AppRoutes.mysteryBox, page: () => const MysteryBoxScreen(), binding: MysteryBoxBinding()),
    GetPage(name: AppRoutes.wordCategories, page: () => const WordCategoriesScreen()),
    GetPage(name: AppRoutes.blockPuzzle, page: () => const BlockPuzzleScreen()),
    GetPage(name: AppRoutes.domino, page: () => const DominoModeScreen()),
    GetPage(name: AppRoutes.dominoClassic, page: () => const DominoScreen()),
    GetPage(name: AppRoutes.dominoAllFives, page: () => const DominoAllFivesScreen()),
    GetPage(name: AppRoutes.challenges, page: () => const ChallengesScreen()),
    GetPage(name: AppRoutes.mergeGame, page: () => const MergeGameScreen()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
    GetPage(name: AppRoutes.notificationDetail, page: () => const NotificationDetailScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(name: AppRoutes.ludo, page: () => const LudoModeScreen()),
    GetPage(name: AppRoutes.snakesLadders, page: () => const SnakesLaddersModeScreen()),
    GetPage(name: AppRoutes.wallet, page: () => const WalletScreen()),
  ];
}
