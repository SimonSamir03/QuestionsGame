import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../models/question_model.dart';
import '../controllers/quiz_game_controller.dart';
import '../widgets/hint_ad_bar.dart';
import '../widgets/depth_card.dart';

class QuizGame extends StatelessWidget {
  final Question question;
  final Function(bool) onAnswer;
  const QuizGame({super.key, required this.question, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      QuizGameController(question: question, onAnswer: onAnswer),
      tag: 'qg_${question.id}',
    );
    final options = ctrl.options;
    const letters = ['A', 'B', 'C', 'D'];

    return Obx(() {
      final isAnswered = ctrl.answered.value;
      final selected = ctrl.selectedIndex.value;
      final eliminated = ctrl.eliminatedIndexes;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hint & Ad bar
          if (!isAnswered)
            HintAdBar(
              onHint: ctrl.useHint,
              hintEnabled: !ctrl.hintUsed.value,
            ),
          SizedBox(height: rs(8)),
          // Question card with 3D depth
          DepthCard(
            accentColor: kSecondaryColor,
            padding: EdgeInsets.all(rs(20)),
            child: Text(
              question.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: kFontSizeH4,
                fontWeight: FontWeight.w700,
                height: 1.6,
                color: kTextPrimary,
              ),
            ),
          ),
          SizedBox(height: rs(24)),
          // Options with 3D
          ...List.generate(options.length, (i) {
            if (eliminated.contains(i)) return const SizedBox.shrink();

            Color borderColor = kBorderColor;
            Color bgColor = kCardColor;
            Color glowColor = Colors.transparent;
            bool isCorrect = false;
            bool isWrong = false;

            if (isAnswered) {
              if (ctrl.isCorrectOption(i)) {
                borderColor = kGreenColor;
                bgColor = kGreenColor.withValues(alpha: 0.12);
                glowColor = kGreenColor;
                isCorrect = true;
              } else if (i == selected) {
                borderColor = kErrorColor;
                bgColor = kErrorColor.withValues(alpha: 0.12);
                glowColor = kErrorColor;
                isWrong = true;
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: rs(10)),
              child: _OptionTile3D(
                letter: letters[i],
                text: options[i],
                borderColor: borderColor,
                bgColor: bgColor,
                glowColor: glowColor,
                isCorrect: isCorrect,
                isWrong: isWrong,
                onTap: () => ctrl.selectAnswer(i),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _OptionTile3D extends StatelessWidget {
  final String letter;
  final String text;
  final Color borderColor;
  final Color bgColor;
  final Color glowColor;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _OptionTile3D({
    required this.letter,
    required this.text,
    required this.borderColor,
    required this.bgColor,
    required this.glowColor,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkCtx(context);
    final darkBorder = HSLColor.fromColor(borderColor)
        .withLightness((HSLColor.fromColor(borderColor).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(14)),
          boxShadow: [
            // 3D base edge
            BoxShadow(
              color: (isCorrect || isWrong)
                  ? darkBorder.withValues(alpha: 0.4)
                  : (isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06)),
              offset: Offset(0, rs(3)),
              blurRadius: rs(1),
            ),
            // Glow for correct/wrong
            if (isCorrect || isWrong)
              BoxShadow(
                color: glowColor.withValues(alpha: 0.2),
                blurRadius: rs(12),
                spreadRadius: rs(1),
              ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: rs(18), vertical: rs(14)),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(rs(14)),
            border: Border.all(color: borderColor, width: rs(2)),
            gradient: (isCorrect || isWrong)
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                        : [Colors.white, const Color(0xFFF8F6FF)],
                  ),
          ),
          child: Row(
            children: [
              // Letter badge with 3D
              Container(
                width: rs(34),
                height: rs(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCorrect
                        ? [kGreenColor, kGreenColor.withValues(alpha: 0.7)]
                        : isWrong
                            ? [kErrorColor, kErrorColor.withValues(alpha: 0.7)]
                            : [
                                kPrimaryColor.withValues(alpha: 0.2),
                                kPrimaryColor.withValues(alpha: 0.08),
                              ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isCorrect ? kGreenColor : isWrong ? kErrorColor : kPrimaryColor)
                          .withValues(alpha: 0.2),
                      blurRadius: rs(4),
                      offset: Offset(0, rs(2)),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: kFontSizeCaption,
                      fontWeight: FontWeight.w700,
                      color: (isCorrect || isWrong) ? Colors.white : kTextPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: rs(12)),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ),
              if (isCorrect)
                Icon(Icons.check_circle, color: kGreenColor, size: rs(22)),
              if (isWrong)
                Icon(Icons.cancel, color: kErrorColor, size: rs(22)),
            ],
          ),
        ),
      ),
    );
  }
}
