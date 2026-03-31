import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/merge_game_controller.dart';
import '../models/merge_item.dart';
import '../controllers/game_controller.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/game_confirm_dialog.dart';
import '../widgets/hint_ad_bar.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/button_3d.dart';
import '../widgets/animated_bg.dart';

class MergeGameScreen extends StatelessWidget {
  const MergeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MergeGameController());
    final gc = Get.find<GameController>();
    final screenW = MediaQuery.of(context).size.width;
    final gridInset = rs(12) * 2 + rs(4) * 2 + 2 + MergeGameController.cols * 4;
    final cellSize = (screenW - gridInset) / MergeGameController.cols;

    return Obx(() => Scaffold(
      body: AnimatedGameBg(
        particleCount: 10,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
                child: Row(
                  children: [
                    _AppBarBtn(icon: Icons.arrow_back_ios, onTap: () => Get.back()),
                    SizedBox(width: rs(10)),
                    Expanded(
                      child: Text(
                        'Merge Craft',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: kFontSizeH4,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: rs(10)),
                    const CoinsLivesRow(),
                  ],
                ),
              ),
              // Hint & Ad bar
              HintAdBar(
                onHint: ctrl.useHint,
                hintEnabled: !ctrl.hintUsed.value,
              ),
              // Action buttons
              _buildActionBar(ctrl, gc),
              SizedBox(height: rs(8)),
              // Grid + game over overlay
              Expanded(
                child: Stack(
                  children: [
                    _buildGrid(context, ctrl, cellSize),
                    if (ctrl.isGameOver.value) _buildGameOver(context, ctrl, gc),
                  ],
                ),
              ),
              SizedBox(height: rs(6)),
              if (!gc.isPremium.value) const BannerAdWidget(),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildActionBar(MergeGameController ctrl, GameController gc) {
    final spawnCost = ctrl.spawnCost;
    final canSpawn = gc.coins.value >= spawnCost && !ctrl.gridFull;
    final canSpawn3 = gc.coins.value >= spawnCost * 3 && !ctrl.gridFull;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(12)),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton3D(
              icon: Icons.add_circle_outline,
              label: 'Spawn ($spawnCost)',
              emoji: '\u{1FA99}',
              color: kSecondaryColor,
              onTap: () => ctrl.spawnItem(),
              enabled: canSpawn,
            ),
          ),
          SizedBox(width: rs(6)),
          Expanded(
            child: _ActionButton3D(
              icon: Icons.auto_awesome,
              label: 'x3 (${spawnCost * 3})',
              emoji: '\u{1FA99}',
              color: kPrimaryColor,
              onTap: () => ctrl.spawnMultiple(3),
              enabled: canSpawn3,
            ),
          ),
          SizedBox(width: rs(6)),
          _IconAction3D(
            icon: Icons.refresh,
            color: kRedColor,
            onTap: () => _showRestartDialog(ctrl, gc),
            enabled: gc.lives.value > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, MergeGameController ctrl, double cellSize) {
    final isDark = isDarkCtx(context);
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: rs(12)),
        padding: EdgeInsets.all(rs(5)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                : [Colors.white, const Color(0xFFF5F3FF)],
          ),
          borderRadius: BorderRadius.circular(rs(18)),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.08),
              blurRadius: rs(16),
              spreadRadius: rs(2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
              blurRadius: rs(10),
              offset: Offset(0, rs(5)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(MergeGameController.rows, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(MergeGameController.cols, (col) {
                final index = row * MergeGameController.cols + col;
                final item = ctrl.grid[index];
                final isSelected = ctrl.selectedIndex.value == index;
                final isHinted = ctrl.isHinted(index);

                bool canMergeWithSelected = false;
                if (ctrl.selectedIndex.value >= 0 && item != null && !isSelected) {
                  final selectedItem = ctrl.grid[ctrl.selectedIndex.value];
                  if (selectedItem != null) {
                    canMergeWithSelected = selectedItem.canMerge(item);
                  }
                }

                return GestureDetector(
                  onTap: () => ctrl.onCellTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: cellSize - 4,
                    height: cellSize - 4,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor.withValues(alpha: 0.2)
                          : isHinted
                              ? kOrangeColor.withValues(alpha: 0.25)
                              : canMergeWithSelected
                                  ? kGreenColor.withValues(alpha: 0.15)
                                  : item != null
                                      ? item.color.withValues(alpha: 0.08)
                                      : kBorderColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rs(10)),
                      border: Border.all(
                        color: isSelected
                            ? kPrimaryColor
                            : isHinted
                                ? kOrangeColor
                                : canMergeWithSelected
                                    ? kGreenColor.withValues(alpha: 0.6)
                                    : kBorderColor.withValues(alpha: 0.2),
                        width: isSelected || isHinted || canMergeWithSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(8)),
                              BoxShadow(color: kPrimaryColor.withValues(alpha: 0.15), offset: Offset(0, rs(2)), blurRadius: 0),
                            ]
                          : isHinted
                              ? [BoxShadow(color: kOrangeColor.withValues(alpha: 0.4), blurRadius: rs(8))]
                              : item != null
                                  ? [
                                      BoxShadow(
                                        color: item.color.withValues(alpha: 0.12),
                                        offset: Offset(0, rs(2)),
                                        blurRadius: rs(1),
                                      ),
                                    ]
                                  : null,
                    ),
                    child: item != null ? _buildItemCell(item) : const SizedBox.shrink(),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildItemCell(MergeItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.emoji, style: TextStyle(fontSize: fs(22))),
        if (item.level > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              item.level.clamp(0, 5),
              (_) => Container(
                width: rs(4),
                height: rs(4),
                margin: EdgeInsets.symmetric(horizontal: rs(0.5)),
                decoration: BoxDecoration(
                  color: kYellowColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: kYellowColor.withValues(alpha: 0.5), blurRadius: rs(2)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameOver(BuildContext context, MergeGameController ctrl, GameController gc) {
    final won = ctrl.isWin.value;
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(rs(32)),
          padding: EdgeInsets.all(rs(28)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkCtx(context)
                  ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                  : [Colors.white, const Color(0xFFF5F3FF)],
            ),
            borderRadius: BorderRadius.circular(rs(24)),
            border: Border.all(color: (won ? kGreenColor : kRedColor).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: (won ? kGreenColor : kRedColor).withValues(alpha: 0.15),
                blurRadius: rs(20),
                spreadRadius: rs(2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(won ? '\u{1F389}' : '\u{1F635}', style: TextStyle(fontSize: fs(52))),
              SizedBox(height: rs(12)),
              Text(
                won
                    ? (gc.isAr ? '\u0623\u062d\u0633\u0646\u062a!' : 'You Win!')
                    : (gc.isAr ? '\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629' : 'Game Over'),
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: kFontSizeH2,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: (won ? kGreenColor : kRedColor).withValues(alpha: 0.4),
                      blurRadius: rs(10),
                    ),
                  ],
                ),
              ),
              SizedBox(height: rs(8)),
              if (won)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\u{1FA99}', style: TextStyle(fontSize: fs(22))),
                    SizedBox(width: rs(6)),
                    Text('+${ctrl.score.value}',
                        style: TextStyle(color: Colors.amber, fontSize: kFontSizeH3, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Text(
                  gc.isAr ? '\u0627\u0644\u0646\u062a\u064a\u062c\u0629: ${ctrl.score.value}' : 'Score: ${ctrl.score.value}',
                  style: TextStyle(color: Colors.amber, fontSize: kFontSizeH4, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: rs(4)),
              Text(
                gc.isAr ? '\u0627\u0644\u0623\u0641\u0636\u0644: ${ctrl.bestScore.value}' : 'Best: ${ctrl.bestScore.value}',
                style: TextStyle(color: kTextHint, fontSize: kFontSizeBody),
              ),
              SizedBox(height: rs(24)),
              Button3D(
                label: gc.isAr
                    ? '\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649'
                    : 'Play Again',
                color: won ? kPrimaryColor : kRedColor,
                icon: Icons.replay,
                onTap: gc.lives.value > 0
                    ? () {
                        if (!gc.tryShowMysteryBox()) ctrl.restart();
                      }
                    : null,
              ),
              SizedBox(height: rs(10)),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  gc.isAr ? '\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0629' : 'Home',
                  style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestartDialog(MergeGameController ctrl, GameController gc) {
    if (gc.lives.value <= 0) {
      Get.snackbar(
        gc.isAr ? '\u0644\u0627 \u064a\u0648\u062c\u062f \u0623\u0631\u0648\u0627\u062d' : 'No Lives Left',
        gc.isAr ? '\u0634\u0627\u0647\u062f \u0625\u0639\u0644\u0627\u0646' : 'Watch an ad to earn coins',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kCardColor,
        colorText: kTextPrimary,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    GameConfirmDialog.show(
      title: gc.isAr ? '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0628\u062f\u0621\u061f' : 'Restart?',
      message: gc.isAr
          ? '\u0633\u064a\u062a\u0645 \u062e\u0633\u0627\u0631\u0629 \u0631\u0648\u062d (${gc.lives.value} \u2764\ufe0f)'
          : 'This will cost 1 life (\u2764\ufe0f ${gc.lives.value})',
      confirmLabel: gc.isAr ? '\u0625\u0639\u0627\u062f\u0629' : 'Restart',
      cancelLabel: gc.isAr ? '\u0625\u0644\u063a\u0627\u0621' : 'Cancel',
      confirmColor: kRedColor,
      onConfirm: () => ctrl.restart(),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkCtx(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()]
                : [Colors.white, const Color(0xFFF5F3FF)],
          ),
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08), offset: Offset(0, rs(2)), blurRadius: rs(1)),
          ],
        ),
        child: Icon(icon, color: kTextSecondary, size: rs(20)),
      ),
    );
  }
}

class _ActionButton3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? emoji;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionButton3D({
    required this.icon,
    required this.label,
    this.emoji,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : color.withValues(alpha: 0.3);
    final darkColor = HSLColor.fromColor(effectiveColor)
        .withLightness((HSLColor.fromColor(effectiveColor).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(10)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              effectiveColor.withValues(alpha: 0.2),
              effectiveColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(14)),
          border: Border.all(color: effectiveColor.withValues(alpha: 0.4)),
          boxShadow: enabled
              ? [
                  BoxShadow(color: darkColor.withValues(alpha: 0.3), offset: Offset(0, rs(2)), blurRadius: 0),
                  BoxShadow(color: effectiveColor.withValues(alpha: 0.1), blurRadius: rs(6)),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor, size: rs(18)),
            SizedBox(height: rs(2)),
            Text(
              label,
              style: TextStyle(color: effectiveColor, fontSize: fs(9), fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction3D extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _IconAction3D({
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : color.withValues(alpha: 0.3);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(rs(10)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              effectiveColor.withValues(alpha: 0.2),
              effectiveColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(14)),
          border: Border.all(color: effectiveColor.withValues(alpha: 0.4)),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: HSLColor.fromColor(effectiveColor).withLightness(
                      (HSLColor.fromColor(effectiveColor).lightness - 0.15).clamp(0.0, 1.0),
                    ).toColor().withValues(alpha: 0.3),
                    offset: Offset(0, rs(2)),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: effectiveColor, size: rs(20)),
      ),
    );
  }
}
