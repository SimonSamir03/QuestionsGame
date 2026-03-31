import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/ludo_controller.dart';
import '../models/ludo_models.dart';
import '../widgets/depth_card.dart';

// ── Warm Wooden Board Yard Colors (colored wood inlays) ────────────────────

const _yardColors = {
  LudoColor.red: Color(0xFFC04040),
  LudoColor.green: Color(0xFF408040),
  LudoColor.yellow: Color(0xFFD0A030),
  LudoColor.blue: Color(0xFF4070B0),
};

class LudoGame extends StatelessWidget {
  final LudoMode mode;
  final LudoColor playerColor;
  final String language;
  final Function(LudoColor winner) onGameEnd;

  const LudoGame({
    super.key,
    required this.mode,
    this.playerColor = LudoColor.red,
    required this.language,
    required this.onGameEnd,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      LudoController(mode: mode, language: language, onGameEnd: onGameEnd, playerColor: playerColor),
      tag: 'ludo_${mode.name}',
    );

    return Obx(() {
      final isAr = language == 'ar';
      return Column(
        children: [
          // Player info bar
          _buildPlayerBar(ctrl, isAr),
          SizedBox(height: rs(8)),

          // Board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildBoard(ctrl),
              ),
            ),
          ),
          SizedBox(height: rs(8)),

          // Dice + controls
          _buildDiceArea(ctrl, isAr),
          SizedBox(height: rs(8)),

          // Message
          Text(
            ctrl.message.value,
            style: TextStyle(
              color: kTextSecondary,
              fontSize: kFontSizeBody,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: rs(4)),

          // Rankings
          if (ctrl.rankings.isNotEmpty)
            _buildRankings(ctrl, isAr),
          SizedBox(height: rs(8)),
        ],
      );
    });
  }

  // ── Player bar ───────────────────────────────────────────────────────────

  Widget _buildPlayerBar(LudoController ctrl, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(12)),
      child: Row(
        children: ctrl.players.asMap().entries.map((e) {
          final player = e.value;
          final isCurrent = ctrl.currentPlayerIndex.value == e.key;
          return Expanded(
            child: DepthCard(
              accentColor: player.color.color,
              elevation: isCurrent ? 1.2 : 0.5,
              borderRadius: 12,
              margin: EdgeInsets.symmetric(horizontal: rs(3)),
              padding: EdgeInsets.symmetric(vertical: rs(6), horizontal: rs(8)),
              gradient: isCurrent
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        player.color.color.withValues(alpha: 0.3),
                        player.color.color.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      color: player.color.color,
                      fontSize: kFontSizeTiny,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: rs(2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (i) {
                      final piece = player.pieces[i];
                      return Container(
                        width: rs(8),
                        height: rs(8),
                        margin: EdgeInsets.symmetric(horizontal: rs(1)),
                        decoration: BoxDecoration(
                          color: piece.isFinished
                              ? Colors.amber
                              : piece.isInYard
                                  ? player.color.color.withValues(alpha: 0.3)
                                  : player.color.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            // 3D depth shadow on mini indicators
                            BoxShadow(
                              color: (piece.isFinished ? Colors.amber : player.color.color)
                                  .withValues(alpha: 0.4),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Board ────────────────────────────────────────────────────────────────

  Widget _buildBoard(LudoController ctrl) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth;
      final cellSize = size / 15;

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(10)),
          // Deep 3D shadows
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: rs(24),
              offset: Offset(0, rs(8)),
              spreadRadius: rs(2),
            ),
            BoxShadow(
              color: const Color(0xFF8B6914).withValues(alpha: 0.4),
              blurRadius: rs(40),
              spreadRadius: rs(-5),
            ),
          ],
        ),
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Board background with gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(rs(10)),
              child: CustomPaint(
                size: Size(size, size),
                painter: _LudoBoardPainter(
                  cellSize: cellSize,
                  players: ctrl.players,
                  theme: ctrl.boardTheme.value,
                ),
              ),
            ),
            // Pieces
            ..._buildPieces(ctrl, cellSize),
          ],
        ),
      );
    });
  }

  // ── Pieces ────────────────────────────────────────────────────────────────

  List<Widget> _buildPieces(LudoController ctrl, double cellSize) {
    // Group non-yard pieces by position to detect stacking
    final positionCounts = <String, int>{};
    final positionIndex = <String, int>{};
    for (final player in ctrl.players) {
      for (final piece in player.pieces) {
        if (piece.isFinished || piece.isInYard) continue;
        final key = '${piece.position}';
        positionCounts[key] = (positionCounts[key] ?? 0) + 1;
      }
    }

    final widgets = <Widget>[];

    for (final player in ctrl.players) {
      for (final piece in player.pieces) {
        if (piece.isFinished) continue;
        final pos = LudoBoard.getGridPosition(piece);
        final canMove = ctrl.hasRolled.value &&
            !ctrl.isProcessing.value &&
            player.color == ctrl.currentPlayer.color &&
            !ctrl.isCurrentPlayerAi &&
            piece.canMove(ctrl.diceValue.value);

        final isYard = piece.isInYard;
        final isActive = player.color == ctrl.currentPlayer.color;

        // Count pieces at same position (for stacking)
        int countAtPos = 1;
        int indexAtPos = 0;
        if (!isYard) {
          final key = '${piece.position}';
          countAtPos = positionCounts[key] ?? 1;
          indexAtPos = positionIndex[key] ?? 0;
          positionIndex[key] = indexAtPos + 1;
        }

        // Scale down when multiple pieces on same cell
        final scale = countAtPos > 1 ? 0.6 : 1.0;
        final pieceW = (isYard ? cellSize * 1.1 : cellSize * 1.15) * scale;
        final pieceH = (isYard ? cellSize * 0.9 : cellSize * 1.0) * scale;

        // Offset for stacking
        double stackOffsetX = 0;
        double stackOffsetY = 0;
        if (countAtPos > 1 && !isYard) {
          final offsets = [
            const Offset(-0.25, -0.15),
            const Offset(0.25, 0.15),
            const Offset(-0.25, 0.15),
            const Offset(0.25, -0.15),
          ];
          final o = offsets[indexAtPos % offsets.length];
          stackOffsetX = o.dx * cellSize;
          stackOffsetY = o.dy * cellSize;
        }

        final left = isYard
            ? pos.dx * cellSize - pieceW / 2
            : pos.dx * cellSize + (cellSize - pieceW) / 2 + stackOffsetX;
        final top = isYard
            ? pos.dy * cellSize - pieceH * 0.65
            : pos.dy * cellSize + cellSize / 2 - pieceH * 0.65 + stackOffsetY;

        widgets.add(
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut,
            left: left,
            top: top,
            child: GestureDetector(
              onTap: canMove ? () => ctrl.selectPiece(piece) : null,
              child: Container(
                width: pieceW,
                height: pieceH,
                decoration: isActive && !isYard
                    ? BoxDecoration(
                        // Neon glow on active player pieces
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(pieceW / 2),
                        boxShadow: [
                          BoxShadow(
                            color: piece.color.color.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: piece.color.color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      )
                    : null,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 3D Token drawn with code
                    _buildToken(pieceW, pieceH, piece.color.color, canMove),
                    // Checkmark badge for movable pieces
                    if (canMove)
                      Positioned(
                        right: -pieceW * 0.05,
                        top: -pieceH * 0.05,
                        child: Container(
                          width: pieceW * 0.35,
                          height: pieceW * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: piece.color.color, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: piece.color.color.withValues(alpha: 0.5), blurRadius: 6),
                            ],
                          ),
                          child: Icon(Icons.check, color: piece.color.color, size: pieceW * 0.2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ── 3D Token (replaces image-based pieces) ────────────────────────────────

  Widget _buildToken(double w, double h, Color color, bool canMove) {
    final darker = Color.lerp(color, Colors.black, 0.35)!;
    final lighter = Color.lerp(color, Colors.white, 0.4)!;
    return SizedBox(
      width: w, height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom shadow/base
          Positioned(
            bottom: 0,
            child: Container(
              width: w * 0.8, height: h * 0.15,
              decoration: BoxDecoration(
                color: darker,
                borderRadius: BorderRadius.circular(w * 0.4),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
          ),
          // Main body (oval)
          Positioned(
            top: h * 0.15,
            child: Container(
              width: w * 0.7, height: h * 0.55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [lighter, color, darker],
                ),
                borderRadius: BorderRadius.circular(w * 0.35),
                border: Border.all(color: darker, width: 1),
              ),
            ),
          ),
          // Head (sphere on top)
          Positioned(
            top: 0,
            child: Container(
              width: w * 0.5, height: w * 0.5,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [lighter, color, darker],
                  stops: const [0.0, 0.5, 1.0],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: darker, width: 1),
              ),
              // Shine highlight
              child: Align(
                alignment: const Alignment(-0.4, -0.4),
                child: Container(
                  width: w * 0.15, height: w * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dice ──────────────────────────────────────────────────────────────────

  Widget _buildDiceArea(LudoController ctrl, bool isAr) {
    final playerColor = ctrl.currentPlayer.color.color;
    final canRoll = !ctrl.isCurrentPlayerAi && !ctrl.hasRolled.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 3D Dice with depth shadow and glossy highlight
        GestureDetector(
          onTap: canRoll ? ctrl.rollDice : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: rs(64),
            height: rs(64),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rs(12)),
              // 3D depth shadow
              boxShadow: [
                // Bottom 3D edge
                BoxShadow(
                  color: HSLColor.fromColor(playerColor)
                      .withLightness((HSLColor.fromColor(playerColor).lightness - 0.2).clamp(0.0, 1.0))
                      .toColor(),
                  offset: Offset(0, rs(4)),
                  blurRadius: 0,
                ),
                // Glow when can roll
                if (canRoll)
                  BoxShadow(
                    color: playerColor.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                // Far shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: Offset(0, rs(6)),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFFF0F0F0)],
                ),
                borderRadius: BorderRadius.circular(rs(12)),
                border: Border.all(color: playerColor, width: 3),
              ),
              child: Stack(
                children: [
                  // Glossy highlight on dice top 40%
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: rs(64) * 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(rs(10))),
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
                  // Dice content - use image assets
                  ctrl.diceValue.value == 0
                      ? Center(child: Icon(Icons.casino, color: playerColor, size: rs(32)))
                      : Padding(
                          padding: EdgeInsets.all(rs(4)),
                          child: Image.asset(
                            'assets/dice/die${ctrl.diceValue.value}.png',
                            width: rs(56),
                            height: rs(56),
                            fit: BoxFit.contain,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Rankings ──────────────────────────────────────────────────────────────

  Widget _buildRankings(LudoController ctrl, bool isAr) {
    const medals = ['🥇', '🥈', '🥉', '4️⃣'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ctrl.rankings.asMap().entries.map((entry) {
          final rank = entry.key;
          final color = entry.value;
          final player = ctrl.players.firstWhere((p) => p.color == color);
          return DepthCard(
            accentColor: color.color,
            elevation: 0.6,
            borderRadius: 10,
            margin: EdgeInsets.symmetric(horizontal: rs(4)),
            padding: EdgeInsets.symmetric(horizontal: rs(10), vertical: rs(6)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.color.withValues(alpha: 0.2),
                color.color.withValues(alpha: 0.1),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(medals[rank.clamp(0, 3)], style: TextStyle(fontSize: fs(16))),
                SizedBox(width: rs(4)),
                Text(
                  player.name,
                  style: TextStyle(
                    color: color.color,
                    fontSize: kFontSizeCaption,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Board Painter (Warm Wooden Board Style) ────────────────────────────────

class _LudoBoardPainter extends CustomPainter {
  final double cellSize;
  final List<LudoPlayer> players;
  final LudoBoardTheme theme;

  _LudoBoardPainter({required this.cellSize, required this.players, required this.theme});

  // Premium 3D wooden board constants
  static const _cellBase = Color(0xFFF0DFC0);
  static const _goldStar = Color(0xFFD4A030);
  static const _goldCenter = Color(0xFFD4A030);

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final outerRRect = RRect.fromRectAndRadius(bgRect, const Radius.circular(10));

    // 1. Rich wood background with gradient
    canvas.drawRRect(outerRRect, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFDCB878), Color(0xFFD0A868), Color(0xFFC89858), Color(0xFFD0A868), Color(0xFFDCB878)],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(bgRect));

    // Wood grain texture
    final grainPaint = Paint()..color = const Color(0xFFC09050).withValues(alpha: 0.25)..strokeWidth = 0.8;
    final gs = size.height / 7;
    for (int i = 1; i <= 6; i++) {
      final y = gs * i + (i.isEven ? 4.0 : -3.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grainPaint);
    }
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.32, size.height),
        Paint()..color = const Color(0xFFC09050).withValues(alpha: 0.12)..strokeWidth = 0.5);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.68, size.height),
        Paint()..color = const Color(0xFFC09050).withValues(alpha: 0.12)..strokeWidth = 0.5);

    // 2. Premium 3D wooden frame with gradient
    canvas.drawRRect(outerRRect, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF9B7420), Color(0xFF7A5A15), Color(0xFFA87E28), Color(0xFF6B4C10), Color(0xFF9B7420)],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(bgRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6);

    // Frame 3D highlight/shadow
    canvas.drawLine(Offset(12, 2.5), Offset(size.width - 12, 2.5),
        Paint()..color = const Color(0x50FFFFFF)..strokeWidth = 2);
    canvas.drawLine(Offset(2.5, 12), Offset(2.5, size.height - 12),
        Paint()..color = const Color(0x50FFFFFF)..strokeWidth = 2);
    canvas.drawLine(Offset(12, size.height - 2.5), Offset(size.width - 12, size.height - 2.5),
        Paint()..color = const Color(0x30000000)..strokeWidth = 2);
    canvas.drawLine(Offset(size.width - 2.5, 12), Offset(size.width - 2.5, size.height - 12),
        Paint()..color = const Color(0x30000000)..strokeWidth = 2);

    _drawYards(canvas);
    _drawTrackCells(canvas, size);
    _drawHomeColumns(canvas);
    _drawCenterTriangles(canvas);
    _drawCenterGoldenCircle(canvas);
    _drawStartArrows(canvas);
    _drawSafeStars(canvas);
  }

  // ── Yards (Colored Wood Inlays) ──────────────────────────────────────────

  void _drawYards(Canvas canvas) {
    final yards = <LudoColor, Rect>{
      LudoColor.red:    Rect.fromLTWH(0, 9 * cellSize, 6 * cellSize, 6 * cellSize),
      LudoColor.green:  Rect.fromLTWH(0, 0, 6 * cellSize, 6 * cellSize),
      LudoColor.yellow: Rect.fromLTWH(9 * cellSize, 0, 6 * cellSize, 6 * cellSize),
      LudoColor.blue:   Rect.fromLTWH(9 * cellSize, 9 * cellSize, 6 * cellSize, 6 * cellSize),
    };

    // Which corner gets the rounded outer corner (10px radius)
    final outerCornerRadius = <LudoColor, BorderRadius>{
      LudoColor.green:  const BorderRadius.only(topLeft: Radius.circular(10)),
      LudoColor.yellow: const BorderRadius.only(topRight: Radius.circular(10)),
      LudoColor.red:    const BorderRadius.only(bottomLeft: Radius.circular(10)),
      LudoColor.blue:   const BorderRadius.only(bottomRight: Radius.circular(10)),
    };

    for (final entry in yards.entries) {
      final color = entry.key;
      final rect = entry.value;
      final c = _yardColors[color]!;
      final br = outerCornerRadius[color]!;

      // Yard fill with gradient for 3D depth
      final yardRRect = br.toRRect(rect);
      final lighterC = Color.lerp(c, Colors.white, 0.2)!;
      final darkerC = Color.lerp(c, Colors.black, 0.2)!;
      canvas.drawRRect(yardRRect, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [lighterC, c, darkerC],
        ).createShader(rect));

      // Deep 3D bevel: thick highlight top/left, thick shadow bottom/right
      canvas.drawLine(Offset(rect.left + 10, rect.top + 1), Offset(rect.right - 1, rect.top + 1),
          Paint()..color = Color.lerp(c, Colors.white, 0.35)!..strokeWidth = 2);
      canvas.drawLine(Offset(rect.left + 1, rect.top + 10), Offset(rect.left + 1, rect.bottom - 1),
          Paint()..color = Color.lerp(c, Colors.white, 0.35)!..strokeWidth = 2);
      canvas.drawLine(Offset(rect.left + 1, rect.bottom - 1), Offset(rect.right - 1, rect.bottom - 1),
          Paint()..color = Color.lerp(c, Colors.black, 0.3)!..strokeWidth = 2);
      canvas.drawLine(Offset(rect.right - 1, rect.top + 1), Offset(rect.right - 1, rect.bottom - 1),
          Paint()..color = Color.lerp(c, Colors.black, 0.3)!..strokeWidth = 2);

      // Inner area with gradient
      final innerMargin = cellSize * 0.8;
      final innerRect = Rect.fromLTWH(rect.left + innerMargin, rect.top + innerMargin,
          rect.width - innerMargin * 2, rect.height - innerMargin * 2);
      final innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.3));

      // Inner shadow for 3D inset look
      canvas.drawRRect(innerRRect.shift(const Offset(1.5, 1.5)), Paint()..color = const Color(0x30000000));
      canvas.drawRRect(innerRRect, Paint()
        ..shader = RadialGradient(colors: [Color.lerp(c, Colors.white, 0.45)!, Color.lerp(c, Colors.white, 0.25)!])
            .createShader(innerRect));
      canvas.drawRRect(innerRRect, Paint()..color = darkerC..style = PaintingStyle.stroke..strokeWidth = 2.5);

      // 4 piece circles with 3D gradient effect
      final cxBase = innerRect.left + innerRect.width / 2;
      final cyBase = innerRect.top + innerRect.height / 2;
      final spacing = innerRect.width * 0.28;
      final positions = [
        Offset(cxBase - spacing, cyBase - spacing), Offset(cxBase + spacing, cyBase - spacing),
        Offset(cxBase - spacing, cyBase + spacing), Offset(cxBase + spacing, cyBase + spacing),
      ];
      for (final pos in positions) {
        // Circle shadow
        canvas.drawCircle(Offset(pos.dx + 1, pos.dy + 1.5), cellSize * 0.35, Paint()..color = const Color(0x25000000));
        // Circle with gradient
        canvas.drawCircle(pos, cellSize * 0.35, Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [Color.lerp(c, Colors.white, 0.3)!, c.withValues(alpha: 0.5)],
          ).createShader(Rect.fromCircle(center: pos, radius: cellSize * 0.35)));
        canvas.drawCircle(pos, cellSize * 0.35, Paint()..color = darkerC..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
  }

  // ── Track Cells ───────────────────────────────────────────────────────────

  void _drawTrackCells(Canvas canvas, Size boardSize) {
    final startPositions = {
      for (final c in LudoColor.values) c.startPos: c,
    };

    for (int i = 0; i < 52; i++) {
      final pos = LudoBoard.getGridPosition(
        LudoPiece(color: LudoColor.red, index: 0)..position = i,
      );

      final rect = Rect.fromLTWH(
        pos.dx * cellSize + 0.25,
        pos.dy * cellSize + 0.25,
        cellSize - 0.5,
        cellSize - 0.5,
      );

      // Cell with gradient for depth
      final cellRRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(cellRRect, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [const Color(0xFFF8F0DC), _cellBase, const Color(0xFFE4D4B4)],
        ).createShader(rect));

      // Stronger 3D bevel
      canvas.drawLine(Offset(rect.left + 1, rect.top + 0.5), Offset(rect.right - 1, rect.top + 0.5),
          Paint()..color = const Color(0x40FFFFFF)..strokeWidth = 1);
      canvas.drawLine(Offset(rect.left + 0.5, rect.top + 1), Offset(rect.left + 0.5, rect.bottom - 1),
          Paint()..color = const Color(0x40FFFFFF)..strokeWidth = 1);
      canvas.drawLine(Offset(rect.left + 1, rect.bottom - 0.5), Offset(rect.right - 1, rect.bottom - 0.5),
          Paint()..color = const Color(0x25000000)..strokeWidth = 1);
      canvas.drawLine(Offset(rect.right - 0.5, rect.top + 1), Offset(rect.right - 0.5, rect.bottom - 1),
          Paint()..color = const Color(0x25000000)..strokeWidth = 1);

      // Draw colored star on start positions
      if (startPositions.containsKey(i)) {
        final center = Offset(
          pos.dx * cellSize + cellSize / 2,
          pos.dy * cellSize + cellSize / 2,
        );
        _drawStar(canvas, center, cellSize * 0.35, _yardColors[startPositions[i]!]!);
      }
    }
  }

  // ── Home Columns ──────────────────────────────────────────────────────────

  void _drawHomeColumns(Canvas canvas) {
    for (final color in LudoColor.values) {
      final c = _yardColors[color]!;

      for (int step = 0; step < 6; step++) {
        final pos = LudoBoard.getGridPosition(
          LudoPiece(color: color, index: 0)..position = 100 + step,
        );
        final rect = Rect.fromLTWH(
          pos.dx * cellSize + 0.25,
          pos.dy * cellSize + 0.25,
          cellSize - 0.5,
          cellSize - 0.5,
        );

        // Home column cells with rich gradient
        final cellRRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(cellRRect, Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color.lerp(c, Colors.white, 0.25)!, c.withValues(alpha: 0.7), Color.lerp(c, Colors.black, 0.1)!.withValues(alpha: 0.7)],
          ).createShader(rect));

        // 3D bevel on home cells
        canvas.drawLine(Offset(rect.left + 1, rect.top + 0.5), Offset(rect.right - 1, rect.top + 0.5),
            Paint()..color = Color.lerp(c, Colors.white, 0.5)!.withValues(alpha: 0.6)..strokeWidth = 1);
        canvas.drawLine(Offset(rect.left + 0.5, rect.top + 1), Offset(rect.left + 0.5, rect.bottom - 1),
            Paint()..color = Color.lerp(c, Colors.white, 0.5)!.withValues(alpha: 0.6)..strokeWidth = 1);
        canvas.drawLine(Offset(rect.left + 1, rect.bottom - 0.5), Offset(rect.right - 1, rect.bottom - 0.5),
            Paint()..color = Color.lerp(c, Colors.black, 0.3)!.withValues(alpha: 0.5)..strokeWidth = 1);
        canvas.drawLine(Offset(rect.right - 0.5, rect.top + 1), Offset(rect.right - 0.5, rect.bottom - 1),
            Paint()..color = Color.lerp(c, Colors.black, 0.3)!.withValues(alpha: 0.5)..strokeWidth = 1);

        // Small arrow pointing toward center
        final arrowCenter = rect.center;
        final arrowSize = cellSize * 0.12;
        final arrowPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;

        switch (color) {
          case LudoColor.red: // points up
            canvas.drawLine(Offset(arrowCenter.dx, arrowCenter.dy + arrowSize), Offset(arrowCenter.dx, arrowCenter.dy - arrowSize), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx - arrowSize * 0.6, arrowCenter.dy - arrowSize * 0.3), Offset(arrowCenter.dx, arrowCenter.dy - arrowSize), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx + arrowSize * 0.6, arrowCenter.dy - arrowSize * 0.3), Offset(arrowCenter.dx, arrowCenter.dy - arrowSize), arrowPaint);
            break;
          case LudoColor.green: // points right
            canvas.drawLine(Offset(arrowCenter.dx - arrowSize, arrowCenter.dy), Offset(arrowCenter.dx + arrowSize, arrowCenter.dy), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx + arrowSize * 0.3, arrowCenter.dy - arrowSize * 0.6), Offset(arrowCenter.dx + arrowSize, arrowCenter.dy), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx + arrowSize * 0.3, arrowCenter.dy + arrowSize * 0.6), Offset(arrowCenter.dx + arrowSize, arrowCenter.dy), arrowPaint);
            break;
          case LudoColor.yellow: // points down
            canvas.drawLine(Offset(arrowCenter.dx, arrowCenter.dy - arrowSize), Offset(arrowCenter.dx, arrowCenter.dy + arrowSize), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx - arrowSize * 0.6, arrowCenter.dy + arrowSize * 0.3), Offset(arrowCenter.dx, arrowCenter.dy + arrowSize), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx + arrowSize * 0.6, arrowCenter.dy + arrowSize * 0.3), Offset(arrowCenter.dx, arrowCenter.dy + arrowSize), arrowPaint);
            break;
          case LudoColor.blue: // points left
            canvas.drawLine(Offset(arrowCenter.dx + arrowSize, arrowCenter.dy), Offset(arrowCenter.dx - arrowSize, arrowCenter.dy), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx - arrowSize * 0.3, arrowCenter.dy - arrowSize * 0.6), Offset(arrowCenter.dx - arrowSize, arrowCenter.dy), arrowPaint);
            canvas.drawLine(Offset(arrowCenter.dx - arrowSize * 0.3, arrowCenter.dy + arrowSize * 0.6), Offset(arrowCenter.dx - arrowSize, arrowCenter.dy), arrowPaint);
            break;
        }
      }
    }
  }

  // ── Center Triangles ──────────────────────────────────────────────────────

  void _drawCenterTriangles(Canvas canvas) {
    final cx = 7.5 * cellSize;
    final cy = 7.5 * cellSize;
    final half = 1.5 * cellSize;

    final triangles = <LudoColor, List<Offset>>{
      LudoColor.red: [
        Offset(cx - half, cy + half), Offset(cx + half, cy + half), Offset(cx, cy),
      ],
      LudoColor.green: [
        Offset(cx - half, cy - half), Offset(cx - half, cy + half), Offset(cx, cy),
      ],
      LudoColor.yellow: [
        Offset(cx - half, cy - half), Offset(cx + half, cy - half), Offset(cx, cy),
      ],
      LudoColor.blue: [
        Offset(cx + half, cy - half), Offset(cx + half, cy + half), Offset(cx, cy),
      ],
    };

    for (final entry in triangles.entries) {
      final pts = entry.value;
      final c = _yardColors[entry.key]!;
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();

      // Colored wood inlay fill
      canvas.drawPath(path, Paint()..color = c);

      // Thin separator stroke between triangles
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFF8B6B3D).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0);
    }
  }

  // ── Center Golden Circle ──────────────────────────────────────────────────

  void _drawCenterGoldenCircle(Canvas canvas) {
    final cx = 7.5 * cellSize;
    final cy = 7.5 * cellSize;
    final r = cellSize * 0.55;

    // Golden circle
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = _goldCenter);

    // Darker golden ring
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = const Color(0xFFB08820)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Subtle highlight on top-left
    canvas.drawCircle(
      Offset(cx - r * 0.2, cy - r * 0.25),
      r * 0.2,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  // ── Start Arrows ──────────────────────────────────────────────────────────

  void _drawStartArrows(Canvas canvas) {
    final homeEntries = <LudoColor, int>{
      LudoColor.red: 37,
      LudoColor.green: 50,
      LudoColor.yellow: 11,
      LudoColor.blue: 24,
    };

    for (final entry in homeEntries.entries) {
      final pos = LudoBoard.getGridPosition(
        LudoPiece(color: LudoColor.red, index: 0)..position = entry.value,
      );
      final center = Offset(
        pos.dx * cellSize + cellSize / 2,
        pos.dy * cellSize + cellSize / 2,
      );

      final c = _yardColors[entry.key]!;
      final arrowPaint = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.12
        ..strokeCap = StrokeCap.round;

      final a = cellSize * 0.22;

      switch (entry.key) {
        case LudoColor.red:
          canvas.drawLine(Offset(center.dx, center.dy + a), Offset(center.dx, center.dy - a), arrowPaint);
          canvas.drawLine(Offset(center.dx - a * 0.6, center.dy - a * 0.3), Offset(center.dx, center.dy - a), arrowPaint);
          canvas.drawLine(Offset(center.dx + a * 0.6, center.dy - a * 0.3), Offset(center.dx, center.dy - a), arrowPaint);
          break;
        case LudoColor.green:
          canvas.drawLine(Offset(center.dx - a, center.dy), Offset(center.dx + a, center.dy), arrowPaint);
          canvas.drawLine(Offset(center.dx + a * 0.3, center.dy - a * 0.6), Offset(center.dx + a, center.dy), arrowPaint);
          canvas.drawLine(Offset(center.dx + a * 0.3, center.dy + a * 0.6), Offset(center.dx + a, center.dy), arrowPaint);
          break;
        case LudoColor.yellow:
          canvas.drawLine(Offset(center.dx, center.dy - a), Offset(center.dx, center.dy + a), arrowPaint);
          canvas.drawLine(Offset(center.dx - a * 0.6, center.dy + a * 0.3), Offset(center.dx, center.dy + a), arrowPaint);
          canvas.drawLine(Offset(center.dx + a * 0.6, center.dy + a * 0.3), Offset(center.dx, center.dy + a), arrowPaint);
          break;
        case LudoColor.blue:
          canvas.drawLine(Offset(center.dx + a, center.dy), Offset(center.dx - a, center.dy), arrowPaint);
          canvas.drawLine(Offset(center.dx - a * 0.3, center.dy - a * 0.6), Offset(center.dx - a, center.dy), arrowPaint);
          canvas.drawLine(Offset(center.dx - a * 0.3, center.dy + a * 0.6), Offset(center.dx - a, center.dy), arrowPaint);
          break;
      }
    }
  }

  // ── Safe Stars ────────────────────────────────────────────────────────────

  void _drawSafeStars(Canvas canvas) {
    final starPositions = {8, 21, 34, 47};

    for (final safePos in starPositions) {
      final pos = LudoBoard.getGridPosition(
        LudoPiece(color: LudoColor.red, index: 0)..position = safePos,
      );

      final center = Offset(
        pos.dx * cellSize + cellSize / 2,
        pos.dy * cellSize + cellSize / 2,
      );

      // Golden star
      _drawStar(canvas, center, cellSize * 0.32, _goldStar);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _drawStar(Canvas canvas, Offset center, double outerRadius, Color color) {
    final innerRadius = outerRadius * 0.45;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * math.pi / 180;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _LudoBoardPainter old) => true;
}

/// Draws a 3D pawn/cone piece like classic Ludo
class _PawnPainter extends CustomPainter {
  final Color color;

  _PawnPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;
    final radius = w * 0.42;

    // ── Base shadow (dark ellipse on the ground) ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.92), width: w * 0.85, height: h * 0.15),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.90), width: w * 0.75, height: h * 0.1),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // ── Side/edge (3D thickness of the disc) ──
    // Draw a slightly smaller circle offset down to create disc thickness
    final edgeCenter = Offset(cx, cy + 3);
    final edgeRadius = radius * 0.95;
    final edgePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 1.0,
        colors: [_darken(color, 0.2), _darken(color, 0.35)],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: edgeCenter, radius: edgeRadius));
    canvas.drawCircle(edgeCenter, edgeRadius, edgePaint);

    // ── Top face (main disc surface with RadialGradient) ──
    final topCenter = Offset(cx, cy);
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 1.0,
        colors: [
          Color.lerp(color, Colors.white, 0.3)!,
          color,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: topCenter, radius: radius));
    canvas.drawCircle(topCenter, radius, topPaint);

    // ── Glossy highlight (top-left quadrant) ──
    final highlightCenter = Offset(cx - radius * 0.3, cy - radius * 0.3);
    canvas.drawOval(
      Rect.fromCenter(center: highlightCenter, width: radius * 0.9, height: radius * 0.6),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // ── Embossed ring (thin rim effect) ──
    canvas.drawCircle(
      topCenter,
      radius * 0.8,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Center dot ──
    canvas.drawCircle(
      topCenter,
      radius * 0.15,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _PawnPainter old) =>
      old.color != color;
}

/// Paints a realistic dice face with dots
class _DiceFacePainter extends CustomPainter {
  final int value;
  final Color dotColor;

  _DiceFacePainter({required this.value, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final edge = 5.0; // 3D edge depth

    // --- 3D cube illusion edges (drawn inside bounds) ---
    final darkerColor = HSLColor.fromColor(dotColor)
        .withLightness((HSLColor.fromColor(dotColor).lightness - 0.25).clamp(0.0, 1.0))
        .toColor();
    final darkestColor = HSLColor.fromColor(dotColor)
        .withLightness((HSLColor.fromColor(dotColor).lightness - 0.35).clamp(0.0, 1.0))
        .toColor();

    // Right edge parallelogram (inside bounds)
    final rightEdge = Path()
      ..moveTo(w - edge, 0)
      ..lineTo(w, edge)
      ..lineTo(w, h)
      ..lineTo(w - edge, h - edge)
      ..close();
    canvas.drawPath(rightEdge, Paint()..color = darkerColor.withValues(alpha: 0.4));

    // Bottom edge parallelogram (inside bounds)
    final bottomEdge = Path()
      ..moveTo(0, h - edge)
      ..lineTo(edge, h)
      ..lineTo(w, h)
      ..lineTo(w - edge, h - edge)
      ..close();
    canvas.drawPath(bottomEdge, Paint()..color = darkestColor.withValues(alpha: 0.35));

    // --- Dice face with subtle gradient (slightly inset for 3D) ---
    final faceRect = Rect.fromLTWH(0, 0, w - edge, h - edge);
    final facePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5), Color(0xFFEAEAEA)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(faceRect);
    final faceRRect = RRect.fromRectAndRadius(faceRect, const Radius.circular(6));
    canvas.drawRRect(faceRRect, facePaint);

    // --- Dots (centered on face area) ---
    final cx = (w - edge) / 2;
    final cy = (h - edge) / 2;
    final r = w * 0.09;
    final d = w * 0.25;

    final tl = Offset(cx - d, cy - d);
    final tr = Offset(cx + d, cy - d);
    final ml = Offset(cx - d, cy);
    final mr = Offset(cx + d, cy);
    final c  = Offset(cx, cy);
    final bl = Offset(cx - d, cy + d);
    final br = Offset(cx + d, cy + d);

    List<Offset> dots;
    switch (value) {
      case 1: dots = [c]; break;
      case 2: dots = [tl, br]; break;
      case 3: dots = [tl, c, br]; break;
      case 4: dots = [tl, tr, bl, br]; break;
      case 5: dots = [tl, tr, c, bl, br]; break;
      case 6: dots = [tl, tr, ml, mr, bl, br]; break;
      default: dots = [];
    }

    final outerDotColor = HSLColor.fromColor(dotColor)
        .withLightness((HSLColor.fromColor(dotColor).lightness - 0.2).clamp(0.0, 1.0))
        .toColor();

    for (final dot in dots) {
      // Recessed pit: outer darker ring, inner dot color
      final pitPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [dotColor, outerDotColor, outerDotColor],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: dot, radius: r));
      canvas.drawCircle(dot, r, pitPaint);

      // Inner shadow to simulate depth (slightly darker ring at the edge)
      canvas.drawCircle(dot, r, Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8);

      // Tiny white highlight at top-left of each pit
      canvas.drawCircle(
        Offset(dot.dx - r * 0.3, dot.dy - r * 0.3),
        r * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter old) =>
      old.value != value || old.dotColor != dotColor;
}
