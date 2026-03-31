import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/domino_all_fives_controller.dart';
import '../controllers/domino_game_controller.dart';
import 'domino_game.dart';
import '../widgets/hint_ad_bar.dart';

class DominoAllFivesGame extends StatelessWidget {
  final String language;
  final Function(bool won) onGameEnd;

  const DominoAllFivesGame({super.key, required this.language, required this.onGameEnd});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      DominoAllFivesController(language: language, onGameEnd: onGameEnd),
      tag: 'domino_all_fives',
    );

    return Obx(() {
      final isAr = language == 'ar';
      return Column(
        children: [
          if (ctrl.gameState.value == GameState.playing)
            HintAdBar(
              onHint: ctrl.useHint,
              hintEnabled: !ctrl.hintUsed.value,
            ),
          _buildScoreBar(ctrl, isAr),
          SizedBox(height: rs(4)),
          _buildStatusBar(ctrl, isAr),
          SizedBox(height: rs(4)),

          // Board - cross layout
          Expanded(
            flex: 4,
            child: _buildCrossBoard(ctrl, isAr),
          ),

          // Message + last scoring play
          Padding(
            padding: EdgeInsets.symmetric(vertical: rs(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctrl.message.value,
                  style: TextStyle(
                    fontSize: kFontSizeBody,
                    fontWeight: FontWeight.w600,
                    color: ctrl.gameState.value == GameState.playerWon
                        ? kGreenColor
                        : ctrl.gameState.value == GameState.aiWon
                            ? kErrorColor
                            : kTextSecondary,
                  ),
                ),
                if (ctrl.lastScoringPlay.value.isNotEmpty)
                  Text(
                    ctrl.lastScoringPlay.value,
                    style: TextStyle(
                      fontSize: kFontSizeCaption,
                      fontWeight: FontWeight.bold,
                      color: kOrangeColor,
                    ),
                  ),
              ],
            ),
          ),

          // Play buttons
          if (ctrl.selectedTile.value != null && ctrl.gameState.value == GameState.playing)
            _buildPlayButtons(ctrl, isAr),

          // Player hand
          Expanded(
            flex: 2,
            child: _buildPlayerHand(ctrl, isAr),
          ),
        ],
      );
    });
  }

  // ── Score bar ──────────────────────────────────────────────────────────────

  Widget _buildScoreBar(DominoAllFivesController ctrl, bool isAr) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(4)),
      padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(8)),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(kRadiusS),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(isAr ? '\u0623\u0646\u062a' : 'You', style: TextStyle(fontSize: kFontSizeCaption, color: kTextSecondary)),
              Text('${ctrl.playerScore.value}', style: TextStyle(fontSize: kFontSizeH3, fontWeight: FontWeight.bold, color: kGreenColor)),
            ],
          ),
          Column(
            children: [
              Text(isAr ? '\u062c\u0648\u0644\u0629 ${ctrl.roundNumber.value}' : 'Round ${ctrl.roundNumber.value}', style: TextStyle(fontSize: kFontSizeCaption, color: kTextHint)),
              Text(isAr ? '\u0627\u0644\u0647\u062f\u0641: ${DominoAllFivesController.targetScore}' : 'Target: ${DominoAllFivesController.targetScore}', style: TextStyle(fontSize: kFontSizeTiny, color: kTextHint)),
            ],
          ),
          Column(
            children: [
              Text(isAr ? '\u0627\u0644\u062e\u0635\u0645' : 'AI', style: TextStyle(fontSize: kFontSizeCaption, color: kTextSecondary)),
              Text('${ctrl.aiScore.value}', style: TextStyle(fontSize: kFontSizeH3, fontWeight: FontWeight.bold, color: kErrorColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status bar ─────────────────────────────────────────────────────────────

  Widget _buildStatusBar(DominoAllFivesController ctrl, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusChip(isAr ? '\u0627\u0644\u062e\u0635\u0645' : 'Opponent', '${ctrl.aiHand.length}', kErrorColor),
          _statusChip(isAr ? '\u0627\u0644\u0645\u062e\u0632\u0646' : 'Boneyard', '${ctrl.boneyard.length}', kTextHint),
          _statusChip(
            isAr
                ? (ctrl.allFourSidesPlayed ? '\u0627\u0644\u0623\u0637\u0631\u0627\u0641' : '\u0627\u0641\u062a\u062d \u0634\u0643\u0644 +')
                : (ctrl.allFourSidesPlayed ? 'Ends' : 'Open all 4'),
            '${ctrl.spinnerTile.value == null ? 0 : ctrl.calculateOpenEndsSum()}',
            ctrl.allFourSidesPlayed ? kOrangeColor : kTextHint,
          ),
          if (ctrl.gameState.value == GameState.playing &&
              ctrl.turnState.value == TurnState.playerTurn &&
              !ctrl.isProcessing.value &&
              !_hasPlayable(ctrl))
            GestureDetector(
              onTap: ctrl.drawTile,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(6)),
                decoration: BoxDecoration(
                  color: kOrangeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(rs(12)),
                  border: Border.all(color: kOrangeColor),
                ),
                child: Text(
                  isAr ? '\u0627\u0633\u062d\u0628' : 'Draw',
                  style: TextStyle(color: kOrangeColor, fontWeight: FontWeight.bold, fontSize: kFontSizeCaption),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _hasPlayable(DominoAllFivesController ctrl) {
    if (ctrl.spinnerTile.value == null) return ctrl.playerHand.isNotEmpty;
    return ctrl.playerHand.any((t) => ctrl.getPlayableEnds(t).isNotEmpty);
  }

  Widget _statusChip(String label, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(8), vertical: rs(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: kFontSizeTiny, color: color)),
          SizedBox(width: rs(4)),
          Text(count, style: TextStyle(fontSize: kFontSizeCaption, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ── Cross-shaped board with bending chains ─────────────────────────────────
  //
  // Chains bend when they reach the screen edge, just like a real domino table.
  // Right chain bends down, left chain bends down, top/bottom go straight.

  static const double _tileUnit = 14.0; // base tile size

  Widget _buildCrossBoard(DominoAllFivesController ctrl, bool isAr) {
    if (ctrl.spinnerTile.value == null) {
      return Center(
        child: Text(
          isAr ? '\u0636\u0639 \u0623\u0648\u0644 \u0642\u0637\u0639\u0629' : 'Place the first tile',
          style: TextStyle(color: kTextHint, fontSize: kFontSizeBody),
        ),
      );
    }

    final s = rs(_tileUnit);
    final spinner = ctrl.spinnerTile.value!;
    final leftTiles = ctrl.leftChain.reversed.toList();
    final rightTiles = ctrl.rightChain.toList();
    final topTiles = ctrl.topChain.reversed.toList();
    final bottomTiles = ctrl.bottomChain.toList();

    // 3-row, 3-column grid layout:
    //        [  ] [top ] [  ]
    //        [left][spin][right]
    //        [  ] [bot ] [  ]
    // Left/right cells are empty in top/bottom rows.
    // This guarantees top/bottom align with spinner.

    final topWidget = topTiles.isNotEmpty
        ? _buildStraightVerticalChain(topTiles, s)
        : (ctrl.spinnerTile.value != null ? _buildEndDot(kGreenColor) : const SizedBox.shrink());

    final bottomWidget = bottomTiles.isNotEmpty
        ? _buildStraightVerticalChain(bottomTiles, s)
        : (ctrl.spinnerTile.value != null ? _buildEndDot(kOrangeColor) : const SizedBox.shrink());

    final leftWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: leftTiles.map((t) => t.isDouble
          ? _buildVerticalTile(t, s)
          : _buildHorizontalTile(t, s)).toList(),
    );

    final rightWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rightTiles.map((t) => t.isDouble
          ? _buildVerticalTile(t, s)
          : _buildHorizontalTile(t, s)).toList(),
    );

    return InteractiveViewer(
      minScale: 0.3,
      maxScale: 1.5,
      constrained: false,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rs(40), vertical: rs(80)),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Row 1: top chain centered in middle column
              TableRow(children: [
                const SizedBox.shrink(),
                topWidget,
                const SizedBox.shrink(),
              ]),
              // Row 2: left + spinner + right
              TableRow(children: [
                leftWidget,
                _buildSpinnerTile(spinner, s),
                rightWidget,
              ]),
              // Row 3: bottom chain centered in middle column
              TableRow(children: [
                const SizedBox.shrink(),
                bottomWidget,
                const SizedBox.shrink(),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  /// Spinner tile — vertical double with amber border.
  /// Left/right chains attach at its center (middle of the double).
  Widget _buildSpinnerTile(DominoTile tile, double size) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(rs(6)),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.8), width: rs(2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size * 1.5,
            height: size,
            child: CustomPaint(
              painter: _DominoDotsPainter(value: tile.left, dotColor: Colors.white),
            ),
          ),
          Container(height: rs(1.5), width: size * 1.5, color: Colors.amber.withValues(alpha: 0.4)),
          SizedBox(
            width: size * 1.5,
            height: size,
            child: CustomPaint(
              painter: _DominoDotsPainter(value: tile.right, dotColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// A straight vertical chain (for top/bottom from spinner).
  Widget _buildStraightVerticalChain(List<DominoTile> tiles, double tileSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: tiles.map((t) => t.isDouble
          ? _buildHorizontalTile(t, tileSize)
          : _buildVerticalTile(t, tileSize),
      ).toList(),
    );
  }

  /// Standard horizontal tile [left|right].
  Widget _buildHorizontalTile(DominoTile tile, double size) {
    return DominoGame.buildDominoTile(tile.left, tile.right, size: size);
  }

  /// Vertical tile (rotated 90 degrees) — for doubles in horizontal chains,
  /// non-doubles in vertical chains, and the spinner.
  Widget _buildVerticalTile(DominoTile tile, double size) {
    return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(rs(6)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: rs(1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size * 1.5,
              height: size * 1.2,
              child: CustomPaint(
                painter: _DominoDotsPainter(value: tile.left, dotColor: Colors.white),
              ),
            ),
            Container(height: rs(1.5), width: size * 1.5, color: Colors.white.withValues(alpha: 0.2)),
            SizedBox(
              width: size * 1.5,
              height: size * 1.2,
              child: CustomPaint(
                painter: _DominoDotsPainter(value: tile.right, dotColor: Colors.white),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildEndDot(Color color) {
    return Padding(
      padding: EdgeInsets.all(rs(2)),
      child: Container(
        width: rs(8),
        height: rs(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  // ── Play buttons ───────────────────────────────────────────────────────────

  Widget _buildPlayButtons(DominoAllFivesController ctrl, bool isAr) {
    final tile = ctrl.selectedTile.value!;
    final ends = ctrl.getPlayableEnds(tile);

    if (ends.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: rs(8)),
        child: Text(
          isAr ? '\u0647\u0630\u0647 \u0627\u0644\u0642\u0637\u0639\u0629 \u0644\u0627 \u062a\u062a\u0637\u0627\u0628\u0642' : 'This tile doesn\'t match',
          style: TextStyle(color: kErrorColor, fontSize: kFontSizeCaption),
        ),
      );
    }

    if (ctrl.spinnerTile.value == null || ends.length == 1) {
      return Padding(
        padding: EdgeInsets.only(bottom: rs(8)),
        child: ElevatedButton(
          onPressed: () => ctrl.playTile(ends.first),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(12))),
            padding: EdgeInsets.symmetric(horizontal: rs(32), vertical: rs(10)),
          ),
          child: Text(
            isAr ? '\u0627\u0644\u0639\u0628' : 'Play',
            style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    // Multiple ends - show directional buttons
    return Padding(
      padding: EdgeInsets.only(bottom: rs(8)),
      child: Wrap(
        spacing: rs(8),
        runSpacing: rs(4),
        alignment: WrapAlignment.center,
        children: ends.map((end) {
          final label = _endLabel(end, ctrl, isAr);
          final color = _endColor(end);
          final icon = _endIcon(end);
          return ElevatedButton.icon(
            onPressed: () => ctrl.playTile(end),
            icon: Icon(icon, size: rs(16)),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(12))),
              padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(8)),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _endLabel(String end, DominoAllFivesController ctrl, bool isAr) {
    switch (end) {
      case 'left':
        return isAr ? '\u064a\u0633\u0627\u0631 (${ctrl.leftEnd.value})' : 'Left (${ctrl.leftEnd.value})';
      case 'right':
        return isAr ? '\u064a\u0645\u064a\u0646 (${ctrl.rightEnd.value})' : 'Right (${ctrl.rightEnd.value})';
      case 'top':
        final v = ctrl.topChain.isNotEmpty ? ctrl.topEnd.value! : ctrl.spinnerValue.value!;
        return isAr ? '\u0623\u0639\u0644\u0649 ($v)' : 'Top ($v)';
      case 'bottom':
        final v = ctrl.bottomChain.isNotEmpty ? ctrl.bottomEnd.value! : ctrl.spinnerValue.value!;
        return isAr ? '\u0623\u0633\u0641\u0644 ($v)' : 'Bottom ($v)';
      default:
        return end;
    }
  }

  Color _endColor(String end) {
    switch (end) {
      case 'left': return kPrimaryColor;
      case 'right': return kSecondaryColor;
      case 'top': return kGreenColor;
      case 'bottom': return kOrangeColor;
      default: return kPrimaryColor;
    }
  }

  IconData _endIcon(String end) {
    switch (end) {
      case 'left': return Icons.arrow_back;
      case 'right': return Icons.arrow_forward;
      case 'top': return Icons.arrow_upward;
      case 'bottom': return Icons.arrow_downward;
      default: return Icons.circle;
    }
  }

  // ── Player hand ────────────────────────────────────────────────────────────

  Widget _buildPlayerHand(DominoAllFivesController ctrl, bool isAr) {
    return Column(
      children: [
        Text(
          isAr ? '\u0642\u0637\u0639\u0643 (${ctrl.playerHand.length})' : 'Your Tiles (${ctrl.playerHand.length})',
          style: TextStyle(fontSize: kFontSizeCaption, color: kTextSecondary, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: rs(6)),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: rs(8),
              runSpacing: rs(8),
              alignment: WrapAlignment.center,
              children: ctrl.playerHand.map((tile) {
                final isSelected = ctrl.selectedTile.value == tile;
                final isHinted = ctrl.hintTile.value == tile;
                final canPlay = ctrl.spinnerTile.value == null || ctrl.getPlayableEnds(tile).isNotEmpty;

                return GestureDetector(
                  onTap: () => ctrl.selectTile(tile),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(rs(4)),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor.withValues(alpha: 0.2)
                          : isHinted
                              ? kOrangeColor.withValues(alpha: 0.25)
                              : canPlay
                                  ? Colors.transparent
                                  : kBorderColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rs(10)),
                      border: Border.all(
                        color: isSelected
                            ? kPrimaryColor
                            : canPlay
                                ? kBorderColor
                                : kBorderColor.withValues(alpha: 0.3),
                        width: isSelected ? rs(2.5) : rs(1),
                      ),
                    ),
                    child: Opacity(
                      opacity: canPlay ? 1.0 : 0.4,
                      child: DominoGame.buildDominoTile(tile.left, tile.right, size: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints domino dot patterns for values 0-6.
class _DominoDotsPainter extends CustomPainter {
  final int value;
  final Color dotColor;

  _DominoDotsPainter({required this.value, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    final r = size.shortestSide * 0.1;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = size.width * 0.28;
    final dy = size.height * 0.28;

    final tl = Offset(cx - dx, cy - dy);
    final tr = Offset(cx + dx, cy - dy);
    final ml = Offset(cx - dx, cy);
    final mr = Offset(cx + dx, cy);
    final c  = Offset(cx, cy);
    final bl = Offset(cx - dx, cy + dy);
    final br = Offset(cx + dx, cy + dy);

    List<Offset> dots;
    switch (value) {
      case 0: dots = []; break;
      case 1: dots = [c]; break;
      case 2: dots = [tl, br]; break;
      case 3: dots = [tl, c, br]; break;
      case 4: dots = [tl, tr, bl, br]; break;
      case 5: dots = [tl, tr, c, bl, br]; break;
      case 6: dots = [tl, tr, ml, mr, bl, br]; break;
      default: dots = [];
    }

    for (final dot in dots) {
      canvas.drawCircle(dot, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DominoDotsPainter old) =>
      old.value != value || old.dotColor != dotColor;
}
