import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import 'level_screen.dart';
import 'word_categories_screen.dart';
import 'daily_reward_screen.dart';
import 'leaderboard_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';
import 'crossword_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

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
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

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
                _buildTopBar(gameState, isAr, context),
                const SizedBox(height: 16),
                // Logo
                _buildLogo(),
                const SizedBox(height: 8),
                Text(
                  isAr ? 'ألغاز بلا حدود' : 'Endless Puzzles',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                // Daily Reward Banner
                _buildDailyRewardBanner(context, isAr),
                const SizedBox(height: 16),
                // Quick Actions
                _buildQuickActions(context, isAr),
                const SizedBox(height: 20),
                // Games Grid
                Text(
                  isAr ? 'اختر لعبة' : 'Choose a Game',
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  context, '🔤',
                  isAr ? 'ترتيب الحروف' : 'Word Builder',
                  isAr ? 'رتب الحروف لتكوين كلمات' : 'Arrange letters to form words',
                  const Color(0xFF6C63FF),
                  () => _navigateToGame(context, 'word', isAr),
                ),
                _buildGameCard(
                  context, '❓',
                  isAr ? 'أسئلة سريعة' : 'Quick Quiz',
                  isAr ? 'أجب على أسئلة المعرفة' : 'Answer knowledge questions',
                  const Color(0xFF4ECDC4),
                  () => _navigateToGame(context, 'quiz', isAr),
                ),
                _buildGameCard(
                  context, '🔢',
                  isAr ? 'عد الأشكال' : 'Count Puzzle',
                  isAr ? 'عد الأشكال الصحيحة' : 'Count the correct shapes',
                  const Color(0xFFFF6B6B),
                  () => _navigateToGame(context, 'count', isAr),
                ),
                _buildGameCard(
                  context, '🅰️',
                  isAr ? 'تحدي الحروف' : 'Word Categories',
                  isAr ? 'اكتب كلمات تبدأ بحرف عشوائي' : 'Write words starting with a random letter',
                  const Color(0xFFFFBE0B),
                  () {
                    SoundService().playClick();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WordCategoriesScreen()));
                  },
                ),
                _buildGameCard(
                  context, '🔍',
                  isAr ? 'الكلمات المتقاطعة' : 'Word Search',
                  isAr ? 'ابحث عن الكلمات المخفية في الشبكة' : 'Find hidden words in the grid',
                  const Color(0xFFFF6B9D),
                  () {
                    SoundService().playClick();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CrosswordScreen()));
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState gameState, bool isAr, BuildContext context) {
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
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('${gameState.coins}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
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
              const Text('❤️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('${gameState.lives}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Streak
        if (gameState.streakDays > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a4a),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text('${gameState.streakDays}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        const Spacer(),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white54),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
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

  Widget _buildDailyRewardBanner(BuildContext context, bool isAr) {
    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRewardScreen()));
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
            const Text('🎁', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'المكافأة اليومية' : 'Daily Reward',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAr ? 'اجمع مكافأتك اليومية!' : 'Claim your daily reward!',
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

  Widget _buildQuickActions(BuildContext context, bool isAr) {
    return Row(
      children: [
        _buildQuickAction(
          context, Icons.leaderboard, isAr ? 'الترتيب' : 'Ranks',
          const Color(0xFFFF6B6B),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
        ),
        const SizedBox(width: 8),
        _buildQuickAction(
          context, Icons.shopping_bag, isAr ? 'المتجر' : 'Shop',
          const Color(0xFFFFBE0B),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
        ),
        const SizedBox(width: 8),
        _buildQuickAction(
          context, Icons.emoji_events, isAr ? 'يومي' : 'Daily',
          const Color(0xFF4ECDC4),
          () async {
            // Navigate to daily challenge level directly
            _navigateToGame(context, 'quiz', isAr);
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
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

  Widget _buildGameCard(BuildContext context, String emoji, String title, String subtitle, Color accentColor, VoidCallback onTap) {
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

  void _navigateToGame(BuildContext context, String type, bool isAr) {
    SoundService().playClick();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LevelScreen(gameType: type),
    ));
  }
}
