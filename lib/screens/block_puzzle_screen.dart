import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/block_puzzle_controller.dart';
import '../controllers/game_controller.dart';
import '../models/block_piece.dart';
import '../widgets/button_3d.dart';
import '../widgets/banner_ad_widget.dart';

class BlockPuzzleScreen extends StatelessWidget {
  const BlockPuzzleScreen({super.key});

  double get _trayCellSize => rs(22.0);

  void _showOverlay(
    BuildContext context,
    BlockPuzzleController ctrl,
    BlockPiece piece,
    double gridCellSize,
  ) {
    final entry = OverlayEntry(builder: (_) {
      return Obx(() {
        final idx = ctrl.dragIndex.value;
        if (idx < 0) return const SizedBox.shrink();
        final x = ctrl.dragGlobalX.value - piece.cols * gridCellSize / 2;
        final y = ctrl.dragGlobalY.value - piece.rows * gridCellSize - 20;
        return Positioned(
          left: x,
          top: y,
          child: IgnorePointer(child: _buildPieceWidget(piece, gridCellSize, opacity: 0.9)),
        );
      });
    });
    ctrl.showOverlayEntry(entry, context);
  }

  void _onPanStart(int index, DragStartDetails d, BlockPuzzleController ctrl, BuildContext context, double gridCellSize) {
    final piece = ctrl.pieces[index];
    if (piece == null) return;
    ctrl.onDragStart(index);
    ctrl.dragGlobalX.value = d.globalPosition.dx;
    ctrl.dragGlobalY.value = d.globalPosition.dy;
    ctrl.onDragUpdate(index, d.globalPosition);
    _showOverlay(context, ctrl, piece, gridCellSize);
  }

  void _onPanUpdate(int index, DragUpdateDetails d, BlockPuzzleController ctrl) {
    if (ctrl.dragIndex.value != index) return;
    ctrl.onDragUpdate(index, d.globalPosition);
    ctrl.markOverlayNeedsBuild();
  }

  void _onPanEnd(int index, BlockPuzzleController ctrl) {
    ctrl.removeOverlayEntry();
    ctrl.onDragEnd(index);
  }

  void _onPanCancel(int index, BlockPuzzleController ctrl) {
    ctrl.removeOverlayEntry();
    ctrl.onDragCancel();
  }

