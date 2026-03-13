import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_model.dart';
import '../services/api_service.dart';
import '../services/game_state.dart';
import '../services/offline_service.dart';
import '../services/local_puzzles.dart';
import 'game_screen.dart';

class LevelScreen extends StatefulWidget {
  final String gameType;

  const LevelScreen({super.key, required this.gameType});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  String _difficulty = 'easy';
  List<Puzzle> _puzzles = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;

  final List<String> _difficulties = ['easy', 'medium', 'hard', 'expert'];

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    setState(() => _isLoading = true);
    final gameState = Provider.of<GameState>(context, listen: false);

    // Try API first, fallback to offline cache
    final puzzles = await ApiService.getPuzzles(
      widget.gameType, _difficulty, gameState.language, page: _currentPage,
    );

    if (puzzles != null) {
      // Cache for offline use
      OfflineService().cachePuzzles(widget.gameType, _difficulty, gameState.language, puzzles);
      if (mounted) {
        setState(() {
          if (_currentPage == 1) {
            _puzzles = puzzles;
          } else {
            _puzzles.addAll(puzzles);
          }
          _hasMore = puzzles.length >= 20;
          _isLoading = false;
        });
      }
    } else {
      // Try offline cache
      final cached = await OfflineService().getCachedPuzzles(
        widget.gameType, _difficulty, gameState.language,
      );
      if (mounted) {
        final fallback = cached != null && cached.isNotEmpty
            ? cached
            : LocalPuzzles.getPuzzles(widget.gameType, _difficulty, gameState.language);
        setState(() {
          _puzzles = fallback;
          _hasMore = false;
          _isLoading = false;
        });
      }
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      _loadPuzzles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    final diffLabels = isAr
        ? {'easy': 'سهل', 'medium': 'متوسط', 'hard': 'صعب', 'expert': 'خبير'}
        : {'easy': 'Easy', 'medium': 'Medium', 'hard': 'Hard', 'expert': 'Expert'};

    final diffColors = {
      'easy': const Color(0xFF4ECDC4),
      'medium': const Color(0xFFFFBE0B),
      'hard': const Color(0xFFFF6B6B),
      'expert': const Color(0xFF6C63FF),
    };

    final gameLabels = isAr
        ? {'word': 'ترتيب الحروف', 'quiz': 'أسئلة سريعة', 'count': 'عد الأشكال'}
        : {'word': 'Word Builder', 'quiz': 'Quick Quiz', 'count': 'Count Puzzle'};

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(gameLabels[widget.gameType] ?? widget.gameType),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('${gameState.coins}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  const Text('❤️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('${gameState.lives}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // "Endless Puzzles" tag
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isAr ? 'تحديات جديدة كل يوم ♾️' : 'New Challenges Every Day ♾️',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            // Difficulty Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _difficulties.map((d) {
                  final isSelected = _difficulty == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _difficulty = d;
                          _currentPage = 1;
                        });
                        _loadPuzzles();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? diffColors[d] : const Color(0xFF2a2a4a),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            diffLabels[d] ?? d,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Puzzle Grid
            Expanded(
              child: _isLoading && _puzzles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _puzzles.isEmpty
                      ? Center(
                          child: Text(
                            isAr ? 'لا توجد ألغاز' : 'No puzzles available',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scroll) {
                            if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                              _loadMore();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _puzzles.length,
                            itemBuilder: (ctx, index) {
                              final isUnlocked = gameState.isLevelUnlocked(widget.gameType, _difficulty, index);
                              final isCompleted = gameState.isLevelCompleted(widget.gameType, _difficulty, index);
                              final accentColor = diffColors[_difficulty] ?? Colors.white;

                              return GestureDetector(
                                onTap: () {
                                  if (!isUnlocked) return;
                                  if (gameState.lives <= 0) {
                                    _showNoLivesDialog(context, isAr, gameState);
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => GameScreen(
                                        puzzle: _puzzles[index],
                                        levelNumber: index + 1,
                                        puzzles: _puzzles,
                                        currentIndex: index,
                                      ),
                                      transitionsBuilder: (_, anim, __, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                                          child: child,
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    // Refresh when coming back so completed levels update
                                    if (mounted) setState(() {});
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !isUnlocked
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : isCompleted
                                            ? accentColor.withValues(alpha: 0.3)
                                            : accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !isUnlocked
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : isCompleted
                                              ? accentColor.withValues(alpha: 0.7)
                                              : accentColor.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Center(
                                    child: !isUnlocked
                                        ? Icon(Icons.lock, color: Colors.white.withValues(alpha: 0.2), size: 18)
                                        : isCompleted
                                            ? Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Text('${index + 1}', style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                                                  Positioned(
                                                    right: 2, top: 2,
                                                    child: Icon(Icons.check_circle, color: accentColor, size: 12),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                '${index + 1}',
                                                style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoLivesDialog(BuildContext context, bool isAr, GameState gameState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'نفدت الحياة!' : 'No Lives Left!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              isAr ? 'شاهد إعلان للحصول على حياة' : 'Watch an ad to get a life',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              gameState.addLife();
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.play_circle),
            label: Text(isAr ? 'شاهد إعلان' : 'Watch Ad'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4)),
          ),
        ],
      ),
    );
  }
}
