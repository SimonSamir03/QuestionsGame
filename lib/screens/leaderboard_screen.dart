import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/leaderboard_controller.dart';
import '../controllers/game_controller.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeaderboardController>();
    return Obx(() {
      final isAr = Get.find<GameController>().isAr;
      final isDark = isDarkCtx(context);
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          leading: _build3DBackButton(context),
          title: Text('leaderboard_title'.tr),
          centerTitle: true,
          bottom: TabBar(
            controller: ctrl.tabController,
            indicatorColor: kSecondaryColor,
            indicatorWeight: 3,
            labelColor: kSecondaryColor,
            unselectedLabelColor: kTextHint,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: kFontSizeBody),
            tabs: [
              Tab(text: 'tab_daily'.tr),
              Tab(text: 'tab_weekly'.tr),
              Tab(text: 'tab_monthly'.tr),
              Tab(text: 'tab_global'.tr),
            ],
          ),
        ),
        body: AnimatedGameBg(
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + rs(48)),
              // Game filter chips
              _buildGameFilter(context, ctrl, isAr),
              // Leaderboard list
              Expanded(
                child: ctrl.isLoading.value
                    ? Padding(
                        padding: EdgeInsets.all(rs(16)),
                        child: ShimmerList(count: 8, itemHeight: 64),
                      )
                    : ctrl.leaderboard.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('\u{1f3c6}', style: TextStyle(fontSize: fs(48))),
                                SizedBox(height: rs(12)),
                                Text(
                                  'leaderboard_empty'.tr,
                                  style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(rs(16)),
                            itemCount: ctrl.leaderboard.length,
                            itemBuilder: (ctx, index) {
                              final entry = ctrl.leaderboard[index];
                              final rank = index + 1;
                              String medal = '';
                              if (rank == 1) medal = '\u{1f947}';
                              if (rank == 2) medal = '\u{1f948}';
                              if (rank == 3) medal = '\u{1f949}';

                              final isTop3 = rank <= 3;
                              final avatarColors = [kPrimaryColor, kSecondaryColor, kOrangeColor, kPinkColor, kGreenColor];
                              final avatarColor = avatarColors[index % avatarColors.length];

                              return FadeSlideIn(
                                delay: Duration(milliseconds: index * 50),
                                child: DepthCard(
                                  margin: EdgeInsets.only(bottom: rs(8)),
                                  padding: EdgeInsets.all(rs(12)),
                                  accentColor: isTop3 ? kPrimaryColor : null,
                                  elevation: isTop3 ? 1.2 : 0.6,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: rs(36),
                                        child: medal.isNotEmpty
                                            ? Text(medal, style: TextStyle(fontSize: fs(24)))
                                            : Center(
                                                child: Text(
                                                  '#$rank',
                                                  style: TextStyle(color: kTextHint, fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                      ),
                                      SizedBox(width: rs(10)),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: avatarColor.withValues(alpha: 0.3), blurRadius: rs(8)),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: avatarColor.withValues(alpha: 0.2),
                                          radius: rs(20),
                                          child: Text(
                                            entry.name[0].toUpperCase(),
                                            style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: kFontSizeBody),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: rs(12)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.name,
                                              style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody, fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal),
                                            ),
                                            SizedBox(height: rs(2)),
                                            Row(
                                              children: [
                                                Text('\u{1fa99}', style: TextStyle(fontSize: fs(10))),
                                                SizedBox(width: rs(2)),
                                                Text(
                                                  '${entry.coins}',
                                                  style: TextStyle(color: kTextHint, fontSize: kFontSizeTiny),
                                                ),
                                                SizedBox(width: rs(8)),
                                                Text('\u2764\ufe0f', style: TextStyle(fontSize: fs(10))),
                                                SizedBox(width: rs(2)),
                                                Text(
                                                  '${entry.lives}',
                                                  style: TextStyle(color: kTextHint, fontSize: kFontSizeTiny),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: rs(10), vertical: rs(4)),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.amber.withValues(alpha: 0.15), Colors.amber.withValues(alpha: 0.05)],
                                          ),
                                          borderRadius: BorderRadius.circular(rs(10)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withValues(alpha: 0.15),
                                              blurRadius: rs(6),
                                              offset: Offset(0, rs(2)),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${entry.score}',
                                              style: TextStyle(color: Colors.amber, fontSize: kFontSizeBody, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: rs(3)),
                                            Text('\u2b50', style: TextStyle(fontSize: fs(12))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _build3DBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkCtx(context) ? kDarkCardColor : Colors.white,
              isDarkCtx(context)
                  ? HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()
                  : const Color(0xFFF0F0F0),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkCtx(context) ? 0.4 : 0.10),
              offset: Offset(0, rs(3)),
              blurRadius: 0,
            ),
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.10),
              blurRadius: rs(8),
              offset: Offset(0, rs(2)),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, size: rs(18), color: kTextPrimary),
      ),
    );
  }

  Widget _buildGameFilter(BuildContext context, LeaderboardController ctrl, bool isAr) {
    final isDark = isDarkCtx(context);
    return SizedBox(
      height: rs(50),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
        children: [
          _buildFilterChip(
            context: context,
            label: isAr ? '\u0627\u0644\u0643\u0644' : 'All',
            emoji: '\u{1f3c6}',
            isSelected: ctrl.selectedGameId.value == null,
            onTap: () => ctrl.changeGame(null),
          ),
          ...ctrl.games.map((game) => _buildFilterChip(
            context: context,
            label: game.name,
            emoji: game.emoji,
            isSelected: ctrl.selectedGameId.value == game.id,
            onTap: () => ctrl.changeGame(game.id),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = isDarkCtx(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: rs(8)),
        padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(4)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)])
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.22).toColor()]
                      : [Colors.white, Colors.white.withValues(alpha: 0.95)],
                ),
          borderRadius: BorderRadius.circular(rs(20)),
          border: Border.all(
            color: isSelected ? kPrimaryColor : kBorderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? kPrimaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              offset: Offset(0, rs(2)),
              blurRadius: isSelected ? rs(6) : 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: fs(14))),
            SizedBox(width: rs(4)),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : kTextHint,
                fontSize: kFontSizeCaption,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
