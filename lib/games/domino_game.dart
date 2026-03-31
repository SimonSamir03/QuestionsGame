import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/domino_game_controller.dart';
import '../widgets/hint_ad_bar.dart';

class DominoGame extends StatelessWidget {
  final String language;
  final Function(bool won) onGameEnd;

  const DominoGame({super.key, required this.language, required this.onGameEnd});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      DominoGameController(language: language, onGameEnd: onGameEnd),
      tag: 'domino_game',
    );

    return Obx(() {
      final isAr = language == 'ar';
      return Column(
        children: [
          // Hint & Ad bar
          if (ctrl.gameState.value == GameState.playing)
            HintAdBar(
              onHint: ctrl.useHint,
              hintEnabled: !ctrl.hintUsed.value,
            ),
          // Status bar
          _buildStatusBar(ctrl, isAr),
          SizedBox(height: rs(8)),

          // Board
          Expanded(
            flex: 3,
            child: _buildBoard(ctrl),
          ),

          // Message
          Padding(
            padding: EdgeInsets.symmetric(vertical: rs(8)),
            child: Text(
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
          ),

          // Play buttons (left/right end)
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

  Widget _buildStatusBar(DominoGameController ctrl, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusChip(
            isAr ? 'الخصم' : 'Opponent',
            '${ctrl.aiHand.length}',
            kErrorColor,
          ),
          _statusChip(
            isAr ? 'المخزن' : 'Boneyard',
            '${ctrl.boneyard.length}',
            kTextHint,
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
                  isAr ? 'اسحب' : 'Draw',
                  style: TextStyle(
                    color: kOrangeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: kFontSizeCaption,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _hasPlayable(DominoGameController ctrl) {
    if (ctrl.board.isEmpty) return ctrl.playerHand.isNotEmpty;
    return ctrl.playerHand.any(
      (t) => t.canMatch(ctrl.leftEnd.value) || t.canMatch(ctrl.rightEnd.value),
    );
  }

  Widget _statusChip(String label, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(10), vertical: rs(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: kFontSizeCaption, color: color)),
          SizedBox(width: rs(6)),
          Text(count, style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildBoard(DominoGameController ctrl) {
    if (ctrl.board.isEmpty) {
      return Center(
        child: Text(
          language == 'ar' ? 'ضع أول قطعة' : 'Place the first tile',
          style: TextStyle(color: kTextHint, fontSize: kFontSizeBody),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = rs(2);
        final pad = rs(8);
        final availableW = constraints.maxWidth - pad * 2;

        // Scale tile size so ~7 regular tiles fit in one row
        final double s = ((availableW / 7 - gap) / (1.2 * 2 + 0.3) * 0.85).clamp(10.0, 20.0);

        // Horizontal tile sizes
        final hRegW = s * 1.2 * 2 + rs(3) + rs(1.5); // regular: wide
        final hRegH = s * 1.5 + rs(3);                // regular: short
        final hDblW = s * 1.5 + rs(3);                // double (perpendicular): narrow
        final hDblH = s * 1.2 * 2 + rs(3) + rs(1.5); // double (perpendicular): tall

        // Vertical tile sizes (regular rotated, double perpendicular)
        final vRegW = hRegH; // short side becomes width
        final vRegH = hRegW; // wide side becomes height
        final vDblW = hDblH; // tall side becomes width (perpendicular)
        final vDblH = hDblW; // narrow side becomes height

        double tw(DominoTile t, bool v) => v ? (t.isDouble ? vDblW : vRegW) : (t.isDouble ? hDblW : hRegW);
        double th(DominoTile t, bool v) => v ? (t.isDouble ? vDblH : vRegH) : (t.isDouble ? hDblH : hRegH);

        // Vertical offset to center regular tiles with doubles
        final rowCenterOff = (hDblH - hRegH) / 2;

        final positions = <_TilePos>[];
        int dir = 0;
        double cx = 0;
        double rowTop = 0;
        double rowBot = hDblH; // row height = tallest tile (double)
        double colRight = 0;
        double colY = 0;
        int colCount = 0;
        const maxColTiles = 3;

        for (int i = 0; i < ctrl.board.length; i++) {
          final tile = ctrl.board[i];

          if (dir == 0) {
            final w = tw(tile, false);
            final h = th(tile, false);
            if (cx + w > availableW && i > 0) {
              // Corner tile: place horizontally in the row, then column starts below
              dir = 1;
              colCount = 0;
              // Place tile horizontally at the right edge
              final tx = availableW - w;
              final yOff2 = tile.isDouble ? 0.0 : rowCenterOff;
              positions.add(_TilePos(tx, rowTop + yOff2, false));
              final bot = rowTop + h;
              if (bot > rowBot) rowBot = bot;
              colRight = availableW;
              colY = rowBot + gap;
              continue;
            }
            // Center regular tiles with doubles
            final yOff = tile.isDouble ? 0.0 : rowCenterOff;
            positions.add(_TilePos(cx, rowTop + yOff, false));
            final bot = rowTop + h;
            if (bot > rowBot) rowBot = bot;
            cx += w + gap;

          } else if (dir == 1) {
            if (colCount >= maxColTiles) {
              // Turn left
              dir = 2;
              final w = tw(tile, false);
              rowTop = colY - gap;
              rowBot = rowTop + hDblH;
              cx = colRight - w - gap;
              final yOff = tile.isDouble ? 0.0 : rowCenterOff;
              positions.add(_TilePos(cx, rowTop + yOff, false, flipped: true));
              continue;
            }
            final cw = tw(tile, true);
            positions.add(_TilePos(colRight - cw, colY, true));
            colY += th(tile, true) + gap;
            colCount++;

          } else if (dir == 2) {
            final w = tw(tile, false);
            final h = th(tile, false);
            if (cx - w < 0 && i > 0) {
              // Corner tile: place horizontally in the row, then column starts below
              dir = 3;
              colCount = 0;
              final yOff2 = tile.isDouble ? 0.0 : rowCenterOff;
              positions.add(_TilePos(0, rowTop + yOff2, false, flipped: true));
              final bot = rowTop + h;
              if (bot > rowBot) rowBot = bot;
              colY = rowBot + gap;
              continue;
            }
            cx -= w + gap;
            final yOff = tile.isDouble ? 0.0 : rowCenterOff;
            positions.add(_TilePos(cx, rowTop + yOff, false, flipped: true));
            final bot = rowTop + h;
            if (bot > rowBot) rowBot = bot;

          } else {
            if (colCount >= maxColTiles) {
              // Turn right
              dir = 0;
              final w = tw(tile, false);
              rowTop = colY - gap;
              rowBot = rowTop + hDblH;
              final maxColW = vDblW > vRegW ? vDblW : vRegW;
              cx = maxColW + gap;
              final yOff = tile.isDouble ? 0.0 : rowCenterOff;
              positions.add(_TilePos(cx, rowTop + yOff, false));
              cx += w + gap;
              continue;
            }
            positions.add(_TilePos(0, colY, true));
            colY += th(tile, true) + gap;
            colCount++;
          }
        }

        // Bounds
        double maxX = 0, maxY = 0;
        for (int i = 0; i < positions.length; i++) {
          final p = positions[i];
          final w = tw(ctrl.board[i], p.rotated);
          final h = th(ctrl.board[i], p.rotated);
          if (p.x + w > maxX) maxX = p.x + w;
          if (p.y + h > maxY) maxY = p.y + h;
        }

        return Directionality(
          textDirection: TextDirection.ltr,
          child: InteractiveViewer(
            boundaryMargin: EdgeInsets.all(rs(40)),
            minScale: 0.5,
            maxScale: 2.0,
            constrained: false,
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: SizedBox(
                width: maxX,
                height: maxY,
                child: Stack(
                  children: [
                    for (int i = 0; i < ctrl.board.length; i++)
                      Positioned(
                        left: positions[i].x,
                        top: positions[i].y,
                        child: _buildTileWidget(ctrl.board[i], positions[i].rotated, positions[i].flipped, s),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Horizontal segment: regular=horizontal, double=vertical (perpendicular).
  /// Vertical segment: regular=vertical, double=horizontal (perpendicular).
  static Widget _buildTileWidget(DominoTile tile, bool verticalSegment, bool flipped, double size) {
    final a = flipped ? tile.right : tile.left;
    final b = flipped ? tile.left : tile.right;
    if (verticalSegment) {
      return tile.isDouble
          ? buildDominoTile(a, b, size: size)
          : buildVerticalDominoTile(a, b, size: size);
    } else {
      return tile.isDouble
          ? buildVerticalDominoTile(a, b, size: size)
          : buildDominoTile(a, b, size: size);
    }
  }

  Widget _buildPlayButtons(DominoGameController ctrl, bool isAr) {
    final tile = ctrl.selectedTile.value!;
    final ends = ctrl.getPlayableEnds(tile);

    if (ends.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: rs(8)),
        child: Text(
          isAr ? 'هذه القطعة لا تتطابق' : 'This tile doesn\'t match',
          style: TextStyle(color: kErrorColor, fontSize: kFontSizeCaption),
        ),
      );
    }

    // If first tile on board, just one "Play" button
    if (ctrl.board.isEmpty || ends.length == 1) {
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
            isAr ? 'العب' : 'Play',
            style: TextStyle(fontSize: kFontSizeBody, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    // Both ends available
    return Padding(
      padding: EdgeInsets.only(bottom: rs(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => ctrl.playTile('left'),
            icon: Icon(Icons.arrow_back, size: rs(16)),
            label: Text(isAr ? 'يسار (${ctrl.leftEnd.value})' : 'Left (${ctrl.leftEnd.value})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(12))),
              padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(8)),
            ),
          ),
          SizedBox(width: rs(12)),
          ElevatedButton.icon(
            onPressed: () => ctrl.playTile('right'),
            icon: Icon(Icons.arrow_forward, size: rs(16)),
            label: Text(isAr ? 'يمين (${ctrl.rightEnd.value})' : 'Right (${ctrl.rightEnd.value})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(12))),
              padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHand(DominoGameController ctrl, bool isAr) {
    return Column(
      children: [
        Text(
          isAr ? 'قطعك (${ctrl.playerHand.length})' : 'Your Tiles (${ctrl.playerHand.length})',
          style: TextStyle(
            fontSize: kFontSizeCaption,
            color: kTextSecondary,
            fontWeight: FontWeight.w600,
          ),
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
                final canPlay = ctrl.board.isEmpty ||
                    tile.canMatch(ctrl.leftEnd.value) ||
                    tile.canMatch(ctrl.rightEnd.value);

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
                      child: buildDominoTile(tile.left, tile.right, size: 24),
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

  /// Renders a single domino tile with two halves side by side.
  static Widget buildDominoTile(int left, int right, {double size = 32}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(rs(6)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: rs(1.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHalf(left, size),
          Container(width: rs(1.5), height: size * 1.5, color: Colors.white.withValues(alpha: 0.2)),
          _buildHalf(right, size),
        ],
      ),
    );
  }

  /// Renders a single domino tile vertically (for doubles — perpendicular to chain).
  static Widget buildVerticalDominoTile(int top, int bottom, {double size = 32}) {
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
              painter: _DominoDotsPainter(value: top, dotColor: Colors.white),
            ),
          ),
          Container(height: rs(1.5), width: size * 1.5, color: Colors.white.withValues(alpha: 0.2)),
          SizedBox(
            width: size * 1.5,
            height: size * 1.2,
            child: CustomPaint(
              painter: _DominoDotsPainter(value: bottom, dotColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHalf(int value, double size) {
    return SizedBox(
      width: size * 1.2,
      height: size * 1.5,
      child: CustomPaint(
        painter: _DominoDotsPainter(value: value, dotColor: Colors.white),
      ),
    );
  }
}

/// Position data for a tile in the snake layout.
class _TilePos {
  final double x;
  final double y;
  final bool rotated;  // vertical segment
  final bool flipped;  // reverse left/right (for left-going rows & down columns)
  const _TilePos(this.x, this.y, this.rotated, {this.flipped = false});
}

/// Paints the classic domino dot patterns for values 0-6.
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
