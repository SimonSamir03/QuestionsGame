import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/word_categories_controller.dart';

class WordCategoriesGame extends StatelessWidget {
  final String language;
  final Function(int score, int correctCount, bool won) onRoundEnd;
  final VoidCallback onTimeUpGoBack;

  const WordCategoriesGame({
    super.key,
    required this.language,
    required this.onRoundEnd,
    required this.onTimeUpGoBack,
  });

  static const Map<String, String> _categoryLabelsEn = {
    'name': 'Name', 'job': 'Job', 'object': 'Object',
    'food': 'Food', 'animal': 'Animal', 'country': 'Country',
  };

  static const Map<String, String> _categoryLabelsAr = {
    'name': 'اسم', 'job': 'مهنة', 'object': 'جماد',
    'food': 'طعام', 'animal': 'حيوان', 'country': 'بلد',
  };

  static const Map<String, IconData> _categoryIcons = {
    'name': Icons.person, 'job': Icons.work, 'object': Icons.category,
    'food': Icons.restaurant, 'animal': Icons.pets, 'country': Icons.flag,
  };

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      WordCategoriesController(
        language: language,
        onRoundEnd: onRoundEnd,
        onTimeUpGoBack: onTimeUpGoBack,
      ),
      tag: 'wc_${identityHashCode(this)}',
    );
    final isAr = language == 'ar';
    final labels = isAr ? _categoryLabelsAr : _categoryLabelsEn;

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(ctrl, isAr),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: ctrl.categories.map((cat) {
                      return _buildCategoryField(ctrl, cat, labels[cat] ?? cat, isAr);
                    }).toList(),
                  ),
                ),
                if (!ctrl.isSubmitted.value && !ctrl.isTimeUp.value)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: ctrl.submitRound,
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
                if (ctrl.results.value != null) _buildResultsSummary(ctrl, isAr),
              ],
            ),
            if (ctrl.isTimeUp.value) _buildTimeUpOverlay(ctrl, isAr),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(WordCategoriesController ctrl, bool isAr) {
    final timerColor = ctrl.timeLeft.value <= 10
        ? Colors.red
        : ctrl.timeLeft.value <= 20
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: timerColor, size: 28),
              const SizedBox(width: 8),
              Text('${ctrl.timeLeft.value}s',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: timerColor)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(ctrl.letter.value ?? '',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
            ),
          ),
          const SizedBox(height: 8),
          Text(isAr ? 'اكتب كلمات تبدأ بهذا الحرف' : 'Write words starting with this letter',
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCategoryField(WordCategoriesController ctrl, String category, String label, bool isAr) {
    final bool? isCorrect = ctrl.results.value != null
        ? (ctrl.results.value!['results']?[category]?['correct'] as bool?)
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
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              enabled: !ctrl.isSubmitted.value && !ctrl.isTimeUp.value,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onChanged: (val) => ctrl.updateAnswer(category, val),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isAr ? 'اكتب هنا...' : 'Type here...',
                hintStyle: const TextStyle(color: Colors.white24),
              ),
            ),
          ),
          if (isCorrect != null)
            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red, size: 24),
        ],
      ),
    );
  }

  Widget _buildTimeUpOverlay(WordCategoriesController ctrl, bool isAr) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏰', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(isAr ? 'انتهى الوقت!' : "Time's Up!",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(isAr ? 'ملحقتش تخلص كل الإجابات' : "You didn't finish all answers",
                style: const TextStyle(color: Colors.white54, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton.icon(
                  onPressed: ctrl.addExtraTime,
                  icon: const Icon(Icons.play_circle, size: 28),
                  label: Text(isAr ? 'شاهد إعلان +15 ثانية' : 'Watch Ad +15 seconds',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  onPressed: () { ctrl.isTimeUp.value = false; ctrl.submitRound(); },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(isAr ? 'أرسل اللي كتبته' : 'Submit what I wrote',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: ctrl.onTimeUpGoBack,
                child: Text(isAr ? 'رجوع' : 'Go Back', style: const TextStyle(color: Colors.white54, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary(WordCategoriesController ctrl, bool isAr) {
    final r = ctrl.results.value!;
    final score = r['score'] as int;
    final correct = r['correct_count'] as int;
    final total = r['total_categories'] as int;
    final won = r['won'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a4a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: won ? Colors.green : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Text(won ? '🎉' : '😢', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            won
                ? (isAr ? 'فزت! كل الإجابات صحيحة!' : 'You Won! All answers correct!')
                : (isAr ? 'خسرت! $correct/$total صح بس' : 'You Lost! Only $correct/$total correct'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: won ? Colors.green : Colors.red),
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
