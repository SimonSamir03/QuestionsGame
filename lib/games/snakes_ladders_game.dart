import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/snakes_ladders_controller.dart';

class SnakesLaddersGame extends StatelessWidget {
  final SnakesLaddersMode mode;
  final String language;
  final Function(int winnerIndex) onGameEnd;

  const SnakesLaddersGame({
    super.key,
    required this.mode,
    required this.language,
    required this.onGameEnd,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      SnakesLaddersController(mode: mode, language: language, onGameEnd: onGameEnd),
      tag: 'snakes_${mode.name}',
    );

    return Obx(() {
      final isAr = language == 'ar';
      return Column(
        children: [
          _buildPlayerBar(ctrl),
          SizedBox(height: rs(6)),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _SnakesLaddersBoard(ctrl: ctrl, size: constraints.maxWidth);
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: rs(6)),
          _buildDiceArea(ctrl, isAr),
          SizedBox(height: rs(4)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: rs(16), vertical: rs(6)),
            decoration: BoxDecoration(
              color: ctrl.currentPlayer.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rs(12)),
            ),
            child: Text(
              ctrl.message.value,
              style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: rs(6)),
        ],
      );
    });
  }

  Widget _buildPlayerBar(SnakesLaddersController ctrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(8)),
      child: Row(
        children: ctrl.players.asMap().entries.map((e) {
          final player = e.value;
          final isCurrent = ctrl.currentPlayerIndex.value == e.key;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: rs(3)),
              padding: EdgeInsets.symmetric(horizontal: rs(6), vertical: rs(6)),
              decoration: BoxDecoration(
                gradient: isCurrent
                    ? LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [player.color.withValues(alpha: 0.3), player.color.withValues(alpha: 0.1)],
                      )
                    : null,
                color: isCurrent ? null : kCardColor,
                borderRadius: BorderRadius.circular(rs(14)),
                border: Border.all(color: isCurrent ? player.color : Colors.transparent, width: 2.5),
                boxShadow: isCurrent
                    ? [BoxShadow(color: player.color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: rs(22), height: rs(22),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(colors: [Color.lerp(player.color, Colors.white, 0.3)!, player.color]),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [BoxShadow(color: player.color.withValues(alpha: isCurrent ? 0.6 : 0.3), blurRadius: isCurrent ? 8 : 4)],
                    ),
                  ),
                  SizedBox(height: rs(3)),
                  Text(player.name, style: TextStyle(color: kTextPrimary, fontSize: kFontSizeTiny, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500), overflow: TextOverflow.ellipsis),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(6), vertical: rs(1)),
                    decoration: BoxDecoration(color: player.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(rs(8))),
                    child: Text('${player.position}', style: TextStyle(color: player.color, fontSize: kFontSizeTiny, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiceArea(SnakesLaddersController ctrl, bool isAr) {
    final playerColor = ctrl.currentPlayer.color;
    final canRoll = !ctrl.hasRolled.value && !ctrl.isRolling.value && !ctrl.isCurrentPlayerAi && !ctrl.gameOver.value;
    return GestureDetector(
      onTap: ctrl.rollDice,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: rs(72), height: rs(72),
        decoration: BoxDecoration(
          gradient: canRoll
              ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  Color.lerp(playerColor, Colors.white, 0.2)!, playerColor, Color.lerp(playerColor, Colors.black, 0.2)!,
                ])
              : null,
          color: canRoll ? null : playerColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(rs(16)),
          border: Border.all(color: canRoll ? playerColor : playerColor.withValues(alpha: 0.3), width: 2.5),
          boxShadow: [
            if (canRoll) BoxShadow(color: playerColor.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2),
            if (canRoll) BoxShadow(color: playerColor.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5),
          ],
        ),
        child: ctrl.diceValue.value == 0
            ? Icon(Icons.casino, color: canRoll ? Colors.white : playerColor, size: rs(36))
            : Padding(
                padding: EdgeInsets.all(rs(6)),
                child: Image.asset('assets/dice/die${ctrl.diceValue.value}.png', width: rs(56), height: rs(56), fit: BoxFit.contain),
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Board Widget
// ══════════════════════════════════════════════════════════════════════════════

class _SnakesLaddersBoard extends StatelessWidget {
  final SnakesLaddersController ctrl;
  final double size;
  const _SnakesLaddersBoard({required this.ctrl, required this.size});

  double get cellSize => size / 10;

  Offset _cellCenter(int number) {
    if (number < 1 || number > 100) return Offset.zero;
    final idx = number - 1;
    final row = idx ~/ 10;
    final col = row.isEven ? idx % 10 : 9 - (idx % 10);
    return Offset(col * cellSize + cellSize / 2, (9 - row) * cellSize + cellSize / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: const Color(0xFF8B6914).withValues(alpha: 0.4), blurRadius: 40, spreadRadius: -5),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Board grid
            CustomPaint(
              size: Size(size, size),
              painter: _BoardPainter(cellSize: cellSize),
            ),
            // Snakes and Ladders
            CustomPaint(
              size: Size(size, size),
              painter: _SnakesLaddersPainter(
                cellSize: cellSize,
                snakes: SnakesLaddersController.snakes,
                ladders: SnakesLaddersController.ladders,
              ),
            ),
            // Cell numbers
            ...List.generate(100, (i) {
              final number = i + 1;
              final center = _cellCenter(number);
              final idx = number - 1;
              final boardRow = idx ~/ 10;
              final boardCol = boardRow.isEven ? idx % 10 : 9 - (idx % 10);
              final visualRow = 9 - boardRow;
              final isLightCell = (visualRow + boardCol) % 2 == 0;
              final isSnakeHead = SnakesLaddersController.snakes.containsKey(number);
              final isLadderBottom = SnakesLaddersController.ladders.containsKey(number);

              return Positioned(
                left: center.dx - cellSize / 2, top: center.dy - cellSize / 2,
                width: cellSize, height: cellSize,
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: isSnakeHead
                          ? const Color(0xFFFF2222)
                          : isLadderBottom
                              ? const Color(0xFF00BB00)
                              : isLightCell ? const Color(0xFF2D1B0E) : const Color(0xFFF5E6C8),
                      fontSize: cellSize * 0.26,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.25), offset: const Offset(0.5, 0.5), blurRadius: 1.5),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Player pieces
            ...ctrl.players.asMap().entries.map((e) {
              final idx = e.key;
              final player = e.value;
              if (player.position == 0) return const SizedBox.shrink();
              final center = _cellCenter(player.position);
              final offsetX = (idx % 2 == 0 ? -1 : 1) * cellSize * 0.15;
              final offsetY = (idx < 2 ? -1 : 1) * cellSize * 0.15;
              final pieceSize = cellSize * 0.40;
              final isCurrent = ctrl.currentPlayerIndex.value == idx;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: center.dx - pieceSize / 2 + offsetX,
                top: center.dy - pieceSize / 2 + offsetY,
                child: Container(
                  width: pieceSize, height: pieceSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.3),
                      colors: [Color.lerp(player.color, Colors.white, 0.5)!, player.color, Color.lerp(player.color, Colors.black, 0.35)!],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: player.color.withValues(alpha: isCurrent ? 0.8 : 0.4), blurRadius: isCurrent ? 12 : 6, spreadRadius: isCurrent ? 3 : 1),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 4, offset: const Offset(1, 2)),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(pieceSize * 0.18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.5, -0.5),
                        colors: [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Board Painter - Premium 3D Wooden Board
// ══════════════════════════════════════════════════════════════════════════════

class _BoardPainter extends CustomPainter {
  final double cellSize;
  _BoardPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final fw = cellSize * 0.2; // frame width

    // ── Outer Frame: Rich golden wood with gradient
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, const Radius.circular(10)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF9B7420), Color(0xFF7A5A15), Color(0xFFA87E28), Color(0xFF6B4C10), Color(0xFF9B7420)],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(outerRect),
    );

    // Frame 3D: highlight top/left, shadow bottom/right
    canvas.drawLine(Offset(6, 3), Offset(size.width - 6, 3), Paint()..color = const Color(0x50FFFFFF)..strokeWidth = 2);
    canvas.drawLine(Offset(3, 6), Offset(3, size.height - 6), Paint()..color = const Color(0x50FFFFFF)..strokeWidth = 2);
    canvas.drawLine(Offset(6, size.height - 3), Offset(size.width - 6, size.height - 3), Paint()..color = const Color(0x30000000)..strokeWidth = 2);
    canvas.drawLine(Offset(size.width - 3, 6), Offset(size.width - 3, size.height - 6), Paint()..color = const Color(0x30000000)..strokeWidth = 2);

    // ── Inner board area
    final boardRect = Rect.fromLTWH(fw, fw, size.width - fw * 2, size.height - fw * 2);
    final bcs = boardRect.width / 10;

    // Cell colors - vibrant alternating palette
    const lightBase = [Color(0xFFF8ECD0), Color(0xFFF0E0B8), Color(0xFFF5E8C4)];
    const darkBase = [Color(0xFF8D6F44), Color(0xFF7E6038), Color(0xFF9B7E52)];

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        final isLight = (row + col) % 2 == 0;
        final x = boardRect.left + col * bcs;
        final y = boardRect.top + row * bcs;
        final v = (row * 10 + col) % 3;
        final cellRect = Rect.fromLTWH(x, y, bcs, bcs);

        // Cell gradient fill
        canvas.drawRect(cellRect, Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isLight
                ? [lightBase[v], Color.lerp(lightBase[v], Colors.white, 0.12)!]
                : [darkBase[v], Color.lerp(darkBase[v], Colors.black, 0.08)!],
          ).createShader(cellRect));

        // 3D bevel: top/left = light, bottom/right = dark
        canvas.drawLine(Offset(x + 1, y + 0.5), Offset(x + bcs - 1, y + 0.5),
            Paint()..color = (isLight ? const Color(0x35FFFFFF) : const Color(0x1AFFFFFF))..strokeWidth = 1);
        canvas.drawLine(Offset(x + 0.5, y + 1), Offset(x + 0.5, y + bcs - 1),
            Paint()..color = (isLight ? const Color(0x35FFFFFF) : const Color(0x1AFFFFFF))..strokeWidth = 1);
        canvas.drawLine(Offset(x + 1, y + bcs - 0.5), Offset(x + bcs - 1, y + bcs - 0.5),
            Paint()..color = (isLight ? const Color(0x20000000) : const Color(0x30000000))..strokeWidth = 1);
        canvas.drawLine(Offset(x + bcs - 0.5, y + 1), Offset(x + bcs - 0.5, y + bcs - 1),
            Paint()..color = (isLight ? const Color(0x20000000) : const Color(0x30000000))..strokeWidth = 1);

        // Special cell tints
        final boardRow = 9 - row;
        final boardCol = boardRow.isEven ? col : 9 - col;
        final cellNum = boardRow * 10 + boardCol + 1;

        if (SnakesLaddersController.snakes.containsKey(cellNum)) {
          canvas.drawRect(cellRect, Paint()..color = const Color(0x20FF0000));
        } else if (SnakesLaddersController.ladders.containsKey(cellNum)) {
          canvas.drawRect(cellRect, Paint()..color = const Color(0x2000FF00));
        }
        if (cellNum == 100) {
          canvas.drawRect(cellRect, Paint()..shader = RadialGradient(colors: [const Color(0x50FFD700), const Color(0x10FFD700)]).createShader(cellRect));
        }
        if (cellNum == 1) {
          canvas.drawRect(cellRect, Paint()..shader = RadialGradient(colors: [const Color(0x303498DB), const Color(0x103498DB)]).createShader(cellRect));
        }
      }
    }

    // Inner border line
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(2)),
        Paint()..color = const Color(0xFF4A3210)..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Snakes & Ladders Painter - Premium 3D Style
// ══════════════════════════════════════════════════════════════════════════════

class _SnakesLaddersPainter extends CustomPainter {
  final double cellSize;
  final Map<int, int> snakes;
  final Map<int, int> ladders;

  _SnakesLaddersPainter({required this.cellSize, required this.snakes, required this.ladders});

  Offset _cellCenter(int number) {
    final fw = cellSize * 0.2;
    final bcs = (cellSize * 10 - fw * 2) / 10;
    final idx = number - 1;
    final row = idx ~/ 10;
    final col = row.isEven ? idx % 10 : 9 - (idx % 10);
    return Offset(fw + col * bcs + bcs / 2, fw + (9 - row) * bcs + bcs / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in ladders.entries) {
      _drawLadder(canvas, _cellCenter(entry.key), _cellCenter(entry.value));
    }
    int i = 0;
    for (final entry in snakes.entries) {
      _drawSnake(canvas, _cellCenter(entry.key), _cellCenter(entry.value), i++);
    }
  }

  void _drawLadder(Canvas canvas, Offset bottom, Offset top) {
    final dir = top - bottom;
    final perp = Offset(-dir.dy, dir.dx).normalized() * cellSize * 0.22;
    final lB = bottom + perp, lT = top + perp;
    final rB = bottom - perp, rT = top - perp;
    final rw = cellSize * 0.09;

    // Shadow
    canvas.save();
    canvas.translate(3, 4);
    final sPaint = Paint()..color = const Color(0x35000000)..style = PaintingStyle.stroke..strokeWidth = rw + 4..strokeCap = StrokeCap.round;
    canvas.drawLine(lB, lT, sPaint);
    canvas.drawLine(rB, rT, sPaint);
    canvas.restore();

    // Rails with gradient
    for (final pair in [[lB, lT], [rB, rT]]) {
      canvas.drawLine(pair[0], pair[1], Paint()
        ..shader = ui.Gradient.linear(pair[0], pair[1],
          [const Color(0xFFD4A234), const Color(0xFFECC870), const Color(0xFFD4A234), const Color(0xFFBB8820), const Color(0xFFD4A234)],
          [0.0, 0.2, 0.5, 0.8, 1.0])
        ..style = PaintingStyle.stroke..strokeWidth = rw..strokeCap = StrokeCap.round);
      // Highlight
      canvas.save(); canvas.translate(-1, -1.5);
      canvas.drawLine(pair[0], pair[1], Paint()..color = const Color(0x45FFFFFF)..style = PaintingStyle.stroke..strokeWidth = rw * 0.3..strokeCap = StrokeCap.round);
      canvas.restore();
    }

    // Rungs
    final dist = dir.distance;
    final rungCount = (dist / (cellSize * 0.5)).floor().clamp(4, 9);
    for (int i = 1; i < rungCount; i++) {
      final t = i / rungCount;
      final l = Offset.lerp(lB, lT, t)!, r = Offset.lerp(rB, rT, t)!;
      // Rung shadow
      canvas.drawLine(Offset(l.dx + 1.5, l.dy + 2.5), Offset(r.dx + 1.5, r.dy + 2.5),
          Paint()..color = const Color(0x30000000)..style = PaintingStyle.stroke..strokeWidth = rw * 0.7..strokeCap = StrokeCap.round);
      // Rung
      canvas.drawLine(l, r, Paint()
        ..shader = ui.Gradient.linear(l, r, [const Color(0xFFBB8820), const Color(0xFFD4A234), const Color(0xFFBB8820)], [0.0, 0.5, 1.0])
        ..style = PaintingStyle.stroke..strokeWidth = rw * 0.65..strokeCap = StrokeCap.round);
      // Rung highlight
      canvas.drawLine(Offset(l.dx - 0.5, l.dy - 0.5), Offset(r.dx - 0.5, r.dy - 0.5),
          Paint()..color = const Color(0x30FFFFFF)..style = PaintingStyle.stroke..strokeWidth = rw * 0.2..strokeCap = StrokeCap.round);
    }

    // Decorative nails
    final nR = rw * 0.45;
    for (final p in [lB, lT, rB, rT]) {
      canvas.drawCircle(Offset(p.dx + 1, p.dy + 1.5), nR, Paint()..color = const Color(0x30000000));
      canvas.drawCircle(p, nR, Paint()..color = const Color(0xFFA07018));
      canvas.drawCircle(Offset(p.dx - nR * 0.3, p.dy - nR * 0.3), nR * 0.3, Paint()..color = const Color(0x55FFFFFF));
    }
  }

  void _drawSnake(Canvas canvas, Offset head, Offset tail, int index) {
    final ci = index % 5;
    const colors = [
      [Color(0xFF4488CC), Color(0xFF2A6098), Color(0xFF70B8F0)], // blue
      [Color(0xFFDD5566), Color(0xFFAA3344), Color(0xFFFF8899)], // red/pink
      [Color(0xFF44AA44), Color(0xFF2A7A2A), Color(0xFF77DD77)], // green
      [Color(0xFFCC8833), Color(0xFF996622), Color(0xFFEEBB66)], // orange
      [Color(0xFF8855BB), Color(0xFF663399), Color(0xFFBB88EE)], // purple
    ];
    final sc = colors[ci][0], sd = colors[ci][1], sl = colors[ci][2];

    // Build smooth S-curve from head to tail
    final path = Path();
    final co = cellSize * 0.9;
    final dx = tail.dx - head.dx;
    final dy = tail.dy - head.dy;
    path.moveTo(head.dx, head.dy);
    path.cubicTo(
      head.dx + (dx > 0 ? co : -co), head.dy + dy * 0.25,
      tail.dx - (dx > 0 ? co : -co), head.dy + dy * 0.75,
      tail.dx, tail.dy,
    );

    final bw = cellSize * 0.2; // body width

    // 1. Shadow
    canvas.save(); canvas.translate(2, 3);
    canvas.drawPath(path, Paint()..color = const Color(0x35000000)..style = PaintingStyle.stroke..strokeWidth = bw + 4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.restore();

    // 2. Dark outline (slightly thicker than body)
    canvas.drawPath(path, Paint()..color = sd..style = PaintingStyle.stroke..strokeWidth = bw + 3..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // 3. Main body color
    canvas.drawPath(path, Paint()..color = sc..style = PaintingStyle.stroke..strokeWidth = bw..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // 4. Body highlight (3D shine on top-left)
    canvas.save(); canvas.translate(-1, -1.5);
    canvas.drawPath(path, Paint()..color = sl.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = bw * 0.3..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.restore();

    // 5. Belly pattern - lighter stripe down the middle
    canvas.drawPath(path, Paint()..color = sl.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = bw * 0.4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // 6. HEAD - big round cute head (part of the same body, just bigger)
    final hr = bw * 1.1;
    // Head shadow
    canvas.drawCircle(Offset(head.dx + 1.5, head.dy + 2), hr + 2, Paint()..color = const Color(0x30000000));
    // Head dark outline
    canvas.drawCircle(head, hr + 1.5, Paint()..color = sd);
    // Head fill with gradient
    canvas.drawCircle(head, hr, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [sl, sc, sd],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: head, radius: hr)));
    // Head shine
    canvas.drawCircle(Offset(head.dx - hr * 0.25, head.dy - hr * 0.25), hr * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.4));

    // 7. BIG cute eyes
    final eyeSpacing = hr * 0.42;
    final eyeR = hr * 0.38;
    for (final side in [-1.0, 1.0]) {
      final ex = head.dx + side * eyeSpacing;
      final ey = head.dy - hr * 0.08;
      // Eye white with shadow
      canvas.drawCircle(Offset(ex + 0.5, ey + 0.5), eyeR, Paint()..color = const Color(0x20000000));
      canvas.drawCircle(Offset(ex, ey), eyeR, Paint()..color = Colors.white);
      // Pupil
      canvas.drawCircle(Offset(ex + side * eyeR * 0.1, ey + eyeR * 0.1), eyeR * 0.55, Paint()..color = const Color(0xFF111122));
      // Glint
      canvas.drawCircle(Offset(ex - eyeR * 0.2, ey - eyeR * 0.2), eyeR * 0.22, Paint()..color = Colors.white);
    }

    // 8. Cute smile
    final smilePath = Path()
      ..moveTo(head.dx - hr * 0.3, head.dy + hr * 0.25)
      ..quadraticBezierTo(head.dx, head.dy + hr * 0.55, head.dx + hr * 0.3, head.dy + hr * 0.25);
    canvas.drawPath(smilePath, Paint()..color = sd..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);

    // 9. Small tongue
    final tongueStart = Offset(head.dx, head.dy + hr * 0.45);
    final tonguePath = Path()
      ..moveTo(tongueStart.dx, tongueStart.dy)
      ..lineTo(tongueStart.dx - hr * 0.08, tongueStart.dy + hr * 0.2)
      ..moveTo(tongueStart.dx, tongueStart.dy)
      ..lineTo(tongueStart.dx + hr * 0.08, tongueStart.dy + hr * 0.2);
    canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFDD3333)..style = PaintingStyle.stroke..strokeWidth = 1..strokeCap = StrokeCap.round);

    // 10. Tail tip - tapered
    final tailAngle = atan2(dy, dx);
    final tailTip = Path()
      ..moveTo(tail.dx, tail.dy)
      ..quadraticBezierTo(
        tail.dx + cos(tailAngle) * cellSize * 0.2,
        tail.dy + sin(tailAngle) * cellSize * 0.2,
        tail.dx + cos(tailAngle) * cellSize * 0.15 + sin(tailAngle) * bw * 0.1,
        tail.dy + sin(tailAngle) * cellSize * 0.15 - cos(tailAngle) * bw * 0.1,
      );
    canvas.drawPath(tailTip, Paint()..color = sc..style = PaintingStyle.stroke..strokeWidth = bw * 0.4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _SnakesLaddersPainter old) => false;
}

extension _OffNorm on Offset {
  Offset normalized() {
    final d = distance;
    return d == 0 ? this : this / d;
  }
}
