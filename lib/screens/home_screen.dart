import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/sound_service.dart';
import '../routes/app_routes.dart';
import 'level_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  final game = Get.find<GameController>();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAr = game.isAr;

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(isAr),
                  const SizedBox(height: 16),
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? '\u0623\u0644\u063a\u0627\u0632 \u0628\u0644\u0627 \u062d\u062f\u0648\u062f' : 'Endless Puzzles',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Daily Reward Banner
                  _buildDailyRewardBanner(isAr),
                  const SizedBox(height: 16),
                  // Quick Actions
                  _buildQuickActions(isAr),
                  const SizedBox(height: 20),
                  // Games Grid
                  Text(
                    isAr ? '\u0627\u062e\u062a\u0631 \u0644\u0639\u0628\u0629' : 'Choose a Game',
                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildGameCard(
                    '\u{1f524}',
                    isAr ? '\u062a\u0631\u062a\u064a\u0628 \u0627\u0644\u062d\u0631\u0648\u0641' : 'Word Builder',
                    isAr ? '\u0631\u062a\u0628 \u0627\u0644\u062d\u0631\u0648\u0641 \u0644\u062a\u0643\u0648\u064a\u0646 \u0643\u0644\u0645\u0627\u062a' : 'Arrange letters to form words',
                    const Color(0xFF6C63FF),
                    () => _navigateToGame('word'),
                  ),
                  _buildGameCard(
                    '\u2753',
                    isAr ? '\u0623\u0633\u0626\u0644\u0629 \u0633\u0631\u064a\u0639\u0629' : 'Quick Quiz',
                    isAr ? '\u0623\u062c\u0628 \u0639\u0644\u0649 \u0623\u0633\u0626\u0644\u0629 \u0627\u0644\u0645\u0639\u0631\u0641\u0629' : 'Answer knowledge questions',
                    const Color(0xFF4ECDC4),
                    () => _navigateToGame('quiz'),
                  ),
                  _buildGameCard(
                    '\u{1f522}',
                    isAr ? '\u0639\u062f \u0627\u0644\u0623\u0634\u0643\u0627\u0644' : 'Count Puzzle',
                    isAr ? '\u0639\u062f \u0627\u0644\u0623\u0634\u0643\u0627\u0644 \u0627\u0644\u0635\u062d\u064a\u062d\u0629' : 'Count the correct shapes',
                    const Color(0xFFFF6B6B),
                    () => _navigateToGame('count'),
                  ),
                  _buildGameCard(
                    '\u{1f170}\u{fe0f}',
                    isAr ? '\u062a\u062d\u062f\u064a \u0627\u0644\u062d\u0631\u0648\u0641' : 'Word Categories',
                    isAr ? '\u0627\u0643\u062a\u0628 \u0643\u0644\u0645\u0627\u062a \u062a\u0628\u062f\u0623 \u0628\u062d\u0631\u0641 \u0639\u0634\u0648\u0627\u0626\u064a' : 'Write words starting with a random letter',
                    const Color(0xFFFFBE0B),
                    () {
                      SoundService().playClick();
                      Get.toNamed(AppRoutes.wordCategories);
                    },
                  ),
                  _buildGameCard(
                    '\u{1f50d}',
                    isAr ? '\u0627\u0644\u0643\u0644\u0645\u0627\u062a \u0627\u0644\u0645\u062a\u0642\u0627\u0637\u0639\u0629' : 'Word Search',
                    isAr ? '\u0627\u0628\u062d\u062b \u0639\u0646 \u0627\u0644\u0643\u0644\u0645\u0627\u062a \u0627\u0644\u0645\u062e\u0641\u064a\u0629 \u0641\u064a \u0627\u0644\u0634\u0628\u0643\u0629' : 'Find hidden words in the grid',
                    const Color(0xFFFF6B9D),
                    () {
                      SoundService().playClick();
                      Get.toNamed(AppRoutes.crossword);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar(bool isAr) {
    return Row(
      children: [
        // Coins
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a4a),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('\u{1fa99}', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('${game.coins.value}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Lives
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a4a),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('\u2764\ufe0f', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('${game.lives.value}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Streak
        if (game.streakDays.value > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a4a),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('\u{1f525}', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text('${game.streakDays.value}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        const Spacer(),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white54),
          onPressed: () {
            Get.toNamed(AppRoutes.settings);
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
        ).createShader(bounds),
        child: const Text(
          'BrainPlay',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDailyRewardBanner(bool isAr) {
    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        Get.toNamed(AppRoutes.dailyReward);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('\u{1f381}', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? '\u0627\u0644\u0645\u0643\u0627\u0641\u0623\u0629 \u0627\u0644\u064a\u0648\u0645\u064a\u0629' : 'Daily Reward',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAr ? '\u0627\u062c\u0645\u0639 \u0645\u0643\u0627\u0641\u0623\u062a\u0643 \u0627\u0644\u064a\u0648\u0645\u064a\u0629!' : 'Claim your daily reward!',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isAr) {
    return Row(
      children: [
        _buildQuickAction(
          Icons.leaderboard, isAr ? '\u0627\u0644\u062a\u0631\u062a\u064a\u0628' : 'Ranks',
          const Color(0xFFFF6B6B),
          () => Get.toNamed(AppRoutes.leaderboard),
        ),
        const SizedBox(width: 8),
        _buildQuickAction(
          Icons.shopping_bag, isAr ? '\u0627\u0644\u0645\u062a\u062c\u0631' : 'Shop',
          const Color(0xFFFFBE0B),
          () => Get.toNamed(AppRoutes.shop),
        ),
        const SizedBox(width: 8),
        _buildQuickAction(
          Icons.emoji_events, isAr ? '\u064a\u0648\u0645\u064a' : 'Daily',
          const Color(0xFF4ECDC4),
          () {
            _navigateToGame('quiz');
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a4a),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(String emoji, String title, String subtitle, Color accentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a4a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(String type) {
    SoundService().playClick();
    Get.to(() => LevelScreen(gameType: type));
  }
}
