import 'dart:math';
import 'package:flutter/material.dart';

class BlockPiece {
  final List<List<int>> cells; // [row, col] offsets from top-left
  final Color color;

  const BlockPiece({required this.cells, required this.color});

  int get rows => cells.map((c) => c[0]).reduce(max) + 1;
  int get cols => cells.map((c) => c[1]).reduce(max) + 1;

  /// Rotate 90° clockwise: (r, c) → (c, maxR - r), then normalize to 0-based.
  BlockPiece rotated() {
    final maxR = cells.map((c) => c[0]).reduce(max);
    final rotated = cells.map((c) => [c[1], maxR - c[0]]).toList();
    // Normalize so min row/col = 0
    final minR = rotated.map((c) => c[0]).reduce(min);
    final minC = rotated.map((c) => c[1]).reduce(min);
    final normalized = rotated.map((c) => [c[0] - minR, c[1] - minC]).toList();
    return BlockPiece(cells: normalized, color: color);
  }

  static const List<List<List<int>>> shapes = [
    [[0,0]],                                              // 1×1
    [[0,0],[0,1]],                                        // 1×2 H
    [[0,0],[1,0]],                                        // 2×1 V
    [[0,0],[0,1],[0,2]],                                  // 1×3 H
    [[0,0],[1,0],[2,0]],                                  // 3×1 V
    [[0,0],[0,1],[0,2],[0,3]],                            // 1×4 H
    [[0,0],[1,0],[2,0],[3,0]],                            // 4×1 V
    [[0,0],[0,1],[1,0],[1,1]],                            // 2×2
    [[0,0],[1,0],[2,0],[2,1]],                            // L
    [[0,1],[1,1],[2,0],[2,1]],                            // J
    [[0,0],[0,1],[1,0],[2,0]],                            // L2
    [[0,0],[0,1],[1,1],[2,1]],                            // J2
    [[0,0],[0,1],[0,2],[1,1]],                            // T
    [[0,1],[1,0],[1,1],[1,2]],                            // T2
    [[0,1],[0,2],[1,0],[1,1]],                            // S
    [[0,0],[0,1],[1,1],[1,2]],                            // Z
    [[0,0],[0,1],[0,2],[1,0],[2,0]],                      // big-L
    [[0,0],[0,1],[0,2],[1,2],[2,2]],                      // big-J
    [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2]],                // 2×3 rect
    [[0,0],[0,1],[0,2],[0,3],[1,0],[1,1],[1,2],[1,3]],    // 2×4 rect
  ];

  static const List<Color> colors = [
    Color(0xFFE53935), // red
    Color(0xFFFDD835), // yellow
    Color(0xFF1E88E5), // blue
    Color(0xFF43A047), // green
    Color(0xFFEC407A), // pink
    Color(0xFFFF7043), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFF00ACC1), // cyan
  ];

  static BlockPiece random(Random rng) => BlockPiece(
        cells: shapes[rng.nextInt(shapes.length)],
        color: colors[rng.nextInt(colors.length)],
      );
}
