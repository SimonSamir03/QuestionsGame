import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../controllers/shop_controller.dart';
import '../models/shop_item_model.dart';
import '../services/ads_service.dart';
import '../services/api_service.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final shopController = Get.find<ShopController>();

    return Obx(() {
      final isDark = isDarkCtx(context);
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextPrimary,
          leading: _build3DBackButton(context),
          title: Text('shop_title'.tr),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.all(rs(16)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.22).toColor()]
                        : [Colors.white, const Color(0xFFF5F5F5)],
                  ),
                  borderRadius: BorderRadius.circular(rs(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      offset: Offset(0, rs(3)),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      blurRadius: rs(8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text('\u{1fa99}', style: TextStyle(fontSize: fs(18))),
                    SizedBox(width: rs(4)),
                    Text('${gameController.coins.value}', style: TextStyle(fontSize: kFontSizeBodyLarge, fontWeight: FontWeight.bold, color: kTextPrimary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: AnimatedGameBg(
          child: shopController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                    left: rs(16),
                    right: rs(16),
                    bottom: rs(16),
                  ),
                  children: [
                    if (!gameController.isPremium.value && shopController.premiumItem != null) ...[
                      _buildSectionTitle('shop_premium'.tr),
                      _buildPremiumCard(context, gameController, shopController.premiumItem!),
                      SizedBox(height: rs(24)),
                    ],
                    if (shopController.coinItems.isNotEmpty) ...[
                      _buildSectionTitle('shop_coins'.tr),
                      ...shopController.coinItems.map((item) => _buildShopItem(context, item, gameController)),
                      SizedBox(height: rs(24)),
                    ],
                    if (shopController.liveItems.isNotEmpty) ...[
                      _buildSectionTitle('shop_lives'.tr),
                      ...shopController.liveItems.map((item) => _buildShopItem(context, item, gameController)),
                      SizedBox(height: rs(24)),
                    ],
                    _buildSectionTitle('shop_free_rewards'.tr),
                    _buildRewardItem(context, '\u{1f3ac}', 'shop_ad_coins'.tr, () async {
                      if (!gameController.isOnline.value) { gameController.showOfflineRewardDialog(); return; }
                      final watched = await AdsService().showRewarded();
                      if (watched) {
                        final res = await ApiService().logAdWatch(rewardType: 'shop_gems', coinsEarned: gameController.gemsPerAd);
                        if (res != null && res['allowed'] == true) {
                          gameController.addGems((res['coins_earned'] as num?)?.toInt() ?? 5);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('shop_plus_5_coins'.tr), backgroundColor: kSecondaryColor),
                          );
                        }
                      }
                    }),
                    _buildRewardItem(context, '\u2764\ufe0f\u200d\u{1f525}', 'shop_ad_life'.tr, () async {
                      if (!gameController.isOnline.value) { gameController.showOfflineRewardDialog(); return; }
                      final watched = await AdsService().showRewarded();
                      if (watched) {
                        await ApiService().logAdWatch(rewardType: 'shop_life', coinsEarned: 0);
                        gameController.addLife();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('shop_plus_1_life'.tr), backgroundColor: kSecondaryColor),
                          );
                        }
                      }
                    }),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(12)),
      child: Text(title, style: TextStyle(color: kTextSecondary, fontSize: kFontSizeH4, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPremiumCard(BuildContext context, GameController gameController, ShopItemModel item) {
    return Container(
      padding: EdgeInsets.all(rs(20)),
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(rs(20)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.5),
            offset: Offset(0, rs(5)),
            blurRadius: 0,
          ),
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: rs(16),
            offset: Offset(0, rs(4)),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: rs(60),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(rs(20))),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(item.emoji ?? '\u{1f451}', style: TextStyle(fontSize: fs(48))),
              SizedBox(height: rs(8)),
              Text(
                'shop_remove_ads'.tr,
                style: TextStyle(fontSize: kFontSizeH4, fontWeight: FontWeight.bold, color: kTextPrimary),
              ),
              SizedBox(height: rs(4)),
              Text('shop_remove_ads_sub'.tr, style: TextStyle(color: kTextSecondary)),
              SizedBox(height: rs(12)),
              Button3D(
                label: '\$${item.priceUsd.toStringAsFixed(2)}',
                color: Colors.amber,
                textColor: Colors.black,
                height: 48,
                onTap: () {
                  gameController.setPremium(true);
                  AdsService().setPremium(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('shop_upgraded'.tr), backgroundColor: Colors.amber),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, ShopItemModel item, GameController gameController) {
    final isDark = isDarkCtx(context);
    return DepthCard(
      margin: EdgeInsets.only(bottom: rs(8)),
      padding: EdgeInsets.all(rs(14)),
      child: Row(
        children: [
          Text(item.emoji ?? '\u{1fa99}', style: TextStyle(fontSize: fs(28))),
          SizedBox(width: rs(14)),
          Expanded(child: Text(item.name, style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBodyLarge))),
          Button3D(
            label: '\$${item.priceUsd.toStringAsFixed(2)}',
            color: kSecondaryColor,
            expanded: false,
            height: 40,
            borderRadius: 10,
            fontSize: 14,
            onTap: () => _confirmPurchase(context, item, gameController),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, String emoji, String label, VoidCallback onTap) {
    return DepthCard(
      margin: EdgeInsets.only(bottom: rs(8)),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: Text(emoji, style: TextStyle(fontSize: fs(28))),
        title: Text(label, style: TextStyle(color: kTextPrimary)),
        trailing: Container(
          padding: EdgeInsets.all(rs(4)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: kSecondaryColor.withValues(alpha: 0.3), blurRadius: rs(8)),
            ],
          ),
          child: Icon(Icons.play_circle_fill, color: kSecondaryColor, size: rs(32)),
        ),
      ),
    );
  }

  void _confirmPurchase(BuildContext context, ShopItemModel item, GameController gameController) {
    final isDark = isDarkCtx(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? kDarkCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(20))),
        title: Text('shop_confirm_title'.tr, style: TextStyle(color: kTextPrimary)),
        content: Text('shop_confirm_body'.tr, style: TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('btn_cancel'.tr)),
          Button3D(
            label: 'btn_buy'.tr,
            color: kPrimaryColor,
            expanded: false,
            height: 40,
            borderRadius: 10,
            fontSize: 14,
            onTap: () {
              if (!gameController.isOnline.value) { Get.back(); gameController.showOfflineRewardDialog(); return; }
              if (item.type == 'coins') gameController.addCoins(item.rewardAmount);
              if (item.type == 'lives') gameController.addLife(item.rewardAmount);
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('shop_purchase_ok'.tr), backgroundColor: kSecondaryColor),
              );
            },
          ),
        ],
      ),
    );
  }
}
