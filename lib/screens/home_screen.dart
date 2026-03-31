import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/home_controller.dart';
import '../services/sound_service.dart';
import '../models/game_model.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_button.dart';
import '../widgets/count_up_text.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';
import '../widgets/glass_container.dart';
import '../controllers/notifications_controller.dart';
import 'game_language_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final gameController = Get.find<GameController>();
    return Obx(() {
      final isAr = gameController.isAr;
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: AnimatedGameBg(
            showParticles: false,
            child: SafeArea(
              child: RepaintBoundary(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(rs(16)),
                child: Column(
                  children: [
                    // Top Bar
                    FadeSlideIn(
                      offset: const Offset(0, -20),
                      child: _buildTopBar(gameController),
                    ),
                    SizedBox(height: rs(16)),
                    // Logo
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: _buildLogo(homeController),
                    ),
                    SizedBox(height: rs(8)),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        'app_tagline'.tr,
                        style: TextStyle(color: kTextHint, fontSize: kFontSizeBody),
                      ),
                    ),
                    SizedBox(height: rs(20)),
                    // Daily Reward Banner
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: _buildDailyRewardBanner(isAr),
                    ),
                    SizedBox(height: rs(16)),
                    // Quick Actions
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: _buildQuickActions(context, isAr, gameController),
                    ),
                    SizedBox(height: rs(20)),
                    // Games Grid
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'choose_game'.tr,
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: kFontSizeBodyLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: rs(12)),
                    if (homeController.isLoadingGames.value)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: rs(4)),
                        child: ShimmerList(count: 4, itemHeight: 80),
                      )
                    else
                      ...homeController.games.asMap().entries.map((entry) {
                        final i = entry.key;
                        final game = entry.value;
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 350 + i * 60),
                          child: _buildGameCard(
                            context,
                            game.emoji,
                            game.name,
                            game.description ?? '',
                            _accentColor(game.slug),
                            () => _navigateToGame(game),
                          ),
                        );
                      }),
                    SizedBox(height: rs(20)),
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar(GameController gameController) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatPill3D(
                  emoji: '\u{1f48e}',
                  value: gameController.coins.value,
                  color: kPrimaryColor,
                ),
                SizedBox(width: rs(6)),
                _StatPill3D(
                  emoji: '\u2b50',
                  value: gameController.xp.value,
                  color: Colors.amber,
                ),
                SizedBox(width: rs(6)),
                _StatPill3D(
                  emoji: '\u2764\ufe0f',
                  value: gameController.lives.value,
                  color: Colors.redAccent,
                ),
                SizedBox(width: rs(6)),
                if (gameController.streakDays.value > 0)
                  _StatPill3D(
                    emoji: '\u{1f525}',
                    value: gameController.streakDays.value,
                    color: Colors.orange,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: rs(4)),
        // Notifications
        AnimatedButton(
          onTap: () => Get.toNamed(AppRoutes.notifications),
          child: Obx(() {
            if (!Get.isRegistered<NotificationsController>()) {
              Get.put(NotificationsController(), permanent: true);
            }
            final notifCtrl = Get.find<NotificationsController>();
            final unread = notifCtrl.unreadCount;
            return _IconButton3D(
              icon: Icons.notifications_outlined,
              badge: unread,
            );
          }),
        ),
        SizedBox(width: rs(8)),
        // Settings
        AnimatedButton(
          onTap: () => Get.toNamed(AppRoutes.settings),
          child: const _IconButton3D(icon: Icons.settings),
        ),
      ],
    );
  }

  Widget _buildLogo(HomeController homeController) {
    return ScaleTransition(
      scale: homeController.pulseAnim,
      child: ShaderMask(
        shaderCallback: (bounds) => kBrandGradient.createShader(bounds),
        child: Text(
          '\u0641\u0643\u0631 .. \u0627\u0644\u0639\u0628 .. \u0627\u0643\u0633\u0628',
          style: TextStyle(
            fontSize: kFontSizeH1,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
            shadows: [
              Shadow(
                color: kPrimaryColor.withValues(alpha: 0.5),
                blurRadius: rs(20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyRewardBanner(bool isAr) {
    return AnimatedButton(
      onTap: () {
        SoundService().playClick();
        Get.toNamed(AppRoutes.dailyReward);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(rs(16)),
        decoration: BoxDecoration(
          gradient: kBrandGradient,
          borderRadius: BorderRadius.circular(rs(18)),
          boxShadow: [
            // 3D base shadow
            BoxShadow(
              color: const Color(0xFF4A35A0),
              offset: Offset(0, rs(5)),
              blurRadius: 0,
            ),
            // Glow
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.45),
              blurRadius: rs(20),
              spreadRadius: rs(2),
            ),
            // Far shadow
            BoxShadow(
              color: kPinkColor.withValues(alpha: 0.2),
              blurRadius: rs(30),
              offset: Offset(0, rs(10)),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glossy overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: rs(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(rs(18))),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Text('\u{1f381}', style: TextStyle(fontSize: fs(32))),
                SizedBox(width: rs(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'daily_reward'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeBodyLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'daily_reward_sub'.tr,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: kFontSizeCaption,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(rs(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(rs(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: rs(4),
                        offset: Offset(0, rs(2)),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: rs(14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isAr, GameController gameController) {
    return Row(
      children: [
        _buildQuickAction(context, Icons.leaderboard, 'nav_ranks'.tr, kRedColor, () => Get.toNamed(AppRoutes.leaderboard)),
        SizedBox(width: rs(8)),
        _buildQuickAction(context, Icons.shopping_bag, 'nav_shop'.tr, kYellowColor, () => Get.toNamed(AppRoutes.shop)),
        SizedBox(width: rs(8)),
        _buildQuickAction(context, Icons.flag, 'nav_challenges'.tr, kSecondaryColor, () => Get.toNamed(AppRoutes.challenges)),
        SizedBox(width: rs(8)),
        _buildQuickAction(
          context, Icons.account_balance_wallet,
          isAr ? '\u0627\u0644\u0645\u062d\u0641\u0638\u0629' : 'Wallet',
          kGreenColor,
          () => Get.toNamed(AppRoutes.wallet),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = isDarkCtx(context);
    final darkColor = HSLColor.fromColor(color)
        .withLightness((HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return Expanded(
      child: AnimatedButton(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: rs(14)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                  : [Colors.white, Colors.white.withValues(alpha: 0.9)],
            ),
            borderRadius: BorderRadius.circular(rs(16)),
            border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.12)),
            boxShadow: [
              // 3D base
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : darkColor.withValues(alpha: 0.15),
                offset: Offset(0, rs(3)),
                blurRadius: rs(1),
              ),
              // Glow
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: rs(12),
                spreadRadius: rs(1),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(rs(10)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(rs(12)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: rs(8),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: rs(24)),
              ),
              SizedBox(height: rs(6)),
              Text(
                label,
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: kFontSizeCaption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String emoji, String title, String subtitle, Color accentColor, VoidCallback onTap) {
    final isDark = isDarkCtx(context);
    final darkAccent = HSLColor.fromColor(accentColor)
        .withLightness((HSLColor.fromColor(accentColor).lightness - 0.2).clamp(0.0, 1.0))
        .toColor();

    return AnimatedButton(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: rs(12)),
        padding: EdgeInsets.all(rs(16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                : [Colors.white, const Color(0xFFF8F6FF)],
          ),
          borderRadius: BorderRadius.circular(rs(18)),
          border: Border.all(color: accentColor.withValues(alpha: isDark ? 0.25 : 0.12)),
          boxShadow: [
            // 3D base edge
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : darkAccent.withValues(alpha: 0.12),
              offset: Offset(0, rs(4)),
              blurRadius: rs(1),
            ),
            // Accent glow
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: rs(16),
              spreadRadius: rs(1),
            ),
            // Depth shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: rs(12),
              offset: Offset(0, rs(6)),
            ),
          ],
        ),
        child: Row(
          children: [
            // 3D emoji container
            Container(
              width: rs(56),
              height: rs(56),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.3),
                    accentColor.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(rs(16)),
                boxShadow: [
                  // Inner 3D depth
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: rs(8),
                  ),
                  BoxShadow(
                    color: darkAccent.withValues(alpha: 0.15),
                    offset: Offset(0, rs(3)),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glossy top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: rs(22),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(rs(16))),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(child: Text(emoji, style: TextStyle(fontSize: fs(28)))),
                ],
              ),
            ),
            SizedBox(width: rs(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: kFontSizeBodyLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: rs(3)),
                  Text(
                    subtitle,
                    style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(rs(8)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(rs(10)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: rs(6),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_forward_ios, color: accentColor, size: rs(14)),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor(String slug) {
    switch (slug) {
      case 'word_rearrange':    return kPrimaryColor;
      case 'quiz':              return kSecondaryColor;
      case 'domino':            return kOrangeColor;
      case 'word_categories':   return kYellowColor;
      case 'crossword':         return kPinkColor;
      case 'classic_crossword': return kSecondaryColor;
      case 'block_puzzle':      return kPrimaryColor;
      case 'merge':             return kGreenColor;
      case 'ludo':              return kRedColor;
      case 'snakes_ladders':   return kGreenColor;
      default:                  return kPrimaryColor;
    }
  }

  void _navigateToGame(GameModel game) {
    SoundService().playClick();
    switch (game.slug) {
      case 'word_categories':
        Get.toNamed(AppRoutes.wordCategories);
        break;
      case 'block_puzzle':
        Get.toNamed(AppRoutes.blockPuzzle);
        break;
      case 'domino':
        Get.toNamed(AppRoutes.domino);
        break;
      case 'merge':
        Get.toNamed(AppRoutes.mergeGame);
        break;
      case 'ludo':
        Get.toNamed(AppRoutes.ludo);
        break;
      case 'snakes_ladders':
        Get.toNamed(AppRoutes.snakesLadders);
        break;
      default:
        Get.to(() => GameLanguageScreen(gameId: game.id, gameSlug: game.slug));
    }
  }
}

/// Stat pill with 3D depth and animated count.
class _StatPill3D extends StatelessWidget {
  final String emoji;
  final int value;
  final Color color;

  const _StatPill3D({required this.emoji, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkCtx(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(10), vertical: rs(6)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()]
              : [Colors.white, const Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(rs(22)),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.12)),
        boxShadow: [
          // 3D base
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : color.withValues(alpha: 0.1),
            offset: Offset(0, rs(2)),
            blurRadius: rs(1),
          ),
          // Glow
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: rs(8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: fs(12))),
          SizedBox(width: rs(3)),
          CountUpText(
            end: value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: kFontSizeCaption),
          ),
        ],
      ),
    );
  }
}

/// Icon button with 3D depth effect.
class _IconButton3D extends StatelessWidget {
  final IconData icon;
  final int badge;

  const _IconButton3D({required this.icon, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkCtx(context);
    return Container(
      padding: EdgeInsets.all(rs(9)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()]
              : [Colors.white, const Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(rs(14)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
            offset: Offset(0, rs(2)),
            blurRadius: rs(1),
          ),
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.06),
            blurRadius: rs(8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: kTextHint, size: rs(22)),
          if (badge > 0)
            Positioned(
              right: -rs(8),
              top: -rs(8),
              child: Container(
                constraints: BoxConstraints(minWidth: rs(18), minHeight: rs(18)),
                padding: EdgeInsets.symmetric(horizontal: rs(4), vertical: rs(1)),
                decoration: BoxDecoration(
                  color: kRedColor,
                  borderRadius: BorderRadius.circular(rs(10)),
                  boxShadow: [
                    BoxShadow(
                      color: kRedColor.withValues(alpha: 0.5),
                      blurRadius: rs(6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: TextStyle(color: Colors.white, fontSize: fs(10), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
