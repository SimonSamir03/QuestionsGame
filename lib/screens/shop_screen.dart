import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state.dart';
import '../services/ads_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isAr ? 'المتجر' : 'Shop'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text('${gameState.coins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Premium Section
          if (!gameState.isPremium) ...[
            _buildSectionTitle(isAr ? 'بريميوم' : 'Premium'),
            _buildPremiumCard(context, isAr, gameState),
            const SizedBox(height: 24),
          ],

          // Coins Section
          _buildSectionTitle(isAr ? 'عملات' : 'Coins'),
          _buildShopItem(context, '🪙', isAr ? '100 عملة' : '100 Coins', '\$0.99', () {
            _simulatePurchase(context, 'coins_100', 100, 0, isAr, gameState);
          }),
          _buildShopItem(context, '💰', isAr ? '500 عملة' : '500 Coins', '\$3.99', () {
            _simulatePurchase(context, 'coins_500', 500, 0, isAr, gameState);
          }),
          _buildShopItem(context, '🏦', isAr ? '1000 عملة' : '1000 Coins', '\$6.99', () {
            _simulatePurchase(context, 'coins_1000', 1000, 0, isAr, gameState);
          }),
          const SizedBox(height: 24),

          // Lives Section
          _buildSectionTitle(isAr ? 'حياة' : 'Lives'),
          _buildShopItem(context, '❤️', isAr ? '5 حياة' : '5 Lives', '\$0.99', () {
            _simulatePurchase(context, 'lives_5', 0, 5, isAr, gameState);
          }),
          const SizedBox(height: 24),

          // Free Rewards
          _buildSectionTitle(isAr ? 'مكافآت مجانية' : 'Free Rewards'),
          _buildRewardItem(context, '🎬', isAr ? 'شاهد إعلان = 5 عملات' : 'Watch Ad = 5 Coins', () async {
            final watched = await AdsService().showRewarded();
            if (watched) {
              gameState.addCoins(5);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? '+5 عملات!' : '+5 Coins!'), backgroundColor: const Color(0xFF4ECDC4)),
                );
              }
            }
          }),
          _buildRewardItem(context, '❤️‍🔥', isAr ? 'شاهد إعلان = حياة إضافية' : 'Watch Ad = Extra Life', () async {
            final watched = await AdsService().showRewarded();
            if (watched) {
              gameState.addLife();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? '+1 حياة!' : '+1 Life!'), backgroundColor: const Color(0xFF4ECDC4)),
                );
              }
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isAr, GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('👑', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            isAr ? 'إزالة جميع الإعلانات' : 'Remove All Ads',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? 'استمتع بلعب بدون إعلانات' : 'Enjoy ad-free gameplay',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              gameState.setPremium(true);
              AdsService().setPremium(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? 'تم الترقية!' : 'Upgraded!'), backgroundColor: Colors.amber),
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

  void _simulatePurchase(BuildContext context, String productId, int coins, int lives, bool isAr, GameState gameState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? 'تأكيد الشراء' : 'Confirm Purchase', style: const TextStyle(color: Colors.white)),
        content: Text(
          isAr ? 'هل تريد شراء هذا المنتج؟' : 'Do you want to buy this item?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (coins > 0) gameState.addCoins(coins);
              if (lives > 0) gameState.addLife(lives);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم الشراء بنجاح!' : 'Purchase successful!'),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: Text(isAr ? 'شراء' : 'Buy'),
          ),
        ],
      ),
    );
  }
}