  Widget _buildPieceWidget(BlockPiece piece, double cs, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: piece.cols * cs,
        height: piece.rows * cs,
        child: Stack(
          children: piece.cells.map((cell) {
            return Positioned(
              left: cell[1] * cs + 1,
              top: cell[0] * cs + 1,
              width: cs - 2,
              height: cs - 2,
              child: _buildBlock(piece.color, cs),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBlock(Color color, double cs) {
    final darkColor = HSLColor.fromColor(color)
        .withLightness((HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0))
        .toColor();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cs * 0.18),
        boxShadow: [
          BoxShadow(color: darkColor, offset: Offset(0, rs(2.5)), blurRadius: 0),
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: rs(5), offset: Offset(0, rs(1))),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cs * 0.18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(color, Colors.white, 0.35)!,
              color,
              Color.lerp(color, Colors.black, 0.15)!,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              height: cs * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(cs * 0.18)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BlockPuzzleController ctrl, double cs) {
    return Container(
      key: ctrl.gridKey,
      padding: EdgeInsets.all(rs(4)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161b27), Color(0xFF1a2035)],
        ),
        borderRadius: BorderRadius.circular(rs(14)),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.08),
            blurRadius: rs(20),
            spreadRadius: rs(2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: rs(10),
            offset: Offset(0, rs(5)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(BlockPuzzleController.kSize, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(BlockPuzzleController.kSize, (col) {
              return Obx(() {
                final filled = ctrl.cellAt(row, col);
                final isPreview = ctrl.isPreviewCell(row, col);
                final piece = ctrl.dragIndex.value >= 0 ? ctrl.pieces[ctrl.dragIndex.value] : null;

                Widget cellChild = const SizedBox.shrink();
                Color? bg;

                if (filled != null && !isPreview) {
                  bg = filled;
                  cellChild = _buildBlock(filled, cs);
                } else if (isPreview) {
                  final valid = ctrl.dragCanPlace.value;
                  bg = valid
                      ? piece!.color.withValues(alpha: 0.55)
                      : Colors.red.withValues(alpha: 0.35);
                } else {
                  bg = const Color(0xFF1e2640);
                }

                return Container(
                  width: cs - 2,
                  height: cs - 2,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: filled == null ? bg : null,
                    borderRadius: BorderRadius.circular(cs * 0.12),
                    border: filled == null && !isPreview
                        ? Border.all(color: Colors.white.withValues(alpha: 0.04))
                        : null,
                  ),
                  child: filled != null && !isPreview ? cellChild : null,
                );
              });
            }),
          );
        }),
      ),
    );
  }

  Widget _buildTray(BlockPuzzleController ctrl, BuildContext context, double gridCellSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) {
        return Obx(() {
          final piece = ctrl.pieces[i];
          final isDragging = ctrl.dragIndex.value == i;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ctrl.rotatePiece(i),
            onPanStart: (d) => _onPanStart(i, d, ctrl, context, gridCellSize),
            onPanUpdate: (d) => _onPanUpdate(i, d, ctrl),
            onPanEnd: (d) => _onPanEnd(i, ctrl),
            onPanCancel: () => _onPanCancel(i, ctrl),
            child: AnimatedOpacity(
              opacity: isDragging ? 0.2 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: rs(105),
                height: rs(105),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a2035), Color(0xFF161b27)],
                  ),
                  borderRadius: BorderRadius.circular(rs(16)),
                  border: Border.all(color: kPrimaryColor.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: Offset(0, rs(3)),
                      blurRadius: rs(1),
                    ),
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.05),
                      blurRadius: rs(8),
                    ),
                  ],
                ),
                child: piece == null
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPieceWidget(piece, _trayCellSize),
                          SizedBox(height: rs(6)),
                          Container(
                            padding: EdgeInsets.all(rs(4)),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(rs(8)),
                              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Icon(Icons.rotate_right_rounded,
                                color: kPrimaryColor.withValues(alpha: 0.7),
                                size: rs(20)),
                          ),
                        ],
                      ),
              ),
            ),
          );
        });
      }),
    );
  }

  Widget _buildGameOver(BlockPuzzleController ctrl) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(rs(32)),
          padding: EdgeInsets.all(rs(28)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a2035), Color(0xFF161b27)],
            ),
            borderRadius: BorderRadius.circular(rs(24)),
            border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.15),
                blurRadius: rs(20),
                spreadRadius: rs(2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\u{1F635}', style: TextStyle(fontSize: fs(52))),
              SizedBox(height: rs(12)),
              Text('Game Over',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fs(26),
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: kPrimaryColor.withValues(alpha: 0.5), blurRadius: rs(10))],
                  )),
              SizedBox(height: rs(8)),
              Obx(() => Text('Score: ${ctrl.score.value}',
                  style: TextStyle(color: Colors.amber, fontSize: fs(18)))),
              SizedBox(height: rs(4)),
              Obx(() => Text('Best: ${ctrl.bestScore.value}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: fs(14)))),
              SizedBox(height: rs(24)),
              Button3D(
                label: 'Play Again',
                color: kPrimaryColor,
                icon: Icons.replay,
                onTap: () {
                  final gc = Get.find<GameController>();
                  if (!gc.tryShowMysteryBox()) {
                    ctrl.restart();
                  }
                },
              ),
              SizedBox(height: rs(10)),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Back to Menu',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scorePill(String emoji, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(5)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a2035), Color(0xFF161b27)],
        ),
        borderRadius: BorderRadius.circular(rs(22)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), offset: Offset(0, rs(2)), blurRadius: rs(1)),
          BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: rs(6)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: TextStyle(fontSize: fs(14))),
        SizedBox(width: rs(5)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fs(15))),
      ]),
    );
  }

  Widget _buildRestartConfirm(BlockPuzzleController ctrl) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1a2035),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(20))),
      title: const Text('Restart?', style: TextStyle(color: Colors.white)),
      content: Text('Your current score will be lost.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () { Get.back(); ctrl.restart(); },
          child: const Text('Restart', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BlockPuzzleController());
    final screenWidth = MediaQuery.of(context).size.width;
    final gridCellSize = (screenWidth - rs(42)) / BlockPuzzleController.kSize;
    ctrl.cellSize = gridCellSize;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF0d1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0d1117),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white70, size: rs(20)),
            onPressed: () => Get.back(),
          ),
          title: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _scorePill('\u{1F3C6}', '${ctrl.score.value}', Colors.amber),
              SizedBox(width: rs(16)),
              _scorePill('\u2B50', '${ctrl.bestScore.value}', Colors.white70),
            ],
          )),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white38, size: rs(20)),
              onPressed: () => Get.dialog(_buildRestartConfirm(ctrl)),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: rs(4)),
                // Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rs(12)),
                  child: _buildGrid(ctrl, gridCellSize),
                ),
                SizedBox(height: rs(12)),
                // Rotate hint
                Text(
                  'Tap piece to rotate \u2022 Drag to place',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: fs(11),
                  ),
                ),
                SizedBox(height: rs(8)),
                // Tray
                Expanded(
                  child: Center(
                    child: _buildTray(ctrl, context, gridCellSize),
                  ),
                ),
                // Ad space
                const BannerAdWidget(),
                SizedBox(height: rs(8)),
              ],
            ),
            // Game Over overlay
            Obx(() => ctrl.isGameOver.value
                ? _buildGameOver(ctrl)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
