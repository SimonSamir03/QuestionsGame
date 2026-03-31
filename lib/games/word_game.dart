import 'package:brainplay/models/question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/word_game_controller.dart';
import '../widgets/hint_ad_bar.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class WordGame extends StatelessWidget {
  final Question question;
  final Function(bool) onAnswer;
  const WordGame({super.key, required this.question, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      WordGameController(question: question, onAnswer: onAnswer),
      tag: 'wg_${question.id}',
    );
    final isAr = question.language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Obx(() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!ctrl.answered.value)
            HintAdBar(
              onHint: ctrl.useHint,
              hintEnabled: !ctrl.hintUsed.value,
            ),
          SizedBox(height: rs(8)),
          // Question hint in glass card
          DepthCard(
            accentColor: kPrimaryColor,
            padding: EdgeInsets.all(rs(20)),
            child: Text(
              ctrl.hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: kFontSizeH4,
                fontWeight: FontWeight.w700,
                color: kTextSecondary,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: rs(24)),
          // Letter tiles with 3D
          Wrap(
            spacing: rs(10),
            runSpacing: rs(10),
            alignment: WrapAlignment.center,
            children: List.generate(ctrl.letters.length, (i) {
              final used = ctrl.used[i];
              return _LetterTile3D(
                letter: ctrl.letters[i],
                used: used,
                onTap: () => ctrl.selectLetter(i),
              );
            }),
          ),
          SizedBox(height: rs(30)),
          // Answer slots with 3D
          Wrap(
            spacing: rs(8),
            runSpacing: rs(8),
            alignment: WrapAlignment.center,
            children: List.generate(ctrl.slots.length, (i) {
              return _SlotTile3D(
                letter: ctrl.slots[i],
                onTap: () => ctrl.removeFromSlot(i),
              );
            }),
          ),
          SizedBox(height: rs(30)),
          // Submit button 3D
          Button3D(
            label: isAr ? '\u0625\u0631\u0633\u0627\u0644' : 'Submit',
            color: kPrimaryColor,
            onTap: ctrl.allFilled ? ctrl.submit : null,
          ),
        ],
      )),
    );
  }
}

class _LetterTile3D extends StatelessWidget {
  final String letter;
  final bool used;
  final VoidCallback onTap;

  const _LetterTile3D({
    required this.letter,
    required this.used,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = used ? kPrimaryColor : kDarkCardColor;
    final darkColor = HSLColor.fromColor(color)
        .withLightness((HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: rs(50),
        height: rs(50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(
              color: darkColor,
              offset: Offset(0, rs(3)),
              blurRadius: 0,
            ),
            BoxShadow(
              color: (used ? kPrimaryColor : kBorderColor).withValues(alpha: 0.2),
              blurRadius: rs(8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: used
                  ? [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.85)]
                  : [kDarkCardColor, kDarkCardColor.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(rs(12)),
            border: Border.all(
              color: kPrimaryColor.withValues(alpha: used ? 0.8 : 0.5),
              width: rs(2),
            ),
          ),
          child: Stack(
            children: [
              // Glossy highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: rs(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(rs(10))),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
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
                    fontSize: kFontSizeH3,
                    fontWeight: FontWeight.w800,
                    color: used ? Colors.white : kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotTile3D extends StatelessWidget {
  final String? letter;
  final VoidCallback onTap;

  const _SlotTile3D({required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final filled = letter != null;
    final color = filled ? kPrimaryColor.withValues(alpha: 0.15) : kBorderColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: rs(46),
        height: rs(46),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.15),
                    blurRadius: rs(6),
                  ),
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    offset: Offset(0, rs(2)),
                    blurRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(0, rs(2)),
                    blurRadius: rs(2),
                  ),
                ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(rs(12)),
            border: Border.all(
              color: filled ? kPrimaryColor : kBorderColor,
              width: rs(2),
            ),
          ),
          child: Center(
            child: Text(
              letter ?? '',
              style: TextStyle(
                fontSize: kFontSizeH4,
                fontWeight: FontWeight.w700,
                color: kPrimaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
