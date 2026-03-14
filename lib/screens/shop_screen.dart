import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/ads_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();

    return Obx(() {
      final isAr = game.isAr;

      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isAr ? '\u0627\u0644\u0645\u062a\u062c\u0631' : 'Shop'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Text('\u{1fa99}', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text('${game.coins.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Premium Section
            if (!game.isPremium.value) ...[
              _buildSectionTitle(isAr ? '\u0628\u0631\u064a\u0645\u064a\u0648\u0645' : 'Premium'),
              _buildPremiumCard(context, isAr, game),
              const SizedBox(height: 24),
            ],

            // Coins Section
            _buildSectionTitle(isAr ? '\u0639\u0645\u0644\u0627\u062a' : 'Coins'),
            _buildShopItem(context, '\u{1fa99}', isAr ? '100 \u0639\u0645\u0644\u0629' : '100 Coins', '\$0.99', () {
              _simulatePurchase(context, 'coins_100', 100, 0, isAr, game);
            }),
            _buildShopItem(context, '\u{1f4b0}', isAr ? '500 \u0639\u0645\u0644\u0629' : '500 Coins', '\$3.99', () {
              _simulatePurchase(context, 'coins_500', 500, 0, isAr, game);
            }),
            _buildShopItem(context, '\u{1f3e6}', isAr ? '1000 \u0639\u0645\u0644\u0629' : '1000 Coins', '\$6.99', () {
              _simulatePurchase(context, 'coins_1000', 1000, 0, isAr, game);
            }),
            const SizedBox(height: 24),

            // Lives Section
            _buildSectionTitle(isAr ? '\u062d\u064a\u0627\u0629' : 'Lives'),
            _buildShopItem(context, '\u2764\ufe0f', isAr ? '5 \u062d\u064a\u0627\u0629' : '5 Lives', '\$0.99', () {
              _simulatePurchase(context, 'lives_5', 0, 5, isAr, game);
            }),
            const SizedBox(height: 24),

            // Free Rewards
            _buildSectionTitle(isAr ? '\u0645\u0643\u0627\u0641\u0622\u062a \u0645\u062c\u0627\u0646\u064a\u0629' : 'Free Rewards'),
            _buildRewardItem(context, '\u{1f3ac}', isAr ? '\u0634\u0627\u0647\u062f \u0625\u0639\u0644\u0627\u0646 = 5 \u0639\u0645\u0644\u0627\u062a' : 'Watch Ad = 5 Coins', () async {
              final watched = await AdsService().showRewarded();
              if (watched) {
                game.addCoins(5);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? '+5 \u0639\u0645\u0644\u0627\u062a!' : '+5 Coins!'), backgroundColor: const Color(0xFF4ECDC4)),
                  );
                }
              }
            }),
            _buildRewardItem(context, '\u2764\ufe0f\u200d\u{1f525}', isAr ? '\u0634\u0627\u0647\u062f \u0625\u0639\u0644\u0627\u0646 = \u062d\u064a\u0627\u0629 \u0625\u0636\u0627\u0641\u064a\u0629' : 'Watch Ad = Extra Life', () async {
              final watched = await AdsService().showRewarded();
              if (watched) {
                game.addLife();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? '+1 \u062d\u064a\u0627\u0629!' : '+1 Life!'), backgroundColor: const Color(0xFF4ECDC4)),
                  );
                }
              }
            }),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isAr, GameController game) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('\u{1f451}', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            isAr ? '\u0625\u0632\u0627\u0644\u0629 \u062c\u0645\u064a\u0639 \u0627\u0644\u0625\u0639\u0644\u0627\u0646\u0627\u062a' : 'Remove All Ads',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? '\u0627\u0633\u062a\u0645\u062a\u0639 \u0628\u0644\u0639\u0628 \u0628\u062f\u0648\u0646 \u0625\u0639\u0644\u0627\u0646\u0627\u062a' : 'Enjoy ad-free gameplay',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              game.setPremium(true);
              AdsService().setPremium(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? '\u062a\u0645 \u0627\u0644\u062a\u0631\u0642\u064a\u0629!' : 'Upgraded!'), backgroundColor: Colors.amber),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('\$4.99', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, String emoji, String label, String price, VoidCallback onBuy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a4a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, String emoji, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: const Color(0xFF2a2a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.play_circle_fill, color: Color(0xFF4ECDC4), size: 32),
        onTap: onTap,
      ),
    );
  }

  void _simulatePurchase(BuildContext context, String productId, int coins, int lives, bool isAr, GameController game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? '\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0634\u0631\u0627\u0621' : 'Confirm Purchase', style: const TextStyle(color: Colors.white)),
        content: Text(
          isAr ? '\u0647\u0644 \u062a\u0631\u064a\u062f \u0634\u0631\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0645\u0646\u062a\u062c\u061f' : 'Do you want to buy this item?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isAr ? '\u0625\u0644\u063a\u0627\u0621' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (coins > 0) game.addCoins(coins);
              if (lives > 0) game.addLife(lives);
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? '\u062a\u0645 \u0627\u0644\u0634\u0631\u0627\u0621 \u0628\u0646\u062c\u0627\u062d!' : 'Purchase successful!'),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: Text(isAr ? '\u0634\u0631\u0627\u0621' : 'Buy'),
          ),
        ],
      ),
    );
  }
}
