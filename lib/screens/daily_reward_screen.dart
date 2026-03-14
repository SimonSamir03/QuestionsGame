import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daily_reward_controller.dart';
import '../controllers/game_controller.dart';

class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final game = Get.find<GameController>();
  final ctrl = Get.put(DailyRewardController());

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
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    await ctrl.claimReward();
    if (ctrl.status.value != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 +${ctrl.status.value?['last_reward_amount'] ?? ''} coins!'),
          backgroundColor: const Color(0xFF4ECDC4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAr = game.isAr;
      final status = ctrl.status.value;

      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isAr ? 'المكافأة اليومية' : 'Daily Rewards'),
          centerTitle: true,
        ),
        body: ctrl.isLoading.value
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
                                '${status?['current_streak'] ?? 0}',
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
                          final item = ctrl.schedule[index];
                          final currentStreak = status?['current_streak'] ?? 0;
                          final isPast = index < (currentStreak % 7);
                          final isCurrent = index == (currentStreak % 7);
                          final canClaim = status?['can_claim'] == true && isCurrent;

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
                    if (status?['can_claim'] == true)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: ctrl.isClaiming.value ? null : _claimReward,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            ctrl.isClaiming.value
                                ? '...'
                                : (isAr ? 'اجمع المكافأة!' : 'Claim Reward!'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    // Restore Streak
                    if (status?['streak_broken'] == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextButton.icon(
                          onPressed: () => ctrl.restoreStreak(),
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
    });
  }
}
