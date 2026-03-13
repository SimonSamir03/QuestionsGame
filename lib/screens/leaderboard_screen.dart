import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _leaderboard = [];
  bool _isLoading = true;
  String _currentPeriod = 'global';

  final List<String> _periods = ['daily', 'weekly', 'monthly', 'global'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _currentPeriod = _periods[_tabController.index];
        _loadLeaderboard();
      }
    });
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getLeaderboard(period: _currentPeriod);
    if (data != null && mounted) {
      setState(() {
        _leaderboard = data['leaderboard'] ?? [];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard.isEmpty
              ? Center(
                  child: Text(
                    isAr ? 'لا توجد نتائج بعد' : 'No results yet',
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _leaderboard.length,
                  itemBuilder: (ctx, index) {
                    final entry = _leaderboard[index];
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
  }
}
