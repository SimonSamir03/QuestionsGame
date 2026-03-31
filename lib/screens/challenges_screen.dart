import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/challenge_controller.dart';
import '../widgets/coins_lives_row.dart';
import '../controllers/game_controller.dart';
import '../models/challenge_model.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ChallengeController());
    final gameController = Get.find<GameController>();
    final isAr = gameController.isAr;

    return Obx(() => Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          leading: _build3DBackButton(context),
          title: Text('challenges_title'.tr),
          centerTitle: true,
          actions: [const CoinsLivesRow()],
        ),
        body: AnimatedGameBg(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ctrl.challenges.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\u{1f3c6}', style: TextStyle(fontSize: fs(64))),
                    SizedBox(height: rs(16)),
                    Text(
                      'no_challenges'.tr,
                      style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: ctrl.loadChallenges,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                  left: rs(16),
                  right: rs(16),
                  bottom: rs(16),
                ),
                itemCount: ctrl.challenges.length,
                itemBuilder: (context, index) {
                  return _buildChallengeCard(ctrl.challenges[index], isAr);
                },
              ),
            );
          }),
        ),
      ),
    ));
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

  Widget _buildChallengeCard(ChallengeModel challenge, bool isAr) {
    final goalIcon = switch (challenge.goalType) {
      'score'  => '\u{1f3af}',
      'levels' => '\u{1f4ca}',
      'streak' => '\u{1f525}',
      _        => '\u2b50',
    };

    final typeColor = switch (challenge.type) {
      'daily'   => kSecondaryColor,
      'weekly'  => kPrimaryColor,
      'special' => kYellowColor,
      _         => kPrimaryColor,
    };

    final typeLabel = switch (challenge.type) {
      'daily'   => isAr ? '\u064a\u0648\u0645\u064a' : 'Daily',
      'weekly'  => isAr ? '\u0623\u0633\u0628\u0648\u0639\u064a' : 'Weekly',
      'special' => isAr ? '\u062e\u0627\u0635' : 'Special',
      _         => challenge.type,
    };

    return DepthCard(
      margin: EdgeInsets.only(bottom: rs(12)),
      padding: EdgeInsets.all(rs(16)),
      accentColor: challenge.isCompleted ? kSecondaryColor : typeColor,
      elevation: challenge.isCompleted ? 0.8 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(goalIcon, style: TextStyle(fontSize: fs(28))),
              SizedBox(width: rs(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: kFontSizeBodyLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (challenge.description != null)
                      Text(
                        challenge.description!,
                        style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: rs(8), vertical: rs(3)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [typeColor.withValues(alpha: 0.25), typeColor.withValues(alpha: 0.1)]),
                  borderRadius: BorderRadius.circular(rs(8)),
                  boxShadow: [
                    BoxShadow(color: typeColor.withValues(alpha: 0.15), blurRadius: rs(4), offset: Offset(0, rs(1))),
                  ],
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(color: typeColor, fontSize: kFontSizeTiny, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          SizedBox(height: rs(12)),

          // Progress bar with 3D effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rs(6)),
              boxShadow: [
                BoxShadow(
                  color: (challenge.isCompleted ? kSecondaryColor : typeColor).withValues(alpha: 0.2),
                  blurRadius: rs(4),
                  offset: Offset(0, rs(1)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rs(6)),
              child: LinearProgressIndicator(
                value: challenge.progressPercent,
                backgroundColor: kBorderColor,
                valueColor: AlwaysStoppedAnimation(
                  challenge.isCompleted ? kSecondaryColor : typeColor,
                ),
                minHeight: rs(8),
              ),
            ),
          ),

          SizedBox(height: rs(8)),

          // Progress text + reward
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                challenge.isCompleted
                    ? (isAr ? '\u0645\u0643\u062a\u0645\u0644 \u2713' : 'Completed \u2713')
                    : '${challenge.progress} / ${challenge.goalValue}',
                style: TextStyle(
                  color: challenge.isCompleted ? kSecondaryColor : kTextSecondary,
                  fontSize: kFontSizeCaption,
                  fontWeight: challenge.isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Row(
                children: [
                  if (challenge.rewardCoins > 0) ...[
                    Text('\u{1fa99}', style: TextStyle(fontSize: fs(14))),
                    SizedBox(width: rs(3)),
                    Text(
                      '${challenge.rewardCoins}',
                      style: TextStyle(color: Colors.amber, fontSize: kFontSizeCaption, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (challenge.rewardCoins > 0 && challenge.rewardLives > 0)
                    SizedBox(width: rs(8)),
                  if (challenge.rewardLives > 0) ...[
                    Text('\u2764\ufe0f', style: TextStyle(fontSize: fs(14))),
                    SizedBox(width: rs(3)),
                    Text(
                      '${challenge.rewardLives}',
                      style: TextStyle(color: kRedColor, fontSize: kFontSizeCaption, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
