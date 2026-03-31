import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/block_piece.dart';
import '../services/storage_service.dart';
import 'game_controller.dart';

class BlockPuzzleController extends GetxController {
  static const int kSize = 10;

  final gridKey = GlobalKey();

  // Grid: null = empty, Color = filled block
  final grid = RxList<Color?>(List.filled(kSize * kSize, null));
  final pieces = RxList<BlockPiece?>([null, null, null]);
  final score = 0.obs;
  final bestScore = 0.obs;
  final isGameOver = false.obs;

  // Drag state
  final dragIndex = (-1).obs;
  final dragGlobalX = 0.0.obs;
  final dragGlobalY = 0.0.obs;
  final dragRow = (-1).obs;
  final dragCol = (-1).obs;
  final dragCanPlace = false.obs;

  double cellSize = 40.0; // set by the screen after layout

  OverlayEntry? _overlayEntry;

  final _rng = Random();
  final _storage = StorageService();

  @override
  void onInit() {
    super.onInit();
    bestScore.value = _storage.read<int>('block_best') ?? 0;
    _spawnPieces();
  }

  // ── Grid helpers ──────────────────────────────────────────────

  Color? cellAt(int row, int col) =>
      (row >= 0 && row < kSize && col >= 0 && col < kSize)
          ? grid[row * kSize + col]
          : null;

  bool isPreviewCell(int row, int col) {
    if (dragIndex.value < 0) return false;
    final piece = pieces[dragIndex.value];
    if (piece == null) return false;
    for (final c in piece.cells) {
      if (row == dragRow.value + c[0] && col == dragCol.value + c[1]) return true;
    }
    return false;
  }

  // ── Rotation ─────────────────────────────────────────────────
  void rotatePiece(int index) {
    final piece = pieces[index];
    if (piece == null) return;
    pieces[index] = piece.rotated();
    pieces.refresh();
  }

  // ── Drag ─────────────────────────────────────────────────────

  void onDragStart(int index) {
    if (pieces[index] == null) return;
    dragIndex.value = index;
  }

  void onDragUpdate(int index, Offset globalPos) {
    if (dragIndex.value != index) return;
    dragGlobalX.value = globalPos.dx;
    dragGlobalY.value = globalPos.dy;
    _updateGridPreview(index, globalPos);
  }

  void _updateGridPreview(int index, Offset globalPos) {
    final piece = pieces[index];
    if (piece == null) return;
    final box = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(globalPos);
    // piece center follows finger; piece shown above finger
    final r = ((local.dy - piece.rows * cellSize) / cellSize).floor();
    final c = ((local.dx - piece.cols * cellSize / 2) / cellSize).floor();

    dragRow.value = r;
    dragCol.value = c;
    dragCanPlace.value = _canPlace(piece, r, c);
  }

  void onDragEnd(int index) {
    if (dragIndex.value == index) {
      final piece = pieces[index];
      if (piece != null && dragCanPlace.value) {
        _placePiece(index, piece, dragRow.value, dragCol.value);
      }
    }
    _clearDragState();
  }

  void onDragCancel() => _clearDragState();

  // ── Overlay ───────────────────────────────────────────────────

  void showOverlayEntry(OverlayEntry entry, BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = entry;
    Overlay.of(context).insert(_overlayEntry!);
  }

  void removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void markOverlayNeedsBuild() => _overlayEntry?.markNeedsBuild();

  void _clearDragState() {
    dragIndex.value = -1;
    dragRow.value = -1;
    dragCol.value = -1;
    dragCanPlace.value = false;
  }

  // ── Game Logic ────────────────────────────────────────────────

  bool _canPlace(BlockPiece piece, int row, int col) {
    for (final cell in piece.cells) {
      final r = row + cell[0];
      final c = col + cell[1];
      if (r < 0 || r >= kSize || c < 0 || c >= kSize) return false;
      if (grid[r * kSize + c] != null) return false;
    }
    return true;
  }

  void _placePiece(int index, BlockPiece piece, int row, int col) {
    for (final cell in piece.cells) {
      grid[(row + cell[0]) * kSize + (col + cell[1])] = piece.color;
    }
    grid.refresh();
    pieces[index] = null;
    pieces.refresh();

    _clearLines();

    if (pieces.every((p) => p == null)) {
      _spawnPieces();
    } else {
      _checkGameOver();
    }
  }

  void _clearLines() {
    // ── Find completed rows ───────────────────────────────────
    final completedRows = <int>[];
    for (int r = 0; r < kSize; r++) {
      if (List.generate(kSize, (c) => grid[r * kSize + c] != null).every((v) => v)) {
        completedRows.add(r);
      }
    }

    // ── Find completed columns ────────────────────────────────
    final completedCols = <int>[];
    for (int c = 0; c < kSize; c++) {
      if (List.generate(kSize, (r) => grid[r * kSize + c] != null).every((v) => v)) {
        completedCols.add(c);
      }
    }

    if (completedRows.isEmpty && completedCols.isEmpty) return;

    // ── Rows: remove, shift rows below UP, add new random row at bottom ──
    // Process bottom→top so upper row indices are unaffected by each shift
    for (final row in completedRows.reversed) {
      for (int r = row; r < kSize - 1; r++) {
        for (int c = 0; c < kSize; c++) {
          grid[r * kSize + c] = grid[(r + 1) * kSize + c];
        }
      }
      for (int c = 0; c < kSize; c++) {
        grid[(kSize - 1) * kSize + c] = null;
      }
    }

    // ── Columns: just clear the cells ────────────────────────
    for (final col in completedCols) {
      for (int r = 0; r < kSize; r++) {
        grid[r * kSize + col] = null;
      }
    }

    grid.refresh();

    final linesCleared = completedRows.length + completedCols.length;
    final cellsCleared = completedRows.length * kSize + completedCols.length * kSize;
    final earned = cellsCleared * 10 + (linesCleared > 1 ? linesCleared * 50 : 0);
    score.value += earned;
    if (score.value > bestScore.value) {
      bestScore.value = score.value;
      _storage.write('block_best', bestScore.value);
    }
    final gc = Get.find<GameController>();
    if (gc.isOnline.value) gc.addXp(earned, source: 'block_puzzle');
  }


  void _spawnPieces() {
    for (int i = 0; i < 3; i++) {
      pieces[i] = BlockPiece.random(_rng);
    }
    pieces.refresh();
    _checkGameOver();
  }

  void _checkGameOver() {
    for (final piece in pieces) {
      if (piece == null) continue;
      for (int r = 0; r < kSize; r++) {
        for (int c = 0; c < kSize; c++) {
          if (_canPlace(piece, r, c)) return;
        }
      }
    }
    isGameOver.value = true;
  }

  void restart() {
    grid.assignAll(List.filled(kSize * kSize, null));
    score.value = 0;
    isGameOver.value = false;
    pieces.assignAll([null, null, null]);
    _spawnPieces();
  }

  @override
  void onClose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.onClose();
  }
}
