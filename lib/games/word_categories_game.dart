import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/word_categories_controller.dart';
import '../widgets/hint_ad_bar.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

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
    'name': '\u0627\u0633\u0645', 'job': '\u0645\u0647\u0646\u0629',
    'object': '\u062c\u0645\u0627\u062f', 'food': '\u0637\u0639\u0627\u0645',
    'animal': '\u062d\u064a\u0648\u0627\u0646', 'country': '\u0628\u0644\u062f',
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
                if (!ctrl.isSubmitted.value && !ctrl.isTimeUp.value)
                  HintAdBar(
                    onHint: ctrl.useHint,
                    hintEnabled: !ctrl.hintUsed.value,
                  ),
                if (ctrl.hintText.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs(16)),
                    child: Text(
                      ctrl.hintText.value,
                      style: TextStyle(
                        color: kOrangeColor,
                        fontSize: kFontSizeCaption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: rs(12)),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: rs(16)),
                    children: ctrl.categories.map((cat) {
                      return _buildCategoryField(ctrl, cat, labels[cat] ?? cat, isAr, context);
                    }).toList(),
                  ),
                ),
                if (!ctrl.isSubmitted.value && !ctrl.isTimeUp.value)
                  Padding(
                    padding: EdgeInsets.all(rs(16)),
                    child: Button3D(
                      label: isAr ? '\u0625\u0631\u0633\u0627\u0644' : 'Submit',
                      color: kPrimaryColor,
                      onTap: ctrl.submitRound,
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

    final keyboardOpen = MediaQuery.of(Get.context!).viewInsets.bottom > 100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: keyboardOpen ? rs(8) : rs(16)),
      margin: EdgeInsets.symmetric(horizontal: rs(16)),
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(rs(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A35A0),
            offset: Offset(0, rs(5)),
            blurRadius: 0,
          ),
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.35),
            blurRadius: rs(16),
            spreadRadius: rs(2),
          ),
        ],
      ),
      child: keyboardOpen
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LetterBox3D(letter: ctrl.letter.value ?? '', size: 40),
                SizedBox(width: rs(16)),
                Icon(Icons.timer, color: timerColor, size: rs(22)),
                SizedBox(width: rs(6)),
                Text('${ctrl.timeLeft.value}s',
                    style: TextStyle(fontSize: kFontSizeH3, fontWeight: FontWeight.bold, color: timerColor)),
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: timerColor, size: rs(28)),
                    SizedBox(width: rs(8)),
                    Text('${ctrl.timeLeft.value}s',
                        style: TextStyle(
                          fontSize: kFontSizeH2,
                          fontWeight: FontWeight.bold,
                          color: timerColor,
                          shadows: [Shadow(color: timerColor.withValues(alpha: 0.5), blurRadius: rs(8))],
                        )),
                  ],
                ),
                SizedBox(height: rs(12)),
                _LetterBox3D(letter: ctrl.letter.value ?? '', size: 80),
                SizedBox(height: rs(8)),
                Text(
                  isAr ? '\u0627\u0643\u062a\u0628 \u0643\u0644\u0645\u0627\u062a \u062a\u0628\u062f\u0623 \u0628\u0647\u0630\u0627 \u0627\u0644\u062d\u0631\u0641' : 'Write words starting with this letter',
                  style: TextStyle(color: Colors.white70, fontSize: kFontSizeBody),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryField(WordCategoriesController ctrl, String category, String label, bool isAr, BuildContext context) {
    final bool? isCorrect = ctrl.results.value != null
        ? ctrl.results.value!.results[category]?.isValid
        : null;

    final isDark = isDarkCtx(context);
    Color borderColor = isDark ? kBorderColor.withValues(alpha: 0.3) : kBorderColor.withValues(alpha: 0.2);
    Color glowColor = Colors.transparent;
    if (isCorrect == true) { borderColor = kGreenColor; glowColor = kGreenColor; }
    if (isCorrect == false) { borderColor = kErrorColor; glowColor = kErrorColor; }

    return Container(
      margin: EdgeInsets.only(bottom: rs(10)),
      padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
              : [Colors.white, const Color(0xFFF8F6FF)],
        ),
        borderRadius: BorderRadius.circular(rs(14)),
        border: Border.all(color: borderColor, width: isCorrect != null ? rs(2) : rs(1)),
        boxShadow: [
          if (isCorrect != null)
            BoxShadow(color: glowColor.withValues(alpha: 0.15), blurRadius: rs(8)),
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
            offset: Offset(0, rs(2)),
            blurRadius: rs(1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(rs(6)),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rs(8)),
            ),
            child: Icon(_categoryIcons[category] ?? Icons.edit, color: kPrimaryColor, size: rs(18)),
          ),
          SizedBox(width: rs(10)),
          SizedBox(
            width: rs(70),
            child: Text(label, style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody, fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: rs(8)),
          Expanded(
            child: TextField(
              enabled: !ctrl.isSubmitted.value && !ctrl.isTimeUp.value,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBodyLarge),
              onChanged: (val) => ctrl.updateAnswer(category, val),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isAr ? '\u0627\u0643\u062a\u0628 \u0647\u0646\u0627...' : 'Type here...',
                hintStyle: TextStyle(color: kBorderColor),
              ),
            ),
          ),
          if (isCorrect != null)
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? kGreenColor : kErrorColor,
              size: rs(24),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeUpOverlay(WordCategoriesController ctrl, bool isAr) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(rs(32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\u23f0', style: TextStyle(fontSize: fs(80))),
              SizedBox(height: rs(16)),
              Text(
                isAr ? '\u0627\u0646\u062a\u0647\u0649 \u0627\u0644\u0648\u0642\u062a!' : "Time's Up!",
                style: TextStyle(
                  fontSize: kFontSizeH1,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                  shadows: [Shadow(color: kRedColor.withValues(alpha: 0.5), blurRadius: rs(12))],
                ),
              ),
              SizedBox(height: rs(8)),
              Text(
                isAr ? '\u0645\u0644\u062d\u0642\u062a\u0634 \u062a\u062e\u0644\u0635' : "You didn't finish all answers",
                style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: rs(32)),
              Button3D(
                label: isAr ? '\u0625\u0639\u0644\u0627\u0646 +15 \u062b\u0627\u0646\u064a\u0629' : 'Watch Ad +15s',
                color: kSecondaryColor,
                icon: Icons.play_circle,
                onTap: ctrl.addExtraTime,
              ),
              SizedBox(height: rs(12)),
              Button3D(
                label: isAr ? '\u0623\u0631\u0633\u0644 \u0627\u0644\u0644\u064a \u0643\u062a\u0628\u062a\u0647' : 'Submit what I wrote',
                color: Colors.amber,
                onTap: () {
                  ctrl.isTimeUp.value = false;
                  ctrl.submitRound();
                },
              ),
              SizedBox(height: rs(12)),
              TextButton(
                onPressed: ctrl.onTimeUpGoBack,
                child: Text(
                  isAr ? '\u0631\u062c\u0648\u0639' : 'Go Back',
                  style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary(WordCategoriesController ctrl, bool isAr) {
    final r = ctrl.results.value!;
    final score = r.score;
    final correct = r.correctCount;
    final total = r.total;
    final won = r.won;
    final resultColor = won ? kGreenColor : kErrorColor;

    return DepthCard(
      accentColor: resultColor,
      margin: EdgeInsets.all(rs(16)),
      padding: EdgeInsets.all(rs(16)),
      child: Column(
        children: [
          Text(won ? '\u{1F389}' : '\u{1F622}', style: TextStyle(fontSize: fs(40))),
          SizedBox(height: rs(8)),
          Text(
            won
                ? (isAr ? '\u0641\u0632\u062a! \u0643\u0644 \u0627\u0644\u0625\u062c\u0627\u0628\u0627\u062a \u0635\u062d\u064a\u062d\u0629!' : 'You Won! All answers correct!')
                : (isAr ? '\u062e\u0633\u0631\u062a! $correct/$total \u0635\u062d' : 'You Lost! Only $correct/$total correct'),
            style: TextStyle(
              fontSize: kFontSizeH4,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: rs(4)),
          Text(
            won
                ? (isAr ? '+$score \u0646\u0642\u0637\u0629' : '+$score points')
                : (isAr ? '\u0644\u0627\u0632\u0645 \u062a\u062c\u064a\u0628 \u0643\u0644\u0647\u0645 \u0635\u062d!' : 'You must get ALL correct to win!'),
            style: TextStyle(
              color: won ? Colors.amber : kTextHint,
              fontSize: won ? kFontSizeH4 : kFontSizeBody,
              fontWeight: won ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LetterBox3D extends StatelessWidget {
  final String letter;
  final double size;
  const _LetterBox3D({required this.letter, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rs(size),
      height: rs(size),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(size * 0.25)),
        boxShadow: [
          // 3D base
          BoxShadow(
            color: const Color(0xFFCCCCCC),
            offset: Offset(0, rs(4)),
            blurRadius: 0,
          ),
          // Glow
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: rs(12),
            spreadRadius: rs(2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy highlight
          Positioned(
            top: 0, left: 0, right: 0,
            height: rs(size * 0.4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(rs(size * 0.25))),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: size > 60 ? kFontSizeDisplay : kFontSizeH2,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
