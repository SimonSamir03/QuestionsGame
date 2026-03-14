import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leaderboard_controller.dart';
import '../controllers/game_controller.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final game = Get.find<GameController>();
  final ctrl = Get.put(LeaderboardController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ctrl.changePeriod(ctrl.periods[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAr = game.isAr;

      final tabLabels = isAr
          ? ['يومي', 'أسبوعي', 'شهري', 'عام']
          : ['Daily', 'Weekly', 'Monthly', 'Global'];

      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isAr ? 'لوحة المتصدرين' : 'Leaderboard'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF4ECDC4),
            labelColor: const Color(0xFF4ECDC4),
            unselectedLabelColor: Colors.white54,
            tabs: tabLabels.map((l) => Tab(text: l)).toList(),
          ),
        ),
        body: ctrl.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ctrl.leaderboard.isEmpty
                ? Center(
                    child: Text(
                      isAr ? 'لا توجد نتائج بعد' : 'No results yet',
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.leaderboard.length,
                    itemBuilder: (ctx, index) {
                      final entry = ctrl.leaderboard[index];
                      final rank = index + 1;
                      String medal = '';
                      if (rank == 1) medal = '🥇';
                      if (rank == 2) medal = '🥈';
                      if (rank == 3) medal = '🥉';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: rank <= 3
                              ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                              : const Color(0xFF2a2a4a),
                          borderRadius: BorderRadius.circular(12),
                          border: rank <= 3
                              ? Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: medal.isNotEmpty
                                  ? Text(medal, style: const TextStyle(fontSize: 24))
                                  : Text(
                                      '#$rank',
                                      style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              backgroundColor: const Color(0xFF6C63FF),
                              radius: 20,
                              child: Text(
                                (entry['name'] ?? '?')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry['name'] ?? 'Unknown',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            Text(
                              '${entry['score'] ?? 0}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
      );
    });
  }
}
