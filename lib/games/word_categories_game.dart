import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/sound_service.dart';
import '../services/ads_service.dart';
import '../services/local_puzzles.dart';

class WordCategoriesGame extends StatefulWidget {
  final String language;
  final Function(int score, int correctCount, bool won) onRoundEnd;
  final VoidCallback onTimeUpGoBack;

  const WordCategoriesGame({
    super.key,
    required this.language,
    required this.onRoundEnd,
    required this.onTimeUpGoBack,
  });

  @override
  State<WordCategoriesGame> createState() => _WordCategoriesGameState();
}

class _WordCategoriesGameState extends State<WordCategoriesGame> with TickerProviderStateMixin {
  String? _letter;
  List<String> _categories = [];
  final Map<String, TextEditingController> _controllers = {};
  int _timeLeft = 30;
  Timer? _timer;
  bool _isLoading = true;
  bool _isSubmitted = false;
  bool _isTimeUp = false;
  Map<String, dynamic>? _results;
  late AnimationController _letterAnimController;
  late Animation<double> _letterScale;

  final Map<String, String> _categoryLabelsEn = {
    'name': 'Name',
    'job': 'Job',
    'object': 'Object',
    'food': 'Food',
    'animal': 'Animal',
    'country': 'Country',
  };

  final Map<String, String> _categoryLabelsAr = {
    'name': 'اسم',
    'job': 'مهنة',
    'object': 'جماد',
    'food': 'طعام',
    'animal': 'حيوان',
    'country': 'بلد',
  };

  final Map<String, IconData> _categoryIcons = {
    'name': Icons.person,
    'job': Icons.work,
    'object': Icons.category,
    'food': Icons.restaurant,
    'animal': Icons.pets,
    'country': Icons.flag,
  };

  @override
  void initState() {
    super.initState();
    _letterAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _letterScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _letterAnimController, curve: Curves.elasticOut),
    );
    _fetchLetter();
  }

  Future<void> _fetchLetter() async {
    var data = await ApiService.getRandomLetter(widget.language);
    data ??= LocalPuzzles.getRandomLetter(widget.language);
    if (data != null && mounted) {
      setState(() {
        _letter = data!['letter'];
        _categories = List<String>.from(data['categories']);
        for (var cat in _categories) {
          _controllers[cat] = TextEditingController();
        }
        _isLoading = false;
      });
      _letterAnimController.forward();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 5 && _timeLeft > 0) {
        SoundService().playCountdown();
      }
      if (_timeLeft <= 0) {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    if (_isSubmitted || _isTimeUp) return;
    SoundService().playWrong();
    setState(() {
      _isTimeUp = true;
    });
  }

  Future<void> _addExtraTime() async {
    final watched = await AdsService().showRewarded();
    if (watched && mounted) {
      setState(() {
        _isTimeUp = false;
        _timeLeft = 15;
      });
      _startTimer();
    }
  }

  Future<void> _submitRound() async {
    if (_isSubmitted) return;
    _isSubmitted = true;
    _isTimeUp = false;
    _timer?.cancel();

    final answers = <String, String>{};
    for (var cat in _categories) {
      answers[cat] = _controllers[cat]?.text.trim() ?? '';
    }

    // Try API first
    final result = await ApiService.submitWordCategoryRound(
      _letter!,
      widget.language,
      answers,
    );

    if (result != null && mounted) {
      setState(() {
        _results = result;
      });

      final correctCount = result['correct_count'] as int;
      final won = result['won'] as bool? ?? (correctCount == _categories.length);
      if (won) {
        SoundService().playLevelComplete();
      } else {
        SoundService().playWrong();
      }

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        widget.onRoundEnd(result['score'] as int, correctCount, won);
      }
    } else if (mounted) {
      // API unavailable - mark all as wrong (cannot validate without server)
      final Map<String, dynamic> localResults = {};
      for (var cat in _categories) {
        localResults[cat] = {'answer': answers[cat] ?? '', 'correct': false};
      }

      SoundService().playWrong();

      setState(() {
        _results = {
          'score': 0,
          'won': false,
          'correct_count': 0,
          'total_categories': _categories.length,
          'results': localResults,
        };
      });

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        widget.onRoundEnd(0, 0, false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _letterAnimController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.language == 'ar';
    final labels = isAr ? _categoryLabelsAr : _categoryLabelsEn;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          // Main game content
          Column(
            children: [
              _buildHeader(isAr),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _categories.map((cat) {
                    return _buildCategoryField(cat, labels[cat] ?? cat, isAr);
                  }).toList(),
                ),
              ),
              if (!_isSubmitted && !_isTimeUp)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitRound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        isAr ? 'إرسال' : 'Submit',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              if (_results != null) _buildResultsSummary(isAr),
            ],
          ),

          // Time's Up overlay
          if (_isTimeUp)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⏰', style: TextStyle(fontSize: 80)),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'انتهى الوقت!' : "Time's Up!",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr ? 'ملحقتش تخلص كل الإجابات' : "You didn't finish all answers",
                        style: const TextStyle(color: Colors.white54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Watch ad for extra time
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _addExtraTime,
                          icon: const Icon(Icons.play_circle, size: 28),
                          label: Text(
                            isAr ? 'شاهد إعلان +15 ثانية' : 'Watch Ad +15 seconds',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ECDC4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Submit what you have
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _isTimeUp = false);
                            _submitRound();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber,
                            side: const BorderSide(color: Colors.amber),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isAr ? 'أرسل اللي كتبته' : 'Submit what I wrote',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Go back
                      TextButton(
                        onPressed: widget.onTimeUpGoBack,
                        child: Text(
                          isAr ? 'رجوع' : 'Go Back',
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isAr) {
    final timerColor = _timeLeft <= 10
        ? Colors.red
        : _timeLeft <= 20
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: timerColor, size: 28),
              const SizedBox(width: 8),
              Text(
                '${_timeLeft}s',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: _letterScale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _letter ?? '',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr ? 'اكتب كلمات تبدأ بهذا الحرف' : 'Write words starting with this letter',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField(String category, String label, bool isAr) {
    final bool? isCorrect = _results != null
        ? (_results!['results'][category]?['correct'] as bool?)
        : null;

    Color borderColor = const Color(0xFF2a2a4a);
    if (isCorrect == true) borderColor = Colors.green;
    if (isCorrect == false) borderColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a4a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isCorrect != null ? 2 : 1),
      ),
      child: Row(
        children: [
          Icon(_categoryIcons[category] ?? Icons.edit, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controllers[category],
              enabled: !_isSubmitted && !_isTimeUp,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isAr ? 'اكتب هنا...' : 'Type here...',
                hintStyle: const TextStyle(color: Colors.white24),
              ),
            ),
          ),
          if (isCorrect != null)
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildResultsSummary(bool isAr) {
    final score = _results!['score'] as int;
    final correct = _results!['correct_count'] as int;
    final total = _results!['total_categories'] as int;
    final won = _results!['won'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a4a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: won ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            won ? '🎉' : '😢',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            won
                ? (isAr ? 'فزت! كل الإجابات صحيحة!' : 'You Won! All answers correct!')
                : (isAr ? 'خسرت! $correct/$total صح بس' : 'You Lost! Only $correct/$total correct'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: won ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            won
                ? (isAr ? '+$score نقطة' : '+$score points')
                : (isAr ? 'لازم تجيب كلهم صح عشان تكسب!' : 'You must get ALL correct to win!'),
            style: TextStyle(
              color: won ? Colors.amber : Colors.white54,
              fontSize: won ? 18 : 14,
              fontWeight: won ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
