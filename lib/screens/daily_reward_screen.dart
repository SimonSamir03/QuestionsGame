import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state.dart';
import '../services/api_service.dart';
import '../services/ads_service.dart';

class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _status;
  bool _isLoading = true;
  bool _isClaiming = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final List<Map<String, dynamic>> _schedule = [
    {'day': 1, 'amount': 20, 'type': 'coins'},
    {'day': 2, 'amount': 40, 'type': 'coins'},
    {'day': 3, 'amount': 60, 'type': 'coins'},
    {'day': 4, 'amount': 80, 'type': 'coins'},
    {'day': 5, 'amount': 100, 'type': 'coins'},
    {'day': 6, 'amount': 120, 'type': 'coins'},
    {'day': 7, 'amount': 200, 'type': 'mystery'},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final data = await ApiService.getDailyRewardStatus();
    if (mounted) {
      setState(() {
        _status = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _claimReward() async {
    setState(() => _isClaiming = true);
    final result = await ApiService.claimDailyReward();
    if (result != null && mounted) {
      final gameState = Provider.of<GameState>(context, listen: false);
      gameState.addCoins(result['reward']['amount'] as int);
      gameState.setStreakDays(result['streak_day'] as int);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 +${result['reward']['amount']} coins!'),
          backgroundColor: const Color(0xFF4ECDC4),
        ),
      );
      _loadStatus();
    }
    if (mounted) setState(() => _isClaiming = false);
  }

  Future<void> _restoreStreak() async {
    final watched = await AdsService().showRewarded();
    if (watched) {
      await ApiService.restoreStreak();
      _loadStatus();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isAr ? 'المكافأة اليومية' : 'Daily Rewards'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Streak Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text(
                              '${_status?['current_streak'] ?? 0}',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              isAr ? 'أيام متتالية' : 'Day Streak',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reward Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 7,
                      itemBuilder: (ctx, index) {
                        final item = _schedule[index];
                        final currentStreak = _status?['current_streak'] ?? 0;
                        final isPast = index < (currentStreak % 7);
                        final isCurrent = index == (currentStreak % 7);
                        final canClaim = _status?['can_claim'] == true && isCurrent;

                        return ScaleTransition(
                          scale: canClaim ? _bounceAnim : const AlwaysStoppedAnimation(1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isPast
                                  ? const Color(0xFF4ECDC4).withValues(alpha: 0.3)
                                  : canClaim
                                      ? const Color(0xFF6C63FF)
                                      : const Color(0xFF2a2a4a),
                              borderRadius: BorderRadius.circular(12),
                              border: canClaim
                                  ? Border.all(color: Colors.amber, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isAr ? 'يوم ${item['day']}' : 'Day ${item['day']}',
                                  style: TextStyle(
                                    color: isPast ? Colors.white54 : Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['type'] == 'mystery' ? '🎁' : '🪙',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['type'] == 'mystery'
                                      ? (isAr ? 'غامض' : 'Mystery')
                                      : '${item['amount']}',
                                  style: TextStyle(
                                    color: isPast ? Colors.white38 : Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                if (isPast)
                                  const Icon(Icons.check_circle, color: Color(0xFF4ECDC4), size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Claim Button
                  if (_status?['can_claim'] == true)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isClaiming ? null : _claimReward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _isClaiming
                              ? '...'
                              : (isAr ? 'اجمع المكافأة!' : 'Claim Reward!'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Restore Streak
                  if (_status?['streak_broken'] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton.icon(
                        onPressed: _restoreStreak,
                        icon: const Icon(Icons.play_circle, color: Color(0xFF4ECDC4)),
                        label: Text(
                          isAr ? 'شاهد إعلان لاستعادة السلسلة' : 'Watch ad to restore streak',
                          style: const TextStyle(color: Color(0xFF4ECDC4)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
