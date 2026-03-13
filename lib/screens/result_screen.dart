import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_model.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../services/ads_service.dart';
import 'game_screen.dart';
import 'mystery_box_screen.dart';

class ResultScreen extends StatefulWidget {
  final bool isCorrect;
  final Puzzle puzzle;
  final int levelNumber;
  final List<Puzzle>? puzzles;
  final int? currentIndex;

  const ResultScreen({
    super.key,
    required this.isCorrect,
    required this.puzzle,
    required this.levelNumber,
    this.puzzles,
    this.currentIndex,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  bool _doubledCoins = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    if (widget.isCorrect) {
      _confettiController.play();
      SoundService().playLevelComplete();
    } else {
      SoundService().playWrong();
    }
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _doubleCoins(GameState gameState) async {
    final watched = await AdsService().showRewarded();
    if (watched && mounted) {
      gameState.addCoins(10); // Double the 10 coins
      setState(() => _doubledCoins = true);
      SoundService().playReward();
    }
  }

  Future<void> _continueAfterLoss(GameState gameState) async {
    final watched = await AdsService().showRewarded();
    if (watched && mounted) {
      gameState.addLife();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF6C63FF), Color(0xFF4ECDC4),
                Colors.amber, Colors.pink, Colors.orange,
              ],
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Result emoji
                      Text(
                        widget.isCorrect ? '🎉' : '😢',
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.isCorrect
                            ? (isAr ? 'أحسنت!' : 'Excellent!')
                            : (isAr ? 'حاول مرة أخرى' : 'Try Again'),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Score
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a4a),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Text(
                                  widget.isCorrect
                                      ? '+${_doubledCoins ? 20 : 10}'
                                      : '+0',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isCorrect ? Colors.amber : Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('❤️', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  '${gameState.lives} ${isAr ? 'حياة' : 'lives'}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Double coins offer
                      if (widget.isCorrect && !_doubledCoins && !gameState.isPremium)
                        _buildAdButton(
                          icon: Icons.play_circle,
                          label: isAr ? 'ضاعف عملاتك!' : 'Double your coins!',
                          color: Colors.amber,
                          onTap: () => _doubleCoins(gameState),
                        ),

                      // Continue after loss
                      if (!widget.isCorrect && gameState.lives <= 0)
                        _buildAdButton(
                          icon: Icons.play_circle,
                          label: isAr ? 'شاهد إعلان للاستمرار' : 'Watch ad to continue',
                          color: const Color(0xFF4ECDC4),
                          onTap: () => _continueAfterLoss(gameState),
                        ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      if (widget.isCorrect)
                        _buildActionButton(
                          label: (widget.puzzles != null && widget.currentIndex != null && widget.currentIndex! + 1 < widget.puzzles!.length)
                              ? (isAr ? 'المستوى التالي' : 'Next Level')
                              : (isAr ? 'الرئيسية' : 'Back to Home'),
                          color: const Color(0xFF6C63FF),
                          onTap: () {
                            SoundService().playClick();
                            if (widget.puzzles != null && widget.currentIndex != null) {
                              final nextIndex = widget.currentIndex! + 1;
                              if (nextIndex < widget.puzzles!.length) {
                                // Check for mystery box
                                if (gameState.shouldShowMysteryBox) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MysteryBoxScreen()),
                                  );
                                  return;
                                }

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GameScreen(
                                      puzzle: widget.puzzles![nextIndex],
                                      levelNumber: nextIndex + 1,
                                      puzzles: widget.puzzles,
                                      currentIndex: nextIndex,
                                    ),
                                  ),
                                );
                                return;
                              }
                            }
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                        ),

                      if (!widget.isCorrect && gameState.lives > 0)
                        _buildActionButton(
                          label: isAr ? 'حاول مرة أخرى' : 'Try Again',
                          color: const Color(0xFFFF6B6B),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  puzzle: widget.puzzle,
                                  levelNumber: widget.levelNumber,
                                  puzzles: widget.puzzles,
                                  currentIndex: widget.currentIndex,
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text(
                          isAr ? 'الرئيسية' : 'Home',
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: color),
          label: Text(label, style: TextStyle(color: color)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
